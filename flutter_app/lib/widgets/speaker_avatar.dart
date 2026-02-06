/// Speaker avatar widget for displaying speaker icons
library;

import 'package:flutter/material.dart';

import '../models/models.dart';

class SpeakerAvatar extends StatelessWidget {
  final Speaker speaker;
  final double size;
  final bool showBadge;
  final bool isSelected;

  const SpeakerAvatar({
    super.key,
    required this.speaker,
    this.size = 40,
    this.showBadge = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = speaker.color;

    return Semantics(
      label: speaker.effectiveName,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                _getInitials(speaker.effectiveName),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ),
            if (showBadge && speaker.isUser)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: size * 0.25,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Row of speaker avatars with overlap
class SpeakerAvatarStack extends StatelessWidget {
  final List<Speaker> speakers;
  final double size;
  final int maxDisplayed;
  final double overlap;

  const SpeakerAvatarStack({
    super.key,
    required this.speakers,
    this.size = 32,
    this.maxDisplayed = 4,
    this.overlap = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final displayedSpeakers = speakers.take(maxDisplayed).toList();
    final remainingCount = speakers.length - maxDisplayed;
    final offsetAmount = size * (1 - overlap);

    return SizedBox(
      height: size,
      width: offsetAmount * displayedSpeakers.length +
          size * overlap +
          (remainingCount > 0 ? size * 0.8 : 0),
      child: Stack(
        children: [
          ...displayedSpeakers.asMap().entries.map((entry) {
            return Positioned(
              left: entry.key * offsetAmount,
              child: SpeakerAvatar(
                speaker: entry.value,
                size: size,
              ),
            );
          }),
          if (remainingCount > 0)
            Positioned(
              left: displayedSpeakers.length * offsetAmount,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Speaker chip for selection
class SpeakerChip extends StatelessWidget {
  final Speaker speaker;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SpeakerChip({
    super.key,
    required this.speaker,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = speaker.color;

    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          speaker.effectiveName.isNotEmpty
              ? speaker.effectiveName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
      label: Text(speaker.effectiveName),
      backgroundColor:
          isSelected ? color.withValues(alpha: 0.2) : null,
      side: isSelected
          ? BorderSide(color: color, width: 2)
          : null,
      onPressed: onTap,
    );
  }
}
