import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final bool isOnline;
  final String conversationId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.conversationId,
    required this.otherUserId,
    this.isOnline = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authService = AuthService();
  final _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  List<Message> _messages = [];
  bool _isLoading = true;
  RealtimeChannel? _messagesChannel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }
  
  void _subscribeToMessages() {
    _messagesChannel = _chatService.subscribeToMessages(
      widget.conversationId,
      (newMessage) {
        debugPrint('🔔 Realtime: Tin nhắn mới!');
        _loadMessages();
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_messagesChannel != null) {
      _chatService.unsubscribe(_messagesChannel!);
    }
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(widget.conversationId);
      final currentUserId = _authService.currentUser?.id;

      if (mounted) {
        setState(() {
          _messages = messages.map((msg) {
            return Message(
              id: msg['id'],
              text: msg['text'] ?? '',
              isSentByMe: msg['sender_id'] == currentUserId,
              timestamp: DateTime.parse(msg['created_at']),
              senderName: msg['sender']?['full_name'] ?? 'Unknown',
              senderAvatar: msg['sender']?['avatar_url'] ?? AppConstants.defaultAvatar,
              imageUrl: msg['media_url'],
              isRead: msg['is_read'] ?? false,
            );
          }).toList();
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        senderId: currentUserId,
        text: messageText,
      );

      // Update typing status
      await _chatService.updateTypingStatus(
        conversationId: widget.conversationId,
        userId: currentUserId,
        isTyping: false,
      );
      
      // Reload messages immediately for sender
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin nhắn: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleTyping(String text) async {
    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return;

    final isTyping = text.isNotEmpty;
    
    await _chatService.updateTypingStatus(
      conversationId: widget.conversationId,
      userId: currentUserId,
      isTyping: isTyping,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF94a3b8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
              itemCount: _messages.length + 2, // +2 for date indicator and typing
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDateIndicator();
                }
                if (index == _messages.length + 1) {
                  return _isTyping ? _buildTypingIndicator() : const SizedBox.shrink();
                }
                return _buildMessageItem(_messages[index - 1]);
              },
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020617).withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFffffff),
            width: 0.05,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFf8fafc),
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Row(
                  children: [
                    // Avatar with status
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: widget.userAvatar.startsWith('http')
                                  ? NetworkImage(widget.userAvatar) as ImageProvider
                                  : AssetImage(widget.userAvatar),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: const Color(0xFFffffff).withOpacity(0.1),
                            ),
                          ),
                        ),
                        if (widget.isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF60a5fa),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF020617),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Name and status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFf8fafc),
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.isOnline)
                          Text(
                            'ĐANG HOẠT ĐỘNG',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: const Color(0xFF60a5fa).withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFF94a3b8),
                  size: 22,
                ),
                onPressed: _loadMessages,
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF94a3b8),
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateIndicator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFffffff).withOpacity(0.05),
          ),
        ),
        child: Text(
          'HÔM NAY',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: const Color(0xFF94a3b8).withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: message.isSentByMe
          ? _buildMyMessage(message)
          : _buildTheirMessage(message),
    );
  }

  Widget _buildTheirMessage(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: message.senderAvatar.startsWith('http')
                      ? NetworkImage(message.senderAvatar) as ImageProvider
                      : AssetImage(message.senderAvatar),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: const Color(0xFFffffff).withOpacity(0.05),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Message bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(2),
                  ),
                  border: Border.all(
                    color: const Color(0xFFffffff).withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFf8fafc),
                    height: 1.6,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44, top: 6),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF94a3b8).withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyMessage(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Message bubble
        if (message.imageUrl != null)
          _buildImageMessage(message)
        else
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1e3a8a),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(2),
              ),
              border: Border.all(
                color: const Color(0xFFffffff).withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFe2e8f0),
                height: 1.6,
                letterSpacing: -0.2,
              ),
            ),
          ),

        // Time and status
        Padding(
          padding: const EdgeInsets.only(right: 4, top: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.isRead ? 'ĐÃ XEM' : 'ĐÃ GỬI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: const Color(0xFF94a3b8).withOpacity(0.8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF94a3b8).withOpacity(0.4),
                  ),
                ),
              ),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF94a3b8).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageMessage(Message message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFffffff).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFF1e293b),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF94a3b8),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage(AppConstants.defaultAvatar),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: const Color(0xFFffffff).withOpacity(0.05),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFffffff).withOpacity(0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 6),
                _buildDot(150),
                const SizedBox(width: 6),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF1e3a8a),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF020617).withOpacity(0),
            const Color(0xFF020617).withOpacity(0.95),
            const Color(0xFF020617),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFffffff).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xFF94a3b8),
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFf8fafc),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhắn tin...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF94a3b8).withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          _handleTyping(value);
                        },
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.sentiment_satisfied_outlined,
                        color: Color(0xFF94a3b8),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Send button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFcbd5e1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFffffff).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Icons.send,
                    color: Color(0xFF020617),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal(); // Convert to local timezone
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
