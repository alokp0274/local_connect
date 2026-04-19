// ─────────────────────────────────────────────────────────
//  REWARDS & LOYALTY MODELS
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Membership Tier ──
enum MembershipTier { silver, gold, elite }

extension MembershipTierX on MembershipTier {
  String get label {
    switch (this) {
      case MembershipTier.silver:
        return 'Silver';
      case MembershipTier.gold:
        return 'Gold';
      case MembershipTier.elite:
        return 'Elite';
    }
  }

  IconData get icon {
    switch (this) {
      case MembershipTier.silver:
        return Icons.shield_rounded;
      case MembershipTier.gold:
        return Icons.workspace_premium_rounded;
      case MembershipTier.elite:
        return Icons.diamond_rounded;
    }
  }

  int get minPoints {
    switch (this) {
      case MembershipTier.silver:
        return 0;
      case MembershipTier.gold:
        return 500;
      case MembershipTier.elite:
        return 2000;
    }
  }
}

// ── Reward Badge ──
class RewardBadge {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool earned;
  final String? earnedDate;
  final double progress; // 0.0 – 1.0
  final String? progressLabel;

  const RewardBadge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.earned = false,
    this.earnedDate,
    this.progress = 0.0,
    this.progressLabel,
  });
}

// ── Earn Rule ──
class EarnRule {
  final String title;
  final String subtitle;
  final int points;
  final IconData icon;
  final Color color;
  final bool completed;

  const EarnRule({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.icon,
    required this.color,
    this.completed = false,
  });
}

// ── Redeemable Reward ──
class RedeemableReward {
  final String id;
  final String title;
  final String subtitle;
  final int pointsCost;
  final IconData icon;
  final Color color;
  final String tag; // e.g. "Popular", "New"

  const RedeemableReward({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pointsCost,
    required this.icon,
    required this.color,
    this.tag = '',
  });
}

// ── Reward Activity ──
enum RewardActivityType { earned, redeemed, bonus, levelUp }

class RewardActivity {
  final String title;
  final String subtitle;
  final String time;
  final int points;
  final RewardActivityType type;

  const RewardActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.points,
    required this.type,
  });
}

// ── Wallet Transaction ──
enum WalletTxType { cashback, promo, debit, reward, referral }

class WalletTransaction {
  final String title;
  final double amount;
  final String date;
  final WalletTxType type;
  final String? subtitle;

  const WalletTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.subtitle,
  });

  bool get isCredit => type != WalletTxType.debit;
}

// ── Offer / Deal ──
class OfferDeal {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String validTill;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? tag;
  final double? discountPercent;

  const OfferDeal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.validTill,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.tag,
    this.discountPercent,
  });
}

// ── Streak Data ──
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final List<bool> weekDays; // Mon–Sun, true = active
  final int totalCheckIns;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.weekDays,
    required this.totalCheckIns,
  });
}

// ── Provider Achievement ──
class ProviderAchievement {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool earned;
  final double progress;
  final String progressLabel;

  const ProviderAchievement({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.earned = false,
    this.progress = 0.0,
    this.progressLabel = '',
  });
}

// ── Reward Notification ──
enum RewardNotifType {
  pointsEarned,
  badgeUnlocked,
  tierUpgrade,
  cashback,
  offer,
  streak,
}

class RewardNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final RewardNotifType type;
  final bool isRead;

  const RewardNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

// ── Retention Suggestion ──
class RetentionSuggestion {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String cta;

  const RetentionSuggestion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.cta,
  });
}

// ── Tier Benefit ──
class TierBenefit {
  final String title;
  final IconData icon;
  final bool available;

  const TierBenefit({
    required this.title,
    required this.icon,
    this.available = true,
  });
}
