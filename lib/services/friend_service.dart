import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/friend_model.dart';

class FriendService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Send friend request
  Future<FriendRequestModel> sendFriendRequest(String receiverId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('friend_requests')
        .insert({
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'status': 'pending',
        })
        .select()
        .single();

    return FriendRequestModel.fromJson(response);
  }

  // Get pending friend requests (received)
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final response = await _supabase
        .from('friend_requests')
        .select('''
          *,
          sender:sender_id (
            id,
            full_name,
            email,
            avatar_url,
            bio,
            is_online,
            last_seen
          )
        ''')
        .eq('receiver_id', currentUserId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get sent friend requests
  Future<List<FriendRequestModel>> getSentRequests() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final response = await _supabase
        .from('friend_requests')
        .select()
        .eq('sender_id', currentUserId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => FriendRequestModel.fromJson(json))
        .toList();
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    await _supabase
        .from('friend_requests')
        .update({'status': 'accepted'})
        .eq('id', requestId);
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    await _supabase
        .from('friend_requests')
        .update({'status': 'rejected'})
        .eq('id', requestId);
  }

  // Cancel sent friend request
  Future<void> cancelFriendRequest(String requestId) async {
    await _supabase
        .from('friend_requests')
        .delete()
        .eq('id', requestId);
  }

  // Get friends list
  Future<List<Map<String, dynamic>>> getFriends() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final response = await _supabase
        .from('friends')
        .select('''
          *,
          friend:friend_id (
            id,
            full_name,
            email,
            avatar_url,
            bio,
            is_online,
            last_seen
          )
        ''')
        .eq('user_id', currentUserId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Remove friend
  Future<void> removeFriend(String friendId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Remove both directions of friendship
    await _supabase
        .from('friends')
        .delete()
        .eq('user_id', currentUserId)
        .eq('friend_id', friendId);

    await _supabase
        .from('friends')
        .delete()
        .eq('user_id', friendId)
        .eq('friend_id', currentUserId);
  }

  // Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    final response = await _supabase
        .from('friends')
        .select()
        .eq('user_id', userId1)
        .eq('friend_id', userId2)
        .maybeSingle();

    return response != null;
  }

  // Check if friend request exists
  Future<String?> checkFriendRequestStatus(String otherUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return null;

    // Check if current user sent request
    final sentRequest = await _supabase
        .from('friend_requests')
        .select()
        .eq('sender_id', currentUserId)
        .eq('receiver_id', otherUserId)
        .eq('status', 'pending')
        .maybeSingle();

    if (sentRequest != null) return 'sent';

    // Check if current user received request
    final receivedRequest = await _supabase
        .from('friend_requests')
        .select()
        .eq('sender_id', otherUserId)
        .eq('receiver_id', currentUserId)
        .eq('status', 'pending')
        .maybeSingle();

    if (receivedRequest != null) return 'received';

    return null;
  }

  // Get friend suggestions
  Future<List<FriendSuggestion>> getFriendSuggestions({int limit = 10}) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final response = await _supabase
          .rpc('get_friend_suggestions', params: {
            'p_current_user_id': currentUserId,
            'p_limit_count': limit,
          });

      return (response as List)
          .map((json) => FriendSuggestion.fromJson(json))
          .toList();
    } catch (e) {
      // If RPC function doesn't exist, fall back to simple query
      final response = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .limit(limit);

      return (response as List).map((json) {
        return FriendSuggestion(
          userId: json['id'],
          fullName: json['full_name'],
          email: json['email'],
          avatarUrl: json['avatar_url'],
          bio: json['bio'],
          isOnline: json['is_online'] ?? false,
          mutualFriendsCount: 0,
        );
      }).toList();
    }
  }

  // Get online friends
  Future<List<Map<String, dynamic>>> getOnlineFriends() async {
    final friends = await getFriends();
    return friends.where((f) {
      final friend = f['friend'] as Map<String, dynamic>?;
      return friend?['is_online'] == true;
    }).toList();
  }

  // Subscribe to friend online status changes
  RealtimeChannel subscribeFriendStatusChanges({
    required Function(Map<String, dynamic>) onStatusChange,
  }) {
    return _supabase
        .channel('friend_status_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            onStatusChange(payload.newRecord);
          },
        )
        .subscribe();
  }
}
