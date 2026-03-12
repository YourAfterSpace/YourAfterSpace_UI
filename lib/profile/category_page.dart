import 'package:flutter/material.dart';
import '../widgets/helper.dart';
import 'profile_api.dart';
import 'question_screen.dart';

const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;

class CategoryPage extends StatefulWidget {
  final Map<String, dynamic> category;
  final double categoryPercent;
  final Map<String, dynamic>? profileData;
  final VoidCallback? onSaved;

  const CategoryPage({
    super.key,
    required this.category,
    required this.categoryPercent,
    this.profileData,
    this.onSaved,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Map<String, dynamic>? _categoryData;

  @override
  void initState() {
    super.initState();
    _categoryData = widget.category;
  }

  Future<void> _openQuestion(Map<String, dynamic> question) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionScreen(
          question: question,
          categoryId: toStr(_categoryData!['id']) ?? '',
          onSaved: () async {
            widget.onSaved?.call();
            await _refreshCategory();
          },
        ),
      ),
    );
    if (result == true && mounted) setState(() {});
  }

  Future<void> _refreshCategory() async {
    try {
      final data = await getProfileData();
      if (data == null || !mounted) return;
      final list = data['questionnaireByCategory'] as List<dynamic>?;
      final id = toStr(_categoryData?['id']);
      if (list != null && id != null) {
        for (final c in list) {
          if ((c as Map<String, dynamic>)['id'] == id) {
            setState(() => _categoryData = c);
            break;
          }
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = toStr(_categoryData?['name']) ?? 'Category';
    final questions = _categoryData?['questions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: questions.isEmpty
          ? const Center(child: Text('No questions in this category.', style: TextStyle(color: _textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final q = questions[i] as Map<String, dynamic>;
                final title = toStr(q['title']) ?? 'Question';
                final answer = q['answer'];
                String subtitle = '';
                if (answer != null) {
                  if (answer is List) {
                    subtitle = answer.map((e) => e.toString()).join(', ');
                  } else {
                    subtitle = answer.toString();
                  }
                }
                if (subtitle.isEmpty) subtitle = 'Not answered';

                return Material(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _openQuestion(q),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _textPrimary)),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
