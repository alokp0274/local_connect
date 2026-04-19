// ─────────────────────────────────────────────────────────
//  REWARDS & LOYALTY — DUMMY DATA
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:local_connect/features/rewards/models/rewards_model.dart';
import 'package:local_connect/core/theme/app_theme.dart';

// ── User Reward State ──
const int userTotalPoints = 1250;
const MembershipTier userTier = MembershipTier.gold;
const int pointsToNextTier = 750; // 2000 - 1250

// ── Earn Rules ──
const List<EarnRule> earnRules = [
  EarnRule(
    title: 'First Signup',
    subtitle: 'Create your account',
    points: 100,
    icon: Icons.person_add_rounded,
    color: AppTheme.accentBlue,
    completed: true,
  ),
  EarnRule(
    title: 'Complete Profile',
    subtitle: 'Add photo, phone & address',
    points: 50,
    icon: Icons.badge_rounded,
    color: AppTheme.accentTeal,
    completed: true,
  ),
  EarnRule(
    title: 'First Service Request',
    subtitle: 'Book your first provider',
    points: 150,
    icon: Icons.rocket_launch_rounded,
    color: AppTheme.accentGold,
    completed: true,
  ),
  EarnRule(
    title: 'Repeat Booking',
    subtitle: 'Book same provider again',
    points: 75,
    icon: Icons.repeat_rounded,
    color: AppTheme.accentPurple,
    completed: true,
  ),
  EarnRule(
    title: 'Write a Review',
    subtitle: 'Review any completed service',
    points: 30,
    icon: Icons.rate_review_rounded,
    color: AppTheme.accentCoral,
    completed: true,
  ),
  EarnRule(
    title: 'Refer a Friend',
    subtitle: 'Each friend who joins',
    points: 200,
    icon: Icons.people_rounded,
    color: AppTheme.accentBlue,
    completed: false,
  ),
  EarnRule(
    title: 'Daily Login',
    subtitle: 'Open app every day',
    points: 10,
    icon: Icons.today_rounded,
    color: AppTheme.accentTeal,
    completed: true,
  ),
  EarnRule(
    title: 'Save a Favorite',
    subtitle: 'Favorite any provider',
    points: 15,
    icon: Icons.favorite_rounded,
    color: AppTheme.accentCoral,
    completed: true,
  ),
  EarnRule(
    title: 'Invite a Provider',
    subtitle: 'Help onboard a provider',
    points: 300,
    icon: Icons.business_rounded,
    color: AppTheme.accentGold,
    completed: false,
  ),
];

// ── Redeemable Rewards ──
const List<RedeemableReward> redeemableRewards = [
  RedeemableReward(
    id: 'r1',
    title: '10% Discount Coupon',
    subtitle: 'Valid on any service booking',
    pointsCost: 200,
    icon: Icons.local_offer_rounded,
    color: AppTheme.accentGold,
    tag: 'Popular',
  ),
  RedeemableReward(
    id: 'r2',
    title: '\u20b950 Cashback',
    subtitle: 'Applied to your wallet instantly',
    pointsCost: 300,
    icon: Icons.savings_rounded,
    color: AppTheme.accentTeal,
    tag: '',
  ),
  RedeemableReward(
    id: 'r3',
    title: 'Free Service Inspection',
    subtitle: 'Free home inspection by verified pro',
    pointsCost: 500,
    icon: Icons.home_repair_service_rounded,
    color: AppTheme.accentBlue,
    tag: 'New',
  ),
  RedeemableReward(
    id: 'r4',
    title: 'Priority Support',
    subtitle: '24/7 dedicated support for 30 days',
    pointsCost: 400,
    icon: Icons.support_agent_rounded,
    color: AppTheme.accentPurple,
    tag: '',
  ),
  RedeemableReward(
    id: 'r5',
    title: 'Premium Trial (7 days)',
    subtitle: 'Access Elite tier benefits free',
    pointsCost: 800,
    icon: Icons.diamond_rounded,
    color: AppTheme.accentCoral,
    tag: 'Premium',
  ),
];

// ── Reward Activity History ──
const List<RewardActivity> rewardActivities = [
  RewardActivity(
    title: 'Daily Login Bonus',
    subtitle: 'Streak reward \u2022 Today',
    time: '2 min ago',
    points: 10,
    type: RewardActivityType.earned,
  ),
  RewardActivity(
    title: 'Review Written',
    subtitle: 'Rajesh Kumar review',
    time: '1 hr ago',
    points: 30,
    type: RewardActivityType.earned,
  ),
  RewardActivity(
    title: 'Redeemed 10% Coupon',
    subtitle: 'Applied to AC Repair',
    time: 'Yesterday',
    points: -200,
    type: RewardActivityType.redeemed,
  ),
  RewardActivity(
    title: 'Repeat Booking Bonus',
    subtitle: 'Priya Sharma - Salon',
    time: '2 days ago',
    points: 75,
    type: RewardActivityType.bonus,
  ),
  RewardActivity(
    title: 'Tier Upgrade',
    subtitle: 'Welcome to Gold!',
    time: '5 days ago',
    points: 0,
    type: RewardActivityType.levelUp,
  ),
  RewardActivity(
    title: 'Referral Bonus',
    subtitle: 'Amit joined via your link',
    time: '1 week ago',
    points: 200,
    type: RewardActivityType.earned,
  ),
  RewardActivity(
    title: 'First Booking Reward',
    subtitle: 'Electrician service',
    time: '2 weeks ago',
    points: 150,
    type: RewardActivityType.earned,
  ),
];

// ── User Badges ──
const List<RewardBadge> userBadges = [
  RewardBadge(
    id: 'b1',
    title: 'First Booking',
    subtitle: 'Complete your first service',
    icon: Icons.rocket_launch_rounded,
    color: AppTheme.accentGold,
    earned: true,
    earnedDate: '2 weeks ago',
    progress: 1.0,
  ),
  RewardBadge(
    id: 'b2',
    title: '5 Services Done',
    subtitle: 'Book 5 services total',
    icon: Icons.star_rounded,
    color: AppTheme.accentTeal,
    earned: true,
    earnedDate: '1 week ago',
    progress: 1.0,
  ),
  RewardBadge(
    id: 'b3',
    title: 'Top Reviewer',
    subtitle: 'Leave 5 reviews',
    icon: Icons.rate_review_rounded,
    color: AppTheme.accentBlue,
    earned: true,
    earnedDate: '3 days ago',
    progress: 1.0,
  ),
  RewardBadge(
    id: 'b4',
    title: 'Loyal Customer',
    subtitle: '10 bookings completed',
    icon: Icons.favorite_rounded,
    color: AppTheme.accentCoral,
    earned: false,
    progress: 0.8,
    progressLabel: '8/10',
  ),
  RewardBadge(
    id: 'b5',
    title: 'On Fire',
    subtitle: '3 bookings in a week',
    icon: Icons.local_fire_department_rounded,
    color: AppTheme.accentPurple,
    earned: false,
    progress: 0.33,
    progressLabel: '1/3',
  ),
  RewardBadge(
    id: 'b6',
    title: 'Elite Member',
    subtitle: '25 completed services',
    icon: Icons.emoji_events_rounded,
    color: AppTheme.accentGold,
    earned: false,
    progress: 0.32,
    progressLabel: '8/25',
  ),
  RewardBadge(
    id: 'b7',
    title: 'Referral Champ',
    subtitle: 'Refer 5 friends',
    icon: Icons.people_rounded,
    color: AppTheme.accentBlue,
    earned: false,
    progress: 0.6,
    progressLabel: '3/5',
  ),
  RewardBadge(
    id: 'b8',
    title: 'Local Explorer',
    subtitle: 'Try 5 different services',
    icon: Icons.explore_rounded,
    color: AppTheme.accentTeal,
    earned: false,
    progress: 0.6,
    progressLabel: '3/5',
  ),
  RewardBadge(
    id: 'b9',
    title: '7-Day Streak',
    subtitle: 'Login 7 days in a row',
    icon: Icons.whatshot_rounded,
    color: AppTheme.accentCoral,
    earned: false,
    progress: 0.43,
    progressLabel: '3/7',
  ),
];

// ── Streaks ──
const StreakData userStreak = StreakData(
  currentStreak: 3,
  longestStreak: 7,
  weekDays: [true, true, true, false, false, false, false],
  totalCheckIns: 28,
);

// ── Wallet ──
const double walletBalance = 520.0;
const double walletCashback = 280.0;
const double walletPromo = 140.0;
const double walletRewards = 100.0;

const List<WalletTransaction> walletTransactions = [
  WalletTransaction(
    title: 'AC Repair Cashback',
    amount: 50,
    date: 'Today',
    type: WalletTxType.cashback,
    subtitle: '5% cashback on \u20b9999',
  ),
  WalletTransaction(
    title: 'Review Reward',
    amount: 30,
    date: 'Today',
    type: WalletTxType.reward,
    subtitle: 'Rajesh Kumar review',
  ),
  WalletTransaction(
    title: 'Salon Booking',
    amount: -399,
    date: 'Yesterday',
    type: WalletTxType.debit,
    subtitle: 'Priya Sharma - Hair Cut',
  ),
  WalletTransaction(
    title: 'Referral Bonus',
    amount: 100,
    date: 'Apr 12',
    type: WalletTxType.referral,
    subtitle: 'Amit joined via link',
  ),
  WalletTransaction(
    title: 'Promo Credit',
    amount: 75,
    date: 'Apr 10',
    type: WalletTxType.promo,
    subtitle: 'Welcome back offer',
  ),
  WalletTransaction(
    title: 'Plumbing Service',
    amount: -650,
    date: 'Apr 8',
    type: WalletTxType.debit,
    subtitle: 'Suresh - Pipe repair',
  ),
  WalletTransaction(
    title: 'First Booking Cashback',
    amount: 200,
    date: 'Apr 5',
    type: WalletTxType.cashback,
    subtitle: 'New user reward',
  ),
  WalletTransaction(
    title: 'Points Redeemed',
    amount: 50,
    date: 'Apr 3',
    type: WalletTxType.reward,
    subtitle: '300 pts \u2192 \u20b950',
  ),
  WalletTransaction(
    title: 'Electrician Service',
    amount: -450,
    date: 'Apr 1',
    type: WalletTxType.debit,
    subtitle: 'Vikram - Wiring repair',
  ),
  WalletTransaction(
    title: 'Weekend Promo',
    amount: 40,
    date: 'Mar 28',
    type: WalletTxType.promo,
    subtitle: 'Weekend special credit',
  ),
];

// ── Offers & Deals ──
final List<OfferDeal> offerDeals = [
  OfferDeal(
    id: 'o1',
    title: '20% OFF First Request',
    subtitle: 'Max discount \u20b9250 \u2022 All services',
    code: 'FIRST20',
    validTill: '30 Jun 2026',
    icon: Icons.celebration_rounded,
    color: AppTheme.accentGold,
    bgColor: const Color(0xFF2A2010),
    tag: 'New User',
    discountPercent: 20,
  ),
  OfferDeal(
    id: 'o2',
    title: '\u20b9100 Cashback',
    subtitle: 'On orders above \u20b9499 in your area',
    code: 'LOCAL100',
    validTill: '15 Jul 2026',
    icon: Icons.savings_rounded,
    color: AppTheme.accentTeal,
    bgColor: const Color(0xFF0A2A20),
    tag: 'Area Special',
  ),
  OfferDeal(
    id: 'o3',
    title: 'Gold Member Exclusive',
    subtitle: '15% OFF + Priority booking',
    code: 'GOLD15',
    validTill: '31 Jul 2026',
    icon: Icons.workspace_premium_rounded,
    color: AppTheme.accentGold,
    bgColor: const Color(0xFF2A2510),
    tag: 'Members Only',
    discountPercent: 15,
  ),
  OfferDeal(
    id: 'o4',
    title: 'Weekend Cleaning Deal',
    subtitle: 'Deep clean at flat \u20b9599',
    code: 'WEEKEND599',
    validTill: '31 Aug 2026',
    icon: Icons.cleaning_services_rounded,
    color: AppTheme.accentBlue,
    bgColor: const Color(0xFF102030),
    tag: 'Weekend',
  ),
  OfferDeal(
    id: 'o5',
    title: 'Monsoon Special',
    subtitle: 'Waterproofing + Pest control combo',
    code: 'MONSOON30',
    validTill: '30 Sep 2026',
    icon: Icons.water_drop_rounded,
    color: AppTheme.accentPurple,
    bgColor: const Color(0xFF1A1030),
    tag: 'Seasonal',
    discountPercent: 30,
  ),
  OfferDeal(
    id: 'o6',
    title: 'Refer & Earn \u20b9200',
    subtitle: 'Both you and your friend get \u20b9100',
    code: 'REFER200',
    validTill: '31 Dec 2026',
    icon: Icons.people_rounded,
    color: AppTheme.accentCoral,
    bgColor: const Color(0xFF2A1515),
    tag: 'Referral',
  ),
];

// ── Referral Stats ──
const int referralFriendsJoined = 3;
const int referralBonusEarned = 600;
const String referralCode = 'JOHN2026';

// ── Provider Achievements ──
const List<ProviderAchievement> providerAchievements = [
  ProviderAchievement(
    title: 'Fast Responder',
    subtitle: 'Reply within 5 min to 10 leads',
    icon: Icons.flash_on_rounded,
    color: AppTheme.accentGold,
    earned: true,
    progress: 1.0,
    progressLabel: '10/10',
  ),
  ProviderAchievement(
    title: 'Top Rated This Month',
    subtitle: 'Avg rating above 4.5',
    icon: Icons.star_rounded,
    color: AppTheme.accentGold,
    earned: true,
    progress: 1.0,
    progressLabel: '4.7\u2605',
  ),
  ProviderAchievement(
    title: 'Trusted Pro',
    subtitle: 'Complete profile + BG check',
    icon: Icons.verified_rounded,
    color: AppTheme.accentBlue,
    earned: true,
    progress: 1.0,
    progressLabel: 'Done',
  ),
  ProviderAchievement(
    title: 'Local Star',
    subtitle: '50 jobs in your area',
    icon: Icons.location_on_rounded,
    color: AppTheme.accentTeal,
    earned: false,
    progress: 0.68,
    progressLabel: '34/50',
  ),
  ProviderAchievement(
    title: '100 Leads Handled',
    subtitle: 'Accept or respond to 100 leads',
    icon: Icons.inbox_rounded,
    color: AppTheme.accentPurple,
    earned: false,
    progress: 0.45,
    progressLabel: '45/100',
  ),
  ProviderAchievement(
    title: 'Revenue Master',
    subtitle: 'Earn \u20b91,00,000 total',
    icon: Icons.currency_rupee_rounded,
    color: AppTheme.accentCoral,
    earned: false,
    progress: 0.43,
    progressLabel: '\u20b942.8K',
  ),
  ProviderAchievement(
    title: '5-Star Streak',
    subtitle: '10 consecutive 5-star reviews',
    icon: Icons.auto_awesome_rounded,
    color: AppTheme.accentGold,
    earned: false,
    progress: 0.7,
    progressLabel: '7/10',
  ),
  ProviderAchievement(
    title: 'Week Warrior',
    subtitle: 'Complete 5 jobs in one week',
    icon: Icons.military_tech_rounded,
    color: AppTheme.accentBlue,
    earned: false,
    progress: 0.6,
    progressLabel: '3/5',
  ),
];

// ── Reward Notifications ──
const List<RewardNotification> rewardNotifications = [
  RewardNotification(
    id: 'rn1',
    title: 'You earned 30 points!',
    body: 'Review written for Rajesh Kumar',
    time: '2 min ago',
    type: RewardNotifType.pointsEarned,
  ),
  RewardNotification(
    id: 'rn2',
    title: 'Daily streak: 3 days!',
    body: 'Keep going to earn the 7-day badge',
    time: '1 hr ago',
    type: RewardNotifType.streak,
  ),
  RewardNotification(
    id: 'rn3',
    title: 'New reward unlocked!',
    body: 'Top Reviewer badge is now yours',
    time: '3 hrs ago',
    type: RewardNotifType.badgeUnlocked,
  ),
  RewardNotification(
    id: 'rn4',
    title: '\u20b950 cashback added',
    body: 'AC Repair cashback credited to wallet',
    time: 'Yesterday',
    type: RewardNotifType.cashback,
  ),
  RewardNotification(
    id: 'rn5',
    title: 'Upgrade to Elite!',
    body: 'Earn 750 more points for Elite tier',
    time: 'Yesterday',
    type: RewardNotifType.tierUpgrade,
    isRead: true,
  ),
  RewardNotification(
    id: 'rn6',
    title: 'Gold Member Offer!',
    body: '15% OFF exclusive for Gold members',
    time: '2 days ago',
    type: RewardNotifType.offer,
    isRead: true,
  ),
  RewardNotification(
    id: 'rn7',
    title: 'Referral bonus: \u20b9100',
    body: 'Amit joined via your link. Points added!',
    time: '3 days ago',
    type: RewardNotifType.pointsEarned,
    isRead: true,
  ),
  RewardNotification(
    id: 'rn8',
    title: 'Elite offer available!',
    body: 'Preview: Free inspection for Elite members',
    time: '1 week ago',
    type: RewardNotifType.offer,
    isRead: true,
  ),
];

// ── Retention Suggestions ──
const List<RetentionSuggestion> retentionSuggestions = [
  RetentionSuggestion(
    title: 'Need AC service again?',
    subtitle: 'Rebook Rajesh Kumar \u2022 Last: 2 weeks ago',
    icon: Icons.ac_unit_rounded,
    color: AppTheme.accentBlue,
    cta: 'Rebook',
  ),
  RetentionSuggestion(
    title: 'Your plumber is available',
    subtitle: 'Suresh Kumar is online now \u2022 4.8\u2605',
    icon: Icons.plumbing_rounded,
    color: AppTheme.accentTeal,
    cta: 'Book Now',
  ),
  RetentionSuggestion(
    title: '\u20b9100 cashback today!',
    subtitle: 'Use code LOCAL100 on any booking',
    icon: Icons.savings_rounded,
    color: AppTheme.accentGold,
    cta: 'Claim',
  ),
  RetentionSuggestion(
    title: 'Salon deals this week',
    subtitle: 'Priya Sharma \u2022 20% OFF haircut',
    icon: Icons.content_cut_rounded,
    color: AppTheme.accentPurple,
    cta: 'View',
  ),
];
