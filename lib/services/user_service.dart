import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Timer? _heartbeatTimer;

  // Start heartbeat to keep online status updated
  void startOnlineStatusHeartbeat() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Update status immediately
    updateOnlineStatus(userId, true);

    // Update every 30 seconds
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId != null) {
        updateOnlineStatus(currentUserId, true);
      } else {
        timer.cancel();
      }
    });
  }

  // Stop heartbeat
  void stopOnlineStatusHeartbeat() {
    _heartbeatTimer?.cancel();
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      updateOnlineStatus(userId, false);
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    return response;
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

    await _supabase.from('users').update(updates).eq('id', userId);
  }

  // Update online status
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _supabase.from('users').update({
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await _supabase
        .from('users')
        .select()
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get multiple users by IDs
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> userIds) async {
    final response = await _supabase
        .from('users')
        .select()
        .inFilter('id', userIds);
    return List<Map<String, dynamic>>.from(response);
  }
}
