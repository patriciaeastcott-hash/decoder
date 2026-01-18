import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LinguisticDecoderApp());
}

class LinguisticDecoderApp extends StatelessWidget {
  const LinguisticDecoderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linguistic Decoder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF7C3AED),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================================
// STORAGE SERVICE - Manages saved analyses
// ============================================================================
class StorageService {
  static const String _savedAnalysesKey = 'saved_analyses';

  static Future<List<Map<String, dynamic>>> getSavedAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_savedAnalysesKey);
    if (savedData == null) return [];

    final List<dynamic> decoded = jsonDecode(savedData);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<bool> saveAnalysis(Map<String, dynamic> analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existing = await getSavedAnalyses();

      // Add timestamp and unique ID
      analysis['saved_at'] = DateTime.now().toIso8601String();
      analysis['id'] = DateTime.now().millisecondsSinceEpoch.toString();

      existing.insert(0, analysis); // Add to beginning
      await prefs.setString(_savedAnalysesKey, jsonEncode(existing));
      return true;
    } catch (e) {
      print('Error saving analysis: $e');
      return false;
    }
  }

  static Future<bool> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> existing = await getSavedAnalyses();
      existing.removeWhere((item) => item['id'] == id);
      await prefs.setString(_savedAnalysesKey, jsonEncode(existing));
      return true;
    } catch (e) {
      print('Error deleting analysis: $e');
      return false;
    }
  }
}

// ============================================================================
// HOME SCREEN - Main Dashboard
// ============================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Linguistic Decoder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Decode communication dynamics with AI-powered insights',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardTile(
                      context,
                      icon: Icons.psychology,
                      title: 'Decode Now',
                      subtitle: 'Analyze conversation',
                      color: const Color(0xFF7C3AED),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DecoderScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.history,
                      title: 'Past Decodes',
                      subtitle: 'View history',
                      color: const Color(0xFF059669),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PastDecodesScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.menu_book,
                      title: 'Library',
                      subtitle: 'Learning resources',
                      color: const Color(0xFFEA580C),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LibraryScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.person,
                      title: 'Profile',
                      subtitle: 'Your account',
                      color: const Color(0xFF0891B2),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      color: const Color(0xFF6B7280),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help',
                      subtitle: 'Support & FAQ',
                      color: const Color(0xFFDB2777),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DECODER SCREEN - Main Analysis Feature with Context
// ============================================================================
class DecoderScreen extends StatefulWidget {
  const DecoderScreen({super.key});

  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  int _selectedSpeakerIndex = 0;

  // Context options
  String? _selectedRelationship;
  String? _selectedAgeGroup;

  final List<String> _relationships = [
    'Professional (Manager/Employee)',
    'Professional (Colleagues)',
    'Romantic (Dating)',
    'Romantic (Married/Partnership)',
    'Family (Parent/Child)',
    'Family (Siblings)',
    'Family (Extended Family)',
    'Friends',
    'Housemates/Roommates',
    'Acquaintances',
    'Other',
  ];

  final List<String> _ageGroups = [
    'Children (under 13)',
    'Teenagers (13-17)',
    'Young Adults (18-25)',
    'Adults (26-40)',
    'Middle Age (41-60)',
    'Seniors (60+)',
    'Mixed Ages',
  ];

  final String apiBaseUrl = "http://127.0.0.1:5000/analyze";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      _showError("Please enter some text to analyze");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
      _selectedSpeakerIndex = 0;
    });

    try {
      // Build context string for AI
      String contextInfo = '';
      if (_selectedRelationship != null || _selectedAgeGroup != null) {
        contextInfo = '\n\nCONTEXT INFORMATION:\n';
        if (_selectedRelationship != null) {
          contextInfo += 'Relationship Type: $_selectedRelationship\n';
        }
        if (_selectedAgeGroup != null) {
          contextInfo += 'Age Group: $_selectedAgeGroup\n';
        }
        contextInfo += 'Please consider this context in your analysis.\n';
      }

      final response = await http
          .post(
            Uri.parse(apiBaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"text": input + contextInfo}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['speakers'] == null || decoded['speakers'] is! List) {
          throw Exception("Invalid response: missing speakers data");
        }

        if ((decoded['speakers'] as List).isEmpty) {
          throw Exception("No speakers detected in the conversation");
        }

        // Store context with result
        decoded['context'] = {
          'relationship': _selectedRelationship,
          'age_group': _selectedAgeGroup,
        };

        setState(() => _result = decoded);

        // Auto-save after successful analysis
        _autoSaveAnalysis();
      } else {
        final decoded = jsonDecode(response.body);
        _showError(decoded['message'] ?? decoded['error'] ?? 'Server error');
      }
    } catch (e) {
      _showError(_getErrorMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _autoSaveAnalysis() async {
    if (_result == null) return;

    final success = await StorageService.saveAnalysis(_result!);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Analysis auto-saved to library"),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timed out')) {
      return "Request timed out. Please check your connection and try again.";
    } else if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection')) {
      return "Cannot connect to server. Please check:\n• Your internet connection\n• Server is running\n• Correct IP address";
    } else if (error.toString().contains('FormatException')) {
      return "Received invalid data from server. Please try again.";
    }
    return "Error: ${error.toString()}";
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Decode Conversation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _result == null ? _buildInputForm() : _buildResults(),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'How it works',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paste any conversation and add context for more accurate insights. Your analysis will be auto-saved.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Context Section
          const Text(
            "Context (Optional but Recommended)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Relationship Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _selectedRelationship,
            items: _relationships.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() => _selectedRelationship = newValue);
            },
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Age Group',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _selectedAgeGroup,
            items: _ageGroups.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() => _selectedAgeGroup = newValue);
            },
          ),
          const SizedBox(height: 20),

          const Text(
            "Conversation Text:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            maxLines: 12,
            decoration: InputDecoration(
              hintText:
                  "Example:\nPerson A: I can't believe you did that...\nPerson B: What are you talking about?",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF7C3AED)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeText,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "ANALYZE CONVERSATION",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults() {
    final List<dynamic> speakers = _result!['speakers'] ?? [];
    final Map<String, dynamic> overview =
        _result!['conversation_overview'] ?? {};

    if (speakers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('No speakers detected'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _result = null),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E3A8A),
                const Color(0xFF1E3A8A).withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overview['overall_dynamic'] ?? 'Analysis Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge(
                    'Speakers: ${overview['detected_speakers'] ?? speakers.length}',
                    Colors.white.withOpacity(0.3),
                  ),
                  _buildBadge(
                    'Conflict: ${overview['conflict_level'] ?? 'Unknown'}',
                    _getConflictColor(overview['conflict_level']),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (speakers.length > 1)
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(speakers.length, (index) {
                  final speaker = speakers[index];
                  final isSelected = index == _selectedSpeakerIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpeakerIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? const Color(0xFF7C3AED)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        (speaker['label'] ?? 'Speaker ${index + 1}')
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF7C3AED)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

        Expanded(child: _buildSpeakerDetail(speakers[_selectedSpeakerIndex])),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _result = null),
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Analysis'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PastDecodesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.library_books),
                  label: const Text('View Saved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getConflictColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'high':
        return Colors.red.withOpacity(0.7);
      case 'medium':
        return Colors.orange.withOpacity(0.7);
      case 'low':
        return Colors.green.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  Widget _buildSpeakerDetail(Map<String, dynamic> speaker) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.psychology,
            title: 'EMOTIONAL STATE',
            color: const Color(0xFF7C3AED),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker['likely_emotional_state'] ?? 'Not specified',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildChip(
                      speaker['sentiment_category'] ?? 'Unknown',
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildInfoCard(
            icon: Icons.translate,
            title: 'PLAIN ENGLISH TRANSLATION',
            color: const Color(0xFF059669),
            child: Text(
              '"${speaker['translation'] ?? 'No translation available'}"',
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          _buildInfoCard(
            icon: Icons.analytics,
            title: 'PSYCHOLOGICAL ANALYSIS',
            color: const Color(0xFFEA580C),
            child: Text(
              speaker['deep_dive'] ?? 'No analysis available',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),

          if (speaker['communication_goals'] != null)
            _buildInfoCard(
              icon: Icons.track_changes,
              title: 'COMMUNICATION GOALS',
              color: const Color(0xFF0891B2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (speaker['communication_goals'] as List)
                    .map(
                      (goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0891B2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                goal.toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          if (speaker['advice'] != null)
            _buildInfoCard(
              icon: Icons.lightbulb_outline,
              title: 'ACTIONABLE GUIDANCE',
              color: const Color(0xFFDB2777),
              child: Text(
                speaker['advice'],
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

          if (speaker['response_options'] != null)
            _buildInfoCard(
              icon: Icons.reply,
              title: 'SUGGESTED RESPONSES',
              color: const Color(0xFF7C3AED),
              child: Column(
                children: (speaker['response_options'] as List)
                    .map(
                      (option) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (option['style'] ?? 'Response')
                                        .toString()
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    onPressed: () =>
                                        _copyToClipboard(option['text'] ?? ''),
                                    tooltip: 'Copy response',
                                  ),
                                ],
                              ),
                              Text(
                                option['text'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // NEW: Test Your Response Section
          ResponseTestWidget(
            currentAnalysis: _result!,
            speakerLabel: speaker['label'] ?? 'Unknown',
            apiBaseUrl: apiBaseUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
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

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ============================================================================
// RESPONSE TEST WIDGET - Test how your response will impact the conversation
// ============================================================================
class ResponseTestWidget extends StatefulWidget {
  final Map<String, dynamic> currentAnalysis;
  final String speakerLabel;
  final String apiBaseUrl;

  const ResponseTestWidget({
    super.key,
    required this.currentAnalysis,
    required this.speakerLabel,
    required this.apiBaseUrl,
  });

  @override
  State<ResponseTestWidget> createState() => _ResponseTestWidgetState();
}

class _ResponseTestWidgetState extends State<ResponseTestWidget> {
  final TextEditingController _responseController = TextEditingController();
  bool _isThisSpeaker = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _impactAnalysis;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _analyzeResponseImpact() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your proposed response')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _impactAnalysis = null;
    });

    try {
      // Build impact analysis prompt
      final prompt =
          """
CURRENT ANALYSIS CONTEXT:
${jsonEncode(widget.currentAnalysis)}

USER IDENTITY: ${_isThisSpeaker ? 'I am ${widget.speakerLabel}' : 'I am responding to ${widget.speakerLabel}'}

PROPOSED RESPONSE:
"${_responseController.text.trim()}"

TASK: Analyze how this proposed response will impact the conversation dynamics. Provide:
1. Likely emotional reaction from the other party
2. Whether this escalates, de-escalates, or maintains current tension
3. Potential misinterpretations or unintended consequences
4. Effectiveness rating (1-10)
5. Suggested improvements (if any)

Output ONLY valid JSON in this format:
{
  "impact_summary": "Brief overview of likely impact",
  "emotional_reaction": "How the other person will likely feel/react",
  "tension_effect": "Escalates / De-escalates / Maintains",
  "effectiveness_rating": 7,
  "potential_risks": ["risk1", "risk2"],
  "strengths": ["strength1", "strength2"],
  "suggested_improvements": "Specific suggestions to improve this response",
  "verdict": "Overall assessment: Recommended / Use with caution / Not recommended"
}
""";

      final response = await http
          .post(
            Uri.parse(
              widget.apiBaseUrl.replaceAll('/analyze', '/analyze_impact'),
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"text": prompt}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() => _impactAnalysis = decoded);
      } else {
        throw Exception('Analysis failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline, color: Color(0xFF7C3AED)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'TEST YOUR RESPONSE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'See how your response will impact the conversation before sending it.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          title: Text('I am ${widget.speakerLabel}'),
          value: _isThisSpeaker,
          onChanged: (bool? value) {
            setState(() => _isThisSpeaker = value ?? false);
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 12),
        TextField(
          controller: _responseController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your proposed response here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeResponseImpact,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.psychology),
            label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Impact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        if (_impactAnalysis != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMPACT ANALYSIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                _buildImpactRow(
                  'Summary',
                  _impactAnalysis!['impact_summary'] ?? 'N/A',
                  Icons.summarize,
                ),
                _buildImpactRow(
                  'Tension Effect',
                  _impactAnalysis!['tension_effect'] ?? 'Unknown',
                  Icons.trending_up,
                ),
                _buildImpactRow(
                  'Effectiveness',
                  '${_impactAnalysis!['effectiveness_rating'] ?? 0}/10',
                  Icons.star,
                ),

                if (_impactAnalysis!['strengths'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Strengths:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  ...(_impactAnalysis!['strengths'] as List).map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text('✓ $s', style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],

                if (_impactAnalysis!['potential_risks'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Potential Risks:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  ...(_impactAnalysis!['potential_risks'] as List).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text('⚠ $r', style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],

                if (_impactAnalysis!['suggested_improvements'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Suggested Improvements:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      _impactAnalysis!['suggested_improvements'],
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getVerdictColor(_impactAnalysis!['verdict']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getVerdictIcon(_impactAnalysis!['verdict']),
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _impactAnalysis!['verdict'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImpactRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Color _getVerdictColor(String? verdict) {
    if (verdict == null) return Colors.grey;
    if (verdict.toLowerCase().contains('recommended')) return Colors.green;
    if (verdict.toLowerCase().contains('caution')) return Colors.orange;
    return Colors.red;
  }

  IconData _getVerdictIcon(String? verdict) {
    if (verdict == null) return Icons.help;
    if (verdict.toLowerCase().contains('recommended'))
      return Icons.check_circle;
    if (verdict.toLowerCase().contains('caution')) return Icons.warning;
    return Icons.cancel;
  }
}

// ============================================================================
// PAST DECODES SCREEN - With Delete Functionality
// ============================================================================
class PastDecodesScreen extends StatefulWidget {
  const PastDecodesScreen({super.key});

  @override
  State<PastDecodesScreen> createState() => _PastDecodesScreenState();
}

class _PastDecodesScreenState extends State<PastDecodesScreen> {
  List<Map<String, dynamic>> _savedAnalyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAnalyses();
  }

  Future<void> _loadSavedAnalyses() async {
    setState(() => _isLoading = true);
    final analyses = await StorageService.getSavedAnalyses();
    setState(() {
      _savedAnalyses = analyses;
      _isLoading = false;
    });
  }

  Future<void> _deleteAnalysis(String id) async {
    final success = await StorageService.deleteAnalysis(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis deleted'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      _loadSavedAnalyses();
    }
  }

  void _confirmDelete(String id, String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Analysis?'),
        content: Text(
          'Are you sure you want to delete this analysis?\n\n"$summary"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnalysis(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Past Decodes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_savedAnalyses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Past Decodes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  'No Saved Analyses Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your decoded conversations will be auto-saved here.\nStart by analyzing your first conversation!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DecoderScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Past Decodes (${_savedAnalyses.length})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedAnalyses.length,
        itemBuilder: (context, index) {
          final analysis = _savedAnalyses[index];
          final overview = analysis['conversation_overview'] ?? {};
          final savedAt = analysis['saved_at'] != null
              ? DateTime.parse(analysis['saved_at'])
              : DateTime.now();
          final context_data = analysis['context'] ?? {};

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to detailed view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Detailed view coming soon!')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            overview['overall_dynamic'] ??
                                'Conversation Analysis',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(
                            analysis['id'],
                            overview['overall_dynamic'] ?? 'this analysis',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSmallBadge(
                          '${overview['detected_speakers'] ?? 0} Speakers',
                          Colors.blue,
                        ),
                        _buildSmallBadge(
                          overview['conflict_level'] ?? 'Unknown',
                          _getConflictBadgeColor(overview['conflict_level']),
                        ),
                        if (context_data['relationship'] != null)
                          _buildSmallBadge(
                            context_data['relationship']
                                .toString()
                                .split('(')
                                .first
                                .trim(),
                            Colors.purple,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(savedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getConflictBadgeColor(String? level) {
    switch (level?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}

// ============================================================================
// LIBRARY SCREEN - Educational Resources
// ============================================================================
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  final List<Map<String, String>> _articles = const [
    {
      "title": "Understanding Communication Patterns",
      "content":
          """Communication patterns reveal deeper dynamics in our interactions. Pay attention to:

• Recurring themes in conversations
• Who initiates and who responds
• Tone shifts and emotional cues
• Unspoken assumptions

Self-Reflection: Notice when you feel defensive or when conversations loop. These patterns often signal unmet needs or unresolved conflicts.""",
    },
    {
      "title": "The Grey Rock Method",
      "content":
          """When dealing with high-conflict situations, the Grey Rock method can help protect your emotional energy.

How to Practice:
• Keep responses brief and factual
• Show minimal emotional reaction
• Avoid sharing personal information
• Don't ask questions that invite drama

Why It Works: High-conflict interactions often feed on emotional reactions. By remaining neutral and uninteresting, you reduce the fuel for conflict.""",
    },
    {
      "title": "Setting Healthy Boundaries",
      "content":
          """Boundaries are not walls—they're guidelines for how you want to be treated.

Effective Boundaries Include:
• Clear statements of your limits
• Consistent enforcement
• Respect for others' boundaries too
• Flexibility when appropriate

Remember: "No" is a complete sentence. You don't always need to justify your boundaries.""",
    },
    {
      "title": "Active Listening Skills",
      "content":
          """True listening goes beyond hearing words—it's about understanding meaning and emotion.

Practice Active Listening:
• Focus fully on the speaker
• Don't interrupt or plan your response
• Reflect back what you heard
• Ask clarifying questions
• Validate their feelings

Tip: Notice the difference between listening to understand vs. listening to respond.""",
    },
    {
      "title": "The BIFF Response Method",
      "content":
          """For difficult emails or messages, use BIFF to stay professional and effective:

• Brief: Keep it concise (2-5 sentences)
• Informative: Stick to facts only
• Friendly: Maintain a neutral, polite tone
• Firm: State your position clearly

Example: 'I understand your concern. The deadline is Friday. I'll send the report by then. Thanks.'""",
    },
    {
      "title": "Recognizing Emotional Manipulation",
      "content": """Common manipulation tactics to be aware of:

• Guilt-tripping: Making you feel responsible for their emotions
• Minimization: Downplaying your concerns
• Deflection: Changing the subject to avoid accountability
• Silent treatment: Using withdrawal as punishment

Self-Protection: Trust your feelings. If something feels off, it usually is. Document important conversations and seek support.""",
    },
    {
      "title": "Understanding 'I' Statements",
      "content":
          """'I' statements reduce defensiveness and promote understanding.

Formula: 'I feel [emotion] when [situation] because [reason].'

Examples:
❌ 'You never listen to me!'
✅ 'I feel unheard when I'm interrupted because my thoughts feel dismissed.'

❌ 'You're so selfish!'
✅ 'I feel hurt when plans change without discussion because I value being included.'

Practice: Reframe your frustrations using this structure before communicating.""",
    },
    {
      "title": "Digital Communication Safety",
      "content": """Protecting yourself in digital spaces is essential.

Best Practices:
• Take 24 hours before responding to heated messages
• Use the block/mute features without guilt
• Screenshot important exchanges for documentation
• Don't engage with trolling or baiting
• Keep professional and personal accounts separate

Remember: You control your digital boundaries. It's okay to disengage from toxic interactions.""",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Library',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: Color(0xFF7C3AED)),
              ),
              title: Text(
                _articles[index]["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _articles[index]["content"]!,
                    style: const TextStyle(height: 1.6, fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// PROFILE SCREEN
// ============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'User Profile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since January 2026',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: StorageService.getSavedAnalyses(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Column(
                        children: [
                          _buildStatRow(
                            'Total Analyses',
                            count.toString(),
                            Icons.analytics,
                          ),
                          _buildStatRow('Articles Read', '0', Icons.menu_book),
                          _buildStatRow(
                            'Saved Decodes',
                            count.toString(),
                            Icons.bookmark,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
            },
          ),
          _buildActionTile(
            context,
            icon: Icons.lock,
            title: 'Privacy',
            subtitle: 'Privacy and data settings',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
            },
          ),
          _buildActionTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7C3AED)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// SETTINGS SCREEN
// ============================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final String privacyPolicyUrl = "https://digitalabcs.com.au/privacy.html";
  final String eulaUrl = "https://digitalabcs.com.au/terms.html";

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Legal & Compliance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () => _launchUrl(privacyPolicyUrl),
          ),
          _buildSettingsTile(
            icon: Icons.gavel,
            title: 'Terms of Use',
            subtitle: 'End User License Agreement',
            onTap: () => _launchUrl(eulaUrl),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: const Text(
              '1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.code,
            title: 'Open Source Licenses',
            subtitle: 'View third-party licenses',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Linguistic Decoder',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Educational Tool Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This app provides linguistic analysis for educational purposes only. It is not a substitute for professional mental health services, legal advice, or medical diagnosis. If you are experiencing a crisis, please contact appropriate emergency services or mental health professionals.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7C3AED)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// HELP SCREEN
// ============================================================================
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Color(0xFF7C3AED),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqTile(
            'How does the analysis work?',
            'The app uses advanced AI to analyze communication patterns, emotional states, and rhetorical strategies in conversations. It provides objective insights based on linguistic analysis, not psychological diagnosis.',
          ),
          _buildFaqTile(
            'Is my data private?',
            'Yes. Your conversations are analyzed in real-time and automatically saved only on your device. We do not store your data on our servers or share it with third parties.',
          ),
          _buildFaqTile(
            'Can I delete saved analyses?',
            'Yes! Go to Past Decodes and tap the delete icon on any saved analysis to remove it permanently from your device.',
          ),
          _buildFaqTile(
            'What is the "Test Your Response" feature?',
            'This feature allows you to type a proposed response and see how it might impact the conversation before sending it. The AI analyzes potential risks, strengths, and suggests improvements.',
          ),
          _buildFaqTile(
            'What kind of conversations can I analyze?',
            'You can analyze any text-based conversation: emails, text messages, chat logs, or any written communication. The AI will detect multiple speakers automatically.',
          ),
          _buildFaqTile(
            'Is this a therapy or medical tool?',
            'No. This is an educational tool for understanding communication patterns. It is not a substitute for professional mental health services, therapy, or medical advice.',
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need More Help?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Contact us at:'),
                  const SizedBox(height: 8),
                  Text(
                    'support@digitalabcs.com.au',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }
}
