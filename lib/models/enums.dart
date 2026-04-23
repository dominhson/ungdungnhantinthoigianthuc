/// Enums for media file sharing functionality

/// Enum representing different types of messages in the chat
enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  file;

  /// Convert enum to string for database storage
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
      case MessageType.document:
        return 'document';
      case MessageType.file:
        return 'file';
    }
  }

  /// Create enum from string value
  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'document':
        return MessageType.document;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  /// Check if message type is media (non-text)
  bool get isMedia => this != MessageType.text;

  /// Check if message type supports thumbnails
  bool get supportsThumbnails => 
      this == MessageType.image || this == MessageType.video;

  /// Check if message type supports duration
  bool get supportsDuration => 
      this == MessageType.video || this == MessageType.audio;
}

/// Enum representing the upload status of media files
enum UploadStatus {
  pending,
  uploading,
  processing,
  completed,
  failed,
  cancelled;

  /// Convert enum to string for database storage
  String get value {
    switch (this) {
      case UploadStatus.pending:
        return 'pending';
      case UploadStatus.uploading:
        return 'uploading';
      case UploadStatus.processing:
        return 'processing';
      case UploadStatus.completed:
        return 'completed';
      case UploadStatus.failed:
        return 'failed';
      case UploadStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Create enum from string value
  static UploadStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return UploadStatus.pending;
      case 'uploading':
        return UploadStatus.uploading;
      case 'processing':
        return UploadStatus.processing;
      case 'completed':
        return UploadStatus.completed;
      case 'failed':
        return UploadStatus.failed;
      case 'cancelled':
        return UploadStatus.cancelled;
      default:
        return UploadStatus.pending;
    }
  }

  /// Check if upload is in progress
  bool get isInProgress => 
      this == UploadStatus.pending || 
      this == UploadStatus.uploading || 
      this == UploadStatus.processing;

  /// Check if upload is complete
  bool get isComplete => this == UploadStatus.completed;

  /// Check if upload has failed
  bool get hasFailed => 
      this == UploadStatus.failed || this == UploadStatus.cancelled;
}

/// Enum representing different quality levels for media files
enum MediaQuality {
  thumbnail,
  medium,
  original;

  /// Convert enum to string for database storage
  String get value {
    switch (this) {
      case MediaQuality.thumbnail:
        return 'thumbnail';
      case MediaQuality.medium:
        return 'medium';
      case MediaQuality.original:
        return 'original';
    }
  }

  /// Create enum from string value
  static MediaQuality fromString(String value) {
    switch (value.toLowerCase()) {
      case 'thumbnail':
        return MediaQuality.thumbnail;
      case 'medium':
        return MediaQuality.medium;
      case 'original':
        return MediaQuality.original;
      default:
        return MediaQuality.original;
    }
  }

  /// Get maximum dimensions for this quality level
  Map<String, int> get maxDimensions {
    switch (this) {
      case MediaQuality.thumbnail:
        return {'width': 200, 'height': 200};
      case MediaQuality.medium:
        return {'width': 800, 'height': 800};
      case MediaQuality.original:
        return {'width': -1, 'height': -1}; // No limit
    }
  }

  /// Get file size suffix for storage organization
  String get suffix {
    switch (this) {
      case MediaQuality.thumbnail:
        return '_thumb';
      case MediaQuality.medium:
        return '_medium';
      case MediaQuality.original:
        return '';
    }
  }
}