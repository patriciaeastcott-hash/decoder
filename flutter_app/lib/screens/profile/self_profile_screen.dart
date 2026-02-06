/// Self profile screen - unbiased analysis of the user's own communication patterns
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class SelfProfileScreen extends StatefulWidget {
  const SelfProfileScreen({super.key});

  @override
  State<SelfProfileScreen> createState() => _SelfProfileScreenState();
}

class _SelfProfileScreenState extends State<SelfProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final userProfile = provider.userProfile;

        if (userProfile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: _NoProfileView(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              if (userProfile.hasEnoughDataForAnalysis &&
                  !provider.isAnalyzing)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refreshAnalysis(userProfile),
                  tooltip: 'Refresh analysis',
                ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showAboutDialog,
                tooltip: 'About self-analysis',
              ),
            ],
            bottom: userProfile.analysis != null
                ? TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Communication'),
                      Tab(text: 'Emotions'),
                      Tab(text: 'Growth'),
                      Tab(text: 'Blind Spots'),
                    ],
                  )
                : null,
          ),
          body: userProfile.analysis != null
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _SelfOverviewTab(profile: userProfile),
                    _SelfCommunicationTab(profile: userProfile),
                    _SelfEmotionsTab(profile: userProfile),
                    _SelfGrowthTab(profile: userProfile),
                    _BlindSpotsTab(profile: userProfile),
                  ],
                )
              : _NoAnalysisView(profile: userProfile, onAnalyze: () => _refreshAnalysis(userProfile)),
        );
      },
    );
  }

  Future<void> _refreshAnalysis(Profile profile) async {
    final profileProvider = context.read<ProfileProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    // Get conversations linked to this profile
    final conversations = conversationProvider.conversations
        .where((c) => profile.conversationIds.contains(c.id))
        .toList();

    await profileProvider.analyzeProfile(
      profile: profile,
      conversations: conversations,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue),
            SizedBox(width: 8),
            Text('About Self-Analysis'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This analysis provides an unbiased view of your own communication patterns based on your conversations.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'How it works',
                'The AI analyzes messages you sent across all your conversations '
                    'to identify patterns, strengths, and areas for growth.',
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                'Objectivity',
                'The analysis is designed to be objective and honest. It may '
                    'highlight areas that are uncomfortable but important for growth.',
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                'Privacy',
                'All analysis happens on your device. Your personal data is never '
                    'stored on external servers.',
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                'Limitations',
                'This analysis is based only on text communication and may not '
                    'reflect your full personality or in-person communication style.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _NoProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Self Profile Yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To create your self profile, start by adding conversations '
              'and identifying yourself as a speaker. Your profile will be built '
              'automatically as you analyze more conversations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('Add a Conversation'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAnalysisView extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onAnalyze;

  const _NoAnalysisView({required this.profile, this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              profile.hasEnoughDataForAnalysis
                  ? 'Ready for Self-Analysis'
                  : 'More Conversations Needed',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              profile.hasEnoughDataForAnalysis
                  ? 'You have ${profile.conversationCount} conversations where you\'re identified. '
                      'Run analysis to discover insights about your communication style.'
                  : 'Self-analysis requires at least 3 conversations where you\'re '
                      'identified as a speaker. Current: ${profile.conversationCount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (profile.hasEnoughDataForAnalysis)
              Consumer<ProfileProvider>(
                builder: (context, provider, _) => ElevatedButton.icon(
                  onPressed: provider.isAnalyzing
                      ? null
                      : onAnalyze,
                  icon: provider.isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(
                    provider.isAnalyzing
                        ? 'Analyzing...'
                        : 'Analyze My Communication',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelfOverviewTab extends StatelessWidget {
  final Profile profile;

  const _SelfOverviewTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Disclaimer banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This is an objective analysis based on your text communications. '
                  'It may reveal patterns you weren\'t aware of.',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Summary card
        _SelfCard(
          title: 'Your Profile Summary',
          icon: Icons.person,
          child: Text(
            analysis.profileSummary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Quick stats
        if (profile.summary != null) ...[
          Row(
            children: [
              Expanded(
                child: _SelfStatCard(
                  label: 'Communication\nHealth',
                  value: '${profile.summary!.overallHealthScore}',
                  icon: Icons.favorite,
                  color: _getHealthColor(profile.summary!.overallHealthScore),
                  description: _getHealthDescription(
                      profile.summary!.overallHealthScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelfStatCard(
                  label: 'Conversations\nAnalyzed',
                  value: '${profile.conversationCount}',
                  icon: Icons.chat,
                  color: Theme.of(context).primaryColor,
                  description: 'Data points',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Overall assessment (honest feedback)
        if (analysis.overallAssessment.isNotEmpty)
          _SelfCard(
            title: 'Honest Assessment',
            icon: Icons.rate_review,
            color: Colors.purple,
            child: Text(analysis.overallAssessment),
          ),

        const SizedBox(height: 16),

        // Strengths you demonstrate
        if (analysis.strengths.isNotEmpty)
          _SelfCard(
            title: 'Your Communication Strengths',
            icon: Icons.star,
            color: Colors.amber,
            child: Column(
              children: analysis.strengths.map((strength) {
                return _StrengthItem(strength: strength);
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Areas that could be perceived negatively
        if (analysis.redFlagsSummary.isNotEmpty)
          _SelfCard(
            title: 'How Others Might Perceive You',
            icon: Icons.visibility,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Based on your messages, others might sometimes perceive:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 12),
                ...analysis.redFlagsSummary.map((flag) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.remove_red_eye,
                            size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(child: Text(flag)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getHealthDescription(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 50) return 'Needs work';
    return 'Concerning';
  }
}

class _SelfCommunicationTab extends StatelessWidget {
  final Profile profile;

  const _SelfCommunicationTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final commProfile = analysis.communicationProfile;
    final conflictProfile = analysis.conflictProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Your communication style
        if (commProfile != null) ...[
          _SelfCard(
            title: 'Your Communication Style',
            icon: Icons.chat_bubble,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    commProfile.dominantStyle,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (commProfile.secondaryStyles.isNotEmpty) ...[
                  Text(
                    'You also tend to use:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: commProfile.secondaryStyles.map((style) {
                      return Chip(label: Text(style));
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (commProfile.styleConsistency.isNotEmpty) ...[
                  _InfoRow(
                    label: 'Consistency',
                    value: commProfile.styleConsistency,
                    icon: Icons.straighten,
                  ),
                  const SizedBox(height: 8),
                ],
                if (commProfile.adaptability.isNotEmpty)
                  _InfoRow(
                    label: 'Adaptability',
                    value: commProfile.adaptability,
                    icon: Icons.sync_alt,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // How you handle conflict
        if (conflictProfile != null) ...[
          _SelfCard(
            title: 'How You Handle Conflict',
            icon: Icons.flash_on,
            color: Colors.red,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Your approach',
                  value: conflictProfile.approach,
                  icon: Icons.psychology,
                ),
                if (conflictProfile.strengthsInConflict.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'What you do well in conflicts:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...conflictProfile.strengthsInConflict.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    );
                  }),
                ],
                if (conflictProfile.challengesInConflict.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Where you could improve:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...conflictProfile.challengesInConflict.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_right,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(c)),
                        ],
                      ),
                    );
                  }),
                ],
                if (conflictProfile.resolutionPatterns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Resolution patterns',
                    value: conflictProfile.resolutionPatterns,
                    icon: Icons.handshake,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Attachment style
        if (analysis.attachmentProfile != null)
          _SelfCard(
            title: 'Your Attachment Style',
            icon: Icons.link,
            color: Colors.purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    analysis.attachmentProfile!.primaryStyle,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (analysis
                    .attachmentProfile!.triggersForInsecurity.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'What tends to trigger your insecurity:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  ...analysis.attachmentProfile!.triggersForInsecurity
                      .map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t)),
                        ],
                      ),
                    );
                  }),
                ],
                if (analysis
                    .attachmentProfile!.secureBaseBehaviors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Your secure behaviors:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  ...analysis.attachmentProfile!.secureBaseBehaviors.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _SelfEmotionsTab extends StatelessWidget {
  final Profile profile;

  const _SelfEmotionsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final emotionalProfile = analysis.emotionalProfile;

    if (emotionalProfile == null) {
      return const Center(
        child: Text('No emotional analysis available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Emotional regulation
        _SelfCard(
          title: 'Your Emotional Regulation',
          icon: Icons.mood,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getRegulationColor(emotionalProfile.baselineRegulation)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  emotionalProfile.baselineRegulation,
                  style: TextStyle(
                    color:
                        _getRegulationColor(emotionalProfile.baselineRegulation),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (emotionalProfile
                  .emotionalIntelligenceIndicators.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Emotional Intelligence',
                  value: emotionalProfile.emotionalIntelligenceIndicators,
                  icon: Icons.lightbulb,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Your triggers
        if (emotionalProfile.commonTriggers.isNotEmpty)
          _SelfCard(
            title: 'Your Emotional Triggers',
            icon: Icons.bolt,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'These situations tend to affect you emotionally:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 12),
                ...emotionalProfile.commonTriggers.map((trigger) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber,
                            size: 20, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(child: Text(trigger)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Coping strategies
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emotionalProfile.healthyCopingStrategies.isNotEmpty)
              Expanded(
                child: _SelfCard(
                  title: 'Healthy Coping',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: emotionalProfile.healthyCopingStrategies.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.add_circle,
                                size: 14, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (emotionalProfile.healthyCopingStrategies.isNotEmpty &&
                emotionalProfile.unhealthyCopingStrategies.isNotEmpty)
              const SizedBox(width: 12),
            if (emotionalProfile.unhealthyCopingStrategies.isNotEmpty)
              Expanded(
                child: _SelfCard(
                  title: 'Less Healthy',
                  icon: Icons.cancel,
                  color: Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        emotionalProfile.unhealthyCopingStrategies.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.remove_circle,
                                size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Color _getRegulationColor(String regulation) {
    final lower = regulation.toLowerCase();
    if (lower.contains('good') ||
        lower.contains('strong') ||
        lower.contains('healthy')) {
      return Colors.green;
    }
    if (lower.contains('moderate') || lower.contains('developing')) {
      return Colors.orange;
    }
    return Colors.red;
  }
}

class _SelfGrowthTab extends StatelessWidget {
  final Profile profile;

  const _SelfGrowthTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Growth header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 40),
              const SizedBox(height: 8),
              Text(
                'Your Growth Journey',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Areas where you can develop your communication skills',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Growth opportunities
        if (analysis.growthOpportunities.isNotEmpty)
          ...analysis.growthOpportunities.map((opp) {
            return _GrowthOpportunityCard(opportunity: opp);
          })
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Great job!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No significant growth areas identified at this time. '
                    'Keep communicating authentically!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _BlindSpotsTab extends StatelessWidget {
  final Profile profile;

  const _BlindSpotsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final behavioralPatterns = analysis.behavioralPatterns;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Explanation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_off, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Blind Spots',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These are patterns in your communication that you might not be '
                'aware of, but others likely notice. This honest feedback is '
                'meant to help you grow.',
                style: TextStyle(color: Colors.purple.shade900),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Red flags as blind spots
        if (analysis.redFlagsSummary.isNotEmpty) ...[
          Text(
            'Patterns That May Concern Others',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...analysis.redFlagsSummary.map((flag) {
            return _BlindSpotCard(
              content: flag,
              severity: 'attention',
            );
          }),
          const SizedBox(height: 24),
        ],

        // Behavioral patterns that might be blind spots
        if (behavioralPatterns != null &&
            behavioralPatterns.frequentBehaviors.isNotEmpty) ...[
          Text(
            'Your Frequent Behaviors',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'These behaviors appear regularly in your messages. Consider whether '
            'they align with how you want to be perceived.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 12),
          ...behavioralPatterns.frequentBehaviors.map((fb) {
            return _FrequentBehaviorCard(behavior: fb);
          }),
        ],

        // Evolving patterns
        if (behavioralPatterns != null &&
            behavioralPatterns.evolvingPatterns.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SelfCard(
            title: 'Evolving Patterns',
            icon: Icons.timeline,
            color: Colors.blue,
            child: Text(behavioralPatterns.evolvingPatterns),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// Helper widgets

class _SelfCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget child;

  const _SelfCard({
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cardColor,
                          fontWeight: FontWeight.w600,
                        ),
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

class _SelfStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String description;

  const _SelfStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StrengthItem extends StatelessWidget {
  final ProfileStrength strength;

  const _StrengthItem({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Icon(Icons.star, color: Colors.amber.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strength.strength,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (strength.evidence.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              strength.evidence,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _GrowthOpportunityCard extends StatelessWidget {
  final GrowthOpportunity opportunity;

  const _GrowthOpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up,
                      color: Colors.blue.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opportunity.area,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (opportunity.currentPattern.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current pattern:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(opportunity.currentPattern),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (opportunity.suggestedGrowth.isNotEmpty) ...[
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
                        Icon(Icons.lightbulb,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Suggestion:',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(opportunity.suggestedGrowth),
                  ],
                ),
              ),
            ],
            if (opportunity.resources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Resources: ${opportunity.resources}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlindSpotCard extends StatelessWidget {
  final String content;
  final String severity;

  const _BlindSpotCard({
    required this.content,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = severity == 'attention' ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.visibility_off, color: color.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: TextStyle(color: color.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequentBehaviorCard extends StatelessWidget {
  final FrequentBehavior behavior;

  const _FrequentBehaviorCard({required this.behavior});

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
                Expanded(
                  child: Text(
                    behavior.behavior,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (behavior.frequency.isNotEmpty)
                  Chip(
                    label: Text(
                      behavior.frequency,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            if (behavior.contexts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Context: ${behavior.contexts}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
            if (behavior.impact.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Impact: ${behavior.impact}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.purple.shade700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
