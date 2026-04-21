import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _authService = AuthService();
  final _chatService = ChatService();
  final _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  String _lastMessageText = '';
  String _lastMessageTime = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _startAutoRefresh();
  }
  
  void _startAutoRefresh() {
    // Auto refresh every 3 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadConversations();
      }
    });
  }

  Future<void> _loadConversations() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return;

      final conversations = await _chatService.getConversations(userId);
      
      // Load user details for each conversation
      final conversationsWithUsers = <Map<String, dynamic>>[];
      
      for (var conv in conversations) {
        final conversationId = conv['conversation_id'];
        
        // Get last message
        final messages = await _chatService.getMessages(conversationId);
        final lastMessage = messages.isNotEmpty ? messages.last : null;
        
        // Get other participants (not current user)
        final participants = await _getConversationParticipants(conversationId, userId);
        
        if (participants.isNotEmpty) {
          final otherUser = participants.first;
          
          // Format last message with sender name
          String lastMessageText = 'Bắt đầu trò chuyện';
          if (lastMessage != null) {
            final senderId = lastMessage['sender_id'] as String?;
            final messageText = lastMessage['text'] as String? ?? '';
            
            if (senderId != null && senderId == userId) {
              // Current user sent the message
              lastMessageText = 'Bạn: $messageText';
            } else {
              // Other user sent the message
              lastMessageText = messageText;
            }
          }
          
          conversationsWithUsers.add({
            'id': conversationId,
            'name': otherUser['full_name'] ?? 'Unknown',
            'avatar': otherUser['avatar_url'] ?? AppConstants.defaultAvatar,
            'lastMessage': lastMessageText,
            'time': _formatTime(lastMessage?['created_at']),
            'unreadCount': conv['unread_count'] ?? 0,
            'isOnline': otherUser['is_online'] ?? false,
            'otherUserId': otherUser['id'],
          });
        }
      }

      // Only update if data changed
      final newLastMessage = conversationsWithUsers.isNotEmpty 
          ? conversationsWithUsers.first['lastMessage'] 
          : '';
      final newLastTime = conversationsWithUsers.isNotEmpty 
          ? conversationsWithUsers.first['time'] 
          : '';
      
      if (newLastMessage != _lastMessageText || newLastTime != _lastMessageTime) {
        _lastMessageText = newLastMessage;
        _lastMessageTime = newLastTime;
        
        if (mounted) {
          setState(() {
            _conversations = conversationsWithUsers;
            _isLoading = false;
          });
          debugPrint('✅ Chat list updated - new message detected');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getConversationParticipants(
    String conversationId,
    String currentUserId,
  ) async {
    try {
      // Get all participant IDs for this conversation
      final response = await _chatService.supabase
          .from('conversation_participants')
          .select('user_id')
          .eq('conversation_id', conversationId)
          .neq('user_id', currentUserId);

      final participantIds = (response as List)
          .map((p) => p['user_id'] as String)
          .toList();

      if (participantIds.isEmpty) return [];

      // Get user details
      return await _userService.getUsersByIds(participantIds);
    } catch (e) {
      print('Error getting participants: $e');
      return [];
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = DateTime.parse(timestamp).toLocal(); // Convert to local time
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Vừa xong';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}p';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _showNewChatDialog() async {
    final searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0d1117),
          title: const Text(
            'Tìm người dùng',
            style: TextStyle(color: Color(0xFFe2e8f0)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Color(0xFFe2e8f0)),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên hoặc email...',
                    hintStyle: const TextStyle(color: Color(0xFF94a3b8)),
                    filled: true,
                    fillColor: const Color(0xFF11141a),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF94a3b8)),
                      onPressed: () async {
                        final query = searchController.text.trim();
                        if (query.isNotEmpty) {
                          final results = await _userService.searchUsers(query);
                          setDialogState(() {
                            searchResults = results;
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted: (query) async {
                    if (query.isNotEmpty) {
                      final results = await _userService.searchUsers(query);
                      setDialogState(() {
                        searchResults = results;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['avatar_url'] != null && user['avatar_url'].startsWith('http')
                                ? NetworkImage(user['avatar_url']) as ImageProvider
                                : const AssetImage(AppConstants.defaultAvatar),
                          ),
                          title: Text(
                            user['full_name'] ?? 'Unknown',
                            style: const TextStyle(color: Color(0xFFe2e8f0)),
                          ),
                          subtitle: Text(
                            user['email'] ?? '',
                            style: const TextStyle(color: Color(0xFF94a3b8)),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            await _createConversation(user);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createConversation(Map<String, dynamic> otherUser) async {
    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) return;

      // Check if conversation already exists
      final existingConversations = await _chatService.getConversations(currentUserId);
      
      String? existingConversationId;
      for (var conv in existingConversations) {
        final conversationId = conv['conversation_id'];
        final participants = await _getConversationParticipants(conversationId, currentUserId);
        
        // Check if this conversation has the other user
        if (participants.any((p) => p['id'] == otherUser['id'])) {
          existingConversationId = conversationId;
          break;
        }
      }

      // Use existing conversation or create new one
      final conversationId = existingConversationId ?? 
        await _chatService.createConversation([currentUserId, otherUser['id']]);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: otherUser['full_name'] ?? 'Unknown',
              userAvatar: otherUser['avatar_url'] ?? AppConstants.defaultAvatar,
              isOnline: otherUser['is_online'] ?? false,
              conversationId: conversationId,
              otherUserId: otherUser['id'],
            ),
          ),
        ).then((_) => _loadConversations());
      }
    } catch (e) {
      print('Error creating conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020408),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF94a3b8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Search Bar
            _buildSearchBar(),
            // Chat List
            Expanded(
              child: _buildChatList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        backgroundColor: const Color(0xFF1e3a8a),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tin nhắn',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFe2e8f0),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF94a3b8).withOpacity(0.15),
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF94a3b8),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF94a3b8).withOpacity(0.15),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Color(0xFFe2e8f0)),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm...',
          hintStyle: TextStyle(color: Color(0xFF94a3b8)),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF94a3b8), size: 20),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: chat['name'],
              userAvatar: chat['avatar'],
              isOnline: chat['isOnline'],
              conversationId: chat['id'],
              otherUserId: chat['otherUserId'],
            ),
          ),
        ).then((_) => _loadConversations());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF0d1117),
                  backgroundImage: chat['avatar'].startsWith('http')
                      ? NetworkImage(chat['avatar']) as ImageProvider
                      : AssetImage(chat['avatar']),
                ),
                if (chat['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF020408),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFe2e8f0),
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: chat['unreadCount'] > 0
                              ? const Color(0xFF1e3a8a)
                              : const Color(0xFF94a3b8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          style: TextStyle(
                            fontSize: 14,
                            color: chat['unreadCount'] > 0
                                ? const Color(0xFFe2e8f0)
                                : const Color(0xFF94a3b8),
                            fontWeight: chat['unreadCount'] > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat['unreadCount'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e3a8a),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat['unreadCount']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF94a3b8).withOpacity(0.15),
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF1e3a8a),
        unselectedItemColor: const Color(0xFF94a3b8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
