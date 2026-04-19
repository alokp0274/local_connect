// features/jobs/screens/post_job_screen.dart
// Feature: Jobs Feed — 2-step job posting form + success screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  int _step = 1; // 1 or 2
  bool _success = false;

  // Step 1 fields
  final _descController = TextEditingController();
  String? _selectedCategory;
  String? _selectedUrgency;
  // Photos list (populated when photo picker is integrated)
  // ignore: unused_field
  final List<String> _photos = [];

  // Step 2 fields
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _areaController = TextEditingController();
  String? _selectedDate;
  String? _selectedTime;
  String? _contactPreference;

  String? _stepError;

  static const List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'AC Repair',
    'Painting',
    'Appliance',
    'Gardening',
  ];

  static const List<Map<String, dynamic>> _urgencies = [
    {
      'label': 'Emergency',
      'value': 'emergency',
      'icon': Icons.priority_high_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'label': 'Today',
      'value': 'today',
      'icon': Icons.today_rounded,
      'color': Color(0xFFFACC15),
    },
    {
      'label': 'This Week',
      'value': 'thisWeek',
      'icon': Icons.date_range_rounded,
      'color': Color(0xFF60A5FA),
    },
    {
      'label': 'Flexible',
      'value': 'flexible',
      'icon': Icons.schedule_rounded,
      'color': Color(0xFF6B7280),
    },
  ];

  static const List<Map<String, String>> _dates = [
    {'label': 'Today', 'value': 'Today'},
    {'label': 'Tomorrow', 'value': 'Tomorrow'},
    {'label': 'This Weekend', 'value': 'This Weekend'},
    {'label': 'Next Week', 'value': 'Next Week'},
  ];

  static const List<Map<String, String>> _times = [
    {'label': 'Morning (8–12)', 'value': 'Morning (8–12)'},
    {'label': 'Afternoon (12–5)', 'value': 'Afternoon (12–5)'},
    {'label': 'Evening (5–9)', 'value': 'Evening (5–9)'},
    {'label': 'Anytime', 'value': 'Anytime'},
  ];

  static const List<Map<String, dynamic>> _contacts = [
    {
      'label': 'Chat',
      'icon': Icons.chat_bubble_outline_rounded,
      'value': 'chat',
    },
    {'label': 'Call', 'icon': Icons.phone_rounded, 'value': 'call'},
    {'label': 'Both', 'icon': Icons.contact_phone_rounded, 'value': 'both'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    _titleController.dispose();
    _budgetController.dispose();
    _pincodeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _descController.text.trim().length >= 20 &&
      _selectedCategory != null &&
      _selectedUrgency != null;
  bool get _step2Valid =>
      _budgetController.text.trim().isNotEmpty &&
      _pincodeController.text.trim().isNotEmpty &&
      _titleController.text.trim().isNotEmpty;

  void _nextStep() {
    if (!_step1Valid) {
      setState(
        () => _stepError =
            'Complete description (min 20 chars), category and urgency',
      );
      return;
    }
    setState(() {
      _step = 2;
      _stepError = null;
    });
  }

  void _postJob() {
    if (!_step2Valid) {
      setState(() => _stepError = 'Enter job title, budget and your pincode');
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _success = true;
      _stepError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessScreen();

    final topPad = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Header + Step indicator ──
          Container(
            padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
            decoration: BoxDecoration(
              gradient: AppTheme.navBarGradient,
              border: const Border(
                bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step == 2) {
                          setState(() {
                            _step = 1;
                            _stepError = null;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Post a Job',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Text(
                      'Step $_step / 2',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _step / 2,
                    backgroundColor: AppTheme.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.accentGold,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          // ── Form ──
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
              child: _step == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),

          // ── Bottom CTA ──
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: const Border(
                top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_stepError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _stepError!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _step == 1 ? _nextStep() : _postJob();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withAlpha(60),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _step == 1 ? 'Next  →' : 'Post Job 🚀',
                        style: const TextStyle(
                          color: AppTheme.textOnAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 1 ───────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        _formLabel('Describe the job *'),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 5,
          maxLength: 500,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText:
                'e.g. My kitchen sink is leaking water under the cabinet. Need an experienced plumber urgently.',
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF141B2D),
            counterStyle: const TextStyle(color: AppTheme.textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1E2A40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppTheme.accentGold,
                width: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Category
        _formLabel('Category *'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final selected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accentPurple.withAlpha(22)
                      : const Color(0xFF141B2D),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: selected
                        ? AppTheme.accentPurple
                        : const Color(0xFF1E2A40),
                    width: selected ? 1.2 : 0.8,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.accentPurple
                        : AppTheme.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Photo picker placeholder
        _formLabel('Photos (optional, max 3)'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo picker would open here'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1E2A40),
                width: 1.2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppTheme.textMuted,
                    size: 30,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add Photos',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Urgency
        _formLabel('When do you need it? *'),
        const SizedBox(height: 10),
        ...(_urgencies.map((u) {
          final selected = _selectedUrgency == u['value'];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedUrgency = u['value'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? (u['color'] as Color).withAlpha(16)
                    : const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? (u['color'] as Color).withAlpha(120)
                      : const Color(0xFF1E2A40),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    u['icon'] as IconData,
                    color: u['color'] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    u['label'] as String,
                    style: TextStyle(
                      color: selected
                          ? u['color'] as Color
                          : AppTheme.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: u['color'] as Color,
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }

  // ─── STEP 2 ───────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job title
        _formLabel('Job Title *'),
        const SizedBox(height: 8),
        _TextInput(
          controller: _titleController,
          hint: 'e.g. Fix kitchen sink leak urgently',
        ),
        const SizedBox(height: 18),

        // Preferred date
        _formLabel('Preferred Date'),
        const SizedBox(height: 8),
        _ChipSelect<String>(
          items: _dates.map((d) => d['value']!).toList(),
          labels: _dates.map((d) => d['label']!).toList(),
          selected: _selectedDate,
          onChanged: (v) => setState(() => _selectedDate = v),
          color: AppTheme.accentTeal,
        ),
        const SizedBox(height: 18),

        // Preferred time
        _formLabel('Preferred Time'),
        const SizedBox(height: 8),
        _ChipSelect<String>(
          items: _times.map((d) => d['value']!).toList(),
          labels: _times.map((d) => d['label']!).toList(),
          selected: _selectedTime,
          onChanged: (v) => setState(() => _selectedTime = v),
          color: AppTheme.accentBlue,
        ),
        const SizedBox(height: 18),

        // Budget
        _formLabel('Budget (₹) *'),
        const SizedBox(height: 8),
        _TextInput(
          controller: _budgetController,
          hint: 'e.g. 500 or "400–800"',
          prefixIcon: const Icon(
            Icons.currency_rupee_rounded,
            color: AppTheme.accentGold,
            size: 18,
          ),
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),

        // Location
        _formLabel('Location *'),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: _TextInput(
                controller: _pincodeController,
                hint: 'Pincode',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TextInput(
                controller: _areaController,
                hint: 'Area / Locality',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('GPS location would be fetched here'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(60)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gps_fixed_rounded,
                  color: AppTheme.accentTeal,
                  size: 15,
                ),
                SizedBox(width: 8),
                Text(
                  'Use my current location',
                  style: TextStyle(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Contact preference
        _formLabel('Contact Preference'),
        const SizedBox(height: 10),
        Row(
          children: _contacts.map((c) {
            final selected = _contactPreference == c['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _contactPreference = c['value'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accentGold.withAlpha(18)
                        : const Color(0xFF141B2D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppTheme.accentGold.withAlpha(120)
                          : const Color(0xFF1E2A40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        c['icon'] as IconData,
                        color: selected
                            ? AppTheme.accentGold
                            : AppTheme.textMuted,
                        size: 18,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        c['label'] as String,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.accentGold
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────
// SUCCESS SCREEN
// ─────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      borderRadius: BorderRadius.circular(45),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentTeal.withAlpha(80),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Job Posted! 🎉',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 10),
              const Text(
                'Local pros near you will see your job and start bidding. You\'ll get notified!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate(delay: 450.ms).fadeIn(),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'View My Jobs',
                    style: TextStyle(
                      color: AppTheme.textOnAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────

Widget _formLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  );
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: const Color(0xFF141B2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2A40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentGold, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _ChipSelect<T> extends StatelessWidget {
  final List<T> items;
  final List<String> labels;
  final T? selected;
  final ValueChanged<T> onChanged;
  final Color color;

  const _ChipSelect({
    required this.items,
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (i) {
        final isSelected = selected == items[i];
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(items[i]);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(20) : const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected
                    ? color.withAlpha(120)
                    : const Color(0xFF1E2A40),
              ),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                color: isSelected ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}
