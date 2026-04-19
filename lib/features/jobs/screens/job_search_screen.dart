// features/jobs/screens/job_search_screen.dart
// Feature: Jobs Feed — Full screen search overlay

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';
import 'package:local_connect/features/jobs/screens/job_detail_screen.dart';
import 'package:local_connect/shared/data/dummy_data.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  static const _recentSearches = [
    'Plumber near me',
    'AC repair',
    'Deep cleaning',
    'Electrician',
  ];

  static const List<Map<String, dynamic>> _categoryGrid = [
    {
      'label': 'Plumbing',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF60A5FA),
    },
    {
      'label': 'Electrical',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFFACC15),
    },
    {
      'label': 'Cleaning',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF10B981),
    },
    {'label': 'Carpentry', 'icon': Icons.carpenter, 'color': Color(0xFFF97316)},
    {
      'label': 'AC Repair',
      'icon': Icons.air_rounded,
      'color': Color(0xFF38BDF8),
    },
    {
      'label': 'Painting',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFFA78BFA),
    },
    {
      'label': 'Appliance',
      'icon': Icons.kitchen_rounded,
      'color': Color(0xFFFF6B6B),
    },
    {
      'label': 'Gardening',
      'icon': Icons.yard_rounded,
      'color': Color(0xFF4ADE80),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<JobPost> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return sampleJobPosts.where((j) {
      return j.status == 'open' &&
          (j.title.toLowerCase().contains(q) ||
              j.description.toLowerCase().contains(q) ||
              j.category.toLowerCase().contains(q) ||
              j.location.toLowerCase().contains(q));
    }).toList();
  }

  void _openJob(JobPost job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Search bar header ──
          Container(
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 12),
            color: const Color(0xFF0F1628),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.accentGold.withAlpha(60),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search jobs, categories, locations…',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: _query.isEmpty
                ? _buildBrowse()
                : _results.isEmpty
                ? _buildNoResults()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          const Text(
            'Recent Searches',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((s) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _controller.text = s;
                  setState(() => _query = s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        color: AppTheme.textMuted,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Category grid
          const Text(
            'Browse by Category',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: _categoryGrid.asMap().entries.map((e) {
              final i = e.key;
              final cat = e.value;
              return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      final label = cat['label'] as String;
                      _controller.text = label;
                      setState(() => _query = label);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withAlpha(14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (cat['color'] as Color).withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            cat['icon'] as IconData,
                            color: cat['color'] as Color,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              cat['label'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cat['color'] as Color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (i * 50).ms)
                  .fadeIn(duration: 250.ms)
                  .scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final j = _results[i];
        return GestureDetector(
              onTap: () => _openJob(j),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141B2D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E2A40)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: AppTheme.accentPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            j.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  j.category,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.accentPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Text(
                                '  •  ',
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                              Flexible(
                                child: Text(
                                  '₹${j.budgetMin}–₹${j.budgetMax}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textMuted,
                      size: 14,
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: (i * 50).ms)
            .fadeIn(duration: 250.ms)
            .slideX(begin: 0.05);
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppTheme.textMuted,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs for "$_query"',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different keyword or browse categories.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
