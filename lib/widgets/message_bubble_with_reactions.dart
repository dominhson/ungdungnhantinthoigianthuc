import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/message_reaction_model.dart';
import '../services/reaction_service.dart';
import 'reaction_picker.dart';

class MessageBubbleWithReactions extends StatefulWidget {
  final MessageModel message;
  final String currentUserId;
  final bool isSentByMe;

  const MessageBubbleWithReactions({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isSentByMe,
  });

  @override
  State<MessageBubbleWithReactions> createState() => _MessageBubbleWithReactionsState();
}

class _MessageBubbleWithReactionsState extends State<MessageBubbleWithReactions> {
  final _reactionService = ReactionService();
  List<ReactionSummary> _reactions = [];
  bool _showReactionPicker = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    try {
      final reactions = await _reactionService.getReactionSummaries(
        widget.message.id,
        widget.currentUserId,
      );
      if (mounted) {
        setState(() => _reactions = reactions);
      }
    } catch (e) {
      debugPrint('Error loading reactions: $e');
    }
  }

  Future<void> _handleReactionTap(String emoji) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _showReactionPicker = false;
    });

    try {
      await _reactionService.toggleReaction(
        messageId: widget.message.id,
        userId: widget.currentUserId,
        emoji: emoji,
      );
      await _loadReactions();
    } catch (e) {
      debugPrint('Error toggling reaction: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể thêm reaction: $e'),
            backgroundColor: const Color(0xFF93000a),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => _showReactionPicker = !_showReactionPicker);
      },
      child: Column(
        crossAxisAlignment: widget.isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isSentByMe
                  ? const Color(0xFF3b82f6)
                  : const Color(0xFF1c212b),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isSentByMe && widget.message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.message.senderName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94a3b8),
                      ),
                    ),
                  ),
                Text(
                  widget.message.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFe1e2eb),
                  ),
                ),
              ],
            ),
          ),

          // Reactions display
          if (_reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ..._reactions.map((reaction) => ReactionDisplay(
                        emoji: reaction.emoji,
                        count: reaction.count,
                        hasCurrentUser: reaction.hasCurrentUser,
                        onTap: () => _handleReactionTap(reaction.emoji),
                      )),
                  ReactionButton(
                    onPressed: () {
                      setState(() => _showReactionPicker = !_showReactionPicker);
                    },
                    isActive: _showReactionPicker,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ReactionButton(
                onPressed: () {
                  setState(() => _showReactionPicker = !_showReactionPicker);
                },
                isActive: _showReactionPicker,
              ),
            ),

          // Reaction picker
          if (_showReactionPicker)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ReactionPicker(
                onEmojiSelected: _handleReactionTap,
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(widget.message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF94a3b8).withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m trước';
    } else {
      return 'Vừa xong';
    }
  }
}
