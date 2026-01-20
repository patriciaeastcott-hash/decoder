import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// --- CONFIGURATION ---
// REPLACE THIS with your actual Cloud Run URL
const String kApiBaseUrl =
    "https://decoder-222632046587.australia-southeast1.run.app";
const String kPrivacyUrl = "https://digitalabcs.com.au/privacy.html";
const String kTermsUrl = "https://digitalabcs.com.au/terms.html";
const String kPremiumProductId = 'linguistic_decoder_premium';

// --- THEME ---
const Color kColorNavy = Color(0xFF1E3A8A);
const Color kColorPurple = Color(0xFF7C3AED);
const Color kColorBackground = Color(0xFFF3F4F6);
const Color kColorError = Color(0xFFDC2626);

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
        useMaterial3: true,
        primaryColor: kColorNavy,
        scaffoldBackgroundColor: kColorBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kColorNavy),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorNavy,
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
// 1. SPLASH SCREEN (Routing Logic)
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
    await Future.delayed(const Duration(seconds: 2)); // Branding moment
    final prefs = await SharedPreferences.getInstance();
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
            Text(
              "Linguistic Decoder",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: kColorPurple),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. PAYWALL SCREEN (In-App Purchases)
// ============================================================================
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  bool _loading = false;
  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription =
        purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    });
    _initStore();
  }

  Future<void> _initStore() async {
    final bool isAvailable = await _iap.isAvailable();
    setState(() => _available = isAvailable);

    if (!isAvailable) return;

    const Set<String> kIds = {kPremiumProductId};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(kIds);

    if (response.error == null) {
      setState(() => _products = response.productDetails);
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() => _loading = true);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Purchase Failed")));
          setState(() => _loading = false);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Save locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasPaidPremium', true);

          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _buyProduct() {
    if (_products.isEmpty) {
      // Fallback for testing/review if store isn't connected yet
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Store not connected. (Using mock for review)")));
      // UNCOMMENT FOR TESTING ONLY:
      // _listenToPurchaseUpdated([]);
      return;
    }
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: _products.first);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _restore() {
    _iap.restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kColorNavy, Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open, size: 60, color: kColorPurple),
            const SizedBox(height: 24),
            const Text(
              "Unlock Full Access",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "One-time purchase for unlimited AI analysis.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            if (_loading)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton(
                onPressed: _buyProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorPurple,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_products.isEmpty
                    ? "Loading Store..."
                    : "Purchase - ${_products.first.price}"),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _restore,
              child: const Text("Restore Purchases",
                  style: TextStyle(color: Colors.white70)),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => launchUrl(Uri.parse(kPrivacyUrl)),
                    child: const Text("Privacy",
                        style: TextStyle(fontSize: 12, color: Colors.grey))),
                TextButton(
                    onPressed: () => launchUrl(Uri.parse(kTermsUrl)),
                    child: const Text("Terms",
                        style: TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. DASHBOARD & DECODER (Main Features)
// ============================================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy,
          automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            title: "New Decode",
            icon: Icons.add_circle,
            color: kColorPurple,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DecoderScreen())),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            title: "Settings",
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class DecoderScreen extends StatefulWidget {
  const DecoderScreen({super.key});

  @override
  State<DecoderScreen> createState() => _DecoderScreenState();
}

class _DecoderScreenState extends State<DecoderScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _analyze() async {
    if (_inputController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse("$kApiBaseUrl/analyze"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": _inputController.text}),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        setState(() => _result = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection failed. Check internet.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reportIssue() async {
    // APPLE COMPLIANCE: Must have a way to report bad AI generation
    await http.post(
      Uri.parse("$kApiBaseUrl/report"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "text": _inputController.text,
        "reason": "User reported offensive/incorrect content"
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Report sent. Thank you.")));
    Navigator.pop(context);
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Report Content"),
        content:
            const Text("Is this analysis offensive, harmful, or incorrect?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: _reportIssue,
              child: const Text("Report", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Decoder", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Paste conversation here...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyze,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analyze"),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "AI analysis can be inaccurate. Please verify important insights.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _result == null
                  ? const Center(
                      child: Text("Ready to decode.",
                          style: TextStyle(color: Colors.grey)))
                  : ListView(
                      children: [
                        // COMPLIANCE: Report Button on results
                        Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                                onPressed: _showReportDialog,
                                icon: const Icon(Icons.flag, size: 16),
                                label: const Text("Report Issue",
                                    style: TextStyle(fontSize: 12)))),
                        _ResultCard(data: _result!),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final speakers = data['speakers'] as List? ?? [];
    return Column(
      children: speakers
          .map((s) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['label'] ?? 'Speaker',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const Divider(),
                      Text(
                          "Emotion: ${s['likely_emotional_state'] ?? 'Unknown'}",
                          style: const TextStyle(color: kColorPurple)),
                      const SizedBox(height: 8),
                      const Text("Translation:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(s['translation'] ?? ''),
                      const SizedBox(height: 8),
                      const Text("Advice:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(s['advice'] ?? '',
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: kColorNavy,
          foregroundColor: Colors.white),
      body: ListView(
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
          ListTile(
            leading: const Icon(Icons.delete, color: kColorError),
            title: const Text("Reset App Data",
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
    );
  }
}
