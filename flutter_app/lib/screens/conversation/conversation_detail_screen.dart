/// Conversation detail screen - view messages, verify speakers, run analysis
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'speaker_verification_screen.dart';
import 'analysis_results_screen.dart';
import 'response_tester_screen.dart';

class ConversationDetailScreen extends StatefulWidget {
  final String conversationId;

  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    final provider = context.read<ConversationProvider>();
    final conversation = await provider.getConversation(widget.conversationId);

    // Auto-start speaker identification for fresh drafts
    if (conversation != null &&
        conversation.status == ConversationStatus.draft &&
        conversation.messages.isEmpty &&
        conversation.rawText.isNotEmpty &&
        !provider.isIdentifyingSpeakers) {
      _identifySpeakers(conversation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.currentConversation;

        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Conversation')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(conversation.title),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, conversation),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit_title',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Title'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Status banner
              _StatusBanner(conversation: conversation),

              // Messages list
              Expanded(
                child: conversation.messages.isEmpty
                    ? _buildEmptyState(conversation)
                    : _buildMessagesList(conversation),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(conversation, provider),
        );
      },
    );
  }

  Widget _buildEmptyState(Conversation conversation) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No messages identified yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Identify Speakers" to analyze the conversation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Show raw text preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Text(
                  conversation.rawText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(Conversation conversation) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversation.messages.length,
      itemBuilder: (context, index) {
        final message = conversation.messages[index];
        final speaker = conversation.speakers.firstWhere(
          (s) => s.id == message.speakerId,
          orElse: () => Speaker.fromAIIdentification(message.speakerName ?? 'Unknown'),
        );

        return MessageBubble(
          message: message,
          speaker: speaker,
          onTap: () => _showSpeakerOptions(conversation, message),
        );
      },
    );
  }

  Widget _buildBottomActions(Conversation conversation, ConversationProvider provider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildActionButton(conversation, provider),
      ),
    );
  }

  Widget _buildActionButton(Conversation conversation, ConversationProvider provider) {
    switch (conversation.status) {
      case ConversationStatus.draft:
        return ElevatedButton.icon(
          onPressed: provider.isIdentifyingSpeakers
              ? null
              : () => _identifySpeakers(conversation),
          icon: provider.isIdentifyingSpeakers
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_search),
          label: Text(
            provider.isIdentifyingSpeakers
                ? 'Identifying Speakers...'
                : 'Identify Speakers',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );

      case ConversationStatus.speakersIdentified:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToVerification(conversation),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Speakers'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _verifySpeakers(conversation),
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
              ),
            ),
          ],
        );

      case ConversationStatus.speakersVerified:
        return ElevatedButton.icon(
          onPressed: provider.isAnalyzing
              ? null
              : () => _analyzeConversation(conversation),
          icon: provider.isAnalyzing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.psychology),
          label: Text(
            provider.isAnalyzing ? 'Analyzing...' : 'Analyze Conversation',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );

      case ConversationStatus.analyzing:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Analyzing...'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );

      case ConversationStatus.analyzed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToResponseTester(conversation),
                icon: const Icon(Icons.reply),
                label: const Text('Test Response'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAnalysis(conversation),
                icon: const Icon(Icons.insights),
                label: const Text('View Analysis'),
              ),
            ),
          ],
        );

      case ConversationStatus.error:
        return ElevatedButton.icon(
          onPressed: () => _retryLastAction(conversation),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  Future<void> _identifySpeakers(Conversation conversation) async {
    final provider = context.read<ConversationProvider>();
    final success = await provider.identifySpeakers(conversation);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to identify speakers'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifySpeakers(Conversation conversation) async {
    final provider = context.read<ConversationProvider>();
    await provider.verifySpeakers(conversation.id);
  }

  Future<void> _analyzeConversation(Conversation conversation) async {
    final provider = context.read<ConversationProvider>();
    final success = await provider.analyzeConversation(conversation);

    if (success && mounted) {
      _navigateToAnalysis(conversation);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Analysis failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retryLastAction(Conversation conversation) {
    // Reset status and try again based on what data we have
    if (conversation.messages.isEmpty) {
      _identifySpeakers(conversation);
    } else if (!conversation.speakersVerified) {
      // Already have messages, just need verification
    } else {
      _analyzeConversation(conversation);
    }
  }

  void _navigateToVerification(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeakerVerificationScreen(
          conversationId: conversation.id,
        ),
      ),
    );
  }

  void _navigateToAnalysis(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultsScreen(
          conversationId: conversation.id,
        ),
      ),
    );
  }

  void _navigateToResponseTester(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseTesterScreen(
          conversationId: conversation.id,
        ),
      ),
    );
  }

  void _showSpeakerOptions(Conversation conversation, Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SpeakerOptionsSheet(
        conversation: conversation,
        message: message,
      ),
    );
  }

  void _handleMenuAction(String action, Conversation conversation) {
    switch (action) {
      case 'edit_title':
        _showEditTitleDialog(conversation);
        break;
      case 'delete':
        _showDeleteConfirmation(conversation);
        break;
    }
  }

  void _showEditTitleDialog(Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<ConversationProvider>();
              await provider.updateConversation(
                conversation.copyWith(title: controller.text.trim()),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'This will permanently delete this conversation and its analysis. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final provider = context.read<ConversationProvider>();
              await provider.deleteConversation(conversation.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Conversation conversation;

  const _StatusBanner({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final text = conversation.status.displayName;

    return Semantics(
      label: conversation.status.accessibilityLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: color.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (conversation.messages.isNotEmpty)
                    Text(
                      '${conversation.messageCount} messages • ${conversation.speakerCount} speakers',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (conversation.analysis != null)
              HealthScoreBadge(score: conversation.healthScore ?? 0),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (conversation.status) {
      case ConversationStatus.draft:
        return Colors.grey;
      case ConversationStatus.speakersIdentified:
        return Colors.orange;
      case ConversationStatus.speakersVerified:
        return Colors.blue;
      case ConversationStatus.analyzing:
        return Colors.purple;
      case ConversationStatus.analyzed:
        return Colors.green;
      case ConversationStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (conversation.status) {
      case ConversationStatus.draft:
        return Icons.edit_note;
      case ConversationStatus.speakersIdentified:
        return Icons.people;
      case ConversationStatus.speakersVerified:
        return Icons.verified;
      case ConversationStatus.analyzing:
        return Icons.psychology;
      case ConversationStatus.analyzed:
        return Icons.check_circle;
      case ConversationStatus.error:
        return Icons.error;
    }
  }
}

class _SpeakerOptionsSheet extends StatelessWidget {
  final Conversation conversation;
  final Message message;

  const _SpeakerOptionsSheet({
    required this.conversation,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Speaker',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select who said this message:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),

          // Current message preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.text.length > 100
                  ? '${message.text.substring(0, 100)}...'
                  : message.text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),

          // Speaker options
          ...conversation.speakers.map((speaker) {
            final isSelected = speaker.id == message.speakerId;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: speaker.color,
                child: Text(
                  speaker.effectiveName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(speaker.effectiveName),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              selected: isSelected,
              onTap: () async {
                final provider = context.read<ConversationProvider>();
                await provider.updateMessageSpeaker(
                  conversationId: conversation.id,
                  messageId: message.id,
                  newSpeakerId: speaker.id,
                  newSpeakerName: speaker.effectiveName,
                );
                if (context.mounted) Navigator.pop(context);
              },
            );
          }),

          const Divider(),

          // Add new speaker option
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.add),
            ),
            title: const Text('Add New Speaker'),
            onTap: () => _showAddSpeakerDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAddSpeakerDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Speaker'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Speaker Name',
            hintText: 'Enter name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              final provider = context.read<ConversationProvider>();
              final newSpeaker = await provider.addSpeaker(
                conversationId: conversation.id,
                name: controller.text.trim(),
              );

              if (newSpeaker != null) {
                await provider.updateMessageSpeaker(
                  conversationId: conversation.id,
                  messageId: message.id,
                  newSpeakerId: newSpeaker.id,
                  newSpeakerName: newSpeaker.effectiveName,
                );
              }

              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
