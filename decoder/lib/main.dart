import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'content_data.dart';
import 'package:google_fonts/google_fonts.dart';

// --- CONFIGURATION ---
const String kPrivacyUrl = "https://digitalabcs.com.au/privacy.html";
const String kTermsUrl = "https://digitalabcs.com.au/terms.html";
const String kApiBaseUrl =
    "https://decoder-backend-222632046587.australia-southeast1.run.app";

// --- THEME ---
const Color kColorNavy = Color(0xFF1E3A8A);
const Color kColorPurple = Color(0xFF7C3AED);
const Color kColorBackground = Color(0xFFF3F4F6);
const Color kColorGreen = Color(0xFF10B981);
const Color kColorError = Color(0xFFDC2626);
const Color kColorGold = Color(0xFFD4AF37);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ .env not found, using defaults");
  }
  runApp(const LinguisticDecoderApp());
}

class LinguisticDecoderApp extends StatelessWidget {
  const LinguisticDecoderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Linguistic Decoder',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
        primaryColor: kColorNavy,
        scaffoldBackgroundColor: kColorBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kColorNavy),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// WIDGETS: Quick Exit & Safe Mode
// ============================================================================
class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    // FIXED: Wrapped in Align to avoid Positioned nesting issues
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FloatingActionButton.extended(
          backgroundColor: kColorError,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SafeModeScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          label: const Text("QUICK EXIT",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class SafeModeScreen extends StatelessWidget {
  const SafeModeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny, size: 100, color: Colors.amber),
            SizedBox(height: 20),
            Text("72°F",
                style: TextStyle(
                    fontSize: 60,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text("Sunny", style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. SPLASH SCREEN
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool('isAgeVerified') ?? false)) {
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AgeVerificationScreen()));
      return;
    }

    final hasPaid = prefs.getBool('hasPaidPremium') ?? false;
    if (!mounted) return;

    if (hasPaid) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kColorNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text("Linguistic Decoder",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: kColorPurple),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1.5 AGE VERIFICATION
// ============================================================================
class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorNavy,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text("Age Verification",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
                "This tool utilizes AI to decode communication. You must be 17+ to use this application.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(kTermsUrl)),
              child: const Text(
                  "By continuing, you agree to our Terms of Service.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white54,
                      decoration: TextDecoration.underline,
                      fontSize: 12)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isAgeVerified', true);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()));
                  }
                },
                child: const Text("Confirm Eligibility"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. PAYWALL SCREEN
// ============================================================================
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;

  void _restorePurchase() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasPaidPremium', true);

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorNavy,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_open, size: 60, color: kColorPurple),
            const SizedBox(height: 20),
            const Text("Unlock Premium",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Get unlimited analysis, speaker profiling, and response simulation.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _restorePurchase,
                    child: const Text("Start Free Trial")),
            TextButton(
              onPressed: _restorePurchase,
              child: const Text("Restore Purchase",
                  style: TextStyle(color: Colors.white54)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. DASHBOARD SCREEN (Fixed Layout)
// ============================================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kColorNavy,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Linguistic Decoder",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("by",
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/logo.png',
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.psychology, color: Colors.white),
            ),
          ],
        ),
      ),
      // FIXED: Use Stack to properly layer QuickExitButton over content
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _DashboardTile(
                    title: "AI Decoder",
                    icon: Icons.psychology,
                    color: kColorGreen,
                    onTap: () => _navigateToDecoder(context)),
                _DashboardTile(
                    title: "Speaker Profiles",
                    icon: Icons.people,
                    color: kColorGold,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SpeakerProfilesScreen()))),
                _DashboardTile(
                    title: "Library",
                    icon: Icons.menu_book,
                    color: kColorPurple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LibraryScreen()))),
                _DashboardTile(
                    title: "Settings",
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()))),
              ],
            ),
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }

  Future<void> _navigateToDecoder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? pin = prefs.getString('parentalPin');

    if (pin != null && pin.isNotEmpty) {
      if (!context.mounted) return;
      final bool? verified = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _PinDialog(correctPin: pin));
      if (verified != true) return;
    }

    if (!context.mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DecoderScreen()));
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardTile(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. DECODER SCREEN
// ============================================================================
class DecoderScreen extends StatefulWidget {
  const DecoderScreen({super.key});
  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _analyze() async {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter text to analyze")));
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final String baseUrl = dotenv.env['API_URL'] ?? kApiBaseUrl;
      debugPrint("Connecting to: $baseUrl/analyze");

      final response = await http
          .post(
            Uri.parse("$baseUrl/analyze"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": _inputController.text}),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] != null && data['error'] != "null") {
          throw Exception(data['message'] ?? "Analysis Error");
        }

        setState(() => _result = data);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut);
          }
        });
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Analysis Error: $e");
      String msg = "Connection failed.";
      if (e.toString().contains("SocketException"))
        msg = "Could not reach server. Check internet.";
      if (e.toString().contains("TimeoutException"))
        msg = "Server timed out. Text may be too long.";

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: kColorError));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToProfile(Map<String, dynamic> analysisData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesStr = prefs.getString('speaker_profiles');
    List<dynamic> profiles = profilesStr != null ? jsonDecode(profilesStr) : [];

    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No profiles found. Create one in Dashboard first.")));
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Save to Profile"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (c, i) {
              final p = profiles[i];
              return ListTile(
                title: Text(p['name']),
                leading: const Icon(Icons.person),
                onTap: () async {
                  if (p['logs'] == null) p['logs'] = [];
                  (p['logs'] as List).add({
                    'date': DateTime.now().toIso8601String(),
                    'text': _inputController.text,
                    'analysis': analysisData
                  });
                  profiles[i] = p;
                  await prefs.setString(
                      'speaker_profiles', jsonEncode(profiles));

                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Saved to ${p['name']}")));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Decoder", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _inputController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText:
                            "Paste conversation here (Emails, Texts, Transcripts)...",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kColorGreen),
                        onPressed: _isLoading ? null : _analyze,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Analyze"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_result != null) ...[
                      _TranscriptVerificationCard(
                        transcript: List<Map<String, dynamic>>.from(
                            _result!['transcript_log'] ?? []),
                        onUpdate: (updatedTranscript) {
                          setState(() {
                            _result!['transcript_log'] = updatedTranscript;
                          });
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _saveToProfile(_result!),
                          icon: const Icon(Icons.save_alt, color: kColorNavy),
                          label: const Text("Save to Profile",
                              style: TextStyle(color: kColorNavy)),
                        ),
                      ),
                      _AnalysisResults(data: _result!),
                      _ResponseSimulator(contextText: _inputController.text),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

// IMPROVED: Transcript Verification Card with better UX
class _TranscriptVerificationCard extends StatelessWidget {
  final List<Map<String, dynamic>> transcript;
  final Function(List<Map<String, dynamic>>) onUpdate;

  const _TranscriptVerificationCard(
      {required this.transcript, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    if (transcript.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
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
                    color: kColorNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.list_alt, color: kColorNavy, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text("Verify Speaker Assignment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kColorNavy,
                          fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "AI has assigned each message to a speaker. Tap any speaker name to correct if wrong.",
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            ...transcript.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: () async {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (ctx) {
                        final c = TextEditingController(text: t['speaker']);
                        return AlertDialog(
                          title: const Text("Edit Speaker Name"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Change the speaker name if this was assigned incorrectly:",
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: c,
                                decoration: const InputDecoration(
                                  labelText: "Speaker Name",
                                  border: OutlineInputBorder(),
                                ),
                                autofocus: true,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, c.text),
                                child: const Text("Update")),
                          ],
                        );
                      },
                    );

                    if (newName != null && newName.isNotEmpty) {
                      final updated =
                          List<Map<String, dynamic>>.from(transcript);
                      updated[index]['speaker'] = newName;
                      onUpdate(updated);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "${t['speaker']}:",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kColorPurple,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(t['text'].toString(),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            const Text(
              "💡 Tip: Add names like 'John:' or 'Sarah:' to your text before analyzing for better accuracy.",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResults extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AnalysisResults({required this.data});

  @override
  Widget build(BuildContext context) {
    final speakers = data['speakers'] as List? ?? [];
    return Column(
      children: speakers.map((s) {
        final String label = s['label'] ?? 'Speaker';
        final String? deepDive = s['deep_dive'];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                if (deepDive != null && deepDive.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red[100]!)),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: kColorError, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("DETECTED TACTIC:",
                                  style: TextStyle(
                                      color: kColorError,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10)),
                              Text(deepDive,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                _InfoRow(
                    label: "Emotion",
                    value: s['likely_emotional_state'] ?? 'Unknown'),
                _InfoRow(label: "Translation", value: s['translation'] ?? ''),
                const SizedBox(height: 8),
                const Text("Advice:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(s['advice'] ?? '',
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black54)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            children: [
              TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}

class _ResponseSimulator extends StatefulWidget {
  final String contextText;
  const _ResponseSimulator({required this.contextText});
  @override
  State<_ResponseSimulator> createState() => _ResponseSimulatorState();
}

class _ResponseSimulatorState extends State<_ResponseSimulator> {
  final TextEditingController _draftCtrl = TextEditingController();
  bool _simLoading = false;
  Map<String, dynamic>? _simResult;

  Future<void> _simulate() async {
    if (_draftCtrl.text.isEmpty) return;
    setState(() {
      _simLoading = true;
      _simResult = null;
    });

    try {
      final String baseUrl = dotenv.env['API_URL'] ?? kApiBaseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/simulate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"context": widget.contextText, "draft": _draftCtrl.text}),
      );

      if (response.statusCode == 200) {
        setState(() => _simResult = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Simulation failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Connection Error")));
    } finally {
      setState(() => _simLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: kColorGold.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.science, color: kColorGold),
                SizedBox(width: 8),
                Text("Response Simulator",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Draft your reply to see how it might be received.",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _draftCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Type your reply here...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kColorNavy),
                onPressed: _simLoading ? null : _simulate,
                child: _simLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Test Response"),
              ),
            ),
            if (_simResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_simResult!['score'] ?? 0) > 70
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${_simResult!['response']} (Score: ${_simResult!['score']})",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (_simResult!['score'] ?? 0) > 70
                                ? Colors.green[800]
                                : Colors.red[800])),
                    const SizedBox(height: 6),
                    Text(_simResult!['analysis'] ?? '',
                        style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. SPEAKER PROFILES
// ============================================================================
class SpeakerProfilesScreen extends StatefulWidget {
  const SpeakerProfilesScreen({super.key});
  @override
  State<SpeakerProfilesScreen> createState() => _SpeakerProfilesScreenState();
}

class _SpeakerProfilesScreenState extends State<SpeakerProfilesScreen> {
  List<Map<String, dynamic>> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('speaker_profiles');
    if (data != null) {
      setState(() {
        _profiles = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _addProfile() async {
    final TextEditingController nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Speaker Profile"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: "Name (e.g. Ex-Partner)"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final newProfile = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameCtrl.text,
                  'logs': []
                };
                setState(() => _profiles.add(newProfile));
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'speaker_profiles', jsonEncode(_profiles));
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Speaker Patterns",
              style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          _profiles.isEmpty
              ? const Center(
                  child: Text("No profiles yet. Create one to track patterns.",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final p = _profiles[index];
                    final logs = (p['logs'] as List?) ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: kColorGold.withOpacity(0.2),
                            child: const Icon(Icons.person, color: kColorGold)),
                        title: Text(p['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${logs.length} Analysis Logs"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    SpeakerDetailScreen(profile: p))),
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: kColorGreen,
              onPressed: _addProfile,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

class SpeakerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const SpeakerDetailScreen({super.key, required this.profile});

  @override
  State<SpeakerDetailScreen> createState() => _SpeakerDetailScreenState();
}

class _SpeakerDetailScreenState extends State<SpeakerDetailScreen> {
  bool _analyzing = false;
  Map<String, dynamic>? _insight;

  Future<void> _analyzeHistory() async {
    final logs = widget.profile['logs'] as List? ?? [];
    if (logs.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Need at least 3 logs for deep analysis.")));
      return;
    }

    setState(() {
      _analyzing = true;
      _insight = null;
    });

    try {
      final String baseUrl = dotenv.env['API_URL'] ?? kApiBaseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/analyze-profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": widget.profile['name'], "logs": logs}),
      );

      if (response.statusCode == 200) {
        setState(() => _insight = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Analysis failed.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Connection error.")));
    } finally {
      setState(() => _analyzing = false);
    }
  }

  Color _getRiskColor(String? level) {
    switch (level?.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red[900]!;
      case 'HIGH':
        return kColorError;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return kColorGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = (widget.profile['logs'] as List? ?? []).reversed.toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.profile['name'],
              style: const TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.analytics, color: kColorNavy),
                          SizedBox(width: 8),
                          Text("Behavioral Profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                        ]),
                        const SizedBox(height: 16),
                        if (_insight != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color:
                                        _getRiskColor(_insight!['risk_level']),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                    "${_insight!['risk_level'] ?? 'UNK'} RISK",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(_insight!['pattern'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kColorNavy)),
                          const SizedBox(height: 6),
                          Text(_insight!['summary'] ?? ''),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children:
                                (List<String>.from(_insight!['traits'] ?? []))
                                    .map((t) => Chip(
                                        label: Text(t,
                                            style:
                                                const TextStyle(fontSize: 10)),
                                        visualDensity: VisualDensity.compact))
                                    .toList(),
                          ),
                          const Divider(),
                          const Text("Strategic Advice:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_insight!['recommendation'] ?? '',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ] else
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                    "Analyze past interactions to detect deep patterns.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kColorPurple),
                                  onPressed:
                                      _analyzing ? null : _analyzeHistory,
                                  child: _analyzing
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text("Generate Full Profile"),
                                )
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("History Log",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kColorNavy))),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final date =
                        DateTime.tryParse(log['date']) ?? DateTime.now();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('dd MMM yyyy').format(date),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Text(DateFormat('h:mm a').format(date),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ]),
                            const SizedBox(height: 4),
                            Text(log['text'],
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. LIBRARY & ARTICLE DETAIL
// ============================================================================
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Library", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kOfflineArticles.length,
            itemBuilder: (context, index) {
              final article = kOfflineArticles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: kColorPurple.withOpacity(0.1),
                      child: const Icon(Icons.article, color: kColorPurple)),
                  title: Text(article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(article.summary,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ArticleDetailScreen(article: article))),
                ),
              );
            },
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(article.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kColorNavy)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: kColorPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kColorPurple.withOpacity(0.3))),
                  child: Text(article.summary,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87)),
                ),
                const SizedBox(height: 24),
                Text(article.content,
                    style: const TextStyle(fontSize: 16, height: 1.6)),
                const SizedBox(height: 100),
              ],
            ),
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. SETTINGS & PIN
// ============================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: kColorNavy,
          foregroundColor: Colors.white),
      body: Stack(
        children: [
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text("Privacy Policy"),
                onTap: () => launchUrl(Uri.parse(kPrivacyUrl)),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text("Terms of Service"),
                onTap: () => launchUrl(Uri.parse(kTermsUrl)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text("Parental Controls"),
                subtitle: const Text("Restrict access to Decoder"),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final currentPin = prefs.getString('parentalPin');

                  if (!context.mounted) return;

                  if (currentPin != null) {
                    final bool? verified = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => _PinDialog(correctPin: currentPin));
                    if (verified == true) {
                      await prefs.remove('parentalPin');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Parental PIN removed")));
                      }
                    }
                  } else {
                    final TextEditingController pinCtrl =
                        TextEditingController();
                    await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: const Text("Set Parental PIN"),
                              content: TextField(
                                  controller: pinCtrl,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  decoration: const InputDecoration(
                                      hintText: "Enter 4 digits")),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      if (pinCtrl.text.length == 4) {
                                        await prefs.setString(
                                            'parentalPin', pinCtrl.text);
                                        Navigator.pop(ctx);
                                      }
                                    },
                                    child: const Text("Save"))
                              ],
                            ));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: kColorError),
                title: const Text("Delete All My Data",
                    style: TextStyle(color: kColorError)),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false);
                },
              ),
            ],
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final String correctPin;
  const _PinDialog({required this.correctPin});
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final TextEditingController _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Parental Control"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter PIN to access Decoder"),
          TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(hintText: "####")),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel")),
        TextButton(
            onPressed: () {
              if (_ctrl.text == widget.correctPin) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect PIN")));
              }
            },
            child: const Text("Unlock")),
      ],
    );
  }
}
