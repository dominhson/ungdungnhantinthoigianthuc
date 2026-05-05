class Message {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isSentByMe;
  final DateTime timestamp;
  final bool isRead;
  final String senderName;
  final String senderAvatar;
  final String senderId;
  final bool isEdited;
  final bool isDeleted;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSenderName;
  final List<MessageReaction> reactions;

  Message({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.isSentByMe,
    required this.timestamp,
    this.isRead = false,
    required this.senderName,
    required this.senderAvatar,
    required this.senderId,
    this.isEdited = false,
    this.isDeleted = false,
    this.editedAt,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderName,
    this.reactions = const [],
  });

  Message copyWith({
    String? id,
    String? text,
    String? imageUrl,
    bool? isSentByMe,
    DateTime? timestamp,
    bool? isRead,
    String? senderName,
    String? senderAvatar,
    String? senderId,
    bool? isEdited,
    bool? isDeleted,
    DateTime? editedAt,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderName,
    List<MessageReaction>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      senderId: senderId ?? this.senderId,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      reactions: reactions ?? this.reactions,
    );
  }
}

class MessageReaction {
  final String emoji;
  final int count;
  final List<String> userIds;

  MessageReaction({
    required this.emoji,
    required this.count,
    required this.userIds,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] as String,
      count: json['count'] as int,
      userIds: (json['users'] as List).map((e) => e.toString()).toList(),
    );
  }
}
