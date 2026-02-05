/// Health score badge widget for compact display

import 'package:flutter/material.dart';

class HealthScoreBadge extends StatelessWidget {
  final int score;
  final String? label;
  final bool showIcon;
  final double size;

  const HealthScoreBadge({
    super.key,
    required this.score,
    this.label,
    this.showIcon = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    final icon = _getScoreIcon(score);

    return Semantics(
      label: 'Health score $score out of 100, ${_getScoreLabel(score)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, color: color, size: size * 0.7),
              const SizedBox(width: 4),
            ],
            Text(
              '$score',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.6,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    if (score >= 20) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }
}

/// Risk level badge
class RiskBadge extends StatelessWidget {
  final String level;
  final bool isPositive;

  const RiskBadge({
    super.key,
    required this.level,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(level, isPositive);

    return Semantics(
      label: '$level ${isPositive ? "positive indicator" : "risk level"}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(
          level.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Color _getColor(String level, bool isPositive) {
    final isHigh = level.toLowerCase() == 'high';
    final isMedium = level.toLowerCase() == 'medium';

    if (isPositive) {
      if (isHigh) return Colors.green;
      if (isMedium) return Colors.orange;
      return Colors.red;
    } else {
      if (isHigh) return Colors.red;
      if (isMedium) return Colors.orange;
      return Colors.green;
    }
  }
}

/// Severity badge
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(severity), color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            severity,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('critical') || lower.contains('severe')) {
      return Colors.red;
    }
    if (lower.contains('high')) return Colors.deepOrange;
    if (lower.contains('moderate') || lower.contains('medium')) {
      return Colors.orange;
    }
    if (lower.contains('low') || lower.contains('mild')) return Colors.yellow.shade800;
    return Colors.green;
  }

  IconData _getIcon(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('critical') || lower.contains('severe')) {
      return Icons.error;
    }
    if (lower.contains('high')) return Icons.warning;
    if (lower.contains('moderate') || lower.contains('medium')) {
      return Icons.info;
    }
    return Icons.check_circle;
  }
}
