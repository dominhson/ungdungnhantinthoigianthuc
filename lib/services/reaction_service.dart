import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_reaction_model.dart';

class ReactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Add a reaction to a message
  Future<MessageReactionModel> addReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    // Check if user already reacted with this emoji
    final existing = await _supabase
        .from('message_reactions')
        .select()
        .eq('message_id', messageId)
        .eq('user_id', userId)
        .eq('emoji', emoji)
        .maybeSingle();

    if (existing != null) {
      // Already reacted, return existing
      return MessageReactionModel.fromJson(existing);
    }

    // Add new reaction
    final response = await _supabase
        .from('message_reactions')
        .insert({
          'message_id': messageId,
          'user_id': userId,
          'emoji': emoji,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('''
          *,
          user:users!user_id(id, full_name, avatar_url)
        ''')
        .single();

    return MessageReactionModel.fromJson(response);
  }

  /// Remove a reaction from a message
  Future<void> removeReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _supabase
        .from('message_reactions')
        .delete()
        .eq('message_id', messageId)
        .eq('user_id', userId)
        .eq('emoji', emoji);
  }

  /// Toggle reaction (add if not exists, remove if exists)
  Future<bool> toggleReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    // Check if reaction exists
    final existing = await _supabase
        .from('message_reactions')
        .select()
        .eq('message_id', messageId)
        .eq('user_id', userId)
        .eq('emoji', emoji)
        .maybeSingle();

    if (existing != null) {
      // Remove reaction
      await removeReaction(
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return false; // Removed
    } else {
      // Add reaction
      await addReaction(
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return true; // Added
    }
  }

  /// Get all reactions for a message
  Future<List<MessageReactionModel>> getReactions(String messageId) async {
    final response = await _supabase
        .from('message_reactions')
        .select('''
          *,
          user:users!user_id(id, full_name, avatar_url)
        ''')
        .eq('message_id', messageId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => MessageReactionModel.fromJson(json))
        .toList();
  }

  /// Get reactions grouped by emoji
  Future<Map<String, List<MessageReactionModel>>> getReactionsGrouped(
    String messageId,
  ) async {
    final reactions = await getReactions(messageId);
    final Map<String, List<MessageReactionModel>> grouped = {};

    for (final reaction in reactions) {
      if (!grouped.containsKey(reaction.emoji)) {
        grouped[reaction.emoji] = [];
      }
      grouped[reaction.emoji]!.add(reaction);
    }

    return grouped;
  }

  /// Get reaction summaries for a message
  Future<List<ReactionSummary>> getReactionSummaries(
    String messageId,
    String currentUserId,
  ) async {
    final grouped = await getReactionsGrouped(messageId);
    
    return grouped.entries
        .map((entry) => ReactionSummary.fromReactions(
              entry.key,
              entry.value,
              currentUserId,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count)); // Sort by count descending
  }

  /// Subscribe to reactions for a message
  RealtimeChannel subscribeToReactions(
    String messageId,
    void Function(MessageReactionModel) onReactionAdded,
    void Function(String reactionId) onReactionRemoved,
  ) {
    return _supabase
        .channel('reactions:$messageId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'message_reactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'message_id',
            value: messageId,
          ),
          callback: (payload) {
            final reaction = MessageReactionModel.fromJson(payload.newRecord);
            onReactionAdded(reaction);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'message_reactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'message_id',
            value: messageId,
          ),
          callback: (payload) {
            final reactionId = payload.oldRecord['id'] as String;
            onReactionRemoved(reactionId);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from reactions
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
