import 'package:flutter/material.dart';

const _primary = Color(0xFF0D9488);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);

class ExperienceDetailPage extends StatelessWidget {
  final Map<String, dynamic> experience;

  const ExperienceDetailPage({super.key, required this.experience});

  String get _title => experience['title'] as String? ?? 'Experience';
  String get _description => experience['description'] as String? ?? '';
  String get _location => experience['location'] as String? ?? '';
  String get _city => experience['city'] as String? ?? '';
  String get _address => experience['address'] as String? ?? '';
  String get _experienceDate => experience['experienceDate'] as String? ?? '';
  String get _startTime => experience['startTime'] as String? ?? '';
  String get _endTime => experience['endTime'] as String? ?? '';
  String get _requirements => experience['requirements'] as String? ?? '';
  String get _cancellationPolicy => experience['cancellationPolicy'] as String? ?? '';
  String get _contactInfo => experience['contactInfo'] as String? ?? '';
  num get _pricePerPerson => (experience['pricePerPerson'] as num?) ?? 0;
  String get _currency => experience['currency'] as String? ?? 'USD';
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
  String get _type => experience['type'] as String? ?? '';

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
