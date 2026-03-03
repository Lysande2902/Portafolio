import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class EventGroupChatScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventGroupChatScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventGroupChatScreen> createState() => _EventGroupChatScreenState();
}

class _EventGroupChatScreenState extends State<EventGroupChatScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _setupRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    try {
      // Cargar participantes del evento
      final participantsData = await _supabase
          .from('participantes_evento')
          .select('user_id, perfiles(nombre_artistico, foto_perfil)')
          .eq('event_id', widget.eventId)
          .eq('confirmed', true);

      // Cargar mensajes del chat grupal
      final messagesData = await _supabase
          .from('mensajes_evento')
          .select('*, perfiles(nombre_artistico, foto_perfil)')
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _participants = List<Map<String, dynamic>>.from(participantsData);
          _messages = List<Map<String, dynamic>>.from(messagesData);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      ErrorHandler.logError('EventGroupChatScreen._loadChatData', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al cargar chat');
      }
    }
  }

  void _setupRealtime() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _channel = _supabase
        .channel('event_chat_${widget.eventId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensajes_evento',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'event_id',
            value: widget.eventId,
          ),
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord != null && mounted) {
              // Cargar info del usuario que envió el mensaje
              final userData = await _supabase
                  .from('perfiles')
                  .select('nombre_artistico, foto_perfil')
                  .eq('id', newRecord['user_id'])
                  .single();

              final hadFocus = _messageFocusNode.hasFocus;
              
              setState(() {
                _messages.add({
                  ...newRecord,
                  'perfiles': userData,
                });
                _scrollToBottom();
              });

              if (hadFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_messageFocusNode.hasFocus) {
                    _messageFocusNode.requestFocus();
                  }
                });
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _messageController.clear();

    try {
      await _supabase.from('mensajes_evento').insert({
        'event_id': widget.eventId,
        'user_id': myId,
        'mensaje': text,
      });
    } catch (e) {
      ErrorHandler.logError('EventGroupChatScreen._sendMessage', e);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al enviar mensaje');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_participants.length} participantes',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: ThemeColors.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.people, color: ThemeColors.icon(context)),
            onPressed: _showParticipants,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: ThemeColors.disabledText(context)),
          const SizedBox(height: 16),
          Text(
            'Inicia la conversación del evento',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos los participantes verán los mensajes',
            style: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final myId = _supabase.auth.currentUser?.id;
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg['user_id'] == myId;
        final profile = msg['perfiles'] as Map<String, dynamic>?;
        final userName = profile?['nombre_artistico'] ?? 'Usuario';
        final userPhoto = profile?['foto_perfil'];
        final timestamp = DateTime.parse(msg['created_at']);

        return _MessageBubble(
          message: msg['mensaje'],
          userName: userName,
          userPhoto: userPhoto,
          timestamp: timestamp,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: ThemeColors.divider(context))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participantes (${_participants.length})',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            ..._participants.map((p) {
              final profile = p['perfiles'] as Map<String, dynamic>?;
              final name = profile?['nombre_artistico'] ?? 'Usuario';
              final photo = profile?['foto_perfil'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                  backgroundImage: photo != null ? NetworkImage(photo) : null,
                  child: photo == null
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(color: AppConstants.primaryColor),
                        )
                      : null,
                ),
                title: Text(
                  name,
                  style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final String userName;
  final String? userPhoto;
  final DateTime timestamp;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.userName,
    this.userPhoto,
    required this.timestamp,
    required this.isMe,
  });

  String _formatTimestamp(DateTime timestamp) {
    final localTime = timestamp.toLocal();
    return DateFormat('HH:mm').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              backgroundImage: userPhoto != null ? NetworkImage(userPhoto!) : null,
              child: userPhoto == null
                  ? Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(color: AppConstants.primaryColor, fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppConstants.primaryColor : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    border: !isMe
                        ? Border.all(color: ThemeColors.divider(context), width: 0.5)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.white : ThemeColors.primaryText(context),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style: GoogleFonts.outfit(
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : ThemeColors.secondaryText(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
