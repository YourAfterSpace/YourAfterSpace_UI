import 'package:flutter/material.dart';
import '../profile/profile_api.dart';
import '../widgets/helper.dart';
import 'experience_api.dart';
import 'experience_detail_page.dart';

const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;

class ExperienceDiscoveryPage extends StatefulWidget {
  const ExperienceDiscoveryPage({super.key});

  @override
  State<ExperienceDiscoveryPage> createState() => _ExperienceDiscoveryPageState();
}

class _ExperienceDiscoveryPageState extends State<ExperienceDiscoveryPage> {
  List<Map<String, dynamic>> _experiences = [];
  final Set<String> _interestedIds = {};
  bool _loading = true;
  String? _error;
  String? _city;

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
      final profile = await getProfileData();
      final city = toStr(profile?['city']);
      final list = await getExperiences(city: city);
      final ids = await getInterestedExperienceIds();
      if (mounted) {
        setState(() {
          _city = city;
          _experiences = list;
          _interestedIds.clear();
          _interestedIds.addAll(ids);
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

  Future<void> _setInterest(String experienceId, bool interested) async {
    final ok = await putExperienceInterest(experienceId, interested);
    if (!mounted) return;
    if (ok) {
      setState(() {
        if (interested) {
          _interestedIds.add(experienceId);
        } else {
          _interestedIds.remove(experienceId);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update interest')),
      );
    }
  }

  void _toggleInterest(String experienceId) {
    if (experienceId.isEmpty) return;
    _setInterest(experienceId, !_interestedIds.contains(experienceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(_city != null ? 'Experiences in $_city' : 'Experience Discovery'),
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
                          Icon(Icons.explore_off_rounded, size: 56, color: _textSecondary),
                          const SizedBox(height: 12),
                          Text('No experiences in your city yet.', style: TextStyle(fontSize: 16, color: _textSecondary)),
                          const SizedBox(height: 8),
                          TextButton(onPressed: _load, child: const Text('Refresh')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _experiences.length,
                        itemBuilder: (context, i) {
                          final exp = _experiences[i];
                          return _ExperienceCard(
                            experience: exp,
                            isInterested: _interestedIds.contains(toStr(exp['experienceId'])),
                            onInterested: () => _toggleInterest(toStr(exp['experienceId']) ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExperienceDetailPage(experience: exp),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Map<String, dynamic> experience;
  final bool isInterested;
  final VoidCallback onInterested;
  final VoidCallback onTap;

  const _ExperienceCard({
    required this.experience,
    required this.isInterested,
    required this.onInterested,
    required this.onTap,
  });

  String get _title => toStr(experience['title']) ?? 'Experience';
  String get _location => toStr(experience['location']) ?? '';
  String get _city => toStr(experience['city']) ?? '';
  num get _price => (experience['pricePerPerson'] as num?) ?? 0;
  String get _currency => toStr(experience['currency']) ?? 'USD';
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
                      OutlinedButton.icon(
                        onPressed: onInterested,
                        icon: Icon(isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20, color: isInterested ? _primary : _textSecondary),
                        label: Text('Interested', style: TextStyle(fontSize: 14, color: isInterested ? _primary : _textSecondary)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primary,
                          side: BorderSide(color: isInterested ? _primary : _textSecondary),
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
