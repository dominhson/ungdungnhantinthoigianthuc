import 'dart:typed_data';
import 'enums.dart';

/// Model representing a media file for upload and processing
class MediaFile {
  /// Local file path on the device
  final String path;
  
  /// Original file name
  final String name;
  
  /// File size in bytes
  final int size;
  
  /// MIME type of the file
  final String mimeType;
  
  /// Message type derived from MIME type
  final MessageType type;
  
  /// Thumbnail data for preview (if available)
  final Uint8List? thumbnailData;
  
  /// Additional metadata extracted from the file
  final Map<String, dynamic>? metadata;
  
  /// User-provided caption for the media
  final String? caption;
  
  /// Unique identifier for tracking uploads
  final String? uploadId;

  const MediaFile({
    required this.path,
    required this.name,
    required this.size,
    required this.mimeType,
    required this.type,
    this.thumbnailData,
    this.metadata,
    this.caption,
    this.uploadId,
  });

  /// Create MediaFile from basic file information
  factory MediaFile.fromPath({
    required String path,
    required String name,
    required int size,
    required String mimeType,
    Uint8List? thumbnailData,
    Map<String, dynamic>? metadata,
    String? caption,
    String? uploadId,
  }) {
    return MediaFile(
      path: path,
      name: name,
      size: size,
      mimeType: mimeType,
      type: _getMessageTypeFromMimeType(mimeType),
      thumbnailData: thumbnailData,
      metadata: metadata,
      caption: caption,
      uploadId: uploadId,
    );
  }

  /// Create MediaFile from JSON (for serialization)
  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      path: json['path'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      mimeType: json['mime_type'] as String,
      type: MessageType.fromString(json['type'] as String),
      thumbnailData: json['thumbnail_data'] != null 
          ? Uint8List.fromList((json['thumbnail_data'] as List).cast<int>())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      caption: json['caption'] as String?,
      uploadId: json['upload_id'] as String?,
    );
  }

  /// Convert MediaFile to JSON (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'mime_type': mimeType,
      'type': type.value,
      'thumbnail_data': thumbnailData?.toList(),
      'metadata': metadata,
      'caption': caption,
      'upload_id': uploadId,
    };
  }

  /// Create a copy with updated fields
  MediaFile copyWith({
    String? path,
    String? name,
    int? size,
    String? mimeType,
    MessageType? type,
    Uint8List? thumbnailData,
    Map<String, dynamic>? metadata,
    String? caption,
    String? uploadId,
  }) {
    return MediaFile(
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      thumbnailData: thumbnailData ?? this.thumbnailData,
      metadata: metadata ?? this.metadata,
      caption: caption ?? this.caption,
      uploadId: uploadId ?? this.uploadId,
    );
  }

  /// Get the message type from MIME type
  static MessageType _getMessageTypeFromMimeType(String mimeType) {
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
  static bool _isDocumentMimeType(String mimeType) {
    const documentMimeTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'application/zip',
    ];
    return documentMimeTypes.contains(mimeType);
  }

  /// Get file extension from name or MIME type
  String get fileExtension {
    // First try to get from file name
    final lastDot = name.lastIndexOf('.');
    if (lastDot != -1) {
      return name.substring(lastDot);
    }

    // Fallback to MIME type mapping
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
      case 'application/zip':
        return '.zip';
      default:
        return '';
    }
  }

  /// Get human-readable file size
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file is an image
  bool get isImage => type == MessageType.image;

  /// Check if file is a video
  bool get isVideo => type == MessageType.video;

  /// Check if file is audio
  bool get isAudio => type == MessageType.audio;

  /// Check if file is a document
  bool get isDocument => type == MessageType.document;

  /// Check if file supports thumbnails
  bool get supportsThumbnails => isImage || isVideo;

  /// Check if file supports duration metadata
  bool get supportsDuration => isVideo || isAudio;

  /// Get image dimensions from metadata
  Map<String, int>? get dimensions {
    if (metadata == null) return null;
    
    final width = metadata!['width'] as int?;
    final height = metadata!['height'] as int?;
    
    if (width != null && height != null) {
      return {'width': width, 'height': height};
    }
    return null;
  }

  /// Get duration from metadata (in seconds)
  int? get duration {
    if (metadata == null) return null;
    return metadata!['duration'] as int?;
  }

  /// Check if the file has a thumbnail
  bool get hasThumbnail => thumbnailData != null && thumbnailData!.isNotEmpty;

  /// Validate file type against supported formats
  bool get isValidType {
    switch (type) {
      case MessageType.image:
        return _isValidImageType();
      case MessageType.video:
        return _isValidVideoType();
      case MessageType.audio:
        return _isValidAudioType();
      case MessageType.document:
        return _isValidDocumentType();
      case MessageType.file:
        return true; // Allow all file types for generic files
      case MessageType.text:
        return false; // Text messages don't have files
    }
  }

  /// Check if image type is supported
  bool _isValidImageType() {
    const supportedImageTypes = [
      'image/jpeg',
      'image/png',
      'image/gif',
      'image/webp',
    ];
    return supportedImageTypes.contains(mimeType);
  }

  /// Check if video type is supported
  bool _isValidVideoType() {
    const supportedVideoTypes = [
      'video/mp4',
      'video/quicktime',
      'video/x-msvideo',
      'video/webm',
    ];
    return supportedVideoTypes.contains(mimeType);
  }

  /// Check if audio type is supported
  bool _isValidAudioType() {
    const supportedAudioTypes = [
      'audio/mpeg',
      'audio/wav',
      'audio/mp4',
      'audio/aac',
    ];
    return supportedAudioTypes.contains(mimeType);
  }

  /// Check if document type is supported
  bool _isValidDocumentType() {
    const supportedDocumentTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'application/zip',
    ];
    return supportedDocumentTypes.contains(mimeType);
  }

  /// Validate file size against type-specific limits
  bool get isValidSize {
    switch (type) {
      case MessageType.image:
        return size <= 10 * 1024 * 1024; // 10MB for images
      case MessageType.video:
        return size <= 50 * 1024 * 1024; // 50MB for videos
      case MessageType.audio:
        return size <= 25 * 1024 * 1024; // 25MB for audio
      case MessageType.document:
      case MessageType.file:
        return size <= 50 * 1024 * 1024; // 50MB for documents and files
      case MessageType.text:
        return false; // Text messages don't have files
    }
  }

  @override
  String toString() {
    return 'MediaFile(name: $name, size: $formattedSize, type: ${type.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaFile &&
        other.path == path &&
        other.name == name &&
        other.size == size &&
        other.mimeType == mimeType &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(path, name, size, mimeType, type);
  }
}