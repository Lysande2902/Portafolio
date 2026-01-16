import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int userId; // Interlocutor ID
  final String userName; // Interlocutor Name (optional, passed for header)

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
     _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _loadMessages(background: true);
     });
  }

  Future<void> _loadMessages({bool background = false}) async {
    try {
      final response = await _api.get('/conversaciones/${widget.userId}/mensajes');
      if (response is List) {
        final newMessages = response.map((data) => Message.fromJson(data)).toList();
        
        if (mounted) {
           setState(() {
             _messages = newMessages;
             if (!background) _isLoading = false;
           });
           // Only scroll to bottom if it's the first load or we are already at bottom?
           // For simplicity, we scroll on first load (handled by !background check usually)
           if (!background) _scrollToBottom(); 
        }
      } else {
        if (!background && mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!background) debugPrint('Error loading messages: $e');
      if (!background && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    
    // Optimistic update
    final tempMsg = Message(
      id: -1, 
      senderId: Provider.of<AuthProvider>(context, listen: false).user?.id ?? 0, 
      receiverId: widget.userId, 
      content: text, 
      sentAt: DateTime.now()
    );

    setState(() {
      _messages.add(tempMsg);
      _msgController.clear();
    });
    _scrollToBottom();

    try {
      await _api.post('/conversaciones/mensaje', {
        'destinatario_id': widget.userId,
        'mensaje': text,
      });
      // In a real app we would replace the tempMsg with the real one returned
      // For now we just reload or assume success
      // _loadMessages(); // Optional: reload to conform with server
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar mensaje')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     final currentUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.userName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty 
                  ? Center(child: Text('Di Hola!', style: GoogleFonts.outfit(color: Colors.white54)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMe = msg.senderId == currentUser?.id;
                        return _MessageBubble(message: msg, isMe: isMe);
                      },
                    ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppConstants.cardColor,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: AppConstants.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppConstants.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF009688) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(message.sentAt),
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
