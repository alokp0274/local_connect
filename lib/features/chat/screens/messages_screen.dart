// features/chat/screens/messages_screen.dart
// Feature: Messaging & Communication
//
// Chat inbox showing all active conversations with providers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/core/utils/category_icons.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/chat/screens/chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';
  final Set<String> _archivedIds = {};
  final Set<String> _pinnedIds = {};
  final Set<String> _readIds = {};
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchFocus.addListener(() {
      if (mounted) setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    HapticFeedback.selectionClick();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {});
  }

  bool _threadHasUnread(ChatThread thread) =>
      thread.hasUnread && !_readIds.contains(thread.provider.id);

  Future<void> _openChat(ChatThread thread) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, b) => ChatDetailScreen(thread: thread),
        transitionsBuilder: (_, anim, b, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
    if (!mounted) return;
    setState(() => _readIds.add(thread.provider.id));
  }

  List<ChatThread> get _allChats {
    var chats = activeChats.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.provider.name.toLowerCase().contains(q) ||
          (t.lastMessage?.text.toLowerCase().contains(q) ?? false);
    }).toList();
    chats.sort((a, b) {
      final aPinned = _pinnedIds.contains(a.provider.id) ? 0 : 1;
      final bPinned = _pinnedIds.contains(b.provider.id) ? 0 : 1;
      if (aPinned != bPinned) return aPinned.compareTo(bPinned);
      final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
      final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return chats;
  }

  List<ChatThread> get _filteredChats {
    switch (_tabController.index) {
      case 1:
        return _allChats
            .where((t) => !_archivedIds.contains(t.provider.id))
            .toList();
      case 2:
        return _allChats.where(_threadHasUnread).toList();
      case 3:
        return _allChats
            .where((t) => _archivedIds.contains(t.provider.id))
            .toList();
      default:
        return _allChats
            .where((t) => !_archivedIds.contains(t.provider.id))
            .toList();
    }
  }

  int get _unreadCount => activeChats.where(_threadHasUnread).length;

  void _togglePin(ChatThread thread) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_pinnedIds.contains(thread.provider.id)) {
        _pinnedIds.remove(thread.provider.id);
      } else {
        _pinnedIds.add(thread.provider.id);
      }
    });
  }

  void _archive(ChatThread thread) {
    setState(() => _archivedIds.add(thread.provider.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${thread.provider.name} archived'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () =>
                setState(() => _archivedIds.remove(thread.provider.id)),
          ),
        ),
      );
  }

  void _delete(ChatThread thread) {
    setState(() => activeChats.remove(thread));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${thread.provider.name} deleted'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => activeChats.add(thread)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pad = AppTheme.responsivePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── HEADER ──
              _buildHeader(tt, pad),
              // ── CHAT LIST ──
              Expanded(
                child: _filteredChats.isEmpty
                    ? _EmptyState(tab: _tabController.index)
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        color: AppTheme.accentGold,
                        backgroundColor: AppTheme.surface,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(pad, 10, pad, 100),
                          itemCount: _filteredChats.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final thread = _filteredChats[i];
                            final isPinned = _pinnedIds.contains(
                              thread.provider.id,
                            );
                            return Dismissible(
                              key: ValueKey(thread.provider.id),
                              background: _SwipeBg(
                                alignLeft: true,
                                color: AppTheme.accentCoral,
                                icon: Icons.delete_rounded,
                                label: 'Delete',
                              ),
                              secondaryBackground: _SwipeBg(
                                alignLeft: false,
                                color: AppTheme.accentTeal,
                                icon: Icons.archive_rounded,
                                label: 'Archive',
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  _delete(thread);
                                } else {
                                  _archive(thread);
                                }
                                return false;
                              },
                              child: _ChatTile(
                                thread: thread,
                                unread: _threadHasUnread(thread),
                                pinned: isPinned,
                                onTap: () => _openChat(thread),
                                onLongPress: () => _togglePin(thread),
                                index: i,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipTab(int index, String label) {
    final selected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _tabController.animateTo(index);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGold : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: selected ? AppTheme.accentGold : AppTheme.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme tt, double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 10, pad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Messages', style: tt.headlineLarge),
                    const SizedBox(height: 3),
                    Text(
                      'Stay connected with your local experts',
                      style: tt.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GlassContainer(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.accentGold,
                  size: 20,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 260.ms),
          const SizedBox(height: 14),
          // Search bar
          AnimatedContainer(
            duration: AppTheme.durationFast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: _isSearchFocused
                    ? AppTheme.accentGold.withAlpha(100)
                    : AppTheme.border,
                width: _isSearchFocused ? 1.0 : 0.6,
              ),
              color: AppTheme.surfaceElevated,
              boxShadow: _isSearchFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.accentGold.withAlpha(15),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: AnimatedContainer(
                    duration: AppTheme.durationFast,
                    child: Icon(
                      Icons.search_rounded,
                      color: _isSearchFocused
                          ? AppTheme.primary
                          : AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.mic_rounded,
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 220.ms),
          const SizedBox(height: 12),
          // Filter chip tabs
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChipTab(0, 'All'),
                const SizedBox(width: 8),
                _buildChipTab(1, 'Booked'),
                const SizedBox(width: 8),
                _buildChipTab(
                  2,
                  'Unread${_unreadCount > 0 ? ' ($_unreadCount)' : ''}',
                ),
                const SizedBox(width: 8),
                _buildChipTab(3, 'Archived'),
              ],
            ),
          ).animate(delay: 120.ms).fadeIn(duration: 220.ms),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CONVERSATION TILE
// ─────────────────────────────────────────
class _ChatTile extends StatefulWidget {
  final ChatThread thread;
  final bool unread;
  final bool pinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int index;

  const _ChatTile({
    required this.thread,
    required this.unread,
    required this.pinned,
    required this.onTap,
    required this.onLongPress,
    required this.index,
  });

  @override
  State<_ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<_ChatTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.thread.provider;
    final last = widget.thread.lastMessage;
    final grad = CategoryIcons.getGradient(p.service);

    return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              gradient: widget.unread
                  ? LinearGradient(
                      colors: [
                        AppTheme.accentGold.withAlpha(8),
                        Colors.transparent,
                      ],
                    )
                  : AppTheme.surfaceGradient,
              border: Border.all(
                color: widget.unread
                    ? AppTheme.accentGold.withAlpha(30)
                    : AppTheme.border,
                width: 0.6,
              ),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: grad),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSM,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: grad.first.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      if (p.isOnline)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.background,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      if (p.isVerified)
                        Positioned(
                          left: -3,
                          top: -3,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.accentBlue.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: AppTheme.accentBlue,
                              size: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.pinned) ...[
                              const Icon(
                                Icons.push_pin_rounded,
                                size: 11,
                                color: AppTheme.accentGold,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: widget.unread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (last != null)
                              Text(
                                timeago.format(
                                  last.timestamp,
                                  locale: 'en_short',
                                ),
                                style: TextStyle(
                                  color: widget.unread
                                      ? AppTheme.accentGold
                                      : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: widget.unread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.service,
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (last != null && last.isFromUser) ...[
                              Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: widget.unread
                                    ? AppTheme.textMuted
                                    : AppTheme.accentTeal,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                last?.text ?? 'Start a conversation',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: widget.unread
                                      ? AppTheme.textSecondary
                                      : AppTheme.textMuted,
                                  fontWeight: widget.unread
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (widget.unread)
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      color: AppTheme.textOnAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 40).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: -0.03);
  }
}

class _SwipeBg extends StatelessWidget {
  final bool alignLeft;
  final Color color;
  final IconData icon;
  final String label;
  const _SwipeBg({
    required this.alignLeft,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!alignLeft) ...[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          if (alignLeft) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'No messages yet',
      'No booked chats',
      'All caught up!',
      'Nothing archived',
    ];
    final icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.calendar_today_outlined,
      Icons.check_circle_outline_rounded,
      Icons.archive_outlined,
    ];
    final colors = [
      AppTheme.textMuted,
      AppTheme.accentBlue,
      AppTheme.accentTeal,
      AppTheme.accentPurple,
    ];

    return Center(
      child:
          Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors[tab].withAlpha(15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icons[tab], size: 36, color: colors[tab]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      labels[tab],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tab == 2
                          ? 'No unread messages'
                          : 'Your conversations will appear here',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
