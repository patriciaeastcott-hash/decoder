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

// --- IN-APP PURCHASE CONFIGURATION ---
// IDs must match exactly what you set in App Store Connect
const String kMonthlyId = 'linguistic_decoder_monthly'; // $14.99
const String kAnnualId = 'linguistic_decoder_annual'; // $8.99/mo
const String kLifetimeId = 'linguistic_decoder_lifetime'; // $99.99

// --- THEME ---
const Color kColorNavy = Color(0xFF1E3A8A);
const Color kColorPurple = Color(0xFF7C3AED);
const Color kColorBackground = Color(0xFFF3F4F6);
const Color kColorGreen = Color(0xFF10B981); // Digital ABCs CTA Color
const Color kColorError = Color(0xFFDC2626);

void main() async {
  // 1. Load Environment Variables
  // Ensure you have a .env file in your assets with API_URL defined
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Prevent crash if .env is missing. Will fall back to localhost in DecoderScreen.
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
        fontFamily: 'Inter', // Branding: Inter font family
        useMaterial3: true,
        primaryColor: kColorNavy,
        scaffoldBackgroundColor: kColorBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: kColorNavy),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorGreen, // Branding: Green for CTAs
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
    
    // 1. AGE ASSURANCE (17+ Requirement)
    final isAgeVerified = prefs.getBool('isAgeVerified') ?? false;
    if (!isAgeVerified) {
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
            // Branding: Logo usage with fallback
            Image.asset('logo.png', width: 120, height: 120, 
              errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 80, color: Colors.white)),
            const SizedBox(height: 20),
            const Text(
              "Linguistic Decoder",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
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
            // Branding: Logo usage
            Image.asset('assets/logo.png', width: 100, height: 100,
              errorBuilder: (c, o, s) => const Icon(Icons.verified_user, size: 80, color: Colors.white)),
            const SizedBox(height: 24),
            const Text(
              "Age Verification",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "This tool utilizes AI to decode communication. For safety and compliance, you must be 17+ to use this application.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Compliance: Explicit EULA agreement for Apple/Google
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(kTermsUrl)),
              child: const Text(
                "By continuing, you agree to our Terms of Service & EULA.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline, fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorGreen, // Branding: CTA Green
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isAgeVerified', true);
                  if (context.mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()));
                  }
                }, 
                child: const Text("Confirm Eligibility"), // Branding: Architect Tone
              ),
            ),
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
          onDone: () => _subscription?.cancel(),
          onError: (error) => print("Error: $error"));
      _initStore();
    }
  }

  Future<void> _initStore() async {
    final bool isAvailable = await _iap?.isAvailable() ?? false;
    if (!isAvailable) return;

    // Query all 3 products
    const Set<String> kIds = {kMonthlyId, kAnnualId, kLifetimeId};
    final ProductDetailsResponse response =
        await _iap!.queryProductDetails(kIds);

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
          await _iap?.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap?.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // DEMO ACCOUNT / BYPASS LOGIC
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
                      if (codeCtrl.text.trim() == "DEMO2025") {
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
              // Branding: Logo usage
              Image.asset('assets/logo.png', width: 80, height: 80,
                errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 60, color: Color(0xFF7C3AED))),
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
        backgroundColor: kColorNavy,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png',
                height: 32,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.psychology, color: Colors.white)),
            const SizedBox(width: 12),
            const Text("Digital ABCs",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Padding(
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
              onTap: () => _navigateToDecoder(context),
            ),
            _DashboardTile(
              title: "Library",
              icon: Icons.menu_book,
              color: kColorPurple,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LibraryScreen())),
            ),
            _DashboardTile(
              title: "My History",
              icon: Icons.history,
              color: kColorNavy,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("History coming soon!")));
              },
            ),
            _DashboardTile(
              title: "Safety Plan",
              icon: Icons.health_and_safety,
              color: kColorNavy,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Safety Plan coming soon!")));
              },
            ),
            _DashboardTile(
              title: "Support",
              icon: Icons.support_agent,
              color: Colors.blueGrey,
              onTap: () {
                launchUrl(Uri.parse("https://digitalabcs.com.au/contact"));
              },
            ),
            _DashboardTile(
              title: "Settings",
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDecoder(BuildContext context) async {
    // PARENTAL CONTROL CHECK
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

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library", style: TextStyle(color: Colors.white)),
        backgroundColor: kColorNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kOfflineArticles.length,
        itemBuilder: (context, index) {
          final article = kOfflineArticles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kColorPurple.withOpacity(0.1),
                child: Icon(_getIcon(article.iconName), color: kColorPurple),
              ),
              title: Text(article.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(article.summary,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article))),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'favorite': return Icons.favorite;
      case 'share': return Icons.share;
      case 'block': return Icons.block;
      case 'switch_video': return Icons.switch_video;
      case 'group': return Icons.group;
      case 'schedule': return Icons.schedule;
      case 'blur_on': return Icons.blur_on;
      case 'cyclone': return Icons.cyclone;
      case 'flash_on': return Icons.flash_on;
      case 'link': return Icons.link;
      case 'grain': return Icons.grain;
      case 'person_remove': return Icons.person_remove;
      case 'sports_score': return Icons.sports_score;
      case 'warning': return Icons.warning;
      case 'casino': return Icons.casino;
      case 'handshake': return Icons.handshake;
      case 'psychology': return Icons.psychology;
      case 'cloud_queue': return Icons.cloud_queue;
      case 'shield': return Icons.shield;
      case 'phishing': return Icons.phishing;
      case 'campaign': return Icons.campaign;
      case 'fingerprint': return Icons.fingerprint;
      case 'volume_off': return Icons.volume_off;
      case 'fence': return Icons.fence;
      case 'build_circle': return Icons.build_circle;
      case 'edit_note': return Icons.edit_note;
      case 'sentiment_satisfied': return Icons.sentiment_satisfied;
      case 'balance': return Icons.balance;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'verified': return Icons.verified;
      case 'sentiment_dissatisfied': return Icons.sentiment_dissatisfied;
      case 'compare_arrows': return Icons.compare_arrows;
      case 'theater_comedy': return Icons.theater_comedy;
      default: return Icons.article;
    }
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: kColorNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                border: Border.all(color: kColorPurple.withOpacity(0.3)),
              ),
              child: Text(article.summary,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87)),
            ),
            const SizedBox(height: 24),
            Text(article.content,
                style: const TextStyle(fontSize: 16, height: 1.6)),
          ],
        ),
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
            decoration: const InputDecoration(hintText: "####"),
          ),
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
                style: ElevatedButton.styleFrom(backgroundColor: kColorGreen), // Branding: CTA
                onPressed: _isLoading ? null : _analyze,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analyze"),
              ),
            ),
            const SizedBox(height: 8),
            const Text( // Ethics: Enhanced disclaimer
              "AI analysis can be inaccurate. Advice is anchored in lived experience but does not replace professional help.",
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
                // Remove PIN
                final bool? verified = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => _PinDialog(correctPin: currentPin));
                if (verified == true) {
                  await prefs.remove('parentalPin');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Parental PIN removed")));
                  }
                }
              } else {
                // Set PIN
                final TextEditingController pinCtrl = TextEditingController();
                await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text("Set Parental PIN"),
                          content: TextField(
                            controller: pinCtrl,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: const InputDecoration(hintText: "Enter 4 digits"),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  if (pinCtrl.text.length == 4) {
                                    await prefs.setString('parentalPin', pinCtrl.text);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("PIN Set Successfully")));
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
            title: const Text("Delete All My Data", // Compliance: Clear data control
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
