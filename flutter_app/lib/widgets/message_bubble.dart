/// Message bubble widget for displaying conversation messages

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/accessibility_utils.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Speaker? speaker;
  final bool showSpeakerName;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.speaker,
    this.showSpeakerName = true,
    this.isHighlighted = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final speakerColor = speaker?.color != null
        ? Color(int.parse(speaker!.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).primaryColor;

    final isUser = speaker?.isUser ?? false;

    return Semantics(
      label:
          '${speaker?.effectiveName ?? "Unknown"} said: ${message.content}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              _SpeakerAvatar(
                name: speaker?.effectiveName ?? '?',
                color: speakerColor,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: GestureDetector(
                onTap: onTap,
                onLongPress: onLongPress,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? speakerColor
                        : speakerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          isUser ? const Radius.circular(16) : Radius.zero,
                      bottomRight:
                          isUser ? Radius.zero : const Radius.circular(16),
                    ),
                    border: isHighlighted
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSpeakerName && !isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            speaker?.effectiveName ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: speakerColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (message.timestamp != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatTime(message.timestamp!),
                            style: TextStyle(
                              fontSize: 10,
                              color: isUser
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              _SpeakerAvatar(
                name: speaker?.effectiveName ?? 'Me',
                color: speakerColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SpeakerAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _SpeakerAvatar({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Compact message bubble for previews
class CompactMessageBubble extends StatelessWidget {
  final String content;
  final String? speakerName;
  final Color? color;

  const CompactMessageBubble({
    super.key,
    required this.content,
    this.speakerName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = color ?? Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bubbleColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (speakerName != null)
            Text(
              speakerName!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bubbleColor,
                fontSize: 11,
              ),
            ),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
