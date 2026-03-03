import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/message.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import '../../services/realtime_service.dart';
import '../../services/media_service.dart';
import '../../services/chat_cache_service.dart';
import '../../services/download_service.dart';
import '../../widgets/media_message_bubble.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/audio_player_widget.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../reports/report_content_screen.dart';
import '../../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String userId; 
  final String? userName; // Ahora es opcional

  const ChatScreen({super.key, required this.userId, this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode(); // NUEVO: Para mantener el foco del teclado
  
  late RealtimeService _realtimeService;
  late MediaService _mediaService;
  late ChatCacheService _cacheService;
  late DownloadService _downloadService;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isConnected = false;
  bool _checkingConnection = true;
  bool _otherUserTyping = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final Set<String> _messageIds = {}; // Para búsqueda O(1) de duplicados
  Timer? _typingTimer;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _connectionSubscription;
  RealtimeConnectionState _realtimeConnectionState = RealtimeConnectionState.disconnected;
  
  // Información del usuario cargada desde BD
  String _loadedUserName = '';
  String? _loadedUserPhoto;
  bool _userIsOnline = false; // Estado real del usuario desde BD
  DateTime? _userLastSeen; // Última conexión del usuario
  RealtimeChannel? _presenceChannel; // Canal de Realtime para escuchar cambios de presencia

  @override
  void initState() {
    super.initState();
    _realtimeService = RealtimeService(_supabase);
    _mediaService = MediaService(_supabase);
    _cacheService = ChatCacheService();
    _downloadService = DownloadService();
    _loadUserInfo(); // Cargar info del usuario
    _checkConnection();
    
    // Listen for typing changes
    _messageController.addListener(_onTypingChanged);
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    _typingTimer?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _presenceChannel?.unsubscribe(); // Desuscribir del canal de presencia
    _messageController.removeListener(_onTypingChanged);
    _messageController.dispose();
    _messageFocusNode.dispose(); // NUEVO: Liberar el FocusNode
    _scrollController.dispose();
    super.dispose();
  }

  void _onTypingChanged() {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    final isTyping = _messageController.text.isNotEmpty;
    final conversationId = _getConversationId(myId, widget.userId);
    
    // Send typing indicator
    _realtimeService.sendTypingIndicator(conversationId, isTyping);
  }

  // Cargar información del usuario desde la base de datos
  Future<void> _loadUserInfo() async {
    try {
      // Si ya tenemos el nombre, usarlo
      if (widget.userName != null && widget.userName!.isNotEmpty) {
        setState(() {
          _loadedUserName = widget.userName!;
        });
      }
      
      // Cargar desde BD incluyendo estado de presencia
      final data = await _supabase
          .from('perfiles')
          .select('nombre_artistico, foto_perfil, en_linea, ultima_conexion')
          .eq('id', widget.userId) // Cambiado de 'user_id' a 'id'
          .single();
      
      if (mounted) {
        setState(() {
          _loadedUserName = data['nombre_artistico'] ?? widget.userName ?? 'Usuario';
          _userIsOnline = data['en_linea'] ?? false;
          
          final lastSeenStr = data['ultima_conexion']?.toString();
          if (lastSeenStr != null) {
            _userLastSeen = () {
              String normalized = lastSeenStr.replaceFirst(' ', 'T');
              if (!normalized.contains('Z') && !normalized.contains('+') && !normalized.substring(10).contains('-')) {
                normalized = '${normalized}Z';
              }
              return DateTime.parse(normalized).toLocal();
            }();
          }
          
          final fotoPerfilPath = data['foto_perfil'];
          
          // Construir URL completa de foto de perfil
          if (fotoPerfilPath != null && fotoPerfilPath.toString().isNotEmpty) {
            if (fotoPerfilPath.toString().startsWith('http')) {
              _loadedUserPhoto = fotoPerfilPath.toString();
            } else {
              _loadedUserPhoto = _supabase.storage.from('avatars').getPublicUrl(fotoPerfilPath.toString());
            }
          }
        });
        
        // Configurar listener de presencia en tiempo real
        _setupPresenceListener();
      }
    } catch (e) {
      debugPrint('Error cargando info del usuario: $e');
      if (mounted) {
        setState(() {
          _loadedUserName = widget.userName ?? 'Usuario';
        });
      }
    }
  }
  
  // Configurar listener para cambios de presencia del usuario
  void _setupPresenceListener() {
    _presenceChannel = _supabase
        .channel('presence:${widget.userId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'perfiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.userId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord != null && mounted) {
              setState(() {
                _userIsOnline = newRecord['en_linea'] ?? false;
                final lastSeenStr = newRecord['ultima_conexion']?.toString();
                if (lastSeenStr != null) {
                  _userLastSeen = () {
                    String normalized = lastSeenStr.replaceFirst(' ', 'T');
                    if (!normalized.contains('Z') && !normalized.contains('+') && !normalized.substring(10).contains('-')) {
                      normalized = '${normalized}Z';
                    }
                    return DateTime.parse(normalized).toLocal();
                  }();
                }
              });
              debugPrint('🔄 Estado de presencia actualizado: ${_userIsOnline ? "En línea" : "Desconectado"}');
            }
          },
        )
        .subscribe();
  }

  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _checkConnection() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      if (mounted) setState(() => _checkingConnection = false);
      return;
    }

    try {
      // Check if user is blocked
      final blockData = await _supabase
          .from('usuarios_bloqueados')
          .select()
          .or('and(usuario_id.eq.$myId,bloqueado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},bloqueado_id.eq.$myId)')
          .eq('activo', true)
          .limit(1)
          .maybeSingle();

      if (blockData != null) {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _checkingConnection = false;
          });
        }
        return;
      }

      // Check if there's an accepted connection
      final connectionData = await _supabase
          .from('conexiones')
          .select()
          .or('and(usuario_id.eq.$myId,conectado_id.eq.${widget.userId}),and(usuario_id.eq.${widget.userId},conectado_id.eq.$myId)')
          .eq('estatus', 'accepted')
          .limit(1)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isConnected = connectionData != null;
          _checkingConnection = false;
        });

        if (_isConnected) {
          await _loadMessages();
          await _setupRealtime();
          await _markAllAsRead();
          _syncPendingMessages(); // Sincronizar mensajes pendientes
        }
      }
    } catch (e) {
      debugPrint('Error checking connection (server): $e');
      if (mounted) {
        setState(() {
          _isConnected = true; 
          _checkingConnection = false;
        });
        await _loadMessages();
      }
    }
  }

  Future<void> _syncPendingMessages() async {
    if (_realtimeConnectionState != RealtimeConnectionState.connected) return;

    final pending = await _cacheService.getPendingMessages();
    if (pending.isEmpty) return;

    debugPrint('🔄 Sincronizando ${pending.length} mensajes pendientes...');

    for (var msg in pending) {
      if (msg.receiverId == widget.userId) {
        try {
          final response = await _supabase.from('conversaciones').insert({
            'remitente_id': msg.senderId,
            'destinatario_id': msg.receiverId,
            'contenido': msg.content,
            'delivered_at': DateTime.now().toIso8601String(),
          }).select().single();

          final sentMsg = Message.fromJson(response);
          // Eliminar el pendiente y actualizar interfaz
          await _cacheService.deleteMessage(msg.id);
          await _cacheService.saveMessage(sentMsg);
          
          if (mounted) {
            setState(() {
              final index = _messages.indexWhere((m) => m.id == msg.id);
              if (index != -1) {
                _messages[index] = sentMsg;
                _messageIds.remove(msg.id);
                _messageIds.add(sentMsg.id);
              }
            });
          }
        } catch (e) {
          debugPrint('❌ Error sincronizando mensaje individual: $e');
        }
      }
    }
  }

  Future<void> _setupRealtime() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // Listen to connection state changes
    _connectionSubscription = _realtimeService.connectionState.listen((state) {
      if (mounted) {
        setState(() {
          _realtimeConnectionState = state;
        });
        
        if (state == RealtimeConnectionState.connected) {
          _syncPendingMessages();
        }
      }
    });

    // Subscribe to conversation messages
    await _realtimeService.subscribeToConversation(
      myId,
      widget.userId,
      (payload) {
        final event = payload['event'];
        final data = payload['data'];
        final message = Message.fromJson(data);
        
        // Solo procesar si pertenece a esta conversación
        final isRelevant = (message.senderId == myId && message.receiverId == widget.userId) ||
                          (message.senderId == widget.userId && message.receiverId == myId);
        if (!isRelevant) return;

        if (event == 'insert') {
          if (mounted) {
            if (!_messageIds.contains(message.id)) {
              final hadFocus = _messageFocusNode.hasFocus;
              setState(() {
                _messageIds.add(message.id);
                _messages.add(message);
                _scrollToBottom();
              });
              _cacheService.saveMessage(message);
              if (hadFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_messageFocusNode.hasFocus) _messageFocusNode.requestFocus();
                });
              }
              if (message.senderId == widget.userId) {
                _realtimeService.markMessageAsRead(message.id.toString());
              }
            }
          }
        } else if (event == 'update') {
          if (mounted) {
            setState(() {
              final index = _messages.indexWhere((m) => m.id == message.id);
              if (index != -1) {
                _messages[index] = message;
              }
            });
            _cacheService.saveMessage(message);
          }
        }
      },
    );

    // Listen for typing indicators
    final conversationId = _getConversationId(myId, widget.userId);
    _typingSubscription = _realtimeService
        .listenTypingIndicators(conversationId)
        .listen((event) {
      if (mounted) {
        setState(() {
          _otherUserTyping = event.isTyping;
        });

        // Auto-hide typing indicator after 3 seconds
        if (event.isTyping) {
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _otherUserTyping = false;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // 1. Cargar desde la caché primero para vista instantánea (offline compatible)
    final cachedMessages = await _cacheService.getCachedMessages(myId, widget.userId);
    if (cachedMessages.isNotEmpty && mounted) {
      setState(() {
        _messages = cachedMessages;
        _messageIds.addAll(_messages.map((m) => m.id));
        _isLoading = false;
      });
      _scrollToBottom();
    }

    // 2. Intentar cargar desde el servidor para actualizar
    try {
      final data = await _supabase
          .from('conversaciones')
          .select()
          .or('and(remitente_id.eq.$myId,destinatario_id.eq.${widget.userId}),and(remitente_id.eq.${widget.userId},destinatario_id.eq.$myId)')
          .order('created_at', ascending: true);

      if (mounted) {
        final serverMessages = (data as List).map((m) => Message.fromJson(m)).toList();
        
        // Guardar en caché todos los mensajes del servidor
        await _cacheService.saveMessages(serverMessages);

        setState(() {
          _messages = serverMessages;
          _messageIds.clear();
          _messageIds.addAll(_messages.map((m) => m.id));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error cargando mensajes del servidor (posible offline): $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    await _realtimeService.markAllMessagesAsRead(myId, widget.userId);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    if (myId == widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes enviarte mensajes a ti mismo'))
      );
      return;
    }

    _messageController.clear();
    
    final tempId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final offlineMsg = Message(
      id: tempId,
      senderId: myId,
      receiverId: widget.userId,
      content: text,
      sentAt: DateTime.now(),
      isRead: false,
      explicitStatus: 'pending',
    );

    // 1. Agregar a la lista local inmediatamente para feedback (Optimistic UI)
    if (mounted) {
      setState(() {
        _messageIds.add(offlineMsg.id);
        _messages.add(offlineMsg);
        _scrollToBottom();
      });
      _cacheService.saveMessage(offlineMsg, isPending: true);
    }

    // 2. Si no hay conexión, se queda en cache como pendiente
    if (_realtimeConnectionState != RealtimeConnectionState.connected) {
      debugPrint('📴 Offline: Mensaje guardado en cola para sincronizar después.');
      return;
    }

    // 3. Si hay conexión, intentar enviar al servidor
    try {
      final response = await _supabase.from('conversaciones').insert({
        'remitente_id': myId,
        'destinatario_id': widget.userId,
        'contenido': text,
        'delivered_at': DateTime.now().toIso8601String(),
      }).select().single();

      final newMessage = Message.fromJson(response);
      
      // Actualizar caché: eliminar temporal, guardar permanente
      await _cacheService.deleteMessage(tempId);
      await _cacheService.saveMessage(newMessage);

      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            _messages[index] = newMessage;
            _messageIds.remove(tempId);
            _messageIds.add(newMessage.id);
          }
        });
      }

      // 4. Enviar notificación (Best effort)
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        await _supabase.from('notificaciones').insert({
          'user_id': widget.userId,
          'tipo': 'new_message',
          'titulo': 'Nuevo mensaje de ${myProfile['nombre_artistico']}',
          'mensaje': text.length > 50 ? '${text.substring(0, 47)}...' : text,
          'metadata': {
            'sender_id': myId,
            'conversation_id': _getConversationId(myId, widget.userId),
          }
        });
      } catch (e) {
        debugPrint('⚠️ Error enviando notificación: $e');
      }
    } catch (e) {
      debugPrint('❌ Error al enviar mensaje real: $e. Se mantiene como pendiente.');
    }
  }

  Future<void> _pickAndSendImage() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      
      // Allow multiple image selection
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isEmpty) return;

      // Show preview dialog
      final shouldSend = await _showImagePreviewDialog(images);
      if (shouldSend != true) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Upload images
      final imageFiles = images.map((xFile) => File(xFile.path)).toList();
      final imageUrls = await _mediaService.uploadMultipleImages(
        imageFiles,
        myId,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress * 0.8; // 80% for upload
            });
          }
        },
      );

      setState(() {
        _uploadProgress = 0.9;
      });

      // Send messages with images
      final text = _messageController.text.trim();
      _messageController.clear();

      for (var i = 0; i < imageUrls.length; i++) {
        final response = await _supabase.from('conversaciones').insert({
          'remitente_id': myId,
          'destinatario_id': widget.userId,
          'contenido': i == 0 ? text : '', // Only first message has text
          'media_url': imageUrls[i],
          'media_type': 'image',
          'delivered_at': DateTime.now().toIso8601String(),
        }).select().single();

        // Agregar a la lista local inmediatamente
        final newMessage = Message.fromJson(response);
        if (mounted) {
          if (!_messageIds.contains(newMessage.id)) {
            setState(() {
              _messageIds.add(newMessage.id);
              _messages.add(newMessage);
              _scrollToBottom();
            });
          }
        }
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      // Create notification
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        final imageText = imageUrls.length > 1 
            ? 'te envió ${imageUrls.length} imágenes'
            : 'te envió una imagen';

        await _supabase.from('notificaciones').insert({
          'user_id': widget.userId,
          'tipo': 'new_message',
          'titulo': 'Nuevo mensaje',
          'mensaje': '${myProfile['nombre_artistico']} $imageText',
          'leido': false,
          'data': {'sender_id': myId, 'conversation_id': widget.userId},
        });
      } catch (notifError) {
        debugPrint('Error creating notification: $notifError');
      }
    } catch (e) {
      ErrorHandler.logError('ChatScreen._pickAndSendImage', e);
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al enviar imagen');
      }
    }
  }

  Future<bool?> _showImagePreviewDialog(List<XFile> images) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          images.length > 1 
              ? 'Enviar ${images.length} imágenes'
              : 'Enviar imagen',
          style: GoogleFonts.outfit(
            color: ThemeColors.primaryText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: images.length == 1
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(images[0].path),
                    fit: BoxFit.contain,
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(images[index].path),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Enviar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendDocument() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      
      // Show file info
      final fileSize = _mediaService.getFormattedFileSize(file);
      final fileName = result.files.first.name;
      
      final shouldSend = await _showDocumentPreviewDialog(fileName, fileSize);
      if (shouldSend != true) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Upload document
      final documentUrl = await _mediaService.uploadDocument(file, myId);

      setState(() {
        _uploadProgress = 0.5;
      });

      // Send message with document
      final text = _messageController.text.trim();
      _messageController.clear();

      final response = await _supabase.from('conversaciones').insert({
        'remitente_id': myId,
        'destinatario_id': widget.userId,
        'contenido': text.isEmpty ? fileName : text,
        'media_url': documentUrl,
        'media_type': 'document',
        'delivered_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Update local UI
      final newMessage = Message.fromJson(response);
      if (mounted) {
        if (!_messageIds.contains(newMessage.id)) {
          setState(() {
            _messageIds.add(newMessage.id);
            _messages.add(newMessage);
            _scrollToBottom();
          });
        }
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }

      // Create notification
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        await _supabase.from('notificaciones').insert({
          'user_id': widget.userId,
          'tipo': 'new_message',
          'titulo': 'Nuevo mensaje',
          'mensaje': '${myProfile['nombre_artistico']} te envió un documento',
          'leido': false,
          'data': {'sender_id': myId, 'conversation_id': widget.userId},
        });
      } catch (notifError) {
        debugPrint('Error creating notification: $notifError');
      }
    } catch (e) {
      ErrorHandler.logError('ChatScreen._pickAndSendDocument', e);
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al enviar documento');
      }
    }
  }

  Future<bool?> _showDocumentPreviewDialog(String fileName, String fileSize) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enviar documento',
          style: GoogleFonts.outfit(
            color: ThemeColors.primaryText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description,
              size: 64,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              fileName,
              style: GoogleFonts.outfit(
                color: ThemeColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              fileSize,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Enviar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendAudio() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Upload audio
      final audioFile = File(result.files.first.path!);
      
      // Validate file size
      if (!_mediaService.validateFileSize(audioFile, 10)) {
        throw Exception('El archivo de audio no debe superar 10MB');
      }

      final audioUrl = await _mediaService.uploadAudio(audioFile, myId);

      setState(() {
        _uploadProgress = 0.5;
      });

      // Send message with audio
      final text = _messageController.text.trim();
      _messageController.clear();

      final response = await _supabase.from('conversaciones').insert({
        'remitente_id': myId,
        'destinatario_id': widget.userId,
        'contenido': text,
        'media_url': audioUrl,
        'media_type': 'audio',
        'delivered_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Update local UI
      final newMessage = Message.fromJson(response);
      if (mounted) {
        if (!_messageIds.contains(newMessage.id)) {
          setState(() {
            _messageIds.add(newMessage.id);
            _messages.add(newMessage);
            _scrollToBottom();
          });
        }
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }

      // Create notification
      try {
        final myProfile = await _supabase
            .from('perfiles')
            .select('nombre_artistico')
            .eq('id', myId)
            .single();

        await _supabase.from('notificaciones').insert({
          'user_id': widget.userId,
          'tipo': 'new_message',
          'titulo': 'Nuevo mensaje',
          'mensaje': '${myProfile['nombre_artistico']} te envió un audio',
          'leido': false,
          'data': {'sender_id': myId, 'conversation_id': widget.userId},
        });
      } catch (notifError) {
        debugPrint('Error creating notification: $notifError');
      }
    } catch (e) {
      ErrorHandler.logError('ChatScreen._pickAndSendAudio', e);
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al enviar audio');
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

  Future<void> _handleDownload(Message message) async {
    if (message.mediaUrl == null) return;
    
    final ext = message.mediaType == 'audio' ? 'mp3' : 'jpg';
    final fileName = 'oolale_${DateTime.now().millisecondsSinceEpoch}.$ext';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando descarga...'))
    );
    
    final path = await _downloadService.downloadFile(message.mediaUrl!, fileName);
    
    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado: ${path.split("/").last}'),
            backgroundColor: AppConstants.primaryColor,
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el archivo'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingConnection) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_loadedUserName.isNotEmpty ? _loadedUserName : 'Cargando...', 
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor)),
      );
    }

    if (!_isConnected) {
      return _buildNotConnectedScreen();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _otherUserTyping ? _buildTypingIndicator() : const SizedBox.shrink(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildNotConnectedScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_loadedUserName.isNotEmpty ? _loadedUserName : 'Usuario', 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: ThemeColors.iconSecondary(context),
              ),
              const SizedBox(height: 24),
              Text(
                'No puedes enviar mensajes',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryText(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Debes estar conectado con ${_loadedUserName.isNotEmpty ? _loadedUserName : "este usuario"} para poder enviar mensajes.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: ThemeColors.secondaryText(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text('Volver', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: _loadedUserPhoto != null
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(_loadedUserPhoto!),
                  )
                : Text(
                    _loadedUserName.isNotEmpty ? _loadedUserName.substring(0, 1).toUpperCase() : 'U', 
              style: const TextStyle(
                color: AppConstants.primaryColor, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadedUserName.isNotEmpty ? _loadedUserName : 'Usuario',
                  style: GoogleFonts.outfit(
                    color: ThemeColors.primaryText(context), 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                _buildConnectionIndicator(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Reconnect button (only show if disconnected)
        if (_realtimeConnectionState == RealtimeConnectionState.error ||
            _realtimeConnectionState == RealtimeConnectionState.failed)
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => _realtimeService.reconnect(),
            tooltip: 'Reconectar',
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: ThemeColors.icon(context)),
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'report') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportContentScreen(
                    contentType: 'message',
                    contentId: widget.userId,
                    contentTitle: 'Conversación con ${_loadedUserName.isNotEmpty ? _loadedUserName : "usuario"}',
                  ),
                ),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Text('Reportar conversación', style: GoogleFonts.outfit(color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectionIndicator() {
    // Mostrar estado real del usuario desde la BD
    if (_userIsOnline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'En línea',
              style: GoogleFonts.outfit(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (_userLastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(_userLastSeen!);
      
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastSeenDate = DateTime(_userLastSeen!.year, _userLastSeen!.month, _userLastSeen!.day);

      String lastSeenText;
      if (difference.inMinutes <= 2) {
        lastSeenText = 'En línea'; // Gracia de 2 minutos para el estado offline
      } else if (difference.inMinutes < 60) {
        lastSeenText = 'Recientemente';
      } else if (lastSeenDate == today) {
        lastSeenText = 'Hoy';
      } else if (lastSeenDate == yesterday) {
        lastSeenText = 'Ayer';
      } else {
        lastSeenText = 'Hace unos días';
      }
      
      return Text(
        lastSeenText,
        style: GoogleFonts.outfit(
          color: ThemeColors.secondaryText(context),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: ThemeColors.disabledText(context)),
          const SizedBox(height: 16),
          Text(
            'Inicia la conversación...',
            style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      key: const ValueKey('typing_indicator_container'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_loadedUserName.isNotEmpty ? _loadedUserName : "El usuario"} está escribiendo',
            style: GoogleFonts.outfit(
              color: ThemeColors.secondaryText(context),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 20,
            child: TypingIndicator(color: ThemeColors.secondaryText(context)),
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
        final isMe = msg.senderId == myId;
        
        // Show date separator if needed
        final showDateSeparator = _shouldShowDateSeparator(index);
        
        // OPTIMIZACIÓN: Eliminamos FadeInUp de toda la lista para evitar stuttering
        // Solo animamos si es el último mensaje y acaba de llegar
        final isLast = index == _messages.length - 1;
        
        Widget bubble = msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty
            ? MediaMessageBubble(
                message: msg,
                isMe: isMe,
                onImageTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageViewer(
                        imageUrl: msg.mediaUrl!,
                        caption: msg.content,
                      ),
                    ),
                  );
                },
                onAudioTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AudioPlayerWidget(audioUrl: msg.mediaUrl!),
                    ),
                  );
                },
                onDownload: () => _handleDownload(msg),
              )
            : _MessageBubble(message: msg, isMe: isMe);

        if (isLast && !isMe) {
          bubble = FadeInRight(duration: const Duration(milliseconds: 200), child: bubble);
        }

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(msg.sentAt),
            bubble,
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == 0) return true;
    
    final currentMsg = _messages[index];
    final previousMsg = _messages[index - 1];
    
    final currentDate = DateTime(
      currentMsg.sentAt.year,
      currentMsg.sentAt.month,
      currentMsg.sentAt.day,
    );
    
    final previousDate = DateTime(
      previousMsg.sentAt.year,
      previousMsg.sentAt.month,
      previousMsg.sentAt.day,
    );
    
    return !currentDate.isAtSameMomentAs(previousDate);
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Hoy';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      dateText = 'Ayer';
    } else {
      dateText = DateFormat('dd MMMM yyyy', 'es').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: ThemeColors.divider(context))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: ThemeColors.divider(context))),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      key: const ValueKey('chat_input_area_container'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: ThemeColors.divider(context))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Upload progress indicator
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: ThemeColors.divider(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subiendo archivo...',
                      style: GoogleFonts.outfit(
                        color: ThemeColors.secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

          // Action Menu Helper
          _buildActionMenu(),
            
            // Input row
            Row(
              children: [
                // Single Action Button for all media
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryColor, size: 28),
                  onPressed: _isUploading ? null : () => _showAttachmentOptions(context),
                  tooltip: 'Adjuntar archivo',
                ),
                
                const SizedBox(width: 8),
                
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
                    ),
                    child: TextField(
                      key: const ValueKey('chat_message_textfield'),
                      controller: _messageController,
                      focusNode: _messageFocusNode, // NUEVO: Mantener el foco
                      enabled: !_isUploading, // Permitimos escribir offline
                      style: GoogleFonts.outfit(color: ThemeColors.primaryText(context)),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Send button
                GestureDetector(
                  onTap: _isUploading ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isUploading 
                          ? AppConstants.primaryColor.withOpacity(0.5)
                          : AppConstants.primaryColor, 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  icon: Icons.image,
                  color: Colors.blue,
                  label: 'Galería',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendImage();
                  },
                ),
                _buildActionItem(
                  icon: Icons.attach_file,
                  color: Colors.orange,
                  label: 'Archivo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendDocument();
                  },
                ),
                _buildActionItem(
                  icon: Icons.mic,
                  color: Colors.red,
                  label: 'Audio',
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndSendAudio();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: ThemeColors.primaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() => const SizedBox.shrink();
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppConstants.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light && !isMe 
                ? ThemeColors.divider(context) 
                : Colors.transparent,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null) ...[
              if (message.mediaType == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.mediaUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: isMe ? Colors.black : AppConstants.primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ ERROR loading image from: ${message.mediaUrl}');
                      debugPrint('   Error: $error');
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.black12,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            Text('Error al cargar imagen', 
                              style: GoogleFonts.outfit(fontSize: 12, color: ThemeColors.secondaryText(context))),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else if (message.mediaType == 'audio')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill, 
                      color: isMe ? Colors.black : AppConstants.primaryColor, size: 38), // Icono más grande
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text('Mensaje de voz', 
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.black : ThemeColors.primaryText(context),
                          fontWeight: FontWeight.bold, // Texto del audio en negrita
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insert_drive_file, 
                      color: isMe ? Colors.black : AppConstants.primaryColor, size: 28),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('Documento', 
                        style: GoogleFonts.outfit(
                          color: isMe ? Colors.black : ThemeColors.primaryText(context),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold, // Documento en negrita
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: GoogleFonts.outfit(
                  color: isMe ? Colors.white : ThemeColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                  height: 1.3,
                ),
              ),
            const SizedBox(height: 6),
            // El reloj ahora se posiciona por el CrossAxisAlignment de la columna, no por un Align expansivo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isMe 
                    ? Colors.black.withOpacity(0.2)
                    : Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message.sentAt),
                    style: GoogleFonts.outfit(
                      color: isMe ? Colors.white : ThemeColors.secondaryText(context),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (message.status == 'pending') {
      return Icon(
        Icons.access_time,
        size: 14,
        color: isMe ? Colors.white70 : Colors.black45,
      );
    }

    final statusColor = isMe ? Colors.white : Colors.black.withOpacity(0.7);
    
    // Check if message has been read
    if (message.readAt != null) {
      return Icon(
        Icons.done_all,
        size: 14,
        color: isMe ? Colors.white : AppConstants.primaryColor,
      );
    }
    
    // Check if message has been delivered
    if (message.deliveredAt != null) {
      return Icon(
        Icons.done_all,
        size: 14,
        color: statusColor,
      );
    }
    
    // Message sent but not delivered yet
    return Icon(
      Icons.done,
      size: 14,
      color: statusColor,
    );
  }
}
