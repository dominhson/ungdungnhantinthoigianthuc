// Group member model
class GroupMember {
  final String userId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final bool isOnline;
  final String role; // 'admin', 'moderator', 'member'
  final DateTime joinedAt;

  GroupMember({
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.isOnline,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get canModerate => isAdmin || isModerator;
}

// Group settings model
class GroupSettings {
  final String id;
  final String conversationId;
  final bool onlyAdminsCanSend;
  final bool onlyAdminsCanAddMembers;
  final bool onlyAdminsCanEditInfo;
  final bool allowMemberToLeave;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupSettings({
    required this.id,
    required this.conversationId,
    this.onlyAdminsCanSend = false,
    this.onlyAdminsCanAddMembers = false,
    this.onlyAdminsCanEditInfo = false,
    this.allowMemberToLeave = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupSettings.fromJson(Map<String, dynamic> json) {
    return GroupSettings(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      onlyAdminsCanSend: json['only_admins_can_send'] as bool? ?? false,
      onlyAdminsCanAddMembers: json['only_admins_can_add_members'] as bool? ?? false,
      onlyAdminsCanEditInfo: json['only_admins_can_edit_info'] as bool? ?? false,
      allowMemberToLeave: json['allow_member_to_leave'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'only_admins_can_send': onlyAdminsCanSend,
      'only_admins_can_add_members': onlyAdminsCanAddMembers,
      'only_admins_can_edit_info': onlyAdminsCanEditInfo,
      'allow_member_to_leave': allowMemberToLeave,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GroupSettings copyWith({
    String? id,
    String? conversationId,
    bool? onlyAdminsCanSend,
    bool? onlyAdminsCanAddMembers,
    bool? onlyAdminsCanEditInfo,
    bool? allowMemberToLeave,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupSettings(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      onlyAdminsCanSend: onlyAdminsCanSend ?? this.onlyAdminsCanSend,
      onlyAdminsCanAddMembers: onlyAdminsCanAddMembers ?? this.onlyAdminsCanAddMembers,
      onlyAdminsCanEditInfo: onlyAdminsCanEditInfo ?? this.onlyAdminsCanEditInfo,
      allowMemberToLeave: allowMemberToLeave ?? this.allowMemberToLeave,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
