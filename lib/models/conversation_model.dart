class ConversationModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> participantIds;
  final String? lastMessageText;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final String? name;
  final String? avatarUrl;
  final String? createdBy;
  final String? description;

  ConversationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.participantIds = const [],
    this.lastMessageText,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
    this.name,
    this.avatarUrl,
    this.createdBy,
    this.description,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participantIds: json['participant_ids'] != null
          ? List<String>.from(json['participant_ids'] as List)
          : [],
      lastMessageText: json['last_message_text'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isGroup: json['is_group'] as bool? ?? false,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdBy: json['created_by'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participant_ids': participantIds,
      'last_message_text': lastMessageText,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
      'is_group': isGroup,
      'name': name,
      'avatar_url': avatarUrl,
      'created_by': createdBy,
      'description': description,
    };
  }

  ConversationModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? participantIds,
    String? lastMessageText,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isGroup,
    String? name,
    String? avatarUrl,
    String? createdBy,
    String? description,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participantIds: participantIds ?? this.participantIds,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      description: description ?? this.description,
    );
  }
}
