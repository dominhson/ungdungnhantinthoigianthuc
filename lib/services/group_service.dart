import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';

class GroupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new group
  Future<String> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatarUrl,
    String? description,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Create conversation
    final conversation = await _supabase
        .from('conversations')
        .insert({
          'name': name,
          'avatar_url': avatarUrl,
          'description': description,
          'is_group': true,
          'created_by': currentUserId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final conversationId = conversation['id'];

    // Add creator as admin
    final participants = [
      {
        'conversation_id': conversationId,
        'user_id': currentUserId,
        'role': 'admin',
        'joined_at': DateTime.now().toIso8601String(),
      }
    ];

    // Add other members
    for (final memberId in memberIds) {
      if (memberId != currentUserId) {
        participants.add({
          'conversation_id': conversationId,
          'user_id': memberId,
          'role': 'member',
          'joined_at': DateTime.now().toIso8601String(),
        });
      }
    }

    await _supabase.from('conversation_participants').insert(participants);

    // Create default group settings
    await _supabase.from('group_settings').insert({
      'conversation_id': conversationId,
      'only_admins_can_send': false,
      'only_admins_can_add_members': false,
      'only_admins_can_edit_info': false,
      'allow_member_to_leave': true,
    });

    return conversationId;
  }

  // Get group members
  Future<List<GroupMember>> getGroupMembers(String conversationId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase.rpc('get_group_members', params: {
        'conversation_id_param': conversationId,
        'current_user_id': currentUserId,
      });

      return (response as List)
          .map((json) => GroupMember.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback if RPC doesn't exist
      final response = await _supabase
          .from('conversation_participants')
          .select('''
            user_id,
            role,
            joined_at,
            users!user_id(
              id,
              full_name,
              email,
              avatar_url,
              is_online
            )
          ''')
          .eq('conversation_id', conversationId);

      return (response as List).map((json) {
        final user = json['users'] as Map<String, dynamic>;
        return GroupMember(
          userId: json['user_id'],
          fullName: user['full_name'],
          email: user['email'],
          avatarUrl: user['avatar_url'],
          isOnline: user['is_online'] ?? false,
          role: json['role'],
          joinedAt: DateTime.parse(json['joined_at']),
        );
      }).toList();
    }
  }

  // Add members to group
  Future<void> addMembers({
    required String conversationId,
    required List<String> memberIds,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if current user has permission
    final settings = await getGroupSettings(conversationId);
    final currentMember = await _getMemberRole(conversationId, currentUserId);

    if (settings.onlyAdminsCanAddMembers && currentMember?.role != 'admin') {
      throw Exception('Only admins can add members');
    }

    final participants = memberIds.map((memberId) => {
      'conversation_id': conversationId,
      'user_id': memberId,
      'role': 'member',
      'joined_at': DateTime.now().toIso8601String(),
    }).toList();

    await _supabase.from('conversation_participants').insert(participants);
  }

  // Remove member from group
  Future<void> removeMember({
    required String conversationId,
    required String memberId,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final currentMember = await _getMemberRole(conversationId, currentUserId);
    if (currentMember?.role != 'admin') {
      throw Exception('Only admins can remove members');
    }

    await _supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', memberId);
  }

  // Leave group
  Future<void> leaveGroup(String conversationId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final settings = await getGroupSettings(conversationId);
    if (!settings.allowMemberToLeave) {
      throw Exception('Members are not allowed to leave this group');
    }

    await _supabase
        .from('conversation_participants')
        .delete()
        .eq('conversation_id', conversationId)
        .eq('user_id', currentUserId);
  }

  // Update member role
  Future<void> updateMemberRole({
    required String conversationId,
    required String memberId,
    required String newRole,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final currentMember = await _getMemberRole(conversationId, currentUserId);
    if (currentMember?.role != 'admin') {
      throw Exception('Only admins can change member roles');
    }

    await _supabase
        .from('conversation_participants')
        .update({'role': newRole})
        .eq('conversation_id', conversationId)
        .eq('user_id', memberId);
  }

  // Update group info
  Future<void> updateGroupInfo({
    required String conversationId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final settings = await getGroupSettings(conversationId);
    final currentMember = await _getMemberRole(conversationId, currentUserId);

    if (settings.onlyAdminsCanEditInfo && currentMember?.role != 'admin') {
      throw Exception('Only admins can edit group info');
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase
        .from('conversations')
        .update(updates)
        .eq('id', conversationId);
  }

  // Get group settings
  Future<GroupSettings> getGroupSettings(String conversationId) async {
    final response = await _supabase
        .from('group_settings')
        .select()
        .eq('conversation_id', conversationId)
        .maybeSingle();

    if (response == null) {
      // Create default settings if not exists
      final newSettings = await _supabase
          .from('group_settings')
          .insert({
            'conversation_id': conversationId,
            'only_admins_can_send': false,
            'only_admins_can_add_members': false,
            'only_admins_can_edit_info': false,
            'allow_member_to_leave': true,
          })
          .select()
          .single();
      return GroupSettings.fromJson(newSettings);
    }

    return GroupSettings.fromJson(response);
  }

  // Update group settings
  Future<void> updateGroupSettings({
    required String conversationId,
    bool? onlyAdminsCanSend,
    bool? onlyAdminsCanAddMembers,
    bool? onlyAdminsCanEditInfo,
    bool? allowMemberToLeave,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final currentMember = await _getMemberRole(conversationId, currentUserId);
    if (currentMember?.role != 'admin') {
      throw Exception('Only admins can update group settings');
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (onlyAdminsCanSend != null) {
      updates['only_admins_can_send'] = onlyAdminsCanSend;
    }
    if (onlyAdminsCanAddMembers != null) {
      updates['only_admins_can_add_members'] = onlyAdminsCanAddMembers;
    }
    if (onlyAdminsCanEditInfo != null) {
      updates['only_admins_can_edit_info'] = onlyAdminsCanEditInfo;
    }
    if (allowMemberToLeave != null) {
      updates['allow_member_to_leave'] = allowMemberToLeave;
    }

    await _supabase
        .from('group_settings')
        .update(updates)
        .eq('conversation_id', conversationId);
  }

  // Helper: Get member role
  Future<GroupMember?> _getMemberRole(
    String conversationId,
    String userId,
  ) async {
    final response = await _supabase
        .from('conversation_participants')
        .select('''
          user_id,
          role,
          joined_at,
          users!user_id(
            id,
            full_name,
            email,
            avatar_url,
            is_online
          )
        ''')
        .eq('conversation_id', conversationId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    final user = response['users'] as Map<String, dynamic>;
    return GroupMember(
      userId: response['user_id'],
      fullName: user['full_name'],
      email: user['email'],
      avatarUrl: user['avatar_url'],
      isOnline: user['is_online'] ?? false,
      role: response['role'],
      joinedAt: DateTime.parse(response['joined_at']),
    );
  }
}
