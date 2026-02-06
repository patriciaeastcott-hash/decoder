/// Response tester screen - test how a reply might impact the conversation
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';
import '../../utils/accessibility_utils.dart';

class ResponseTesterScreen extends StatefulWidget {
  final String conversationId;

  const ResponseTesterScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ResponseTesterScreen> createState() => _ResponseTesterScreenState();
}

class _ResponseTesterScreenState extends State<ResponseTesterScreen> {
  final _responseController = TextEditingController();
  String? _selectedSpeaker;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.currentConversation;

        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Test Response')),
            body: const Center(child: Text('No conversation loaded')),
          );
        }

        // Find user speaker (or first speaker as default)
        final userSpeaker = conversation.speakers
            .where((s) => s.isUser)
            .firstOrNull ?? conversation.speakers.firstOrNull;

        _selectedSpeaker ??= userSpeaker?.effectiveName;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Test Response'),
          ),
          body: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Draft a response and see how it might impact the conversation dynamics.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Speaker selection
                      Text(
                        'You are responding as:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSpeaker,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: conversation.speakers.map((s) {
                          return DropdownMenuItem(
                            value: s.effectiveName,
                            child: Text(s.effectiveName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSpeaker = value);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Response input
                      Text(
                        'Your draft response:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      AccessibleTextField(
                        controller: _responseController,
                        labelText: 'Response',
                        hintText: 'Type your response here...',
                        maxLines: 5,
                      ),

                      const SizedBox(height: 24),

                      // Test button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isTestingResponse
                              ? null
                              : () => _testResponse(conversation),
                          icon: provider.isTestingResponse
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.psychology),
                          label: Text(
                            provider.isTestingResponse
                                ? 'Analyzing...'
                                : 'Analyze Impact',
                          ),
                        ),
                      ),

                      // Results
                      if (provider.lastResponseImpact != null) ...[
                        const SizedBox(height: 32),
                        _ResponseImpactResults(
                          result: provider.lastResponseImpact!,
                          onUseAlternative: (text) {
                            _responseController.text = text;
                            provider.clearResponseImpact();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _testResponse(Conversation conversation) async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response to test')),
      );
      return;
    }

    if (_selectedSpeaker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who you are responding as')),
      );
      return;
    }

    final provider = context.read<ConversationProvider>();
    await provider.testResponse(
      conversation: conversation,
      userSpeaker: _selectedSpeaker!,
      draftResponse: _responseController.text.trim(),
    );
  }
}

class _ResponseImpactResults extends StatelessWidget {
  final ResponseImpactResult result;
  final Function(String) onUseAlternative;

  const _ResponseImpactResults({
    required this.result,
    required this.onUseAlternative,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Results',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Impact Analysis
        _ResultCard(
          title: 'Impact Analysis',
          icon: Icons.analytics,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImpactRow(
                label: 'Likely Reception',
                value: result.impactAnalysis.likelyReception,
              ),
              _ImpactRow(
                label: 'Emotional Impact',
                value: result.impactAnalysis.emotionalImpact,
              ),
              _ImpactRow(
                label: 'Power Dynamic Shift',
                value: result.impactAnalysis.powerDynamicShift,
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _RiskIndicator(
                      label: 'Escalation Risk',
                      level: result.impactAnalysis.escalationRisk,
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RiskIndicator(
                      label: 'De-escalation Potential',
                      level: result.impactAnalysis.deEscalationPotential,
                      isPositive: true,
                    ),
                  ),
                ],
              ),
              if (result.impactAnalysis.predictedOutcomes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Predicted Outcomes:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...result.impactAnalysis.predictedOutcomes.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(o)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tone Analysis
        _ResultCard(
          title: 'Tone Analysis',
          icon: Icons.record_voice_over,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(result.toneAnalysis.detectedTone),
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 8),
              Text(result.toneAnalysis.alignmentWithGoals),
              if (result.toneAnalysis.potentialMisinterpretations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Potential Misinterpretations:',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ...result.toneAnalysis.potentialMisinterpretations.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Expanded(child: Text(m)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Recommended Response
        if (result.recommendedResponse != null) ...[
          const SizedBox(height: 16),
          _ResultCard(
            title: 'Recommended Response',
            icon: Icons.star,
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    result.recommendedResponse!.text,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Why: ${result.recommendedResponse!.reasoning}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (result.recommendedResponse!.expectedOutcome.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Expected: ${result.recommendedResponse!.expectedOutcome}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => onUseAlternative(result.recommendedResponse!.text),
                  icon: const Icon(Icons.edit),
                  label: const Text('Use This Response'),
                ),
              ],
            ),
          ),
        ],

        // Alternative Responses
        if (result.alternativeResponses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Alternative Approaches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...result.alternativeResponses.map((alt) {
            return _AlternativeResponseCard(
              alternative: alt,
              onUse: () => onUseAlternative(alt.response),
            );
          }),
        ],

        // Communication Tips
        if (result.communicationTips.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ResultCard(
            title: 'Communication Tips',
            icon: Icons.tips_and_updates,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: result.communicationTips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget child;

  const _ResultCard({
    required this.title,
    required this.icon,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cardColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cardColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;

  const _ImpactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

class _RiskIndicator extends StatelessWidget {
  final String label;
  final String level;
  final bool isPositive;

  const _RiskIndicator({
    required this.label,
    required this.level,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(level, isPositive);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Container(
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
      ],
    );
  }

  Color _getColor(String level, bool isPositive) {
    final isHigh = level.toLowerCase() == 'high';
    final isMedium = level.toLowerCase() == 'medium';

    if (isPositive) {
      // High is good for positive indicators
      if (isHigh) return Colors.green;
      if (isMedium) return Colors.orange;
      return Colors.red;
    } else {
      // High is bad for negative indicators (like escalation risk)
      if (isHigh) return Colors.red;
      if (isMedium) return Colors.orange;
      return Colors.green;
    }
  }
}

class _AlternativeResponseCard extends StatelessWidget {
  final AlternativeResponse alternative;
  final VoidCallback onUse;

  const _AlternativeResponseCard({
    required this.alternative,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(alternative.approach),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                TextButton(
                  onPressed: onUse,
                  child: const Text('Use'),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                alternative.response,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            if (alternative.likelyImpact.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Impact: ${alternative.likelyImpact}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (alternative.bestFor.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Best for: ${alternative.bestFor}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
