/// Profile detail screen - view speaker profile analysis
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/accessibility_utils.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String profileId;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        final profile = provider.profiles
            .where((p) => p.id == widget.profileId)
            .firstOrNull;

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(child: Text('Profile not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(profile.displayName ?? profile.name),
            actions: [
              if (profile.hasEnoughDataForAnalysis &&
                  (profile.analysis == null || provider.isAnalyzing == false))
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _refreshAnalysis(profile),
                  tooltip: 'Refresh analysis',
                ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, profile),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'retention',
                    child: ListTile(
                      leading: Icon(Icons.schedule),
                      title: Text('Data Retention'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete Profile',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            bottom: profile.analysis != null
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Communication'),
                      Tab(text: 'Patterns'),
                      Tab(text: 'Tips'),
                    ],
                  )
                : null,
          ),
          body: profile.analysis != null
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(profile: profile),
                    _CommunicationTab(profile: profile),
                    _PatternsTab(profile: profile),
                    _TipsTab(profile: profile),
                  ],
                )
              : _NoAnalysisView(profile: profile, onAnalyze: () => _refreshAnalysis(profile)),
        );
      },
    );
  }

  Future<void> _refreshAnalysis(Profile profile) async {
    final provider = context.read<ProfileProvider>();
    final convProvider = context.read<ConversationProvider>();
    final conversations = convProvider.conversations
        .where((c) => profile.conversationIds.contains(c.id))
        .toList();
    await provider.analyzeProfile(
      profile: profile,
      conversations: conversations,
    );
    final profileProvider = context.read<ProfileProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    // Get conversations linked to this profile
    final   conversations = conversationProvider.conversations
        .where((c) => profile.conversationIds.contains(c.id))
        .toList();

    await profileProvider.analyzeProfile(
      profile: profile,
      conversations: conversations,
    );
  }

  void _handleMenuAction(String action, Profile profile) {
    switch (action) {
      case 'edit':
        _showEditDialog(profile);
        break;
      case 'retention':
        _showRetentionDialog(profile);
        break;
      case 'delete':
        _showDeleteConfirmation(profile);
        break;
    }
  }

  void _showEditDialog(Profile profile) {
    final nameController =
        TextEditingController(text: profile.displayName ?? profile.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: AccessibleTextField(
          controller: nameController,
          labelText: 'Display Name',
          hintText: 'Enter a display name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileProvider>().updateProfile(
                    profile.copyWith(
                      displayName: nameController.text.trim(),
                      updatedAt: DateTime.now(),
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRetentionDialog(Profile profile) {
    int selectedMonths = profile.retentionMonths;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Data Retention'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How long should this profile data be retained?'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedMonths,
                decoration: const InputDecoration(
                  labelText: 'Retention Period',
                ),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('3 months')),
                  DropdownMenuItem(value: 6, child: Text('6 months')),
                  DropdownMenuItem(value: 12, child: Text('12 months')),
                  DropdownMenuItem(value: 24, child: Text('24 months')),
                  DropdownMenuItem(value: 0, child: Text('Keep indefinitely')),
                ],
                onChanged: (value) {
                  setState(() => selectedMonths = value!);
                },
              ),
              if (profile.expiresAt != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Current expiry: ${_formatDate(profile.expiresAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                context.read<ProfileProvider>().updateProfile(
                      profile.copyWith(
                        retentionMonths: selectedMonths,
                        expiresAt: selectedMonths > 0
                            ? now.add(Duration(days: selectedMonths * 30))
                            : null,
                        updatedAt: now,
                      ),
                    );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete the profile for "${profile.displayName ?? profile.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<ProfileProvider>().deleteProfile(profile.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              profile.hasEnoughDataForAnalysis
                  ? 'Profile Ready for Analysis'
                  : 'Not Enough Data',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              profile.hasEnoughDataForAnalysis
                  ? 'This profile has ${profile.conversationCount} conversations. '
                      'Run analysis to generate insights.'
                  : 'This profile needs at least 3 conversations for meaningful analysis. '
                      'Current: ${profile.conversationCount} conversations.',
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
                      provider.isAnalyzing ? 'Analyzing...' : 'Run Analysis'),
                ),
              Consumer2<ProfileProvider, ConversationProvider>(
                builder: (context, profileProvider, conversationProvider, _) {
                  final conversations = conversationProvider.conversations
                      .where((c) => profile.conversationIds.contains(c.id))
                      .toList();

                  return ElevatedButton.icon(
                    onPressed: profileProvider.isAnalyzing
                        ? null
                        : () => profileProvider.analyzeProfile(
                              profile: profile,
                              conversations: conversations,
                            ),
                    icon: profileProvider.isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(profileProvider.isAnalyzing
                        ? 'Analyzing...'
                        : 'Run Analysis'),
                  );
                },
              ),
              ),
          ],
        ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Profile profile;

  const _OverviewTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _ProfileCard(
          title: 'Profile Summary',
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
                child: _StatCard(
                  label: 'Health Score',
                  value: '${profile.summary!.overallHealthScore}',
                  icon: Icons.favorite,
                  color: _getHealthColor(profile.summary!.overallHealthScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Conversations',
                  value: '${profile.conversationCount}',
                  icon: Icons.chat,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Overall assessment
        if (analysis.overallAssessment.isNotEmpty)
          _ProfileCard(
            title: 'Overall Assessment',
            icon: Icons.assessment,
            child: Text(analysis.overallAssessment),
          ),

        const SizedBox(height: 16),

        // Green flags
        if (analysis.greenFlagsSummary.isNotEmpty)
          _FlagsCard(
            title: 'Positive Indicators',
            flags: analysis.greenFlagsSummary,
            color: Colors.green,
            icon: Icons.thumb_up,
          ),

        const SizedBox(height: 16),

        // Red flags
        if (analysis.redFlagsSummary.isNotEmpty)
          _FlagsCard(
            title: 'Areas of Concern',
            flags: analysis.redFlagsSummary,
            color: Colors.red,
            icon: Icons.warning,
          ),

        const SizedBox(height: 16),

        // Strengths
        if (analysis.strengths.isNotEmpty) ...[
          _ProfileCard(
            title: 'Strengths',
            icon: Icons.star,
            color: Colors.amber,
            child: Column(
              children: analysis.strengths.map((strength) {
                return _StrengthTile(strength: strength);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Growth opportunities
        if (analysis.growthOpportunities.isNotEmpty)
          _ProfileCard(
            title: 'Growth Opportunities',
            icon: Icons.trending_up,
            color: Colors.blue,
            child: Column(
              children: analysis.growthOpportunities.map((opp) {
                return _GrowthTile(opportunity: opp);
              }).toList(),
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
}

class _CommunicationTab extends StatelessWidget {
  final Profile profile;

  const _CommunicationTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final commProfile = analysis.communicationProfile;
    final attachmentProfile = analysis.attachmentProfile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Communication style
        if (commProfile != null) ...[
          _ProfileCard(
            title: 'Communication Style',
            icon: Icons.chat_bubble,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledValue(
                  label: 'Dominant Style',
                  value: commProfile.dominantStyle,
                ),
                if (commProfile.secondaryStyles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Secondary Styles',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: commProfile.secondaryStyles.map((style) {
                      return Chip(label: Text(style));
                    }).toList(),
                  ),
                ],
                if (commProfile.styleConsistency.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LabeledValue(
                    label: 'Consistency',
                    value: commProfile.styleConsistency,
                  ),
                ],
                if (commProfile.adaptability.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LabeledValue(
                    label: 'Adaptability',
                    value: commProfile.adaptability,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Attachment style
        if (attachmentProfile != null) ...[
          _ProfileCard(
            title: 'Attachment Style',
            icon: Icons.link,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledValue(
                  label: 'Primary Style',
                  value: attachmentProfile.primaryStyle,
                ),
                if (attachmentProfile.triggersForInsecurity.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Triggers for Insecurity',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...attachmentProfile.triggersForInsecurity.map((trigger) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(trigger)),
                        ],
                      ),
                    );
                  }),
                ],
                if (attachmentProfile.secureBaseBehaviors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Secure Base Behaviors',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...attachmentProfile.secureBaseBehaviors.map((behavior) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(child: Text(behavior)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Conflict profile
        if (analysis.conflictProfile != null)
          _ProfileCard(
            title: 'Conflict Approach',
            icon: Icons.flash_on,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledValue(
                  label: 'Approach',
                  value: analysis.conflictProfile!.approach,
                ),
                if (analysis.conflictProfile!.strengthsInConflict.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Strengths in Conflict',
                    items: analysis.conflictProfile!.strengthsInConflict,
                    icon: Icons.check,
                    color: Colors.green,
                  ),
                ],
                if (analysis.conflictProfile!.challengesInConflict.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Challenges in Conflict',
                    items: analysis.conflictProfile!.challengesInConflict,
                    icon: Icons.close,
                    color: Colors.red,
                  ),
                ],
                if (analysis.conflictProfile!.resolutionPatterns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _LabeledValue(
                    label: 'Resolution Patterns',
                    value: analysis.conflictProfile!.resolutionPatterns,
                  ),
                ],
              ],
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _PatternsTab extends StatelessWidget {
  final Profile profile;

  const _PatternsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final emotionalProfile = analysis.emotionalProfile;
    final behavioralPatterns = analysis.behavioralPatterns;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Emotional profile
        if (emotionalProfile != null) ...[
          _ProfileCard(
            title: 'Emotional Profile',
            icon: Icons.mood,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabeledValue(
                  label: 'Baseline Regulation',
                  value: emotionalProfile.baselineRegulation,
                ),
                if (emotionalProfile.emotionalIntelligenceIndicators
                    .isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _LabeledValue(
                    label: 'Emotional Intelligence',
                    value: emotionalProfile.emotionalIntelligenceIndicators,
                  ),
                ],
                if (emotionalProfile.commonTriggers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Common Triggers',
                    items: emotionalProfile.commonTriggers,
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                ],
                if (emotionalProfile.healthyCopingStrategies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Healthy Coping Strategies',
                    items: emotionalProfile.healthyCopingStrategies,
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
                if (emotionalProfile.unhealthyCopingStrategies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Unhealthy Coping Strategies',
                    items: emotionalProfile.unhealthyCopingStrategies,
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Behavioral patterns
        if (behavioralPatterns != null) ...[
          _ProfileCard(
            title: 'Behavioral Patterns',
            icon: Icons.psychology,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (behavioralPatterns.frequentBehaviors.isNotEmpty) ...[
                  Text(
                    'Frequent Behaviors',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...behavioralPatterns.frequentBehaviors.map((fb) {
                    return _BehaviorTile(behavior: fb);
                  }),
                ],
                if (behavioralPatterns.rareBehaviors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _BulletList(
                    title: 'Rare Behaviors',
                    items: behavioralPatterns.rareBehaviors,
                    icon: Icons.arrow_right,
                    color: Colors.grey,
                  ),
                ],
                if (behavioralPatterns.evolvingPatterns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _LabeledValue(
                    label: 'Evolving Patterns',
                    value: behavioralPatterns.evolvingPatterns,
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

class _TipsTab extends StatelessWidget {
  final Profile profile;

  const _TipsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final analysis = profile.analysis!;
    final recommendations = analysis.communicationRecommendations;

    if (recommendations == null) {
      return const Center(
        child: Text('No communication recommendations available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Best approaches
        if (recommendations.bestApproaches.isNotEmpty)
          _ProfileCard(
            title: 'Best Approaches',
            icon: Icons.lightbulb,
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.bestApproaches.map((approach) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          approach,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Topics to approach carefully
        if (recommendations.topicsToApproachCarefully.isNotEmpty)
          _ProfileCard(
            title: 'Sensitive Topics',
            icon: Icons.warning,
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.topicsToApproachCarefully.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          topic,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Conflict resolution strategies
        if (recommendations.conflictResolutionStrategies.isNotEmpty)
          _ProfileCard(
            title: 'Conflict Resolution Strategies',
            icon: Icons.handshake,
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.conflictResolutionStrategies.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Relationship potential
        if (recommendations.relationshipPotential.isNotEmpty)
          _ProfileCard(
            title: 'Relationship Potential',
            icon: Icons.favorite,
            color: Colors.pink,
            child: Text(
              recommendations.relationshipPotential,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// Helper widgets

class _ProfileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget child;

  const _ProfileCard({
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagsCard extends StatelessWidget {
  final String title;
  final List<String> flags;
  final Color color;
  final IconData icon;

  const _FlagsCard({
    required this.title,
    required this.flags,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...flags.map((flag) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, color: color, size: 8),
                    const SizedBox(width: 8),
                    Expanded(child: Text(flag)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _BulletList({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StrengthTile extends StatelessWidget {
  final ProfileStrength strength;

  const _StrengthTile({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strength.strength,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (strength.evidence.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              strength.evidence,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (strength.impact.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Impact: ${strength.impact}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrowthTile extends StatelessWidget {
  final GrowthOpportunity opportunity;

  const _GrowthTile({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opportunity.area,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (opportunity.currentPattern.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Current: ${opportunity.currentPattern}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (opportunity.suggestedGrowth.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Suggestion: ${opportunity.suggestedGrowth}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BehaviorTile extends StatelessWidget {
  final FrequentBehavior behavior;

  const _BehaviorTile({required this.behavior});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            behavior.behavior,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (behavior.frequency.isNotEmpty) ...[
                Chip(
                  label: Text(
                    behavior.frequency,
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
              ],
              if (behavior.contexts.isNotEmpty)
                Expanded(
                  child: Text(
                    behavior.contexts,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (behavior.impact.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Impact: ${behavior.impact}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
