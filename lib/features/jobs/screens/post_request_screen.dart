// features/jobs/screens/post_request_screen.dart
// Feature: Job Posts & Service Requests
//
// Form to create a new service request/job post.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/features/jobs/data/job_post_data.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/jobs/screens/request_success_screen.dart';

// ─────────────────────────────────────────────────────────
//  POST REQUEST SCREEN — Premium multi-step job posting
// ─────────────────────────────────────────────────────────

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final _pincodeController = TextEditingController(text: '110001');
  final _areaController = TextEditingController(text: 'Connaught Place');

  String _selectedCategory = '';
  JobUrgency _selectedUrgency = JobUrgency.today;
  String _selectedDate = 'Today';
  String _selectedTime = 'Morning (9-12)';
  String _contactPref = 'Both';
  bool _isSubmitting = false;

  late AnimationController _submitController;

  static const _dateOptions = [
    'Today',
    'Tomorrow',
    'This Weekend',
    'Next Week',
    'Flexible',
  ];
  static const _timeOptions = [
    'ASAP',
    'Morning (9-12)',
    'Afternoon (12-4)',
    'Evening (4-8)',
    'Any Time',
  ];

  @override
  void initState() {
    super.initState();
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    _pincodeController.dispose();
    _areaController.dispose();
    _submitController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      _showSnack('Please select a category');
      return;
    }

    setState(() => _isSubmitting = true);
    _submitController.forward();

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Add to local list
    final newPost = JobPost(
      id: 'job-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descController.text.trim(),
      urgency: _selectedUrgency,
      preferredDate: _selectedDate,
      preferredTime: _selectedTime,
      budget: _budgetController.text.trim().isEmpty
          ? null
          : _budgetController.text.trim(),
      pincode: _pincodeController.text.trim(),
      area: _areaController.text.trim(),
      contactPreference: _contactPref,
      postedBy: 'John Doe',
      postedByInitial: 'J',
      timePosted: 'Just now',
      status: JobStatus.active,
      applicationCount: 0,
    );
    dummyJobPosts.insert(0, newPost);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RequestSuccessScreen(jobPost: newPost)),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Post Your Requirement',
                        style: tt.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // ── Form ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    16,
                    pad,
                    bottomInset > 0 ? bottomInset + 16 : 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(tt, 'What do you need?'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: 'e.g. Need plumber for kitchen leak',
                          icon: Icons.edit_note_rounded,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Category'),
                        const SizedBox(height: 8),
                        _buildCategorySelector(),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Describe the problem'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descController,
                          hint: 'Tell providers what exactly you need...',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Urgency'),
                        const SizedBox(height: 8),
                        _buildUrgencySelector(),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(tt, 'Preferred Date'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedDate,
                                    items: _dateOptions,
                                    onChanged: (v) =>
                                        setState(() => _selectedDate = v!),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(tt, 'Preferred Time'),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedTime,
                                    items: _timeOptions,
                                    onChanged: (v) =>
                                        setState(() => _selectedTime = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Budget (Optional)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _budgetController,
                          hint: 'e.g. \u20b9500 - \u20b91,000',
                          icon: Icons.currency_rupee_rounded,
                          keyboardType: TextInputType.text,
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(tt, 'PIN Code'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _pincodeController,
                                    hint: '110001',
                                    icon: Icons.pin_drop_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v == null || v.trim().length != 6
                                        ? '6 digits'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(tt, 'Area'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _areaController,
                                    hint: 'e.g. Connaught Place',
                                    icon: Icons.place_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Upload Image (Optional)'),
                        const SizedBox(height: 8),
                        _buildImagePlaceholder(),

                        const SizedBox(height: 20),
                        _buildSectionLabel(tt, 'Contact Preference'),
                        const SizedBox(height: 8),
                        _buildContactPreference(),

                        const SizedBox(height: 28),
                        _buildSubmitButton(tt),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildSectionLabel(TextTheme tt, String text) {
    return Text(
      text,
      style: tt.labelLarge?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppTheme.accentGold, size: 20)
            : null,
        filled: true,
        fillColor: AppTheme.surfaceElevated,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          borderSide: const BorderSide(color: AppTheme.accentGold, width: 0.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          borderSide: const BorderSide(color: AppTheme.accentCoral, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          borderSide: const BorderSide(color: AppTheme.accentCoral, width: 0.8),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: jobCategories.map((cat) {
        final selected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          },
          child: AnimatedContainer(
            duration: AppTheme.durationFast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: selected ? AppTheme.primarySubtleGradient : null,
              color: selected ? null : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: selected
                    ? AppTheme.accentGold.withAlpha(100)
                    : AppTheme.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                color: selected ? AppTheme.accentGold : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUrgencySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: JobUrgency.values.map((u) {
        final selected = _selectedUrgency == u;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedUrgency = u);
          },
          child: AnimatedContainer(
            duration: AppTheme.durationFast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? u.color.withAlpha(20) : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: selected
                    ? u.color.withAlpha(100)
                    : AppTheme.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  u.icon,
                  size: 14,
                  color: selected ? u.color : AppTheme.textMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  u.label,
                  style: TextStyle(
                    color: selected ? u.color : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.surfaceElevated,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
            size: 20,
          ),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: () => _showSnack('Image upload coming soon'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: AppTheme.border,
            width: 0.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: AppTheme.textMuted,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Tap to add photo',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPreference() {
    return Row(
      children: contactOptions.map((opt) {
        final selected = _contactPref == opt.label;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _contactPref = opt.label);
            },
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              margin: EdgeInsets.only(
                right: opt.label != contactOptions.last.label ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.primarySubtleGradient : null,
                color: selected ? null : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(
                  color: selected
                      ? AppTheme.accentGold.withAlpha(100)
                      : AppTheme.border,
                  width: selected ? 1 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt.icon,
                    size: 20,
                    color: selected ? AppTheme.accentGold : AppTheme.textMuted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt.label,
                    style: TextStyle(
                      color: selected
                          ? AppTheme.accentGold
                          : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(TextTheme tt) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: _isSubmitting ? null : _onSubmit,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          decoration: BoxDecoration(
            gradient: _isSubmitting ? null : AppTheme.primaryGradient,
            color: _isSubmitting ? AppTheme.surfaceElevated : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            boxShadow: _isSubmitting ? null : AppTheme.softGlow,
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppTheme.accentGold),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        color: AppTheme.textOnAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Post Request',
                        style: tt.titleMedium?.copyWith(
                          color: AppTheme.textOnAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}
