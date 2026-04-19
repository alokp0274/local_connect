// features/chat/screens/chat_detail_screen.dart
// Feature: Messaging & Communication
//
// Individual chat thread with message bubbles, input, and quick actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:local_connect/shared/models/provider_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';
import 'package:local_connect/shared/widgets/animated_mesh_background.dart';
import 'package:local_connect/shared/widgets/glass_container.dart';
import 'package:local_connect/features/chat/screens/audio_call_screen.dart';
import 'package:local_connect/features/chat/screens/video_call_screen.dart';
import 'package:local_connect/features/provider/screens/provider_detail_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatThread thread;
  const ChatDetailScreen({super.key, required this.thread});
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocus = FocusNode();
  late List<ChatMessage> _messages;
  bool _typing = false;
  bool _showAttach = false;
  bool _hasText = false;
  bool _isInputFocused = false;
  late final AnimationController _sendBtnController;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.thread.messages);
    _sendBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (_hasText != has && mounted) {
        setState(() => _hasText = has);
        if (has) {
          _sendBtnController.forward();
        } else {
          _sendBtnController.reverse();
        }
      }
    });
    _inputFocus.addListener(() {
      if (mounted) setState(() => _isInputFocused = _inputFocus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _sendBtnController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _send([String? override]) {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'user',
          senderName: 'You',
          text: text,
          timestamp: DateTime.now(),
          isFromUser: true,
        ),
      );
      _controller.clear();
      _hasText = false;
      _showAttach = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    setState(() => _typing = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: widget.thread.provider.id,
            senderName: widget.thread.provider.name,
            text: 'Got it. I will update you shortly.',
            timestamp: DateTime.now(),
            isFromUser: false,
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.thread.provider;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedMeshBackground(
        subtle: true,
        child: Column(
          children: [
            // ── TOP BAR ──
            _buildAppBar(p),
            // ── MESSAGES ──
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      itemCount: _messages.length + (_typing ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_typing && i == _messages.length) {
                          return const _TypingIndicator();
                        }
                        final msg = _messages[i];
                        final showDate =
                            i == 0 ||
                            !_sameDay(
                              _messages[i - 1].timestamp,
                              msg.timestamp,
                            );
                        return Column(
                          children: [
                            if (showDate) _DateSeparator(date: msg.timestamp),
                            _ChatBubble(message: msg, index: i),
                          ],
                        );
                      },
                    ),
            ),
            // ── ATTACHMENT PANEL ──
            if (_showAttach) _buildAttachPanel(),
            // ── INPUT COMPOSER ──
            _buildComposer(bottomInset),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──
  Widget _buildAppBar(ServiceProvider p) {
    return GlassContainer(
      padding: EdgeInsets.fromLTRB(
        4,
        MediaQuery.of(context).padding.top + 8,
        8,
        10,
      ),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      border: Border(
        bottom: BorderSide(color: AppTheme.glassBorderLight, width: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0x30000000),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
          Hero(
            tag: 'provider-avatar-${p.id}',
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProviderDetailScreen(provider: p),
                ),
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppTheme.primarySubtleGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(color: AppTheme.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withAlpha(25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProviderDetailScreen(provider: p),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (p.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppTheme.accentBlue,
                        size: 15,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _typing
                            ? AppTheme.primary
                            : (p.isOnline
                                  ? AppTheme.accentTeal
                                  : AppTheme.textMuted),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _typing
                          ? 'typing...'
                          : (p.isOnline ? 'Online now' : 'Last seen recently'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _typing
                            ? AppTheme.accentGold
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
          _AppBarAction(
            icon: Icons.call_rounded,
            color: AppTheme.accentTeal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AudioCallScreen(provider: p)),
            ),
          ),
          const SizedBox(width: 6),
          _AppBarAction(
            icon: Icons.videocam_rounded,
            color: AppTheme.accentBlue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VideoCallScreen(provider: p)),
            ),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 36,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Start the conversation',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Send a message to ${widget.thread.provider.name.split(' ').first}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  // ── ATTACHMENT PANEL ──
  Widget _buildAttachPanel() {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      color: AppTheme.surfaceElevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _AttachOption(
            icon: Icons.photo_rounded,
            label: 'Gallery',
            color: AppTheme.accentPurple,
          ),
          _AttachOption(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            color: AppTheme.accentCoral,
          ),
          _AttachOption(
            icon: Icons.insert_drive_file_rounded,
            label: 'Document',
            color: AppTheme.accentBlue,
          ),
          _AttachOption(
            icon: Icons.location_on_rounded,
            label: 'Location',
            color: AppTheme.accentTeal,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.15);
  }

  // ── INPUT COMPOSER ──
  Widget _buildComposer(double bottomInset) {
    return GlassContainer(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        bottomInset > 0 ? 8 : MediaQuery.of(context).padding.bottom + 8,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      border: Border(top: BorderSide(color: AppTheme.glassBorderLight, width: 0.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button
          _ComposerAction(
            icon: _showAttach ? Icons.close_rounded : Icons.add_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showAttach = !_showAttach);
            },
          ),
          const SizedBox(width: 6),
          // Text field
          Expanded(
            child: AnimatedContainer(
              duration: AppTheme.durationFast,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                border: Border.all(
                  color: _isInputFocused
                      ? AppTheme.accentGold.withAlpha(60)
                      : AppTheme.border,
                  width: _isInputFocused ? 0.8 : 0.5,
                ),
                boxShadow: _isInputFocused
                    ? [BoxShadow(color: AppTheme.accentGold.withAlpha(15), blurRadius: 12)]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _inputFocus,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(14, 10, 4, 10),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Send / Voice
          _SendButton(hasText: _hasText, onSend: _send),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// APP BAR ACTION BUTTON
// ─────────────────────────────────────────
class _AppBarAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AppBarAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  State<_AppBarAction> createState() => _AppBarActionState();
}

class _AppBarActionState extends State<_AppBarAction> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(20),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            border: Border.all(color: widget.color.withAlpha(50), width: 0.6),
          ),
          child: Icon(widget.icon, color: widget.color, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SEND BUTTON WITH MORPH
// ─────────────────────────────────────────
class _SendButton extends StatefulWidget {
  final bool hasText;
  final VoidCallback onSend;
  const _SendButton({required this.hasText, required this.onSend});
  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.hasText
          ? () {
              widget.onSend();
            }
          : null,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: widget.hasText ? AppTheme.primaryGradient : null,
            color: widget.hasText ? null : AppTheme.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.hasText ? Colors.transparent : AppTheme.border,
              width: 0.6,
            ),
            boxShadow: widget.hasText
                ? [
                    BoxShadow(
                      color: AppTheme.accentGold.withAlpha(60),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              widget.hasText ? Icons.send_rounded : Icons.mic_rounded,
              key: ValueKey(widget.hasText),
              color: widget.hasText
                  ? AppTheme.textOnAccent
                  : AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// COMPOSER ACTION BUTTON
// ─────────────────────────────────────────
class _ComposerAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ComposerAction({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.textMuted, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;
  const _ChatBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    final user = message.isFromUser;
    final time = DateFormat('HH:mm').format(message.timestamp);
    final maxW = MediaQuery.of(context).size.width * 0.78;

    return Align(
          alignment: user ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: maxW),
            decoration: BoxDecoration(
              color: user ? AppTheme.primary : AppTheme.surfaceElevated,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(user ? 18 : 4),
                bottomRight: Radius.circular(user ? 4 : 18),
              ),
              border: user
                  ? null
                  : Border.all(color: AppTheme.border, width: 0.4),
              boxShadow: [
                BoxShadow(
                  color: user
                      ? AppTheme.accentGold.withAlpha(25)
                      : const Color(0x20000000),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: user ? Colors.white : AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: user ? Colors.white70 : AppTheme.textMuted,
                      ),
                    ),
                    if (user) ...[
                      const SizedBox(width: 3),
                      Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 20).ms)
        .fadeIn(duration: 180.ms)
        .slideY(begin: 0.06);
  }
}

// ─────────────────────────────────────────
// DATE SEPARATOR
// ─────────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    final text = diff == 0
        ? 'Today'
        : diff == 1
        ? 'Yesterday'
        : DateFormat('MMM dd, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 0.5, color: AppTheme.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Container(height: 0.5, color: AppTheme.border)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// TYPING INDICATOR
// ─────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: AppTheme.border, width: 0.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) =>
                Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      decoration: const BoxDecoration(
                        color: AppTheme.textMuted,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 400.ms, delay: (i * 200).ms)
                    .then()
                    .fadeOut(duration: 400.ms),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ATTACHMENT OPTION
// ─────────────────────────────────────────
class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(50), width: 0.6),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


