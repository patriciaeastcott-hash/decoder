/// Main home screen with responsive navigation
///
/// Navigation adapts by screen size:
/// - Phone (compact): Bottom navigation bar
/// - Tablet (medium/expanded): Navigation rail
/// - Desktop (large+): Persistent navigation drawer
///
/// Quick exit uses platform-safe methods:
/// - Android: SystemNavigator.pop()
/// - Desktop/Web: Minimise or close window
/// Main home screen with bottom navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/accessibility_utils.dart';
import '../utils/platform_utils.dart';
import '../utils/responsive_layout.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'conversation/conversation_detail_screen.dart';
import 'profile/profile_detail_screen.dart';
import 'profile/self_profile_screen.dart';
import 'library/behavior_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _ConversationsTab(),
    const _ProfilesTab(),
    const _LibraryTab(),
    const _SettingsTab(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Conversations',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profiles',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Library',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final appState = context.watch<AppStateProvider>();

    // Handle quick exit — platform-safe
    if (appState.quickExitTriggered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performQuickExit();
      });
    }

    return ResponsiveScaffold(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        announceToScreenReader(_getTabName(index));
      },
      destinations: _destinations,
      bodies: _screens,
      title: 'Text Decoder',
      // Quick exit FAB
      floatingActionButton: settings.quickExitEnabled
          ? Semantics(
              label: 'Quick exit button. Double tap to immediately close the app.',
              button: true,
              child: FloatingActionButton.small(
                heroTag: 'quick_exit',
                backgroundColor: AppTheme.red,
                onPressed: () => _handleQuickExit(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            )
          : null,
    );
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Conversations tab';
      case 1:
        return 'Profiles tab';
      case 2:
        return 'Behavior library tab';
      case 3:
        return 'Settings tab';
      default:
        return '';
    }
  }

  void _handleQuickExit(BuildContext context) {
    context.read<AppStateProvider>().triggerQuickExit();
  }

  /// Platform-safe app exit
  void _performQuickExit() {
    if (PlatformUtils.supportsSystemNavigatorPop) {
      // Android: close the app via system navigator
      SystemNavigator.pop();
    } else {
      // iOS/Desktop/Web: navigate to a blank screen (iOS doesn't allow programmatic exit)
      // On desktop, the user can close the window via Ctrl+Q or the window close button
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const _BlankExitScreen()),
        (_) => false,
      );
    }
  }
}

/// Blank screen shown on platforms that don't support programmatic exit
class _BlankExitScreen extends StatelessWidget {
  const _BlankExitScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('You can close this window.'),
      ),
    );
  }
}

// ============================================
// CONVERSATIONS TAB
// ============================================

class _ConversationsTab extends StatelessWidget {
  const _ConversationsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          AccessibleIconButton(
            icon: Icons.add,
            semanticLabel: 'Add new conversation',
            onPressed: () => _showAddConversation(context),
          ),
        ],
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: AccessibleProgressIndicator(
                semanticLabel: 'Loading conversations',
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Add your first conversation to decode',
              actionLabel: 'Add Conversation',
              onAction: () => _showAddConversation(context),
            );
          }

          return ResponsiveContentWrapper(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                return AccessibleListItem(
                  index: index,
                  total: provider.conversations.length,
                  semanticLabel: conversation.accessibilityLabel,
                  semanticHint: conversation.accessibilityHint,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationDetailScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${conversation.messageCount} messages • ${conversation.status.displayName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddConversation(BuildContext context) {
    // Use responsive dialog — bottom sheet on phone, dialog on desktop
    showResponsiveDialog(
      context: context,
      builder: (context) => const _AddConversationSheet(),
    );
  }
}

// ============================================
// PROFILES TAB
// ============================================

class _ProfilesTab extends StatelessWidget {
  const _ProfilesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: AccessibleProgressIndicator(
                semanticLabel: 'Loading profiles',
              ),
            );
          }

          final allProfiles = [
            if (provider.userProfile != null) provider.userProfile!,
            ...provider.speakerProfiles,
          ];

          if (allProfiles.isEmpty) {
            return _EmptyState(
              icon: Icons.person_outline,
              title: 'No profiles yet',
              subtitle: 'Profiles are created from analyzed conversations',
              actionLabel: 'Go to Conversations',
              onAction: () {
                // Switch to conversations tab
                final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                homeState?.setState(() => homeState._currentIndex = 0);
              },
            );
          }

          return ResponsiveContentWrapper(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allProfiles.length,
              itemBuilder: (context, index) {
                final profile = allProfiles[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: profile.isUserProfile
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.secondary,
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(profile.displayName ?? profile.name),
                    subtitle: Text(
                      profile.isUserProfile
                          ? 'Your self-profile'
                          : '${profile.conversationCount} conversations',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (profile.isUserProfile) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelfProfileScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDetailScreen(
                              profileId: profile.id,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// LIBRARY TAB
// ============================================

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Library'),
      ),
      body: Consumer<BehaviorLibraryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: AccessibleProgressIndicator(
                semanticLabel: 'Loading behavior library',
              ),
            );
          }

          if (!provider.isLoaded) {
            return _EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Library unavailable',
              subtitle: 'Unable to load the behavior library',
              actionLabel: 'Retry',
              onAction: () => provider.loadLibrary(),
            );
          }

          return ResponsiveContentWrapper(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(category.category),
                    subtitle: Text('${category.behaviorCount} behaviors'),
                    children: category.subcategories.map((sub) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 72, right: 16, top: 8, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                sub.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                          ...sub.behaviors.map((behavior) {
                            return ListTile(
                              contentPadding: const EdgeInsets.only(left: 72, right: 16),
                              leading: Icon(
                                behavior.isHealthy ? Icons.check_circle : Icons.warning,
                                color: behavior.isHealthy ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              title: Text(behavior.name),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              dense: true,
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
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// SETTINGS TAB
// ============================================

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ResponsiveContentWrapper(
            child: ListView(
              children: [
                // Account section
                _SettingsSection(
                  title: 'Account',
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.isAuthenticated) {
                          return ListTile(
                            leading: const Icon(Icons.account_circle),
                            title: Text(auth.userDisplayName ?? 'Signed in'),
                            subtitle: Text(auth.userEmail ?? ''),
                            trailing: TextButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Sign Out'),
                                    content: const Text('Are you sure you want to sign out?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && context.mounted) {
                                  await context.read<AuthProvider>().signOut();
                                }
                              },
                              child: const Text('Sign Out'),
                            ),
                          );
                        }
                        return ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text('Not signed in'),
                          subtitle: const Text('Tap to sign in'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                // Appearance section
                _SettingsSection(
                  title: 'Appearance',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: const Text('Theme'),
                      trailing: DropdownButton<ThemeMode>(
                        value: settings.themeMode,
                        onChanged: (mode) {
                          if (mode != null) settings.setThemeMode(mode);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Accessibility section
                _SettingsSection(
                  title: 'Accessibility',
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.contrast),
                      title: const Text('High Contrast'),
                      value: settings.highContrastMode,
                      onChanged: settings.setHighContrastMode,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.animation),
                      title: const Text('Reduce Motion'),
                      value: settings.reduceMotion,
                      onChanged: settings.setReduceMotion,
                    ),
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text('Text Size'),
                      trailing: Text('${(settings.fontSizeMultiplier * 100).toInt()}%'),
                      onTap: () => _showTextSizeDialog(context, settings),
                    ),
                  ],
                ),

                // Privacy section
                _SettingsSection(
                  title: 'Privacy & Data',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Data Retention'),
                      subtitle: Text('${settings.dataRetentionMonths} months'),
                      onTap: () => _showRetentionDialog(context, settings),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.sync),
                      title: const Text('Cloud Sync'),
                      subtitle: const Text('Sync data across devices'),
                      value: settings.cloudSyncEnabled,
                      onChanged: settings.setCloudSyncEnabled,
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: AppTheme.red),
                      title: const Text('Delete All Data',
                          style: TextStyle(color: AppTheme.red)),
                      onTap: () => _showDeleteDataDialog(context),
                    ),
                  ],
                ),

                // Safety section
                _SettingsSection(
                  title: 'Safety',
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.exit_to_app),
                      title: const Text('Quick Exit Button'),
                      subtitle: Text(
                        PlatformUtils.isDesktop
                            ? 'Also available via Ctrl+Q'
                            : 'Show button to instantly close app',
                      ),
                      value: settings.quickExitEnabled,
                      onChanged: settings.setQuickExitEnabled,
                    ),
                  ],
                ),

                // Legal section
                _SettingsSection(
                  title: 'Legal',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      onTap: () => _launchUrl(PlatformUtils.privacyPolicyUrl),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms of Service'),
                      onTap: () => _launchUrl(PlatformUtils.termsOfServiceUrl),
                    ),
                  ],
                ),

                // About section
                _SettingsSection(
                  title: 'About',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Text Decoder'),
                      subtitle: Text(
                        'Version 1.0.0 • ${PlatformUtils.platformName}\n'
                        'A Digital ABCs AI App',
                      ),
                      isThreeLine: true,
                    ),
                  ],
                ),

                // Support resources
                _SettingsSection(
                  title: 'Support Resources',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppTheme.green),
                      title: const Text('1800RESPECT'),
                      subtitle: const Text('1800 737 732'),
                      onTap: () => _launchUrl('tel:1800737732'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppTheme.lightBlue),
                      title: const Text('Lifeline'),
                      subtitle: const Text('13 11 14'),
                      onTap: () => _launchUrl('tel:131114'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: settings.fontSizeMultiplier,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(settings.fontSizeMultiplier * 100).toInt()}%',
                  onChanged: (value) {
                    settings.setFontSizeMultiplier(value);
                    setState(() {});
                  },
                ),
                Text(
                  'Preview text at ${(settings.fontSizeMultiplier * 100).toInt()}%',
                  style: TextStyle(fontSize: 16 * settings.fontSizeMultiplier),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showRetentionDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Data Retention Period'),
        children: [3, 6, 12, 24, 36, 60].map((months) {
          return SimpleDialogOption(
            onPressed: () {
              settings.setDataRetentionMonths(months);
              Navigator.pop(context);
            },
            child: Text(months == 60 ? '5 years' : '$months months'),
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your conversations, profiles, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            onPressed: () async {
              Navigator.pop(context);
              final storage = context.read<ConversationProvider>();
              await storage.deleteAllConversations();
              await context.read<ProfileProvider>().deleteAllProfiles();
              await context.read<SettingsProvider>().resetToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data deleted')),
                );
              }
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// ============================================
// HELPER WIDGETS
// ============================================

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddConversationSheet extends StatefulWidget {
  const _AddConversationSheet();

  @override
  State<_AddConversationSheet> createState() => _AddConversationSheetState();
}

class _AddConversationSheetState extends State<_AddConversationSheet> {
  final _textController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Conversation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AccessibleTextField(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Optional conversation title',
            ),
            const SizedBox(height: 16),
            AccessibleTextField(
              controller: _textController,
              labelText: 'Conversation Text',
              hintText: 'Paste your conversation here...',
              maxLines: 8,
              required: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createConversation,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createConversation() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter conversation text')),
      );
      return;
    }

    final provider = context.read<ConversationProvider>();
    final conversation = await provider.createConversation(
      rawText: _textController.text.trim(),
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
      sourceType: 'paste',
    );

    if (mounted) {
      Navigator.pop(context);
      if (conversation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation added')),
        );
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationDetailScreen(
                conversationId: conversation.id,
              ),
            ),
          );
        }
      }
    }
  }
}
