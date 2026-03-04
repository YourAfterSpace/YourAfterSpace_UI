import 'package:flutter/material.dart';
import 'experience_api.dart';
import 'experience_detail_page.dart';

const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;

class MyExperiencesPage extends StatefulWidget {
  const MyExperiencesPage({super.key});

  @override
  State<MyExperiencesPage> createState() => _MyExperiencesPageState();
}

class _MyExperiencesPageState extends State<MyExperiencesPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];
  bool _loading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        getUpcomingExperiences(),
        getPastExperiences(),
      ]);
      if (mounted) {
        setState(() {
          _upcoming = results[0];
          _past = results[1];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Text('My Experiences'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _ExperienceList(experiences: _upcoming, emptyMessage: 'No upcoming experiences.', onRefresh: _load),
                    _ExperienceList(experiences: _past, emptyMessage: 'No past experiences.', onRefresh: _load),
                  ],
                ),
    );
  }
}

class _ExperienceList extends StatelessWidget {
  final List<Map<String, dynamic>> experiences;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _ExperienceList({required this.experiences, required this.emptyMessage, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, size: 56, color: _textSecondary.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: _textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: experiences.length,
        itemBuilder: (context, i) {
          final exp = experiences[i];
          return _MyExperienceCard(
            experience: exp,
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
    );
  }
}

class _MyExperienceCard extends StatelessWidget {
  final Map<String, dynamic> experience;
  final VoidCallback onTap;

  const _MyExperienceCard({required this.experience, required this.onTap});

  String get _title => experience['title'] as String? ?? 'Experience';
  String get _location => experience['location'] as String? ?? '';
  String get _city => experience['city'] as String? ?? '';
  String get _date => experience['experienceDate'] as String? ?? '';
  String get _startTime => experience['startTime'] as String? ?? '';
  num get _price => (experience['pricePerPerson'] as num?) ?? 0;
  String get _currency => experience['currency'] as String? ?? 'USD';
  List<String> get _images {
    final i = experience['images'] as List<dynamic>?;
    return i?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: _images.isNotEmpty
                      ? Image.network(
                          _images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (_date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_date, style: const TextStyle(fontSize: 13, color: _textSecondary)),
                        ],
                        if (_startTime.isNotEmpty)
                          Text('$_startTime', style: const TextStyle(fontSize: 13, color: _textSecondary)),
                        const SizedBox(height: 4),
                        Text('$_location, $_city', style: const TextStyle(fontSize: 13, color: _textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('$_currency $_price per person', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _primary)),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12, top: 36),
                  child: Icon(Icons.chevron_right_rounded, color: _textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: _primary.withValues(alpha: 0.12),
      child: const Icon(Icons.image_rounded, size: 32, color: _primary),
    );
  }
}
