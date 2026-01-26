import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'content_data.dart';

// --- CONFIGURATION ---
const String kPrivacyUrl = "https://digitalabcs.com.au/privacy.html";
const String kTermsUrl = "https://digitalabcs.com.au/terms.html";
const String kApiBaseUrl =
    "https://decoder-backend-222632046587.australia-southeast1.run.app";

// --- IN-APP PURCHASE CONFIGURATION ---
const String kMonthlyId = 'linguistic_decoder_monthly';
const String kAnnualId = 'linguistic_decoder_annual';
const String kLifetimeId = 'linguistic_decoder_lifetime';

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
    debugPrint("⚠️ .env not found, using defaults: $e");
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
        fontFamily: 'Inter',
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
    return Positioned(
      bottom: 30,
      left: 20,
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: kColorNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png',
                width: 120,
                height: 120,
                errorBuilder: (c, o, s) => const Icon(Icons.psychology,
                    size: 80, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Linguistic Decoder",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: kColorPurple),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1.5 AGE VERIFICATION SCREEN
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
            Image.asset('assets/logo.png',
                width: 100,
                height: 100,
                errorBuilder: (c, o, s) => const Icon(Icons.verified_user,
                    size: 80, color: Colors.white)),
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
                  if (context.mounted)
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()));
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
  InAppPurchase? _iap;
  List<ProductDetails> _products = [];
  bool _loading = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _iap = InAppPurchase.instance;
      final purchaseUpdated = _iap!.purchaseStream;
      _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated,
          onDone: () => _subscription?.cancel(), onError: (error) => {});
      _initStore();
    }
  }

  Future<void> _initStore() async {
    final bool isAvailable = await _iap?.isAvailable() ?? false;
    if (!isAvailable) return;
    const Set<String> kIds = {kMonthlyId, kAnnualId, kLifetimeId};
    final ProductDetailsResponse response =
        await _iap!.queryProductDetails(kIds);
    if (response.error == null)
      setState(() => _products = response.productDetails);
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasPaidPremium', true);
          if (mounted)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()));
        }
        if (purchaseDetails.pendingCompletePurchase)
          await _iap?.completePurchase(purchaseDetails);
      }
    }
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap?.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _showDemoDialog() {
    final TextEditingController codeCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Enter Demo Code"),
              content: TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(hintText: "Code")),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (codeCtrl.text.trim().toUpperCase() == "DEMO2025") {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasPaidPremium', true);
                        if (mounted)
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DashboardScreen()));
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
    final monthly = _products.firstWhere((p) => p.id == kMonthlyId,
        orElse: () => _nullProduct);
    final annual = _products.firstWhere((p) => p.id == kAnnualId,
        orElse: () => _nullProduct);
    final lifetime = _products.firstWhere((p) => p.id == kLifetimeId,
        orElse: () => _nullProduct);

    return Scaffold(
      backgroundColor: kColorNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (c, o, s) => const Icon(Icons.psychology,
                      size: 60, color: kColorPurple)),
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
                _SubscriptionCard(
                    title: "Annual (Best Value)",
                    price: annual.price.isEmpty ? "\$107.88/yr" : annual.price,
                    subtitle: "Just \$8.99/mo, billed annually",
                    isHighlighted: true,
                    onTap: () =>
                        annual.id != 'null' ? _buyProduct(annual) : null),
                const SizedBox(height: 12),
                _SubscriptionCard(
                    title: "Monthly",
                    price: monthly.price.isEmpty ? "\$14.99/mo" : monthly.price,
                    subtitle: "Cancel anytime",
                    onTap: () =>
                        monthly.id != 'null' ? _buyProduct(monthly) : null),
                const SizedBox(height: 12),
                _SubscriptionCard(
                    title: "Lifetime Access",
                    price: lifetime.price.isEmpty ? "\$99.99" : lifetime.price,
                    subtitle: "One-time payment",
                    onTap: () =>
                        lifetime.id != 'null' ? _buyProduct(lifetime) : null),
              ],
              const Spacer(),
              TextButton(
                  onPressed: () => _iap?.restorePurchases(),
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
          color: isHighlighted ? kColorPurple : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              isHighlighted ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
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
// 4. DASHBOARD
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
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
              Text("Linguistic Decoder",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Text("by", style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
            const SizedBox(width: 8),
            Image.asset('assets/logo.png',
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.psychology, color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
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
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: color)),
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
// 5. DECODER SCREEN (Updated with Simulator & Transcript)
// ============================================================================
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
      final String baseUrl = dotenv.env['API_URL'] ?? kApiBaseUrl;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Decoder", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                    controller: _inputController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        hintText: "Paste conversation...",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white)),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _isLoading ? null : _analyze,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Analyze"))),
                const SizedBox(height: 16),
                Expanded(
                  child: _result == null
                      ? const Center(
                          child: Text("Ready to decode.",
                              style: TextStyle(color: Colors.grey)))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: [
                            _AnalysisResultView(
                                result: _result!,
                                originalText: _inputController.text),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const QuickExitButton(),
        ],
      ),
    );
  }
}

class _AnalysisResultView extends StatefulWidget {
  final Map<String, dynamic> result;
  final String originalText;
  const _AnalysisResultView({required this.result, required this.originalText});

  @override
  State<_AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<_AnalysisResultView> {
  final TextEditingController _draftCtrl = TextEditingController();
  bool _simLoading = false;
  Map<String, dynamic>? _simulation;

  Future<void> _simulate() async {
    if (_draftCtrl.text.isEmpty) return;
    setState(() {
      _simLoading = true;
      _simulation = null;
    });
    try {
      final String baseUrl = dotenv.env['API_URL'] ?? kApiBaseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/simulate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"context": widget.originalText, "draft": _draftCtrl.text}),
      );
      if (response.statusCode == 200) {
        setState(() => _simulation = jsonDecode(response.body));
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _simLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final speakers = widget.result['speakers'] as List? ?? [];
    final transcript = widget.result['transcript_log'] as List? ?? [];

    return Column(
      children: [
        // 1. Transcript Verification
        if (transcript.isNotEmpty)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Transcript Verification",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: kColorNavy)),
                  const SizedBox(height: 8),
                  ...transcript
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${t['speaker']}: ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                Expanded(
                                    child: Text(t['text'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          ))
                      .toList()
                ],
              ),
            ),
          ),

        // 2. Speaker Analysis
        ...speakers
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
                        if (s['deep_dive'] != null)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8)),
                            child: Text("TACTIC: ${s['deep_dive']}",
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87)),
                          ),
                        const SizedBox(height: 8),
                        const Text("Translation:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(s['translation'] ?? ''),
                        const SizedBox(height: 8),
                        const Text("Advice:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(s['advice'] ?? '',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ))
            .toList(),

        // 3. Response Simulator
        Card(
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: kColorGold),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.science, color: kColorGold),
                  SizedBox(width: 8),
                  Text("Response Simulator",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kColorNavy,
                          fontSize: 16))
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: _draftCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: "Draft your reply...",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: kColorNavy),
                    onPressed: _simLoading ? null : _simulate,
                    child: _simLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text("Test Reply"),
                  ),
                ),
                if (_simulation != null)
                  Container(
                    margin: const EdgeInsets.top(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_simulation!['score'] ?? 0) > 70
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: (_simulation!['score'] ?? 0) > 70
                              ? Colors.green
                              : Colors.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${_simulation!['response']} (Score: ${_simulation!['score']}/100)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (_simulation!['score'] ?? 0) > 70
                                    ? Colors.green[800]
                                    : Colors.red[800])),
                        const SizedBox(height: 4),
                        Text(_simulation!['analysis'] ?? ''),
                      ],
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}

// ============================================================================
// 6. SPEAKER PROFILES
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
      setState(
          () => _profiles = List<Map<String, dynamic>>.from(jsonDecode(data)));
    }
  }

  Future<void> _createProfile(String name) async {
    final newProfile = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'logs': []
    };
    setState(() => _profiles.add(newProfile));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('speaker_profiles', jsonEncode(_profiles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Speaker Profiles",
              style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy),
      body: _profiles.isEmpty
          ? const Center(
              child: Text("No profiles yet. Create one to track patterns."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length,
              itemBuilder: (ctx, i) {
                final p = _profiles[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: kColorGold.withOpacity(0.2),
                        child: const Icon(Icons.person, color: kColorGold)),
                    title: Text(p['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text("${(p['logs'] as List).length} Analysis Logs"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SpeakerDetailScreen(profile: p))),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kColorGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          final ctrl = TextEditingController();
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text("New Profile"),
                    content: TextField(
                        controller: ctrl,
                        decoration: const InputDecoration(
                            hintText: "Name (e.g. Ex-Partner)")),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            if (ctrl.text.isNotEmpty) {
                              _createProfile(ctrl.text);
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text("Create")),
                    ],
                  ));
        },
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
    final logs = widget.profile['logs'] as List;
    if (logs.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Need at least 3 logs for analysis.")));
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
      if (response.statusCode == 200)
        setState(() => _insight = jsonDecode(response.body));
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = widget.profile['logs'] as List;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.profile['name'],
              style: const TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                            fontSize: 18, fontWeight: FontWeight.bold))
                  ]),
                  const SizedBox(height: 16),
                  if (_insight == null)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kColorPurple),
                        onPressed: _analyzing ? null : _analyzeHistory,
                        child: _analyzing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Generate Full Profile"),
                      ),
                    )
                  else ...[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                              label: Text(_insight!['risk_level'] ?? 'UNKNOWN',
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: kColorError),
                          Text("Trend: ${_insight!['escalation_trend']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        ]),
                    const SizedBox(height: 8),
                    Text(_insight!['pattern'] ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kColorNavy)),
                    const SizedBox(height: 8),
                    Text(_insight!['summary'] ?? ''),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("Advice: ${_insight!['recommendation']}",
                            style:
                                const TextStyle(fontStyle: FontStyle.italic))),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("History Log",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kColorNavy)),
          const SizedBox(height: 10),
          ...logs.reversed
              .map((l) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(l['date'].toString().split('T')[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey)),
                      subtitle: Text(l['text'],
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }
}

// ============================================================================
// 7. LIBRARY & SETTINGS (Keep existing)
// ============================================================================
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Library", style: TextStyle(color: Colors.white)),
          backgroundColor: kColorNavy),
      body: ListView(padding: const EdgeInsets.all(16), children: const [
        Card(
            child: ListTile(
                title: Text("Understanding DARVO"),
                subtitle: Text("Deny, Attack, Reverse Victim & Offender"))),
        Card(
            child: ListTile(
                title: Text("Grey Rock Method"),
                subtitle: Text("How to become uninteresting to toxic people"))),
      ]),
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
              onTap: () => launchUrl(Uri.parse(kPrivacyUrl))),
          ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Terms of Service"),
              onTap: () => launchUrl(Uri.parse(kTermsUrl))),
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
      content: TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(hintText: "####")),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel")),
        TextButton(
            onPressed: () =>
                Navigator.pop(context, _ctrl.text == widget.correctPin),
            child: const Text("Unlock")),
      ],
    );
  }
}
