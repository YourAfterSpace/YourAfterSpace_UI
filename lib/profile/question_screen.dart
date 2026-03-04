import 'package:flutter/material.dart';
import 'profile_api.dart';

const _primary = Color(0xFF0D9488);
const _surface = Color(0xFFF8FAFC);
const _textPrimary = Color(0xFF1E293B);
const _textSecondary = Color(0xFF64748B);
const _cardBg = Colors.white;
const _border = Color(0xFFE2E8F0);

class QuestionScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  final String categoryId;
  final VoidCallback? onSaved;

  const QuestionScreen({super.key, required this.question, required this.categoryId, this.onSaved});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _textController = TextEditingController();
  String? _singleChoice;
  final List<String> _multipleChoice = [];
  bool _saving = false;

  static const List<String> _ratingScale = [
    'Strongly disagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly agree',
  ];

  @override
  void initState() {
    super.initState();
    final answer = widget.question['answer'];
    if (answer is String) {
      _textController.text = answer;
      _singleChoice = answer;
    } else if (answer is List) {
      _multipleChoice.addAll(answer.map((e) => e.toString()));
      if (widget.question['type'] == 'SINGLE_CHOICE' && _multipleChoice.isNotEmpty) {
        _singleChoice = _multipleChoice.first;
        _multipleChoice.clear();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String get _type => widget.question['type'] as String? ?? 'TEXT';
  List<String> get _options {
    final o = widget.question['options'] as List<dynamic>?;
    return o?.map((e) => e.toString()).toList() ?? [];
  }

  Future<void> _save() async {
    final id = widget.question['id'] as String?;
    if (id == null) return;

    dynamic value;
    if (_type == 'TEXT') {
      value = _textController.text.trim();
    } else if (_type == 'SINGLE_CHOICE' || _type == 'RATING') {
      value = _singleChoice;
    } else {
      value = List<String>.from(_multipleChoice);
    }

    if (value == null || (value is List && value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await postQuestionnaire({id: value});
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context, true);
    } on ProfileApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.question['title'] as String? ?? 'Question';
    final description = widget.question['description'] as String?;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_type != 'RATING' && description != null && description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(description, style: const TextStyle(fontSize: 15, color: _textSecondary)),
              ),
            _buildInput(),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _saving
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    if (_type == 'RATING') {
      return _RatingInput(
        sentence: widget.question['description'] as String? ?? widget.question['title'] as String? ?? '',
        scale: _options.isNotEmpty ? _options : _ratingScale,
        value: _singleChoice,
        onChanged: (v) => setState(() => _singleChoice = v),
      );
    }

    if (_type == 'TEXT') {
      return TextField(
        controller: _textController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Your answer',
          isDense: true,
          border: const UnderlineInputBorder(borderSide: BorderSide(color: _border)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _border)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 4),
        ),
      );
    }

    final options = _options;
    if (options.isEmpty) {
      return TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'Your answer',
          isDense: true,
          border: const UnderlineInputBorder(borderSide: BorderSide(color: _border)),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _border)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _primary, width: 2)),
          contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 4),
        ),
      );
    }

    if (_type == 'SINGLE_CHOICE') {
      if (options.length < 10) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: options.map((opt) => RadioListTile<String>(
            title: Text(opt),
            value: opt,
            groupValue: _singleChoice,
            activeColor: _primary,
            onChanged: (v) => setState(() => _singleChoice = v),
          )).toList(),
        );
      }
      return _InlineSearchSingle(
        options: options,
        value: _singleChoice,
        onChanged: (v) => setState(() => _singleChoice = v),
      );
    }

    // MULTIPLE_CHOICE
    if (options.length < 10) {
      return Column(
        children: options.map((opt) => CheckboxListTile(
          title: Text(opt),
          value: _multipleChoice.contains(opt),
          activeColor: _primary,
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _multipleChoice.add(opt);
              } else {
                _multipleChoice.remove(opt);
              }
            });
          },
        )).toList(),
      );
    }
    return _InlineSearchMultiple(
      options: options,
      selected: _multipleChoice,
      onChanged: (v) => setState(() => _multipleChoice
        ..clear()
        ..addAll(v)),
    );
  }
}

class _RatingInput extends StatelessWidget {
  final String sentence;
  final List<String> scale;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RatingInput({
    required this.sentence,
    required this.scale,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate the following sentence',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        const SizedBox(height: 12),
        if (sentence.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              sentence,
              style: const TextStyle(fontSize: 16, color: _textSecondary, height: 1.4),
            ),
          ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < scale.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _RatingChip(
                  label: scale[i],
                  selected: value == scale[i],
                  onTap: () => onChanged(scale[i]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Strongly disagree',
              style: TextStyle(fontSize: 12, color: _textSecondary),
            ),
            Text(
              'Strongly agree',
              style: TextStyle(fontSize: 12, color: _textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RatingChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _primary : _cardBg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? _primary : _border, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : _textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineSearchSingle extends StatefulWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _InlineSearchSingle({required this.options, this.value, required this.onChanged});

  @override
  State<_InlineSearchSingle> createState() => _InlineSearchSingleState();
}

class _InlineSearchSingleState extends State<_InlineSearchSingle> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.from(widget.options);
    return widget.options.where((o) => o.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search_rounded, color: _textSecondary),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final opt = _filtered[i];
              final selected = widget.value == opt;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(opt, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: _textPrimary)),
                  trailing: selected ? const Icon(Icons.check_rounded, color: _primary, size: 22) : null,
                  onTap: () => widget.onChanged(opt),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineSearchMultiple extends StatefulWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _InlineSearchMultiple({required this.options, required this.selected, required this.onChanged});

  @override
  State<_InlineSearchMultiple> createState() => _InlineSearchMultipleState();
}

class _InlineSearchMultipleState extends State<_InlineSearchMultiple> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.from(widget.options);
    return widget.options.where((o) => o.toLowerCase().contains(q)).toList();
  }

  void _toggle(String opt) {
    final next = List<String>.from(widget.selected);
    if (next.contains(opt)) {
      next.remove(opt);
    } else {
      next.add(opt);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.selected.map((opt) => Chip(
                    label: Text(opt, style: const TextStyle(fontSize: 14)),
                    deleteIcon: const Icon(Icons.close, size: 18, color: _textSecondary),
                    onDeleted: () {
                      final next = List<String>.from(widget.selected)..remove(opt);
                      widget.onChanged(next);
                    },
                  )),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search_rounded, color: _textSecondary),
            filled: true,
            fillColor: _cardBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final opt = _filtered[i];
              final selected = widget.selected.contains(opt);
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(opt, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: _textPrimary)),
                  trailing: selected ? const Icon(Icons.check_rounded, color: _primary, size: 22) : null,
                  onTap: () => _toggle(opt),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

