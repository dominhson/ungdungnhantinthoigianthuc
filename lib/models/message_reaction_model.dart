class MessageReactionModel {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  MessageReactionModel({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user']?['full_name'] as String?,
      userAvatar: json['user']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageReactionModel copyWith({
    String? id,
    String? messageId,
    String? userId,
    String? emoji,
    DateTime? createdAt,
    String? userName,
    String? userAvatar,
  }) {
    return MessageReactionModel(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageReactionModel &&
        other.id == id &&
        other.messageId == messageId &&
        other.userId == userId &&
        other.emoji == emoji;
  }

  @override
  int get hashCode {
    return Object.hash(id, messageId, userId, emoji);
  }

  @override
  String toString() {
    return 'MessageReactionModel(id: $id, emoji: $emoji, userId: $userId)';
  }
}

/// Aggregated reaction data for display
class ReactionSummary {
  final String emoji;
  final int count;
  final List<String> userIds;
  final bool hasCurrentUser;

  ReactionSummary({
    required this.emoji,
    required this.count,
    required this.userIds,
    required this.hasCurrentUser,
  });

  factory ReactionSummary.fromReactions(
    String emoji,
    List<MessageReactionModel> reactions,
    String currentUserId,
  ) {
    final userIds = reactions.map((r) => r.userId).toList();
    return ReactionSummary(
      emoji: emoji,
      count: reactions.length,
      userIds: userIds,
      hasCurrentUser: userIds.contains(currentUserId),
    );
  }

  @override
  String toString() {
    return 'ReactionSummary(emoji: $emoji, count: $count, hasCurrentUser: $hasCurrentUser)';
  }
}
