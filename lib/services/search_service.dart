import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Search conversations (groups) by name or description
  Future<List<Map<String, dynamic>>> searchConversations(String query) async {
    if (query.trim().isEmpty) return [];

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      // Search in conversations where user is a participant
      final response = await _supabase
          .from('conversation_participants')
          .select('''
            conversation_id,
            conversations!inner(
              id,
              name,
              description,
              avatar_url,
              is_group,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', currentUserId)
          .eq('conversations.is_group', true)
          .or('name.ilike.%$query%,description.ilike.%$query%', 
              referencedTable: 'conversations')
          .limit(20);

      // Extract conversation data
      return (response as List).map((item) {
        final conversation = item['conversations'] as Map<String, dynamic>;
        return {
          'id': conversation['id'],
          'name': conversation['name'],
          'description': conversation['description'],
          'avatar_url': conversation['avatar_url'],
          'is_group': conversation['is_group'],
          'created_at': conversation['created_at'],
          'updated_at': conversation['updated_at'],
        };
      }).toList();
    } catch (e) {
      print('Error searching conversations: $e');
      return [];
    }
  }

  // Search friends by name or email
  Future<List<Map<String, dynamic>>> searchFriends(String query) async {
    if (query.trim().isEmpty) return [];

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
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
          .or('friend.full_name.ilike.%$query%,friend.email.ilike.%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching friends: $e');
      return [];
    }
  }

  // Search all (users, conversations, friends) at once
  Future<Map<String, dynamic>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return {
        'users': <UserModel>[],
        'conversations': <Map<String, dynamic>>[],
        'friends': <Map<String, dynamic>>[],
      };
    }

    try {
      final results = await Future.wait([
        searchUsers(query),
        searchConversations(query),
        searchFriends(query),
      ]);

      return {
        'users': results[0],
        'conversations': results[1],
        'friends': results[2],
      };
    } catch (e) {
      print('Error in searchAll: $e');
      return {
        'users': <UserModel>[],
        'conversations': <Map<String, dynamic>>[],
        'friends': <Map<String, dynamic>>[],
      };
    }
  }
}
