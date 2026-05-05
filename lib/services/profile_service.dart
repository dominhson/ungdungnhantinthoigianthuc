import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get real user stats
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Get friends count
      final friendsResponse = await _supabase
          .from('friends')
          .select('id')
          .eq('user_id', userId);
      final friendsCount = (friendsResponse as List).length;

      // Get groups count (conversations where is_group = true)
      final groupsResponse = await _supabase
          .from('conversation_participants')
          .select('''
            conversation_id,
            conversations!inner(is_group)
          ''')
          .eq('user_id', userId)
          .eq('conversations.is_group', true);
      final groupsCount = (groupsResponse as List).length;

      // Get messages count
      final messagesResponse = await _supabase
          .from('messages')
          .select('id')
          .eq('sender_id', userId);
      final messagesCount = (messagesResponse as List).length;

      return {
        'friends': friendsCount,
        'groups': groupsCount,
        'messages': messagesCount,
      };
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return {
        'friends': 0,
        'groups': 0,
        'messages': 0,
      };
    }
  }

  // Get user's groups
  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    try {
      final response = await _supabase
          .from('conversation_participants')
          .select('''
            conversation_id,
            role,
            conversations!inner(
              id,
              name,
              avatar_url,
              description,
              is_group,
              created_at
            )
          ''')
          .eq('user_id', userId)
          .eq('conversations.is_group', true)
          .order('created_at', referencedTable: 'conversations', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user groups: $e');
      return [];
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase
        .from('users')
        .update(updates)
        .eq('id', userId);
  }

  // Get notification settings (stored in local preferences for now)
  Future<Map<String, bool>> getNotificationSettings() async {
    // TODO: Implement with shared_preferences or database
    return {
      'messages': true,
      'friend_requests': true,
      'group_invites': true,
      'mentions': true,
    };
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    // TODO: Implement with shared_preferences or database
    debugPrint('Notification settings updated: $settings');
  }

  // Get theme preference
  Future<String> getThemePreference() async {
    // TODO: Implement with shared_preferences
    return 'dark'; // 'dark', 'light', 'system'
  }

  // Update theme preference
  Future<void> updateThemePreference(String theme) async {
    // TODO: Implement with shared_preferences
    debugPrint('Theme preference updated: $theme');
  }
}
