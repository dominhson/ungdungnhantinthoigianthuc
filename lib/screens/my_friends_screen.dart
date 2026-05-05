import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import 'chat_screen.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  final _friendService = FriendService();
  final _chatService = ChatService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bạn bè: $e')),
        );
      }
    }
  }

  Future<void> _openChat(Map<String, dynamic> friend) async {
    final currentUserId = _authService.currentUser?.id;
    if (currentUserId == null) return;

    try {
      // Check if conversation exists
      final conversations = await _chatService.getConversations(currentUserId);
      String? conversationId;

      for (var conv in conversations) {
        final convId = conv['conversation_id'];
        final convData = conv['conversations'] as Map<String, dynamic>?;
        
        // Skip groups
        if (convData?['is_group'] == true) continue;

        // Check participants
        final participants = await _chatService.supabase
            .from('conversation_participants')
            .select('user_id')
            .eq('conversation_id', convId)
            .neq('user_id', currentUserId);

        if ((participants as List).any((p) => p['user_id'] == friend['id'])) {
          conversationId = convId;
          break;
        }
      }

      // Create conversation if not exists
      conversationId ??= await _chatService.createConversation([
        currentUserId,
        friend['id'],
      ]);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: friend['full_name'] ?? 'Unknown',
              userAvatar: friend['avatar_url'] ?? '',
              isOnline: friend['is_online'] ?? false,
              conversationId: conversationId!,
              otherUserId: friend['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text('Bạn bè'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            )
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bạn bè nào',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friendData = _friends[index];
                    final friend = friendData['friend'] as Map<String, dynamic>;

                    return Card(
                      color: const Color(0xFF0d1117),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: friend['avatar_url'] != null
                                  ? NetworkImage(friend['avatar_url'])
                                  : null,
                              child: friend['avatar_url'] == null
                                  ? Text(
                                      (friend['full_name'] ?? 'U')[0].toUpperCase(),
                                    )
                                  : null,
                            ),
                            if (friend['is_online'] == true)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0d1117),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          friend['full_name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Color(0xFFe2e8f0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          friend['bio'] ?? friend['email'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF60a5fa),
                          ),
                          onPressed: () => _openChat(friend),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
