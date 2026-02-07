/// Analysis results screen - display psychological insights from conversation
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../library/behavior_detail_screen.dart';

class AnalysisResultsScreen extends StatelessWidget {
  final String conversationId;

  const AnalysisResultsScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.currentConversation;
        final analysis = conversation?.analysis;

        if (conversation == null || analysis == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Analysis')),
            body: const Center(child: Text('No analysis available')),
          );
        }

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Conversation Analysis'),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Speakers'),
                  Tab(text: 'Dynamics'),
                  Tab(text: 'Actions'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OverviewTab(analysis: analysis),
                _SpeakersTab(analysis: analysis),
                _DynamicsTab(analysis: analysis),
                _ActionsTab(analysis: analysis),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// OVERVIEW TAB
// ============================================

class _OverviewTab extends StatelessWidget {
  final AnalysisResult analysis;

  const _OverviewTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Score
          Center(
            child: HealthScoreCard(
              score: analysis.conversationHealthScore,
            ),
          ),
          const SizedBox(height: 24),

          // Summary
          _SectionCard(
            title: 'Summary',
            icon: Icons.summarize,
            child: Text(
              analysis.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          // Power Dynamics
          if (analysis.powerDynamics != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Power Dynamics',
              icon: Icons.balance,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(analysis.powerDynamics!.assessment),
                  const SizedBox(height: 12),
                  _ScoreIndicator(
                    label: 'Balance',
                    score: analysis.powerDynamics!.balanceScore,
                    maxScore: 10,
                  ),
                  if (analysis.powerDynamics!.indicators.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Key Indicators:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...analysis.powerDynamics!.indicators.map(
                      (i) => _BulletPoint(text: i),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Manipulation Check
          if (analysis.manipulationCheck != null) ...[
            const SizedBox(height: 16),
            _ManipulationCard(check: analysis.manipulationCheck!),
          ],

          // Follow-up Questions
          if (analysis.followUpQuestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Questions to Consider',
              icon: Icons.help_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: analysis.followUpQuestions
                    .map((q) => _BulletPoint(text: q))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ============================================
// SPEAKERS TAB
// ============================================

class _SpeakersTab extends StatelessWidget {
  final AnalysisResult analysis;

  const _SpeakersTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.speakerAnalyses.isEmpty) {
      return const Center(child: Text('No speaker analysis available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.speakerAnalyses.length,
      itemBuilder: (context, index) {
        final speakerAnalysis = analysis.speakerAnalyses[index];
        return _SpeakerAnalysisCard(analysis: speakerAnalysis);
      },
    );
  }
}

class _SpeakerAnalysisCard extends StatelessWidget {
  final SpeakerAnalysis analysis;

  const _SpeakerAnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          child: Text(analysis.speakerName[0].toUpperCase()),
        ),
        title: Text(analysis.speakerName),
        subtitle: analysis.communicationStyle != null
            ? Text('${analysis.communicationStyle!.primary} communicator')
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Communication Style
                if (analysis.communicationStyle != null) ...[
                  _SubSection(
                    title: 'Communication Style',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(analysis.communicationStyle!.primary)),
                            const SizedBox(width: 8),
                            _ScoreIndicator(
                              label: 'Effectiveness',
                              score: analysis.communicationStyle!.effectivenessScore,
                              maxScore: 10,
                              compact: true,
                            ),
                          ],
                        ),
                        if (analysis.communicationStyle!.examples.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...analysis.communicationStyle!.examples
                              .take(2)
                              .map((e) => _QuoteText(text: e)),
                        ],
                      ],
                    ),
                  ),
                ],

                // Emotional Patterns
                if (analysis.emotionalPatterns != null) ...[
                  const SizedBox(height: 16),
                  _SubSection(
                    title: 'Emotional Patterns',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(analysis.emotionalPatterns!.regulationLevel),
                          backgroundColor: _getRegulationColor(
                            analysis.emotionalPatterns!.regulationLevel,
                          ),
                        ),
                        if (analysis.emotionalPatterns!.triggersObserved.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Triggers:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Wrap(
                            spacing: 4,
                            children: analysis.emotionalPatterns!.triggersObserved
                                .map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Attachment Indicators
                if (analysis.attachmentIndicators != null) ...[
                  const SizedBox(height: 16),
                  _SubSection(
                    title: 'Attachment Style',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(analysis.attachmentIndicators!.likelyStyle),
                          backgroundColor: Colors.purple.shade50,
                        ),
                        if (analysis.attachmentIndicators!.evidence.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...analysis.attachmentIndicators!.evidence
                              .take(2)
                              .map((e) => _BulletPoint(text: e)),
                        ],
                      ],
                    ),
                  ),
                ],

                // Behaviors Exhibited
                if (analysis.behaviorsExhibited.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SubSection(
                    title: 'Behaviors Identified',
                    child: Column(
                      children: analysis.behaviorsExhibited.map((b) {
                        return _BehaviorChip(behavior: b);
                      }).toList(),
                    ),
                  ),
                ],

                // Strengths & Growth Areas
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (analysis.strengths.isNotEmpty)
                      Expanded(
                        child: _SubSection(
                          title: 'Strengths',
                          titleColor: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: analysis.strengths
                                .map((s) => _BulletPoint(text: s, color: Colors.green))
                                .toList(),
                          ),
                        ),
                      ),
                    if (analysis.growthAreas.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SubSection(
                          title: 'Growth Areas',
                          titleColor: Colors.orange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: analysis.growthAreas
                                .map((g) => _BulletPoint(text: g, color: Colors.orange))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Flags
                if (analysis.redFlags.isNotEmpty || analysis.greenFlags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (analysis.greenFlags.isNotEmpty)
                        Expanded(
                          child: _FlagsSection(
                            title: 'Green Flags',
                            flags: analysis.greenFlags,
                            color: Colors.green,
                            icon: Icons.flag,
                          ),
                        ),
                      if (analysis.redFlags.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FlagsSection(
                            title: 'Red Flags',
                            flags: analysis.redFlags,
                            color: Colors.red,
                            icon: Icons.flag,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRegulationColor(String level) {
    switch (level.toLowerCase()) {
      case 'well-regulated':
        return Colors.green.shade50;
      case 'moderately-regulated':
        return Colors.orange.shade50;
      case 'dysregulated':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }
}

// ============================================
// DYNAMICS TAB
// ============================================

class _DynamicsTab extends StatelessWidget {
  final AnalysisResult analysis;

  const _DynamicsTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final dynamics = analysis.relationshipDynamics;

    if (dynamics == null) {
      return const Center(child: Text('No relationship dynamics data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Health
          _SectionCard(
            title: 'Overall Relationship Health',
            icon: Icons.favorite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HealthBadge(health: dynamics.overallHealth),
                const SizedBox(height: 12),
                Text(
                  'Conflict Style: ${dynamics.conflictStyle}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                _ResolutionPotentialIndicator(potential: dynamics.resolutionPotential),
              ],
            ),
          ),

          // Patterns
          if (dynamics.patterns.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Relationship Patterns',
              icon: Icons.pattern,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dynamics.patterns
                    .map((p) => _BulletPoint(text: p))
                    .toList(),
              ),
            ),
          ],

          // Power Dynamics visualization
          if (analysis.powerDynamics != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Power Balance',
              icon: Icons.balance,
              child: _PowerBalanceVisualization(
                balance: analysis.powerDynamics!.balanceScore,
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ============================================
// ACTIONS TAB
// ============================================

class _ActionsTab extends StatelessWidget {
  final AnalysisResult analysis;

  const _ActionsTab({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.actionableInsights.isEmpty) {
      return const Center(child: Text('No actionable insights available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.actionableInsights.length,
      itemBuilder: (context, index) {
        final insight = analysis.actionableInsights[index];
        return _ActionableInsightCard(insight: insight, index: index);
      },
    );
  }
}

class _ActionableInsightCard extends StatelessWidget {
  final ActionableInsight insight;
  final int index;

  const _ActionableInsightCard({
    required this.insight,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For: ${insight.forSpeaker}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Insight
            Text(
              'Observation',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(insight.insight),

            const SizedBox(height: 16),

            // Suggestion
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Suggestion',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(insight.suggestion),
                ],
              ),
            ),

            // Expected Outcome
            if (insight.expectedOutcome.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Expected Outcome',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                insight.expectedOutcome,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// HELPER WIDGETS
// ============================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _SubSection extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final Widget child;

  const _SubSection({
    required this.title,
    this.titleColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;
  final bool compact;

  const _ScoreIndicator({
    required this.label,
    required this.score,
    required this.maxScore,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = score / maxScore;
    final color = _getScoreColor(progress);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12)),
          Text(
            '$score/$maxScore',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$score/$maxScore',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }

  Color _getScoreColor(double progress) {
    if (progress >= 0.7) return Colors.green;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final Color? color;

  const _BulletPoint({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: color)),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}

class _QuoteText extends StatelessWidget {
  final String text;

  const _QuoteText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: Colors.grey.shade400, width: 3)),
      ),
      child: Text(
        '"$text"',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}

class _ManipulationCard extends StatelessWidget {
  final ManipulationCheck check;

  const _ManipulationCard({required this.check});

  @override
  Widget build(BuildContext context) {
    final color = check.detected ? Colors.red : Colors.green;
    final icon = check.detected ? Icons.warning : Icons.check_circle;

    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  'Manipulation Check',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              check.detected
                  ? 'Potential manipulation patterns detected'
                  : 'No manipulation patterns detected',
              style: TextStyle(color: color.shade800),
            ),
            if (check.detected && check.types.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: check.types.map((t) {
                  return Chip(
                    label: Text(t),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: TextStyle(color: Colors.red.shade800),
                  );
                }).toList(),
              ),
              if (check.examples.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...check.examples.map((e) => _QuoteText(text: e)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BehaviorChip extends StatelessWidget {
  final BehaviorExhibited behavior;

  const _BehaviorChip({required this.behavior});

  @override
  Widget build(BuildContext context) {
    final impactColor = switch (behavior.impact.toLowerCase()) {
      'positive' => Colors.green,
      'negative' => Colors.red,
      _ => Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BehaviorDetailScreen(
                behaviorId: behavior.behaviorId,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: impactColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: impactColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      behavior.behaviorName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${behavior.frequency} • ${behavior.impact} impact',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagsSection extends StatelessWidget {
  final String title;
  final List<String> flags;
  final Color color;
  final IconData icon;

  const _FlagsSection({
    required this.title,
    required this.flags,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...flags.map((f) => _BulletPoint(text: f, color: color)),
      ],
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String health;

  const _HealthBadge({required this.health});

  @override
  Widget build(BuildContext context) {
    final color = switch (health.toLowerCase()) {
      'healthy' => Colors.green,
      'concerning' => Colors.orange,
      'unhealthy' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        health.toUpperCase(),
        style: TextStyle(
          color: color.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ResolutionPotentialIndicator extends StatelessWidget {
  final String potential;

  const _ResolutionPotentialIndicator({required this.potential});

  @override
  Widget build(BuildContext context) {
    final value = switch (potential.toLowerCase()) {
      'high' => 0.9,
      'medium' => 0.5,
      'low' => 0.2,
      _ => 0.5,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resolution Potential: ${potential.toUpperCase()}',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            value > 0.6 ? Colors.green : (value > 0.3 ? Colors.orange : Colors.red),
          ),
        ),
      ],
    );
  }
}

class _PowerBalanceVisualization extends StatelessWidget {
  final int balance; // 0-10, where 5 is balanced

  const _PowerBalanceVisualization({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isBalanced = balance >= 4 && balance <= 6;
    final position = balance / 10;

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Stack(
            children: [
              // Background bar
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade100,
                        Colors.green.shade100,
                        Colors.red.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Center line
              Center(
                child: Container(
                  width: 2,
                  height: 60,
                  color: Colors.green,
                ),
              ),
              // Position indicator
              Positioned(
                left: (MediaQuery.of(context).size.width - 64) * position - 12,
                top: 18,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isBalanced ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isBalanced ? 'Balanced' : (balance < 5 ? 'Speaker 1 dominant' : 'Speaker 2 dominant'),
          style: TextStyle(
            color: isBalanced ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
