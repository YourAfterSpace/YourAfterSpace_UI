import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'experience_api.dart';
import 'experience_detail_page.dart';

const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;

/// Placeholder UPI VPA – replace with your backend/gateway VPA for production.
const String _upiPayeeVpa = 'merchant@paytm';
const String _upiPayeeName = 'YAS Experience';

class SelectedExperiencesPage extends StatefulWidget {
  const SelectedExperiencesPage({super.key});

  @override
  State<SelectedExperiencesPage> createState() => _SelectedExperiencesPageState();
}

class _SelectedExperiencesPageState extends State<SelectedExperiencesPage> {
  List<Map<String, dynamic>> _experiences = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // For now use all experiences (no city filter) as "selected" list.
      final list = await getExperiences(city: null);
      if (mounted) {
        setState(() {
          _experiences = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _onPayNow(BuildContext context, Map<String, dynamic> experience) async {
    final experienceId = experience['experienceId'] as String?;
    if (experienceId == null || experienceId.isEmpty) return;

    final amount = (experience['pricePerPerson'] as num?)?.toDouble() ?? 0.0;
    final title = experience['title'] as String? ?? 'Experience';
    final currency = experience['currency'] as String? ?? 'USD';
    final cu = currency == 'INR' ? 'INR' : 'INR'; // UPI typically INR; use INR for amount display

    // 1) Show UPI app picker (bottom sheet)
    final selectedApp = await _showUpiAppPicker(context, amount, title);
    if (selectedApp == null || !mounted) return;

    // 2) Launch UPI intent (same URL for all; system shows installed UPI apps)
    final amountStr = amount.toStringAsFixed(2);
    final uri = Uri.parse(
      'upi://pay?pa=$_upiPayeeVpa&pn=${Uri.encodeComponent(_upiPayeeName)}&am=$amountStr&cu=$cu&tn=${Uri.encodeComponent(title)}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open UPI. Install a UPI app or try again.')),
      );
      return;
    }

    // 3) After user returns from UPI app, ask to confirm payment success
    final confirmed = await _showPaymentConfirmDialog(context);
    if (!mounted || confirmed != true) return;

    // 4) Call backend to add experience to upcoming (status = BOOKED)
    final ok = await putExperienceStatus(experienceId, 'BOOKED');
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed. Check My Experiences → Upcoming.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm booking. Please try again.')),
      );
    }
  }

  Future<String?> _showUpiAppPicker(BuildContext context, double amount, String title) async {
    final apps = [
      ('Google Pay', Icons.account_balance_wallet_rounded),
      ('PhonePe', Icons.phone_android_rounded),
      ('Paytm', Icons.payment_rounded),
      ('BHIM', Icons.savings_rounded),
      ('Any UPI app', Icons.apps_rounded),
    ];
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pay ₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 14, color: _textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                const Text('Choose UPI app', style: TextStyle(fontSize: 14, color: _textSecondary)),
                const SizedBox(height: 8),
                ...apps.map((e) {
                  return ListTile(
                    leading: Icon(e.$2, color: _primary),
                    title: Text(e.$1),
                    onTap: () => Navigator.pop(ctx, e.$1),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showPaymentConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment complete?'),
        content: const Text(
          'Did you complete the payment in your UPI app? Tap Yes to confirm booking and add this experience to Upcoming.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, paid')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text('Selected experiences'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _textSecondary)),
                      const SizedBox(height: 16),
                      TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
                    ],
                  ),
                )
              : _experiences.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 56, color: _textSecondary.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          const Text('No selected experiences.', style: TextStyle(fontSize: 16, color: _textSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: _primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _experiences.length,
                        itemBuilder: (context, i) {
                          final exp = _experiences[i];
                          return _SelectedExperienceCard(
                            experience: exp,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ExperienceDetailPage(experience: exp)),
                              );
                            },
                            onPayNow: () => _onPayNow(context, exp),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _SelectedExperienceCard extends StatelessWidget {
  final Map<String, dynamic> experience;
  final VoidCallback onTap;
  final VoidCallback onPayNow;

  const _SelectedExperienceCard({
    required this.experience,
    required this.onTap,
    required this.onPayNow,
  });

  String get _title => experience['title'] as String? ?? 'Experience';
  String get _location => experience['location'] as String? ?? '';
  String get _city => experience['city'] as String? ?? '';
  num get _price => (experience['pricePerPerson'] as num?) ?? 0;
  String get _currency => experience['currency'] as String? ?? 'USD';
  List<String> get _images {
    final i = experience['images'] as List<dynamic>?;
    return i?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160,
                  child: _images.isNotEmpty
                      ? Image.network(
                          _images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text('$_location, $_city', style: const TextStyle(fontSize: 14, color: _textSecondary)),
                      const SizedBox(height: 6),
                      Text('$_currency $_price per person', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _primary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onPayNow,
                          icon: const Icon(Icons.payment_rounded, size: 20),
                          label: const Text('Pay now'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: _primary.withValues(alpha: 0.15),
      child: const Icon(Icons.image_rounded, size: 48, color: _primary),
    );
  }
}
