class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String type; // 'text', 'image', 'video', 'audio', 'file'
  final String? mediaUrl;
  final int? duration; // For audio/video messages in seconds
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? senderAvatar;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.mediaUrl,
    this.duration,
    required this.createdAt,
    this.isRead = false,
    this.senderName,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      senderName: json['sender']?['full_name'] as String?,
      senderAvatar: json['sender']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
      'type': type,
      'media_url': mediaUrl,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    String? type,
    String? mediaUrl,
    int? duration,
    DateTime? createdAt,
    bool? isRead,
    String? senderName,
    String? senderAvatar,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  bool get isSentByMe {
    // This will be determined by comparing senderId with current user ID
    return false; // Placeholder
  }
}
