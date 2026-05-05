import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/message_actions_service.dart';
import 'group_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final bool isOnline;
  final String conversationId;
  final String? otherUserId; // Nullable for group chats
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.conversationId,
    this.otherUserId,
    this.isOnline = true,
    this.isGroup = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authService = AuthService();
  final _chatService = ChatService();
  final _mediaService = MediaService();
  final _messageActionsService = MessageActionsService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  bool _isUploading = false;
  List<Message> _messages = [];
  bool _isLoading = true;
  RealtimeChannel? _messagesChannel;
  Message? _replyingTo; // Message being replied to
  Message? _editingMessage; // Message being edited

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
            // Parse reactions if available
            List<MessageReaction> reactions = [];
            if (msg['reactions'] != null) {
              try {
                final reactionsData = msg['reactions'] as List;
                reactions = reactionsData
                    .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
                    .toList();
              } catch (e) {
                debugPrint('Error parsing reactions: $e');
              }
            }

            return Message(
              id: msg['id'],
              text: msg['text'] ?? '',
              isSentByMe: msg['sender_id'] == currentUserId,
              timestamp: DateTime.parse(msg['created_at']),
              senderName: msg['sender']?['full_name'] ?? 'Unknown',
              senderAvatar: msg['sender']?['avatar_url'] ?? AppConstants.defaultAvatar,
              senderId: msg['sender_id'],
              imageUrl: msg['media_url'],
              isRead: msg['is_read'] ?? false,
              isEdited: msg['is_edited'] ?? false,
              isDeleted: msg['is_deleted'] ?? false,
              editedAt: msg['edited_at'] != null ? DateTime.parse(msg['edited_at']) : null,
              replyToMessageId: msg['reply_to_message_id'],
              replyToText: msg['reply_to_text'],
              replyToSenderName: msg['reply_to_sender_name'],
              reactions: reactions,
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
    
    try {
      // Check if editing
      if (_editingMessage != null) {
        final success = await _messageActionsService.editMessage(
          _editingMessage!.id,
          messageText,
        );
        
        if (success) {
          _messageController.clear();
          setState(() => _editingMessage = null);
          await _loadMessages();
        } else {
          throw Exception('Không thể chỉnh sửa tin nhắn');
        }
      } else {
        // Send new message (with optional reply)
        _messageController.clear();
        
        await _chatService.sendMessage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          text: messageText,
          replyToMessageId: _replyingTo?.id,
        );

        // Clear reply state
        if (_replyingTo != null) {
          setState(() => _replyingTo = null);
        }

        // Update typing status
        await _chatService.updateTypingStatus(
          conversationId: widget.conversationId,
          userId: currentUserId,
          isTyping: false,
        );
        
        // Reload messages immediately for sender
        await _loadMessages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: const Color(0xFFef4444),
          ),
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

  Future<void> _showMediaPicker() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0d1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF94a3b8).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Gửi media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFf8fafc),
                ),
              ),
              const SizedBox(height: 24),
              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    color: const Color(0xFF1e3a8a),
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendImage(fromCamera: false);
                    },
                  ),
                  _buildMediaOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: const Color(0xFF059669),
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendImage(fromCamera: true);
                    },
                  ),
                  _buildMediaOption(
                    icon: Icons.insert_drive_file,
                    label: 'File',
                    color: const Color(0xFFf59e0b),
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndSendFile();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage({required bool fromCamera}) async {
    try {
      setState(() => _isUploading = true);

      final image = fromCamera
          ? await _mediaService.pickImageFromCamera()
          : await _mediaService.pickImageFromGallery();

      if (image == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Check file size
      final isValid = await _mediaService.isFileSizeValid(image.path);
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File quá lớn! Giới hạn 10MB'),
              backgroundColor: Color(0xFFef4444),
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      // Upload image
      final imageUrl = await _mediaService.uploadImage(
        filePath: image.path,
        conversationId: widget.conversationId,
      );

      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi upload ảnh'),
              backgroundColor: Color(0xFFef4444),
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      // Send message with image
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId != null) {
        await _chatService.sendMessage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          text: '',
          mediaUrl: imageUrl,
        );
        await _loadMessages();
      }

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Future<void> _pickAndSendFile() async {
    try {
      setState(() => _isUploading = true);

      final file = await _mediaService.pickFile();

      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Check file size
      if (file.path != null) {
        final isValid = await _mediaService.isFileSizeValid(file.path!);
        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File quá lớn! Giới hạn 10MB'),
                backgroundColor: Color(0xFFef4444),
              ),
            );
          }
          setState(() => _isUploading = false);
          return;
        }

        // Upload file
        final fileUrl = await _mediaService.uploadFile(
          filePath: file.path!,
          conversationId: widget.conversationId,
          fileName: file.name,
        );

        if (fileUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lỗi upload file'),
                backgroundColor: Color(0xFFef4444),
              ),
            );
          }
          setState(() => _isUploading = false);
          return;
        }

        // Send message with file
        final currentUserId = _authService.currentUser?.id;
        if (currentUserId != null) {
          await _chatService.sendMessage(
            conversationId: widget.conversationId,
            senderId: currentUserId,
            text: file.name,
            mediaUrl: fileUrl,
          );
          await _loadMessages();
        }
      }

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  // Message Actions Methods
  void _showMessageActions(Message message) {
    final canModify = _messageActionsService.canModifyMessage(message.senderId);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0d1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF94a3b8).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Reply
              _buildActionTile(
                icon: Icons.reply,
                label: 'Trả lời',
                color: const Color(0xFF1e3a8a),
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
              ),
              // React
              _buildActionTile(
                icon: Icons.add_reaction_outlined,
                label: 'Thả cảm xúc',
                color: const Color(0xFFf59e0b),
                onTap: () {
                  Navigator.pop(context);
                  _showReactionPicker(message);
                },
              ),
              // Edit (only for own messages)
              if (canModify && !message.isDeleted)
                _buildActionTile(
                  icon: Icons.edit,
                  label: 'Chỉnh sửa',
                  color: const Color(0xFF059669),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              // Delete (only for own messages)
              if (canModify && !message.isDeleted)
                _buildActionTile(
                  icon: Icons.delete,
                  label: 'Xóa',
                  color: const Color(0xFFef4444),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFf8fafc),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _replyToMessage(Message message) {
    setState(() {
      _replyingTo = message;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _editMessage(Message message) {
    setState(() {
      _editingMessage = message;
      _messageController.text = message.text;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Xóa tin nhắn', style: TextStyle(color: Color(0xFFe2e8f0))),
        content: const Text(
          'Bạn có chắc muốn xóa tin nhắn này?',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF94a3b8))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _messageActionsService.deleteMessage(message.id);
      if (success) {
        await _loadMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa tin nhắn'),
              backgroundColor: Color(0xFF10b981),
            ),
          );
        }
      }
    }
  }

  void _showReactionPicker(Message message) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0d1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF94a3b8).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chọn cảm xúc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFf8fafc),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: emojis.map((emoji) {
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await _addReaction(message, emoji);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e293b),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFffffff).withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addReaction(Message message, String emoji) async {
    // Check if user already reacted with this emoji
    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return;

    final hasReacted = message.reactions.any((r) => 
      r.emoji == emoji && r.userIds.contains(currentUserId)
    );

    if (hasReacted) {
      // Remove reaction
      await _messageActionsService.removeReaction(
        messageId: message.id,
        emoji: emoji,
      );
    } else {
      // Add reaction
      await _messageActionsService.addReaction(
        messageId: message.id,
        emoji: emoji,
      );
    }

    await _loadMessages();
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

              // User/Group info
              Expanded(
                child: Row(
                  children: [
                    // Avatar with status or group icon
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isGroup 
                                ? const Color(0xFF0d1117)
                                : null,
                            image: !widget.isGroup && widget.userAvatar.startsWith('http')
                                ? DecorationImage(
                                    image: NetworkImage(widget.userAvatar),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(
                              color: const Color(0xFFffffff).withOpacity(0.1),
                            ),
                          ),
                          child: widget.isGroup
                              ? const Icon(
                                  Icons.group,
                                  color: Color(0xFF94a3b8),
                                  size: 24,
                                )
                              : (!widget.userAvatar.startsWith('http')
                                  ? ClipOval(
                                      child: Image.asset(
                                        widget.userAvatar,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : null),
                        ),
                        if (!widget.isGroup && widget.isOnline)
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    color: Color(0xFFf8fafc),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.isGroup) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.people,
                                  size: 14,
                                  color: Color(0xFF94a3b8),
                                ),
                              ],
                            ],
                          ),
                          if (!widget.isGroup)
                            Text(
                              widget.isOnline ? 'Đang hoạt động' : 'Không hoạt động',
                              style: TextStyle(
                                color: widget.isOnline
                                    ? const Color(0xFF60a5fa)
                                    : const Color(0xFF64748b),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Group info button
              if (widget.isGroup)
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFf8fafc),
                    size: 22,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupInfoScreen(
                          conversationId: widget.conversationId,
                          groupName: widget.userName,
                          groupAvatar: widget.userAvatar,
                        ),
                      ),
                    );
                    
                    // If user left the group, go back to chat list
                    if (result == true && mounted) {
                      Navigator.pop(context);
                    }
                  },
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply/Edit Preview
            if (_replyingTo != null || _editingMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8, top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _editingMessage != null 
                        ? const Color(0xFF059669)
                        : const Color(0xFF1e3a8a),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _editingMessage != null 
                            ? const Color(0xFF059669)
                            : const Color(0xFF1e3a8a),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingMessage != null 
                                ? 'Chỉnh sửa tin nhắn'
                                : 'Trả lời ${_replyingTo!.senderName}',
                            style: TextStyle(
                              color: _editingMessage != null 
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFF60a5fa),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _editingMessage?.text ?? _replyingTo!.text,
                            style: const TextStyle(
                              color: Color(0xFF94a3b8),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: const Color(0xFF94a3b8),
                      onPressed: _editingMessage != null ? _cancelEdit : _cancelReply,
                    ),
                  ],
                ),
              ),
            // Input row
            Padding(
              padding: const EdgeInsets.only(top: 16),
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
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF94a3b8),
                              ),
                            )
                          : const Icon(
                              Icons.add,
                              color: Color(0xFF94a3b8),
                            ),
                      onPressed: _isUploading ? null : _showMediaPicker,
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
