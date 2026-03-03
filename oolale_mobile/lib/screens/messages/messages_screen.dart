import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/conversation.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _supabase = Supabase.instance.client;
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupRealtime();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupRealtime() {
    _subscription = _supabase
        .from('conversaciones')
        .stream(primaryKey: ['id'])
        .listen((_) => _loadConversations());
  }

  Future<void> _loadConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Obtener lista de usuarios bloqueados
      final blockedUsers = await _supabase
          .from('usuarios_bloqueados')
          .select('bloqueado_id')
          .eq('usuario_id', userId)
          .eq('activo', true);
      
      final blockedIds = blockedUsers.map((b) => b['bloqueado_id'] as String).toList();

      final data = await _supabase
          .from('conversaciones')
          .select('''
            *,
            remitente:perfiles!conversaciones_remitente_id_fkey(nombre_artistico, foto_perfil),
            destinatario:perfiles!conversaciones_destinatario_id_fkey(nombre_artistico, foto_perfil)
          ''')
          .or('remitente_id.eq.$userId,destinatario_id.eq.$userId')
          .order('created_at', ascending: false);

      final Map<String, Conversation> chatGroups = {};
      
      for (var msg in data) {
        final bool iAmSender = msg['remitente_id'] == userId;
        final String otherId = iAmSender ? msg['destinatario_id'] : msg['remitente_id'];
        
        // Filtrar usuarios bloqueados
        if (blockedIds.contains(otherId)) continue;
        
        if (!chatGroups.containsKey(otherId)) {
          // El interlocutor es el destinatario si yo envié, o el remitente si yo recibí
          final otherProfile = iAmSender ? msg['destinatario'] : msg['remitente'];
          
          // Construir URL completa de foto de perfil si existe
          String? photoUrl;
          final fotoPerfilPath = otherProfile?['foto_perfil'];
          if (fotoPerfilPath != null && fotoPerfilPath.toString().isNotEmpty) {
            // Si ya es una URL completa, usarla directamente
            if (fotoPerfilPath.toString().startsWith('http')) {
              photoUrl = fotoPerfilPath.toString();
            } else {
              // Si es un path, construir URL de Supabase Storage
              photoUrl = _supabase.storage.from('avatars').getPublicUrl(fotoPerfilPath.toString());
            }
          }
          
          chatGroups[otherId] = Conversation(
            interlocutorId: otherId,
            interlocutorName: otherProfile?['nombre_artistico'] ?? 'Artista',
            interlocutorPhoto: photoUrl,
            lastMessage: msg['contenido'] ?? '',
            lastDate: DateTime.parse(msg['created_at']),
            unreadCount: (!iAmSender && !msg['leido']) ? 1 : 0,
          );
        } else if (!iAmSender && !msg['leido']) {
          // Sumar al contador de no leídos si hay más mensajes nuevos en el mismo grupo
          chatGroups[otherId]!.unreadCount++;
        }
      }

      if (mounted) {
        setState(() {
          _conversations = chatGroups.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('MessagesScreen._loadConversations', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando mensajes',
          onRetry: _loadConversations,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Mensajes', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : _conversations.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final convo = _conversations[index];
        return _ConversationTile(conversation: convo);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: ThemeColors.iconSecondary(context)),
          const SizedBox(height: 16),
          Text(
            'Sin mensajes aún',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasUnread ? AppConstants.primaryColor.withOpacity(0.3) : ThemeColors.divider(context)
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/messages/${conversation.interlocutorId}', extra: conversation.interlocutorName),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF1E1E1E),
                backgroundImage: conversation.interlocutorPhoto != null ? NetworkImage(conversation.interlocutorPhoto!) : null,
                child: conversation.interlocutorPhoto == null 
                  ? Text(conversation.interlocutorName.substring(0, 1).toUpperCase(), 
                      style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold))
                  : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.interlocutorName,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, // Nombre mucho más fuerte
                            fontSize: 17, // Un poco más grande
                            color: ThemeColors.primaryText(context),
                          ),
                        ),
                        Text(
                          _formatDate(conversation.lastDate),
                          style: GoogleFonts.outfit(
                            color: ThemeColors.secondaryText(context),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: hasUnread 
                            ? ThemeColors.primaryText(context) 
                            : ThemeColors.primaryText(context).withOpacity(0.6), // Más oscuro que el anterior
                        fontSize: 14,
                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500, // Más peso táctil
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    if (localDate.year == now.year && localDate.month == now.month && localDate.day == now.day) {
      return DateFormat('HH:mm').format(localDate);
    }
    return DateFormat('dd/MM').format(localDate);
  }
}
