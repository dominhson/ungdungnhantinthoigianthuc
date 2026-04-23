import 'enums.dart';

/// Model representing comprehensive metadata for media files
class MediaMetadata {
  /// URL to the original full-resolution file
  final String? originalUrl;
  
  /// URL to the thumbnail/preview image
  final String? thumbnailUrl;
  
  /// URL to the medium-resolution version (for images)
  final String? mediumUrl;
  
  /// Original file name as provided by user
  final String fileName;
  
  /// File size in bytes
  final int fileSize;
  
  /// MIME type of the file (e.g., 'image/jpeg', 'video/mp4')
  final String mimeType;
  
  /// Dimensions for images and videos (width, height)
  final Map<String, dynamic>? dimensions;
  
  /// Duration in seconds for audio/video files
  final int? duration;
  
  /// User-provided caption for the media
  final String? caption;
  
  /// Timestamp when the file was uploaded
  final DateTime uploadedAt;
  
  /// File checksum for integrity verification
  final String checksum;
  
  /// Additional metadata (EXIF data, etc.)
  final Map<String, dynamic>? additionalMetadata;

  const MediaMetadata({
    this.originalUrl,
    this.thumbnailUrl,
    this.mediumUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    this.dimensions,
    this.duration,
    this.caption,
    required this.uploadedAt,
    required this.checksum,
    this.additionalMetadata,
  });

  /// Create MediaMetadata from JSON
  factory MediaMetadata.fromJson(Map<String, dynamic> json) {
    return MediaMetadata(
      originalUrl: json['original_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediumUrl: json['medium_url'] as String?,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      duration: json['duration'] as int?,
      caption: json['caption'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      checksum: json['checksum'] as String,
      additionalMetadata: json['additional_metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert MediaMetadata to JSON
  Map<String, dynamic> toJson() {
    return {
      'original_url': originalUrl,
      'thumbnail_url': thumbnailUrl,
      'medium_url': mediumUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'dimensions': dimensions,
      'duration': duration,
      'caption': caption,
      'uploaded_at': uploadedAt.toIso8601String(),
      'checksum': checksum,
      'additional_metadata': additionalMetadata,
    };
  }

  /// Create a copy with updated fields
  MediaMetadata copyWith({
    String? originalUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    Map<String, dynamic>? dimensions,
    int? duration,
    String? caption,
    DateTime? uploadedAt,
    String? checksum,
    Map<String, dynamic>? additionalMetadata,
  }) {
    return MediaMetadata(
      originalUrl: originalUrl ?? this.originalUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      dimensions: dimensions ?? this.dimensions,
      duration: duration ?? this.duration,
      caption: caption ?? this.caption,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      checksum: checksum ?? this.checksum,
      additionalMetadata: additionalMetadata ?? this.additionalMetadata,
    );
  }

  /// Get the message type based on MIME type
  MessageType get messageType {
    if (mimeType.startsWith('image/')) {
      return MessageType.image;
    } else if (mimeType.startsWith('video/')) {
      return MessageType.video;
    } else if (mimeType.startsWith('audio/')) {
      return MessageType.audio;
    } else if (_isDocumentMimeType(mimeType)) {
      return MessageType.document;
    } else {
      return MessageType.file;
    }
  }

  /// Check if the MIME type represents a document
  bool _isDocumentMimeType(String mimeType) {
    const documentMimeTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
    ];
    return documentMimeTypes.contains(mimeType);
  }

  /// Get file extension from MIME type
  String get fileExtension {
    switch (mimeType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      case 'video/mp4':
        return '.mp4';
      case 'video/quicktime':
        return '.mov';
      case 'video/x-msvideo':
        return '.avi';
      case 'video/webm':
        return '.webm';
      case 'audio/mpeg':
        return '.mp3';
      case 'audio/wav':
        return '.wav';
      case 'application/pdf':
        return '.pdf';
      case 'application/msword':
        return '.doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return '.docx';
      case 'text/plain':
        return '.txt';
      default:
        // Extract from fileName if available
        final lastDot = fileName.lastIndexOf('.');
        return lastDot != -1 ? fileName.substring(lastDot) : '';
    }
  }

  /// Get human-readable file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get formatted duration for audio/video files
  String? get formattedDuration {
    if (duration == null) return null;
    
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get image dimensions as a formatted string
  String? get formattedDimensions {
    if (dimensions == null) return null;
    
    final width = dimensions!['width'];
    final height = dimensions!['height'];
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return null;
  }

  /// Check if the media has a thumbnail
  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  /// Check if the media has multiple resolutions
  bool get hasMultipleResolutions => 
      (originalUrl != null && originalUrl!.isNotEmpty) &&
      (mediumUrl != null && mediumUrl!.isNotEmpty);

  @override
  String toString() {
    return 'MediaMetadata(fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaMetadata &&
        other.originalUrl == originalUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.mediumUrl == mediumUrl &&
        other.fileName == fileName &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.checksum == checksum;
  }

  @override
  int get hashCode {
    return Object.hash(
      originalUrl,
      thumbnailUrl,
      mediumUrl,
      fileName,
      fileSize,
      mimeType,
      checksum,
    );
  }
}