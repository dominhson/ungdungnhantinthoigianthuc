import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageActionsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Delete message (soft delete)
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toIso8601String(),
            'text': 'Tin nhắn đã bị xóa',
            'media_url': null,
          })
          .eq('id', messageId);
      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  // Edit message
  Future<bool> editMessage(String messageId, String newText) async {
    try {
      await _supabase
          .from('messages')
          .update({
            'text': newText,
            'is_edited': true,
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
      return true;
    } catch (e) {
      debugPrint('Error editing message: $e');
      return false;
    }
  }

  // Add reaction to message
  Future<bool> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('message_reactions').insert({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding reaction: $e');
      return false;
    }
  }

  // Remove reaction from message
  Future<bool> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .eq('emoji', emoji);
      return true;
    } catch (e) {
      debugPrint('Error removing reaction: $e');
      return false;
    }
  }

  // Get reactions for a message
  Future<List<Map<String, dynamic>>> getReactions(String messageId) async {
    try {
      final response = await _supabase
          .from('message_reactions')
          .select('''
            *,
            user:users!user_id(id, full_name, avatar_url)
          ''')
          .eq('message_id', messageId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting reactions: $e');
      return [];
    }
  }

  // Get messages with replies and reactions
  Future<List<Map<String, dynamic>>> getMessagesWithReplies(
    String conversationId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'get_messages_with_replies',
        params: {'p_conversation_id': conversationId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting messages with replies: $e');
      // Fallback to regular messages query
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:users!sender_id(id, full_name, avatar_url)
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    }
  }

  // Check if user can edit/delete message
  bool canModifyMessage(String senderId) {
    final currentUserId = _supabase.auth.currentUser?.id;
    return currentUserId == senderId;
  }

  // Forward message to another conversation
  Future<bool> forwardMessage({
    required String messageId,
    required String toConversationId,
  }) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      // Get original message
      final originalMessage = await _supabase
          .from('messages')
          .select()
          .eq('id', messageId)
          .single();

      // Create new message in target conversation
      await _supabase.from('messages').insert({
        'conversation_id': toConversationId,
        'sender_id': currentUserId,
        'text': originalMessage['text'],
        'media_url': originalMessage['media_url'],
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error forwarding message: $e');
      return false;
    }
  }
}
