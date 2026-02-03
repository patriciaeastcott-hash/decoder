/// Behavior detail screen - view detailed information about a behavior from the library

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/accessibility_utils.dart';

class BehaviorDetailScreen extends StatelessWidget {
  final String behaviorId;

  const BehaviorDetailScreen({
    super.key,
    required this.behaviorId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BehaviorLibraryProvider>(
      builder: (context, provider, _) {
        final behavior = provider.getBehaviorById(behaviorId);

        if (behavior == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Behavior')),
            body: const Center(child: Text('Behavior not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(behavior.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareBehavior(context, behavior),
                tooltip: 'Share',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Semantics(
              label: 'Behavior details for ${behavior.name}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with category info
                  _BehaviorHeader(behavior: behavior),

                  const SizedBox(height: 24),

                  // Definition
                  _Section(
                    title: 'Definition',
                    icon: Icons.menu_book,
                    child: Text(
                      behavior.definition,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Examples
                  if (behavior.examples.isNotEmpty)
                    _Section(
                      title: 'Examples',
                      icon: Icons.format_quote,
                      child: Column(
                        children: behavior.examples.map((example) {
                          return _ExampleCard(example: example);
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Healthy vs Unhealthy Indicators
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (behavior.healthyIndicators.isNotEmpty)
                        Expanded(
                          child: _IndicatorsCard(
                            title: 'Healthy Indicators',
                            indicators: behavior.healthyIndicators,
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        ),
                      if (behavior.healthyIndicators.isNotEmpty &&
                          behavior.unhealthyIndicators.isNotEmpty)
                        const SizedBox(width: 12),
                      if (behavior.unhealthyIndicators.isNotEmpty)
                        Expanded(
                          child: _IndicatorsCard(
                            title: 'Unhealthy Indicators',
                            indicators: behavior.unhealthyIndicators,
                            color: Colors.red,
                            icon: Icons.warning,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Context and impact
                  if (behavior.commonContexts.isNotEmpty ||
                      behavior.potentialImpact.isNotEmpty)
                    _Section(
                      title: 'Context & Impact',
                      icon: Icons.psychology,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (behavior.commonContexts.isNotEmpty) ...[
                            Text(
                              'Common Contexts',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: behavior.commonContexts.map((ctx) {
                                return Chip(
                                  label: Text(ctx),
                                  backgroundColor:
                                      Theme.of(context).primaryColor.withOpacity(0.1),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (behavior.potentialImpact.isNotEmpty) ...[
                            Text(
                              'Potential Impact',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(behavior.potentialImpact),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Related behaviors
                  if (behavior.relatedBehaviors.isNotEmpty)
                    _Section(
                      title: 'Related Behaviors',
                      icon: Icons.link,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: behavior.relatedBehaviors.map((relatedId) {
                          final related = provider.getBehaviorById(relatedId);
                          if (related == null) return const SizedBox.shrink();
                          return ActionChip(
                            label: Text(related.name),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BehaviorDetailScreen(
                                    behaviorId: relatedId,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Tips for healthy communication
                  if (behavior.communicationTips.isNotEmpty)
                    _Section(
                      title: 'Communication Tips',
                      icon: Icons.lightbulb,
                      color: Colors.amber,
                      child: Column(
                        children: behavior.communicationTips.map((tip) {
                          return _TipCard(tip: tip);
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareBehavior(BuildContext context, Behavior behavior) {
    // In a real app, this would use share_plus or similar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share "${behavior.name}" - Coming soon'),
      ),
    );
  }
}

class _BehaviorHeader extends StatelessWidget {
  final Behavior behavior;

  const _BehaviorHeader({required this.behavior});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breadcrumb
          Row(
            children: [
              Icon(Icons.folder, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 4),
              Text(
                behavior.category,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              if (behavior.subcategory.isNotEmpty) ...[
                Icon(Icons.chevron_right,
                    color: Colors.white.withOpacity(0.6), size: 16),
                Text(
                  behavior.subcategory,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Behavior name
          Text(
            behavior.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderTag(
                label: behavior.isHealthy ? 'Healthy' : 'Potentially Harmful',
                color: behavior.isHealthy ? Colors.green : Colors.orange,
                icon: behavior.isHealthy ? Icons.favorite : Icons.warning,
              ),
              if (behavior.severity.isNotEmpty)
                _HeaderTag(
                  label: behavior.severity,
                  color: _getSeverityColor(behavior.severity),
                  icon: Icons.speed,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    final lower = severity.toLowerCase();
    if (lower.contains('high') || lower.contains('severe')) return Colors.red;
    if (lower.contains('moderate') || lower.contains('medium')) {
      return Colors.orange;
    }
    return Colors.blue;
  }
}

class _HeaderTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _HeaderTag({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sectionColor = color ?? Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: sectionColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: sectionColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String example;

  const _ExampleCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote,
              color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              example,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorsCard extends StatelessWidget {
  final String title;
  final List<String> indicators;
  final Color color;
  final IconData icon;

  const _IndicatorsCard({
    required this.title,
    required this.indicators,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...indicators.map((indicator) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        indicator,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
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

class _TipCard extends StatelessWidget {
  final String tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen for browsing the behavior library by category
class BehaviorLibraryScreen extends StatefulWidget {
  const BehaviorLibraryScreen({super.key});

  @override
  State<BehaviorLibraryScreen> createState() => _BehaviorLibraryScreenState();
}

class _BehaviorLibraryScreenState extends State<BehaviorLibraryScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BehaviorLibraryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final categories = provider.categories;
        final filteredBehaviors = _selectedCategory != null
            ? provider.getBehaviorsByCategory(_selectedCategory!)
            : _searchController.text.isNotEmpty
                ? provider.searchBehaviors(_searchController.text)
                : <Behavior>[];

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: AccessibleTextField(
                controller: _searchController,
                labelText: 'Search behaviors',
                hintText: 'Search by name or description...',
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _selectedCategory = null;
                    }
                  });
                },
              ),
            ),

            // Category chips or search results
            if (_searchController.text.isEmpty) ...[
              // Category list
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isExpanded = _selectedCategory == category.name;

                    return _CategoryExpansionTile(
                      category: category,
                      isExpanded: isExpanded,
                      onTap: () {
                        setState(() {
                          _selectedCategory =
                              isExpanded ? null : category.name;
                        });
                      },
                      onBehaviorTap: (behavior) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BehaviorDetailScreen(
                              behaviorId: behavior.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ] else ...[
              // Search results
              Expanded(
                child: filteredBehaviors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No behaviors found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredBehaviors.length,
                        itemBuilder: (context, index) {
                          final behavior = filteredBehaviors[index];
                          return _BehaviorListTile(
                            behavior: behavior,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BehaviorDetailScreen(
                                    behaviorId: behavior.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryExpansionTile extends StatelessWidget {
  final BehaviorCategory category;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(Behavior) onBehaviorTap;

  const _CategoryExpansionTile({
    required this.category,
    required this.isExpanded,
    required this.onTap,
    required this.onBehaviorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _getCategoryIcon(category.name),
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${category.totalBehaviors} behaviors',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onTap,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            ...category.subcategories.map((sub) {
              return _SubcategorySection(
                subcategory: sub,
                onBehaviorTap: onBehaviorTap,
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('communication')) return Icons.chat_bubble;
    if (lower.contains('manipulation')) return Icons.warning;
    if (lower.contains('defense')) return Icons.shield;
    if (lower.contains('attachment')) return Icons.link;
    if (lower.contains('emotional')) return Icons.mood;
    if (lower.contains('conflict')) return Icons.flash_on;
    if (lower.contains('trust')) return Icons.handshake;
    if (lower.contains('cognitive')) return Icons.psychology;
    if (lower.contains('boundary')) return Icons.border_all;
    if (lower.contains('positive')) return Icons.favorite;
    return Icons.category;
  }
}

class _SubcategorySection extends StatelessWidget {
  final BehaviorSubcategory subcategory;
  final Function(Behavior) onBehaviorTap;

  const _SubcategorySection({
    required this.subcategory,
    required this.onBehaviorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            subcategory.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...subcategory.behaviors.map((behavior) {
          return _BehaviorListTile(
            behavior: behavior,
            onTap: () => onBehaviorTap(behavior),
            compact: true,
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BehaviorListTile extends StatelessWidget {
  final Behavior behavior;
  final VoidCallback onTap;
  final bool compact;

  const _BehaviorListTile({
    required this.behavior,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: compact,
      contentPadding: compact
          ? const EdgeInsets.symmetric(horizontal: 24)
          : const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(
        behavior.isHealthy ? Icons.check_circle : Icons.warning,
        color: behavior.isHealthy ? Colors.green : Colors.orange,
        size: compact ? 20 : 24,
      ),
      title: Text(
        behavior.name,
        style: TextStyle(
          fontWeight: compact ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      subtitle: compact
          ? null
          : Text(
              behavior.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
