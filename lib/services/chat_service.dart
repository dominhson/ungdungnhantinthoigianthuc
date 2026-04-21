import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  
  // Expose supabase client for external access
  SupabaseClient get supabase => _supabase;

  // Get all conversations for current user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final response = await _supabase
        .from('conversation_participants')
        .select('''
          conversation_id,
          unread_count,
          conversations!inner(
            id,
            created_at,
            updated_at
          )
        ''')
        .eq('user_id', userId)
        .order('updated_at', referencedTable: 'conversations', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
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

  // Send a message with broadcast
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    int? duration,
  }) async {
    final message = {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
      'type': type,
      'media_url': mediaUrl,
      'duration': duration,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from('messages')
        .insert(message)
        .select()
        .single();

    // Update conversation updated_at
    await _supabase
        .from('conversations')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', conversationId);

    // Broadcast using existing channel
    final shortId = conversationId.replaceAll('-', '').substring(0, 8);
    final topic = 'c:$shortId';
    
    final channel = _channels[topic];
    if (channel != null) {
      try {
        await channel.sendBroadcastMessage(
          event: 'msg',
          payload: {'id': response['id']},
        );
      } catch (e) {
        print('Broadcast error: $e');
      }
    }

    return response;
  }

  // Create a new conversation
  Future<String> createConversation(List<String> participantIds) async {
    // Create conversation
    final conversation = await _supabase
        .from('conversations')
        .insert({
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final conversationId = conversation['id'];

    // Add participants
    final participants = participantIds.map((userId) => {
      'conversation_id': conversationId,
      'user_id': userId,
      'joined_at': DateTime.now().toIso8601String(),
    }).toList();

    await _supabase.from('conversation_participants').insert(participants);

    return conversationId;
  }

  // Mark messages as read
  Future<void> markAsRead(String messageId, String userId) async {
    await _supabase.from('message_reads').insert({
      'message_id': messageId,
      'user_id': userId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  // Update typing indicator
  Future<void> updateTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _supabase.from('typing_indicators').upsert(
        {
          'conversation_id': conversationId,
          'user_id': userId,
          'is_typing': isTyping,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'conversation_id,user_id',
      );
    } catch (e) {
      // Ignore typing indicator errors
      print('Typing indicator error: $e');
    }
  }

  // Subscribe to new messages using Broadcast (short topic)
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    // Ultra-short topic: c:<first_8_chars>
    final shortId = conversationId.replaceAll('-', '').substring(0, 8);
    final topic = 'c:$shortId';
    
    // Reuse existing channel if available
    if (_channels.containsKey(topic)) {
      return _channels[topic]!;
    }
    
    final channel = _supabase
        .channel(topic)
        .onBroadcast(
          event: 'msg',
          callback: (payload) {
            print('🔔 Broadcast received!');
            onMessage(payload);
          },
        )
        .subscribe((status, error) {
          print('📡 Status: $status');
          if (error != null) print('❌ Error: $error');
        });
    
    // Store channel for reuse
    _channels[topic] = channel;
    
    return channel;
  }

  // Subscribe to typing indicators
  RealtimeChannel subscribeToTyping(
    String conversationId,
    void Function(Map<String, dynamic>) onTyping,
  ) {
    // Short topic for typing
    final shortId = conversationId.replaceAll('-', '').substring(0, 8);
    
    return _supabase
        .channel('t:$shortId')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            onTyping(payload);
          },
        )
        .subscribe();
  }

  // Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    // Remove from cache
    _channels.removeWhere((key, value) => value == channel);
    await _supabase.removeChannel(channel);
  }
}
