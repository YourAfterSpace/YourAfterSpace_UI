import 'package:flutter/material.dart';
import '../widgets/helper.dart';
import 'experience_api.dart';

const _primary = Color(0xFF0D9488);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);

class ExperienceDetailPage extends StatefulWidget {
  final Map<String, dynamic> experience;

  const ExperienceDetailPage({super.key, required this.experience});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  bool _isInterested = false;
  bool _loadingInterest = true;

  Map<String, dynamic> get experience => widget.experience;

  String get _experienceId => toStr(experience['experienceId']) ?? '';
  String get _title => toStr(experience['title']) ?? 'Experience';
  String get _description => toStr(experience['description']) ?? '';
  String get _location => toStr(experience['location']) ?? '';
  String get _city => toStr(experience['city']) ?? '';
  String get _address => toStr(experience['address']) ?? '';
  String get _experienceDate => toStr(experience['experienceDate']) ?? '';
  String get _startTime => toStr(experience['startTime']) ?? '';
  String get _endTime => toStr(experience['endTime']) ?? '';
  String get _requirements => toStr(experience['requirements']) ?? '';
  String get _cancellationPolicy => toStr(experience['cancellationPolicy']) ?? '';
  String get _contactInfo => toStr(experience['contactInfo']) ?? '';
  num get _pricePerPerson => (experience['pricePerPerson'] as num?) ?? 0;
  String get _currency => toStr(experience['currency']) ?? 'USD';
  int get _maxCapacity => (experience['maxCapacity'] as int?) ?? 0;
  int get _remainingCapacity => (experience['remainingCapacity'] as int?) ?? 0;
  List<String> get _images {
    final i = experience['images'] as List<dynamic>?;
    return i?.map((e) => e.toString()).toList() ?? [];
  }
  List<String> get _tags {
    final t = experience['tags'] as List<dynamic>?;
    return t?.map((e) => e.toString()).toList() ?? [];
  }
  String get _type => toStr(experience['type']) ?? '';

  @override
  void initState() {
    super.initState();
    _loadInterested();
  }

  Future<void> _loadInterested() async {
    final ids = await getInterestedExperienceIds();
    if (mounted) {
      setState(() {
        _isInterested = ids.contains(_experienceId);
        _loadingInterest = false;
      });
    }
  }

  Future<void> _toggleInterested() async {
    if (_experienceId.isEmpty) return;
    setState(() => _loadingInterest = true);
    final newValue = !_isInterested;
    final ok = await putExperienceInterest(_experienceId, newValue);
    if (!mounted) return;
    setState(() {
      _loadingInterest = false;
      if (ok) _isInterested = newValue;
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update interest')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_title, overflow: TextOverflow.ellipsis),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_images.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: _images.length,
                  itemBuilder: (_, i) => Image.network(
                    _images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 180,
                color: _primary.withValues(alpha: 0.2),
                child: const Icon(Icons.image_rounded, size: 64, color: _primary),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_type.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(label: Text(_type), backgroundColor: _primary.withValues(alpha: 0.15)),
                    ),
                  Text(_title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 18, color: _textSecondary),
                      const SizedBox(width: 6),
                      Text('$_location, $_city', style: const TextStyle(fontSize: 15, color: _textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$_currency $_pricePerPerson per person · $_remainingCapacity of $_maxCapacity spots left',
                      style: const TextStyle(fontSize: 14, color: _textSecondary)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loadingInterest ? null : _toggleInterested,
                      icon: _loadingInterest
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(_isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20, color: _isInterested ? _primary : _textSecondary),
                      label: Text(
                        _loadingInterest ? 'Loading...' : (_isInterested ? 'Interested' : 'Mark as interested'),
                        style: TextStyle(fontSize: 15, color: _isInterested ? _primary : _textSecondary),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(color: _isInterested ? _primary : _textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_description.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(_description, style: const TextStyle(fontSize: 15, color: _textSecondary, height: 1.5)),
                    const SizedBox(height: 20),
                  ],
                  if (_experienceDate.isNotEmpty || _startTime.isNotEmpty) ...[
                    const Text('Date & time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text('$_experienceDate · $_startTime – $_endTime', style: const TextStyle(fontSize: 15, color: _textSecondary)),
                    const SizedBox(height: 20),
                  ],
                  if (_address.isNotEmpty) ...[
                    const Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(_address, style: const TextStyle(fontSize: 15, color: _textSecondary)),
                    const SizedBox(height: 20),
                  ],
                  if (_requirements.isNotEmpty) ...[
                    const Text('Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(_requirements, style: const TextStyle(fontSize: 15, color: _textSecondary)),
                    const SizedBox(height: 20),
                  ],
                  if (_cancellationPolicy.isNotEmpty) ...[
                    const Text('Cancellation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(_cancellationPolicy, style: const TextStyle(fontSize: 15, color: _textSecondary)),
                    const SizedBox(height: 20),
                  ],
                  if (_contactInfo.isNotEmpty) ...[
                    const Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(_contactInfo, style: const TextStyle(fontSize: 15, color: _textSecondary)),
                  ],
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _tags.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.grey.shade100)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
