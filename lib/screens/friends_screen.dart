import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../services/friend_service.dart';
import '../services/auth_service.dart';
import '../models/friend_model.dart';
import 'chat_screen.dart';
import '../services/chat_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final _friendService = FriendService();
  final _authService = AuthService();
  final _chatService = ChatService();

  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<FriendSuggestion> _suggestions = [];
  bool _isLoading = true;
  
  RealtimeChannel? _friendsChannel;
  RealtimeChannel? _requestsChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupRealtimeSubscriptions();
  }
  
  void _setupRealtimeSubscriptions() {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    // Subscribe to friends table changes
    _friendsChannel = Supabase.instance.client
        .channel('friends_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friends',
          callback: (payload) {
            debugPrint('Friends changed: ${payload.eventType}');
            _loadData(); // Reload when friends change
          },
        )
        .subscribe();

    // Subscribe to friend_requests table changes
    _requestsChannel = Supabase.instance.client
        .channel('friend_requests_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friend_requests',
          callback: (payload) {
            debugPrint('Friend requests changed: ${payload.eventType}');
            _loadData(); // Reload when requests change
          },
        )
        .subscribe();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _friendService.getFriends();
      final requests = await _friendService.getPendingRequests();
      final suggestions = await _friendService.getFriendSuggestions(limit: 20);

      if (mounted) {
        setState(() {
          _friends = friends;
          _pendingRequests = requests;
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading friends data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await _friendService.acceptFriendRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chấp nhận lời mời kết bạn')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      await _friendService.rejectFriendRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối lời mời kết bạn')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    try {
      await _friendService.sendFriendRequest(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lời mời kết bạn')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeFriend(String friendId, String friendName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: const Text(
          'Xóa bạn bè',
          style: TextStyle(color: Color(0xFFe2e8f0)),
        ),
        content: Text(
          'Bạn có chắc muốn xóa $friendName khỏi danh sách bạn bè?',
          style: const TextStyle(color: Color(0xFF94a3b8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _friendService.removeFriend(friendId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bạn bè')),
          );
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _openChat(Map<String, dynamic> friendData) async {
    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) return;

      // Check if conversation already exists
      final conversations = await _chatService.getConversations(currentUserId);
      String? conversationId;

      for (var conv in conversations) {
        final convId = conv['conversation_id'];
        final participants = await _chatService.supabase
            .from('conversation_participants')
            .select('user_id')
            .eq('conversation_id', convId)
            .neq('user_id', currentUserId);

        final participantIds =
            (participants as List).map((p) => p['user_id'] as String).toList();

        if (participantIds.contains(friendData['id'])) {
          conversationId = convId;
          break;
        }
      }

      // Create new conversation if doesn't exist
      conversationId ??=
          await _chatService.createConversation([currentUserId, friendData['id']]);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userName: friendData['full_name'] ?? 'Unknown',
              userAvatar: friendData['avatar_url'] ?? AppConstants.defaultAvatar,
              isOnline: friendData['is_online'] ?? false,
              conversationId: conversationId!,
              otherUserId: friendData['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _friendsChannel?.unsubscribe();
    _requestsChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1117),
        elevation: 0,
        title: const Text(
          'Bạn bè',
          style: TextStyle(
            color: Color(0xFFe2e8f0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1e3a8a),
          labelColor: const Color(0xFF1e3a8a),
          unselectedLabelColor: const Color(0xFF94a3b8),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bạn bè'),
                  if (_friends.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e3a8a),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_friends.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Lời mời'),
                  if (_pendingRequests.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingRequests.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(text: 'Gợi ý'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF94a3b8),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildRequestsList(),
                _buildSuggestionsList(),
              ],
            ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bạn bè',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friendData = _friends[index]['friend'] as Map<String, dynamic>;
          return _buildFriendCard(friendData, isFriend: true);
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Text(
          'Không có lời mời kết bạn',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          final sender = request['sender'] as Map<String, dynamic>;
          final requestId = request['id'] as String;

          return _buildRequestCard(sender, requestId);
        },
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return const Center(
        child: Text(
          'Không có gợi ý',
          style: TextStyle(color: Color(0xFF94a3b8)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return _buildSuggestionCard(suggestion);
        },
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend, {bool isFriend = false}) {
    final isOnline = friend['is_online'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF94a3b8).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: friend['avatar_url'] != null &&
                        friend['avatar_url'].toString().startsWith('http')
                    ? NetworkImage(friend['avatar_url']) as ImageProvider
                    : const AssetImage(AppConstants.defaultAvatar),
              ),
              if (isOnline)
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
                        color: const Color(0xFF0d1117),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend['full_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Color(0xFFe2e8f0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? 'Đang hoạt động' : 'Không hoạt động',
                  style: TextStyle(
                    color: isOnline
                        ? const Color(0xFF10b981)
                        : const Color(0xFF94a3b8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isFriend) ...[
            IconButton(
              onPressed: () => _openChat(friend),
              icon: const Icon(Icons.chat_bubble_outline),
              color: const Color(0xFF1e3a8a),
            ),
            IconButton(
              onPressed: () => _removeFriend(
                friend['id'],
                friend['full_name'] ?? 'Unknown',
              ),
              icon: const Icon(Icons.person_remove_outlined),
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> sender, String requestId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF94a3b8).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: sender['avatar_url'] != null &&
                    sender['avatar_url'].toString().startsWith('http')
                ? NetworkImage(sender['avatar_url']) as ImageProvider
                : const AssetImage(AppConstants.defaultAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender['full_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Color(0xFFe2e8f0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sender['email'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _acceptRequest(requestId),
            icon: const Icon(Icons.check_circle_outline),
            color: const Color(0xFF10b981),
          ),
          IconButton(
            onPressed: () => _rejectRequest(requestId),
            icon: const Icon(Icons.cancel_outlined),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(FriendSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF94a3b8).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: suggestion.avatarUrl != null &&
                        suggestion.avatarUrl!.startsWith('http')
                    ? NetworkImage(suggestion.avatarUrl!) as ImageProvider
                    : const AssetImage(AppConstants.defaultAvatar),
              ),
              if (suggestion.isOnline)
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
                        color: const Color(0xFF0d1117),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.fullName,
                  style: const TextStyle(
                    color: Color(0xFFe2e8f0),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (suggestion.mutualFriendsCount > 0)
                  Text(
                    '${suggestion.mutualFriendsCount} bạn chung',
                    style: const TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    suggestion.email,
                    style: const TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _sendFriendRequest(suggestion.userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1e3a8a),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Kết bạn'),
          ),
        ],
      ),
    );
  }
}
