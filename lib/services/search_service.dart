import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Try using RPC function first
      final response = await _supabase.rpc('search_users', params: {
        'search_query': query,
        'current_user_id': currentUserId,
        'limit_count': limit,
      });

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to simple query if RPC doesn't exist
      final response = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .limit(limit);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    }
  }

  // Search messages in a conversation
  Future<List<MessageModel>> searchMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Try using RPC function first
      final response = await _supabase.rpc('search_messages', params: {
        'conversation_id_param': conversationId,
        'search_query': query,
        'current_user_id': currentUserId,
        'limit_count': limit,
      });

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to simple query if RPC doesn't exist
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:users!sender_id(id, full_name, avatar_url)
          ''')
          .eq('conversation_id', conversationId)
          .ilike('text', '%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    }
  }

  // Search conversations by name
  Future<List<Map<String, dynamic>>> searchConversations(String query) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    // Get user's conversations
    final participantResponse = await _supabase
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', currentUserId);

    final conversationIds = (participantResponse as List)
        .map((p) => p['conversation_id'] as String)
        .toList();

    if (conversationIds.isEmpty) {
      return [];
    }

    // Search in group conversations by name
    final response = await _supabase
        .from('conversations')
        .select('''
          *,
          conversation_participants!inner(user_id)
        ''')
        .inFilter('id', conversationIds)
        .eq('is_group', true)
        .ilike('name', '%$query%')
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Search friends
  Future<List<Map<String, dynamic>>> searchFriends(String query) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (query.trim().isEmpty) {
      return [];
    }

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
        .or(
          'friend.full_name.ilike.%$query%,friend.email.ilike.%$query%',
          referencedTable: 'friend_id',
        );

    return List<Map<String, dynamic>>.from(response);
  }

  // Get recent searches (stored locally)
  List<String> getRecentSearches() {
    // TODO: Implement local storage for recent searches
    return [];
  }

  // Save search query to recent searches
  void saveRecentSearch(String query) {
    // TODO: Implement local storage for recent searches
  }

  // Clear recent searches
  void clearRecentSearches() {
    // TODO: Implement local storage for recent searches
  }
}
