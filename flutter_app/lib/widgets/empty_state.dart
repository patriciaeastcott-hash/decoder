/// Empty state widget for displaying when there's no content
library;

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null || customAction != null) ...[
              const SizedBox(height: 24),
              customAction ??
                  ElevatedButton(
                    onPressed: onAction,
                    child: Text(actionLabel ?? 'Get Started'),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for conversations
class EmptyConversationsState extends StatelessWidget {
  final VoidCallback? onAddConversation;

  const EmptyConversationsState({
    super.key,
    this.onAddConversation,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'No Conversations Yet',
      message:
          'Add your first conversation to start analyzing communication patterns.',
      actionLabel: 'Add Conversation',
      onAction: onAddConversation,
    );
  }
}

/// Empty state for profiles
class EmptyProfilesState extends StatelessWidget {
  final VoidCallback? onLearnMore;

  const EmptyProfilesState({
    super.key,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.person_outline,
      title: 'No Profiles Yet',
      message:
          'Profiles are built automatically as you analyze conversations. Add more conversations to build speaker profiles.',
      actionLabel: 'Learn More',
      onAction: onLearnMore,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.searchTerm,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'No items match "$searchTerm". Try a different search term.',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
    );
  }
}

/// Empty state for analysis
class EmptyAnalysisState extends StatelessWidget {
  final VoidCallback? onStartAnalysis;
  final bool hasEnoughData;

  const EmptyAnalysisState({
    super.key,
    this.onStartAnalysis,
    this.hasEnoughData = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasEnoughData) {
      return const EmptyState(
        icon: Icons.analytics_outlined,
        title: 'Not Enough Data',
        message:
            'Add more conversation messages to enable analysis. At least 5 messages are needed.',
      );
    }

    return EmptyState(
      icon: Icons.analytics_outlined,
      title: 'Ready for Analysis',
      message:
          'This conversation is ready to be analyzed. Tap the button below to start.',
      actionLabel: 'Start Analysis',
      onAction: onStartAnalysis,
    );
  }
}

/// Empty state for offline mode
class OfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off,
      title: 'You\'re Offline',
      message:
          'Some features require an internet connection. Check your connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Error state
class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      message: errorMessage ?? 'An unexpected error occurred. Please try again.',
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }
}

/// Coming soon state
class ComingSoonState extends StatelessWidget {
  final String feature;

  const ComingSoonState({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.construction,
      title: 'Coming Soon',
      message: '$feature is currently under development. Stay tuned!',
    );
  }
}
