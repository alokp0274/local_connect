// features/jobs/screens/jobs_screen.dart
// Feature: Jobs Feed — Main Screen
//
// Social-feed bidding marketplace. Two tabs:
//   "Find Work" — provider sees open jobs near them to bid on
//   "Post a Job" — customer sees their own jobs + can post new ones

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/features/jobs/models/job_model.dart';
import 'package:local_connect/features/jobs/screens/job_detail_screen.dart';
import 'package:local_connect/features/jobs/screens/post_job_screen.dart';
import 'package:local_connect/features/jobs/screens/job_search_screen.dart';
import 'package:local_connect/features/jobs/widgets/job_card.dart';
import 'package:local_connect/shared/data/dummy_data.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  // Toggle: 0 = Find Work, 1 = Post a Job
  int _tab = 0;

  // Search + filter state
  String _searchQuery = '';
  String? _selectedCategory;

  static const List<String> _categories = [
    'All', 'Plumbing', 'Electrical', 'Cleaning', 'Carpentry',
    'AC Repair', 'Painting', 'Appliance', 'Gardening',
  ];

  List<JobPost> get _openJobs {
    return sampleJobPosts.where((j) {
      if (j.status != 'open') return false;
      if (_selectedCategory != null && _selectedCategory != 'All' && j.category != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return j.title.toLowerCase().contains(q) || j.description.toLowerCase().contains(q) || j.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<JobPost> get _myJobs {
    return sampleJobPosts.where((j) => j.customerId == 'user-current').toList();
  }

  void _openPostJob() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen()));
  }

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const JobSearchScreen()));
  }

  void _openDetail(JobPost job) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Header ──
          _JobsHeader(
            topPad: topPad,
            onSearch: _openSearch,
            onPostJob: _openPostJob,
          ),

          // ── Stats row ──
          _StatsRow(
            openCount: sampleJobPosts.where((j) => j.status == 'open').length,
            nearCount: sampleJobPosts.where((j) => j.status == 'open' && j.distanceKm < 5).length,
            hiredCount: 12, // illustrative stat
          ),

          // ── Toggle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _ToggleSwitch(value: _tab, onChanged: (v) => setState(() => _tab = v)),
          ),

          // ── Content ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _tab == 0
                  ? _FindWorkTab(
                      key: const ValueKey('find'),
                      openJobs: _openJobs,
                      searchQuery: _searchQuery,
                      selectedCategory: _selectedCategory,
                      categories: _categories,
                      onSearchChanged: (v) => setState(() => _searchQuery = v),
                      onCategorySelected: (c) => setState(() => _selectedCategory = c == 'All' ? null : c),
                      onJobTap: _openDetail,
                    )
                  : _PostAJobTab(
                      key: const ValueKey('post'),
                      myJobs: _myJobs,
                      onPostJob: _openPostJob,
                      onJobTap: _openDetail,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────

class _JobsHeader extends StatelessWidget {
  final double topPad;
  final VoidCallback onSearch;
  final VoidCallback onPostJob;

  const _JobsHeader({required this.topPad, required this.onSearch, required this.onPostJob});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 14),
      decoration: BoxDecoration(
        gradient: AppTheme.navBarGradient,
        border: const Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
      ),
      child: Row(
        children: [
          const Text(
            'Jobs',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const Spacer(),
          // Search icon
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSearch();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Post job CTA
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onPostJob();
            },
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(21),
                boxShadow: [BoxShadow(color: AppTheme.accentGold.withAlpha(70), blurRadius: 14)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.textOnAccent, size: 18),
                  SizedBox(width: 4),
                  Text('Post Job', style: TextStyle(color: AppTheme.textOnAccent, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STATS ROW
// ─────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int openCount;
  final int nearCount;
  final int hiredCount;

  const _StatsRow({required this.openCount, required this.nearCount, required this.hiredCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _StatChip(value: openCount, label: 'posted', icon: Icons.work_outline_rounded, color: AppTheme.accentPurple),
          const SizedBox(width: 8),
          _StatChip(value: nearCount, label: 'open near you', icon: Icons.location_on_rounded, color: AppTheme.accentTeal),
          const SizedBox(width: 8),
          _StatChip(value: hiredCount, label: 'hired today', icon: Icons.handshake_rounded, color: AppTheme.accentGold),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }
}

class _StatChip extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50), width: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                '$value $label',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ANIMATED TOGGLE SWITCH
// ─────────────────────────────────────────

class _ToggleSwitch extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            left: value == 0 ? 3 : null,
            right: value == 1 ? 3 : null,
            top: 3,
            bottom: 3,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [BoxShadow(color: AppTheme.accentGold.withAlpha(60), blurRadius: 8)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(0);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: value == 0 ? AppTheme.textOnAccent : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      child: const Text('Find Work'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(1);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: TextStyle(
                        color: value == 1 ? AppTheme.textOnAccent : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      child: const Text('Post a Job'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// FIND WORK TAB
// ─────────────────────────────────────────

class _FindWorkTab extends StatelessWidget {
  final List<JobPost> openJobs;
  final String searchQuery;
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<JobPost> onJobTap;

  const _FindWorkTab({
    super.key,
    required this.openJobs,
    required this.searchQuery,
    required this.selectedCategory,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _SearchBar(query: searchQuery, onChanged: onSearchChanged),
          ),
        ),
        // Category chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = (selectedCategory == null && cat == 'All') || selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onCategorySelected(cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentGold.withAlpha(22) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppTheme.accentGold.withAlpha(120) : AppTheme.border,
                        width: isSelected ? 1.2 : 0.8,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppTheme.accentGold : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Job cards
        if (openJobs.isEmpty)
          SliverFillRemaining(
            child: _EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No jobs found',
              subtitle: 'Try a different category or search term',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: JobCard(
                    job: openJobs[i],
                    index: i,
                    isCustomerView: false,
                    onTap: () => onJobTap(openJobs[i]),
                    onBidTap: () => onJobTap(openJobs[i]),
                  ),
                ),
                childCount: openJobs.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// POST A JOB TAB
// ─────────────────────────────────────────

class _PostAJobTab extends StatelessWidget {
  final List<JobPost> myJobs;
  final VoidCallback onPostJob;
  final ValueChanged<JobPost> onJobTap;

  const _PostAJobTab({super.key, required this.myJobs, required this.onPostJob, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    if (myJobs.isEmpty) {
      return _EmptyState(
        icon: Icons.work_off_rounded,
        title: 'No jobs posted yet',
        subtitle: 'Post your first job and get bids from local pros',
        action: GestureDetector(
          onTap: onPostJob,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppTheme.textOnAccent),
                SizedBox(width: 8),
                Text('Post a Job', style: TextStyle(color: AppTheme.textOnAccent, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: myJobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => JobCard(
        job: myJobs[i],
        index: i,
        isCustomerView: true,
        onTap: () => onJobTap(myJobs[i]),
        onViewBidsTap: () => onJobTap(myJobs[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────
// INLINE SEARCH BAR
// ─────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search jobs by title, category…',
          hintStyle: TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyState({required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textMuted, size: 60),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
