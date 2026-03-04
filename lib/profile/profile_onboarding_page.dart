import 'package:flutter/material.dart';

import '../home/home_page.dart';
import 'profile_api.dart';
import 'user_profile.dart';

const List<String> _cities = ['Mumbai', 'Delhi', 'Nagpur'];
const List<String> _genders = ['Male', 'Female'];

// Elegant theme
const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;
const _border = Color(0xFFE2E8F0);

class ProfileOnboardingPage extends StatefulWidget {
  const ProfileOnboardingPage({super.key});

  @override
  State<ProfileOnboardingPage> createState() => _ProfileOnboardingPageState();
}

class _ProfileOnboardingPageState extends State<ProfileOnboardingPage> {
  static const _totalSteps = 7;
  int _step = 0;
  bool _submitting = false;

  DateTime? _dateOfBirth;
  String? _gender;
  String? _city;

  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isOptionalStep => _step >= 3;

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _skip() {
    if (_isOptionalStep && _step < _totalSteps - 1) {
      setState(() => _step++);
    } else if (_step == _totalSteps - 1) {
      _submit();
    }
  }

  bool _canProceed() {
    switch (_step) {
      case 0:
        return _dateOfBirth != null;
      case 1:
        return _gender != null && _gender!.isNotEmpty;
      case 2:
        return _city != null && _city!.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submit() async {
    if (_dateOfBirth == null || _gender == null || _city == null) return;

    setState(() => _submitting = true);

    final dateStr =
        '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}';

    final profile = UserProfile(
      dateOfBirth: dateStr,
      gender: _gender!,
      city: _city!,
      address: _nullable(_addressController.text),
      bio: _nullable(_bioController.text),
      company: _nullable(_companyController.text),
      country: 'India',
      phoneNumber: _nullable(_phoneController.text),
    );

    try {
      await postUserProfile(profile);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _nullable(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text('Complete your profile'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  minHeight: 6,
                  backgroundColor: _border,
                  valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Step ${_step + 1} of $_totalSteps',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStepContent(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              color: _cardBg,
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: _submitting ? null : () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Previous'),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  if (_isOptionalStep) ...[
                    TextButton(
                      onPressed: _submitting ? null : _skip,
                      child: const Text('Skip', style: TextStyle(color: _textSecondary)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: (!_submitting && (_isOptionalStep || _canProceed()))
                          ? _next
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_step == _totalSteps - 1 ? 'Submit' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _DateStep(value: _dateOfBirth, onChanged: (v) => setState(() => _dateOfBirth = v));
      case 1:
        return _GenderStep(value: _gender, onChanged: (v) => setState(() => _gender = v));
      case 2:
        return _CityStep(value: _city, onChanged: (v) => setState(() => _city = v));
      case 3:
        return _TextStep(title: 'Address', hint: 'Enter your address', controller: _addressController);
      case 4:
        return _TextStep(title: 'Bio', hint: 'Tell us about yourself', controller: _bioController, maxLines: 3);
      case 5:
        return _TextStep(title: 'Company', hint: 'Your company name', controller: _companyController);
      case 6:
        return _TextStep(
          title: 'Phone number',
          hint: 'Your phone number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        );
      default:
        return const SizedBox();
    }
  }
}

class _DateStep extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of birth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          const Text('When were you born?', style: TextStyle(fontSize: 15, color: _textSecondary)),
          const SizedBox(height: 28),
          Material(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            elevation: 0,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900, 1, 1),
                  lastDate: DateTime.now(),
                );
                if (picked != null) onChanged(picked);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: _primary, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      value == null
                          ? 'Select date'
                          : '${value!.day} / ${value!.month} / ${value!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: value == null ? _textSecondary : _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: _textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderStep extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          const Text('How do you identify?', style: TextStyle(fontSize: 15, color: _textSecondary)),
          const SizedBox(height: 28),
          ..._genders.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  child: RadioListTile<String>(
                    title: Text(g, style: const TextStyle(fontSize: 16, color: _textPrimary)),
                    value: g,
                    groupValue: value,
                    activeColor: _primary,
                    onChanged: (v) => onChanged(v),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _CityStep extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _CityStep({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'City',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        const SizedBox(height: 6),
        const Text('Select your city', style: TextStyle(fontSize: 15, color: _textSecondary)),
        const SizedBox(height: 28),
        Material(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _showCityPicker(context, onChanged),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Icon(Icons.location_city_rounded, color: _primary, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    value ?? 'Search and select city',
                    style: TextStyle(fontSize: 16, color: value == null ? _textSecondary : _textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: _textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _showCityPicker(BuildContext context, ValueChanged<String?> onChanged) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CitySearchSheet(
        cities: _cities,
        onSelect: (city) {
          onChanged(city);
          Navigator.pop(ctx, city);
        },
      ),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  final List<String> cities;
  final ValueChanged<String> onSelect;

  const _CitySearchSheet({required this.cities, required this.onSelect});

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  String _query = '';
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.cities);
  }

  void _updateFilter() {
    final q = _query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(widget.cities)
          : widget.cities.where((c) => c.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select city',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) {
                    _query = v;
                    _updateFilter();
                  },
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: const TextStyle(color: _textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: _textSecondary),
                    filled: true,
                    fillColor: _surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final city = _filtered[i];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onSelect(city),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 20, color: _primary),
                              const SizedBox(width: 12),
                              Text(city, style: const TextStyle(fontSize: 16, color: _textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TextStep extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _TextStep({
    required this.title,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
          ),
          const SizedBox(height: 6),
          Text(hint, style: const TextStyle(fontSize: 15, color: _textSecondary)),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, color: _textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: _textSecondary),
              filled: true,
              fillColor: _cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
