import 'enums.dart';
import 'media_metadata.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final MessageType type;
  final MediaMetadata? mediaMetadata;
  final UploadStatus uploadStatus;
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? senderAvatar;
  
  // Legacy fields for backward compatibility
  final String? mediaUrl;
  final int? duration;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.mediaMetadata,
    this.uploadStatus = UploadStatus.completed,
    required this.createdAt,
    this.isRead = false,
    this.senderName,
    this.senderAvatar,
    // Legacy fields
    this.mediaUrl,
    this.duration,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String? ?? '',
      type: json['type'] is String 
          ? MessageType.fromString(json['type'] as String)
          : MessageType.text,
      mediaMetadata: json['media_metadata'] != null
          ? MediaMetadata.fromJson(json['media_metadata'] as Map<String, dynamic>)
          : null,
      uploadStatus: json['upload_status'] is String
          ? UploadStatus.fromString(json['upload_status'] as String)
          : UploadStatus.completed,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      senderName: json['sender']?['full_name'] as String?,
      senderAvatar: json['sender']?['avatar_url'] as String?,
      // Legacy fields for backward compatibility
      mediaUrl: json['media_url'] as String?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
      'type': type.value,
      'media_metadata': mediaMetadata?.toJson(),
      'upload_status': uploadStatus.value,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      // Legacy fields for backward compatibility
      'media_url': mediaUrl ?? mediaMetadata?.originalUrl,
      'duration': duration ?? mediaMetadata?.duration,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    MessageType? type,
    MediaMetadata? mediaMetadata,
    UploadStatus? uploadStatus,
    DateTime? createdAt,
    bool? isRead,
    String? senderName,
    String? senderAvatar,
    // Legacy fields
    String? mediaUrl,
    int? duration,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaMetadata: mediaMetadata ?? this.mediaMetadata,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
    );
  }

  bool get isSentByMe {
    // This will be determined by comparing senderId with current user ID
    return false; // Placeholder
  }

  /// Check if this message contains media content
  bool get hasMedia => type != MessageType.text;

  /// Check if this message is currently uploading
  bool get isUploading => uploadStatus.isInProgress;

  /// Check if upload has completed successfully
  bool get isUploadComplete => uploadStatus.isComplete;

  /// Check if upload has failed
  bool get hasUploadFailed => uploadStatus.hasFailed;

  /// Get the primary media URL (original or fallback to legacy mediaUrl)
  String? get primaryMediaUrl => 
      mediaMetadata?.originalUrl ?? mediaUrl;

  /// Get the thumbnail URL if available
  String? get thumbnailUrl => mediaMetadata?.thumbnailUrl;

  /// Get the medium resolution URL if available
  String? get mediumUrl => mediaMetadata?.mediumUrl;

  /// Get the file name if available
  String? get fileName => mediaMetadata?.fileName;

  /// Get the file size if available
  int? get fileSize => mediaMetadata?.fileSize;

  /// Get the MIME type if available
  String? get mimeType => mediaMetadata?.mimeType;

  /// Get formatted file size
  String? get formattedFileSize => mediaMetadata?.formattedFileSize;

  /// Get formatted duration
  String? get formattedDuration => 
      mediaMetadata?.formattedDuration ?? 
      (duration != null ? _formatDuration(duration!) : null);

  /// Get media caption
  String? get caption => mediaMetadata?.caption;

  /// Check if message has a thumbnail
  bool get hasThumbnail => mediaMetadata?.hasThumbnail ?? false;

  /// Check if message supports thumbnails
  bool get supportsThumbnails => type.supportsThumbnails;

  /// Check if message supports duration
  bool get supportsDuration => type.supportsDuration;

  /// Format duration from seconds to MM:SS
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Create a media message from MediaFile
  factory MessageModel.fromMediaFile({
    required String id,
    required String conversationId,
    required String senderId,
    required MediaMetadata mediaMetadata,
    String text = '',
    UploadStatus uploadStatus = UploadStatus.pending,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatar,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      type: mediaMetadata.messageType,
      mediaMetadata: mediaMetadata,
      uploadStatus: uploadStatus,
      createdAt: createdAt ?? DateTime.now(),
      senderName: senderName,
      senderAvatar: senderAvatar,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, type: ${type.value}, text: $text, uploadStatus: ${uploadStatus.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.senderId == senderId &&
        other.text == text &&
        other.type == type &&
        other.uploadStatus == uploadStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      conversationId,
      senderId,
      text,
      type,
      uploadStatus,
    );
  }
}
