import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- CONFIGURATION ---
const String kPrivacyUrl = "https://digitalabcs.com.au/privacy.html";
const String kTermsUrl = "https://digitalabcs.com.au/terms.html";

// --- IN-APP PURCHASE CONFIGURATION ---
// IDs must match exactly what you set in App Store Connect
const String kMonthlyId = 'linguistic_decoder_monthly'; // $14.99
const String kAnnualId = 'linguistic_decoder_annual'; // $8.99/mo
const String kLifetimeId = 'linguistic_decoder_lifetime'; // $99.99

// --- THEME ---
const Color kColorNavy = Color(0xFF1E3A8A);
const Color kColorPurple = Color(0xFF7C3AED);
const Color kColorBackground = Color(0xFFF3F4F6);
const Color kColorError = Color(0xFFDC2626);

void main() async {
  // 1. Load Environment Variables
  // Ensure you have a .env file in your assets with API_URL defined
  await dotenv.load(fileName: ".env");
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
  List<ProductDetails> _products = [];
  bool _loading = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) => print("Error: $error"));
    _initStore();
  }

  Future<void> _initStore() async {
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    // Query all 3 products
    const Set<String> kIds = {kMonthlyId, kAnnualId, kLifetimeId};
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
          setState(() => _loading = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Purchase Failed")));
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Grant Access
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

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // DEMO ACCOUNT / BYPASS LOGIC
  void _showDemoDialog() {
    final TextEditingController _codeCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Enter Demo Code"),
              content: TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(hintText: "Code")),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (_codeCtrl.text.trim() == "DEMO2025") {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasPaidPremium', true);
                        if (mounted) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DashboardScreen()));
                        }
                      } else {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invalid Code")));
                      }
                    },
                    child: const Text("Redeem"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // Sort products if needed, or find specific ones
    final monthly = _products.firstWhere((p) => p.id == kMonthlyId,
        orElse: () => _nullProduct);
    final annual = _products.firstWhere((p) => p.id == kAnnualId,
        orElse: () => _nullProduct);
    final lifetime = _products.firstWhere((p) => p.id == kLifetimeId,
        orElse: () => _nullProduct);

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Navy
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.psychology, size: 60, color: Color(0xFF7C3AED)),
              const SizedBox(height: 20),
              const Text("Unlock Full Analysis",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Choose a plan that works for you.",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const Spacer(),
              if (_loading)
                const CircularProgressIndicator(color: Colors.white),
              if (!_loading) ...[
                // ANNUAL (Highlight this one)
                _SubscriptionCard(
                  title: "Annual (Best Value)",
                  price: annual.id == 'null' ? "\$107.88/yr" : annual.price,
                  subtitle: "Just \$8.99/mo, billed annually",
                  isHighlighted: true,
                  onTap: () => annual.id != 'null' ? _buyProduct(annual) : null,
                ),
                const SizedBox(height: 12),

                // MONTHLY
                _SubscriptionCard(
                  title: "Monthly",
                  price: monthly.id == 'null' ? "\$14.99/mo" : monthly.price,
                  subtitle: "Cancel anytime",
                  onTap: () =>
                      monthly.id != 'null' ? _buyProduct(monthly) : null,
                ),
                const SizedBox(height: 12),

                // LIFETIME
                _SubscriptionCard(
                  title: "Lifetime Access",
                  price: lifetime.id == 'null' ? "\$99.99" : lifetime.price,
                  subtitle: "One-time payment",
                  onTap: () =>
                      lifetime.id != 'null' ? _buyProduct(lifetime) : null,
                ),
              ],
              const Spacer(),
              TextButton(
                  onPressed: () => _iap.restorePurchases(),
                  child: const Text("Restore Purchases",
                      style: TextStyle(color: Colors.white70))),
              TextButton(
                  onPressed: _showDemoDialog,
                  child: const Text("Redeem Code",
                      style: TextStyle(color: Colors.grey, fontSize: 12))),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for dummy product
  ProductDetails get _nullProduct => ProductDetails(
      id: 'null',
      title: '',
      description: '',
      price: '',
      currencyCode: '',
      rawPrice: 0);
}

class _SubscriptionCard extends StatelessWidget {
  final String title, price, subtitle;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _SubscriptionCard(
      {required this.title,
      required this.price,
      required this.subtitle,
      this.isHighlighted = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF7C3AED)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              isHighlighted ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Text(price,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
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

    // Use default localhost if .env is missing (Safety fallback)
    final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5000';

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/analyze"),
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
    final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5000';

    // APPLE COMPLIANCE: Must have a way to report bad AI generation
    try {
      await http.post(
        Uri.parse("$baseUrl/report"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "input_text": _inputController.text,
          "output_text": jsonEncode(_result),
          "reason": "User reported offensive/incorrect content"
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report sent. Thank you.")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send report.")));
    }
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
