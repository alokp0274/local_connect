// features/booking/screens/bookings_screen.dart
//
// User's bookings dashboard with chip-style tab bar (Upcoming / Ongoing /
// Completed / Cancelled). Cards show provider info, status badge,
// date+price row and contextual action buttons per tab.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import 'package:local_connect/core/routes/app_router.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/category_icons.dart';
import 'package:local_connect/features/booking/screens/booking_detail_screen.dart';

// ---------------------------------------------------------------
//  BookingsScreen - stateful with TabController for 4 categories
// ---------------------------------------------------------------
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Tab metadata (label + icon)
  static const _tabs = [
    _TabMeta('Upcoming', Icons.schedule_rounded),
    _TabMeta('Ongoing', Icons.play_circle_outline_rounded),
    _TabMeta('Completed', Icons.check_circle_outline_rounded),
    _TabMeta('Cancelled', Icons.cancel_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() => setState(() {}));
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // -- Build -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // -- Header ------------------------------------------------
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Bookings', style: tt.headlineLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Track, manage and rebook services',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _RefreshButton(onTap: _refresh),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // -- Chip Tab Bar ------------------------------------------
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: pad),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _tabController.index == i;
                  return _ChipTab(
                    meta: _tabs[i],
                    selected: selected,
                    onTap: () => _tabController.animateTo(i),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // -- Tab Content -------------------------------------------
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookingTabView(
                    status: 'upcoming',
                    bookings: _upcomingBookings,
                    pad: pad,
                    loading: _isLoading,
                  ),
                  _BookingTabView(
                    status: 'ongoing',
                    bookings: _ongoingBookings,
                    pad: pad,
                    loading: _isLoading,
                  ),
                  _BookingTabView(
                    status: 'completed',
                    bookings: _completedBookings,
                    pad: pad,
                    loading: _isLoading,
                  ),
                  _BookingTabView(
                    status: 'cancelled',
                    bookings: _cancelledBookings,
                    pad: pad,
                    loading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Dummy data ---------------------------------------------------
  List<Map<String, dynamic>> get _upcomingBookings => [
    {
      'id': 'BK-1942',
      'providerName': 'Rajesh Kumar',
      'service': 'Plumber',
      'date': 'Tomorrow',
      'time': '10:00 AM',
      'address': '42, MG Road, Sector 14',
      'price': '\u20b9500',
      'status': 'confirmed',
      'package': 'Standard Repair',
      'notes': 'Please bring connector set',
      'payment': 'UPI',
    },
    {
      'id': 'BK-1943',
      'providerName': 'Vikram Singh',
      'service': 'Electrician',
      'date': 'Fri, 11 Jul',
      'time': '02:00 PM',
      'address': '118, Park Avenue',
      'price': '\u20b9800',
      'status': 'pending',
      'package': 'Basic Visit',
      'notes': 'Inverter inspection',
      'payment': 'Cash',
    },
  ];

  List<Map<String, dynamic>> get _ongoingBookings => [
    {
      'id': 'BK-1944',
      'providerName': 'Priya Gupta',
      'service': 'Tutor',
      'date': 'Today',
      'time': '04:00 PM',
      'address': '33, Lotus Residency',
      'price': '\u20b91,500/hr',
      'status': 'in-progress',
      'package': 'Premium Full Service',
      'notes': 'Math + Science session',
      'payment': 'Card',
    },
  ];

  List<Map<String, dynamic>> get _completedBookings => [
    {
      'id': 'BK-1932',
      'providerName': 'Cool Care Services',
      'service': 'AC Repair',
      'date': 'Mon, 01 Jul',
      'time': '11:00 AM',
      'address': '22, Ocean Heights',
      'price': '\u20b92,500',
      'status': 'completed',
      'package': 'Premium Full Service',
      'notes': 'Gas refill included',
      'payment': 'UPI',
    },
    {
      'id': 'BK-1930',
      'providerName': 'Sparkle Clean',
      'service': 'Cleaning',
      'date': 'Sat, 29 Jun',
      'time': '09:00 AM',
      'address': '11, Maple Street',
      'price': '\u20b93,000',
      'status': 'completed',
      'package': 'Standard Repair',
      'notes': 'Deep cleaning',
      'payment': 'Card',
    },
  ];

  List<Map<String, dynamic>> get _cancelledBookings => [
    {
      'id': 'BK-1918',
      'providerName': 'Manoj Tiwari',
      'service': 'Electrician',
      'date': 'Wed, 19 Jun',
      'time': '03:00 PM',
      'address': '7, Lakeside Towers',
      'price': '\u20b9600',
      'status': 'cancelled',
      'package': 'Basic Visit',
      'notes': 'Switchboard issue',
      'payment': 'Cash',
    },
  ];
}

// ---------------------------------------------------------------
//  _TabMeta - tiny value class for tab label + icon
// ---------------------------------------------------------------
class _TabMeta {
  final String label;
  final IconData icon;
  const _TabMeta(this.label, this.icon);
}

// ---------------------------------------------------------------
//  _ChipTab - scrollable chip-style tab button
// ---------------------------------------------------------------
class _ChipTab extends StatelessWidget {
  final _TabMeta meta;
  final bool selected;
  final VoidCallback onTap;

  const _ChipTab({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGold : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: selected ? AppTheme.accentGold : AppTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              meta.icon,
              size: 16,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              meta.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  _RefreshButton - subtle icon button on the header
// ---------------------------------------------------------------
class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RefreshButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.refresh_rounded, size: 22, color: AppTheme.accentGold),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  _BookingTabView - content for a single tab
// ---------------------------------------------------------------
class _BookingTabView extends StatelessWidget {
  final String status;
  final List<Map<String, dynamic>> bookings;
  final double pad;
  final bool loading;

  const _BookingTabView({
    required this.status,
    required this.bookings,
    required this.pad,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return ListView.builder(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 20),
        itemCount: 3,
        itemBuilder: (_, _) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: AppTheme.surfaceElevated,
              highlightColor: AppTheme.surface,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                ),
              ),
            ),
          );
        },
      );
    }

    if (bookings.isEmpty) return _EmptyBookings(status: status);

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      color: AppTheme.accentGold,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(pad, 8, pad, 20),
        itemCount: bookings.length,
        itemBuilder: (_, i) =>
            _BookingCard(booking: bookings[i], index: i, tabStatus: status),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  _EmptyBookings - shown when a tab has zero bookings
// ---------------------------------------------------------------
class _EmptyBookings extends StatelessWidget {
  final String status;
  const _EmptyBookings({required this.status});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final map = {
      'upcoming': ('No upcoming bookings', Icons.schedule_rounded),
      'ongoing': ('No ongoing bookings', Icons.play_circle_outline_rounded),
      'completed': (
        'No completed bookings',
        Icons.check_circle_outline_rounded,
      ),
      'cancelled': ('No cancelled bookings', Icons.cancel_outlined),
    };
    final entry = map[status]!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(entry.$2, size: 32, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Text(entry.$1, style: tt.titleMedium),
            const SizedBox(height: 4),
            Text(
              'New bookings will appear here automatically.',
              style: tt.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  _BookingCard - single booking item with provider info,
//  status badge, date/price row, and contextual action buttons
// ---------------------------------------------------------------
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int index;
  final String tabStatus;

  const _BookingCard({
    required this.booking,
    required this.index,
    required this.tabStatus,
  });

  // Status color mapping
  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'in-progress':
        return AppTheme.accentGold;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textMuted;
    }
  }

  // Contextual actions per tab
  List<_ActionItem> _actions(BuildContext context) {
    switch (tabStatus) {
      case 'upcoming':
        return [
          _ActionItem('View', Icons.visibility_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailScreen(booking: booking),
              ),
            );
          }),
          _ActionItem('Reschedule', Icons.update_rounded, () {
            Navigator.pushNamed(
              context,
              AppRoutes.selectSlot,
              arguments: {'providerName': booking['providerName']},
            );
          }),
          _ActionItem('Cancel', Icons.cancel_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking cancellation requested')),
            );
          }, isDestructive: true),
        ];
      case 'ongoing':
        return [
          _ActionItem('Track', Icons.route_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Live tracking coming soon')),
            );
          }),
          _ActionItem('Chat', Icons.chat_rounded, () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Opening chat...')));
          }),
          _ActionItem('Call', Icons.call_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling provider...')),
            );
          }),
        ];
      case 'completed':
        return [
          _ActionItem('Rebook', Icons.refresh_rounded, () {
            Navigator.pushNamed(
              context,
              AppRoutes.selectSlot,
              arguments: {'providerName': booking['providerName']},
            );
          }),
          _ActionItem('Review', Icons.star_rounded, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review form opening...')),
            );
          }),
          _ActionItem('Invoice', Icons.receipt_long_rounded, () {
            Navigator.pushNamed(
              context,
              AppRoutes.invoice,
              arguments: {'bookingId': booking['id']},
            );
          }),
        ];
      case 'cancelled':
        return [
          _ActionItem('Rebook', Icons.refresh_rounded, () {
            Navigator.pushNamed(
              context,
              AppRoutes.selectSlot,
              arguments: {'providerName': booking['providerName']},
            );
          }),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final status = booking['status'] as String;
    final statusColor = _statusColor(status);
    final actions = _actions(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            // -- Provider row + status badge --
            Row(
              children: [
                Hero(
                  tag: 'booking-${booking['id']}',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: CategoryIcons.getCategoryGradient(
                        booking['service'] as String,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Icon(
                      CategoryIcons.getIcon(booking['service'] as String),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['providerName'] as String,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking['service']} \u00b7 ${booking['package']}',
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: statusColor.withAlpha(60)),
                  ),
                  child: Text(
                    status.replaceAll('-', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // -- Date / Time + Price row --
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${booking['date']} \u00b7 ${booking['time']}',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    booking['price'] as String,
                    style: tt.titleMedium?.copyWith(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // -- Action buttons --
            Row(
              children: actions.map((action) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: action == actions.last ? 0 : 8,
                    ),
                    child: _ActionButton(action: action),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ).animate(delay: (index * 60).ms).fadeIn(duration: 280.ms).slideY(begin: 0.08),
    );
  }
}

// ---------------------------------------------------------------
//  _ActionItem - data holder for a contextual action
// ---------------------------------------------------------------
class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionItem(
    this.label,
    this.icon,
    this.onTap, {
    this.isDestructive = false,
  });
}

// ---------------------------------------------------------------
//  _ActionButton - tappable chip-style action
// ---------------------------------------------------------------
class _ActionButton extends StatelessWidget {
  final _ActionItem action;
  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive ? AppTheme.error : AppTheme.accentGold;

    return Material(
      color: color.withAlpha(15),
      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        onTap: () {
          HapticFeedback.selectionClick();
          action.onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                action.label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
