import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;
  final List<String> quickReactions;

  const ReactionPicker({
    super.key,
    required this.onEmojiSelected,
    this.quickReactions = const ['👍', '❤️', '😂', '😮', '😢', '😡', '🔥', '👏'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1c212b),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: quickReactions.map((emoji) {
          return _buildEmojiButton(emoji);
        }).toList(),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEmojiSelected(emoji),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class ReactionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const ReactionButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF3b82f6).withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF3b82f6).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.add_reaction_outlined,
            size: 18,
            color: isActive
                ? const Color(0xFF3b82f6)
                : const Color(0xFF94a3b8),
          ),
        ),
      ),
    );
  }
}

class ReactionDisplay extends StatelessWidget {
  final String emoji;
  final int count;
  final bool hasCurrentUser;
  final VoidCallback onTap;

  const ReactionDisplay({
    super.key,
    required this.emoji,
    required this.count,
    required this.hasCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasCurrentUser
                ? const Color(0xFF3b82f6).withValues(alpha: 0.2)
                : const Color(0xFF1c212b),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasCurrentUser
                  ? const Color(0xFF3b82f6).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasCurrentUser
                      ? const Color(0xFF3b82f6)
                      : const Color(0xFF94a3b8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
