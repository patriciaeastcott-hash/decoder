/// Speaker verification screen - review and correct AI speaker identification
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/accessibility_utils.dart';

class SpeakerVerificationScreen extends StatefulWidget {
  final String conversationId;

  const SpeakerVerificationScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<SpeakerVerificationScreen> createState() => _SpeakerVerificationScreenState();
}

class _SpeakerVerificationScreenState extends State<SpeakerVerificationScreen> {
  bool _showAllMessages = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.currentConversation;

        if (conversation == null || conversation.messages.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Verify Speakers')),
            body: const Center(child: Text('No messages to verify')),
          );
        }

        final unverifiedMessages = conversation.messages
            .where((m) => !m.isVerified)
            .toList();

        final messagesToShow = _showAllMessages
            ? conversation.messages
            : unverifiedMessages;

        if (messagesToShow.isEmpty) {
          return _buildAllVerifiedView(context, conversation);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Verify Speakers'),
            actions: [
              TextButton(
                onPressed: () => setState(() => _showAllMessages = !_showAllMessages),
                child: Text(_showAllMessages ? 'Unverified Only' : 'Show All'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              _VerificationProgress(
                total: conversation.messages.length,
                verified: conversation.messages.where((m) => m.isVerified).length,
              ),

              // Instructions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Review each message and confirm or change the speaker. '
                  'AI confidence is shown - lower confidence may need more attention.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Messages list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messagesToShow.length,
                  itemBuilder: (context, index) {
                    final message = messagesToShow[index];
                    final speaker = conversation.speakers.firstWhere(
                      (s) => s.id == message.speakerId,
                      orElse: () => Speaker.fromAIIdentification(
                        message.speakerName ?? 'Unknown',
                      ),
                    );

                    return _VerificationCard(
                      message: message,
                      speaker: speaker,
                      speakers: conversation.speakers,
                      onSpeakerChanged: (newSpeaker) => _updateSpeaker(
                        conversation,
                        message,
                        newSpeaker,
                      ),
                      onVerified: () => _verifyMessage(conversation, message),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _verifyAllRemaining(conversation),
                      child: const Text('Verify All Remaining'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeVerification(conversation),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllVerifiedView(BuildContext context, Conversation conversation) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Speakers')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'All Speakers Verified',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${conversation.messages.length} messages across ${conversation.speakers.length} speakers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _completeVerification(conversation),
                icon: const Icon(Icons.psychology),
                label: const Text('Continue to Analysis'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateSpeaker(
    Conversation conversation,
    Message message,
    Speaker newSpeaker,
  ) async {
    final provider = context.read<ConversationProvider>();
    await provider.updateMessageSpeaker(
      conversationId: conversation.id,
      messageId: message.id,
      newSpeakerId: newSpeaker.id,
      newSpeakerName: newSpeaker.effectiveName,
    );
  }

  Future<void> _verifyMessage(Conversation conversation, Message message) async {
    final provider = context.read<ConversationProvider>();
    final updatedMessages = conversation.messages.map((m) {
      if (m.id == message.id) {
        return m.copyWith(isVerified: true);
      }
      return m;
    }).toList();

    await provider.updateConversation(
      conversation.copyWith(messages: updatedMessages),
    );

    announceToScreenReader('Message verified');
  }

  Future<void> _verifyAllRemaining(Conversation conversation) async {
    final provider = context.read<ConversationProvider>();
    final updatedMessages = conversation.messages
        .map((m) => m.copyWith(isVerified: true))
        .toList();

    await provider.updateConversation(
      conversation.copyWith(messages: updatedMessages),
    );

    announceToScreenReader('All messages verified');
  }

  Future<void> _completeVerification(Conversation conversation) async {
    final provider = context.read<ConversationProvider>();
    await provider.verifySpeakers(conversation.id);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _VerificationProgress extends StatelessWidget {
  final int total;
  final int verified;

  const _VerificationProgress({
    required this.total,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? verified / total : 0.0;

    return Semantics(
      label: '$verified of $total messages verified, ${(progress * 100).toInt()} percent complete',
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verification Progress',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '$verified / $total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final Message message;
  final Speaker speaker;
  final List<Speaker> speakers;
  final Function(Speaker) onSpeakerChanged;
  final VoidCallback onVerified;

  const _VerificationCard({
    required this.message,
    required this.speaker,
    required this.speakers,
    required this.onSpeakerChanged,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(message.confidenceScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker selector and confidence
            Row(
              children: [
                // Speaker dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: speaker.id,
                    decoration: InputDecoration(
                      labelText: 'Speaker',
                      prefixIcon: CircleAvatar(
                        radius: 12,
                        backgroundColor: speaker.color,
                        child: Text(
                          speaker.effectiveName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: speakers.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: s.color,
                            ),
                            const SizedBox(width: 8),
                            Text(s.effectiveName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final newSpeaker = speakers.firstWhere((s) => s.id == value);
                        onSpeakerChanged(newSpeaker);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Confidence indicator
                Semantics(
                  label: 'AI confidence ${(message.confidenceScore * 100).toInt()} percent',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: confidenceColor),
                    ),
                    child: Text(
                      '${(message.confidenceScore * 100).toInt()}%',
                      style: TextStyle(
                        color: confidenceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // AI reasoning
            if (message.reasoning != null && message.reasoning!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'AI reasoning: ${message.reasoning}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
              ),
            ],

            const Divider(height: 24),

            // Message text
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Verification status / button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: onVerified,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Verify'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
