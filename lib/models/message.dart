class Message {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isSentByMe;
  final DateTime timestamp;
  final bool isRead;
  final String senderName;
  final String senderAvatar;

  Message({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.isSentByMe,
    required this.timestamp,
    this.isRead = false,
    required this.senderName,
    required this.senderAvatar,
  });
}
