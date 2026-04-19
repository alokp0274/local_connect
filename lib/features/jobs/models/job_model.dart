// features/jobs/models/job_model.dart
// Feature: Jobs Feed & Bidding Marketplace
//
// JobPost and JobBid data models for the social-feed marketplace.

// ─────────────────────────────────────────────────────────
//  JOB POST MODEL
// ─────────────────────────────────────────────────────────

class JobPost {
  final String id;
  final String customerId;
  final String customerName;
  final double customerRating;
  final bool customerVerified;
  final String title;
  final String description;
  final String category;
  final String urgency; // 'emergency' | 'today' | 'thisWeek' | 'flexible'
  final String location;
  final String pincode;
  final double distanceKm;
  final String budgetMin;
  final String budgetMax;
  final String preferredDate;
  final String preferredTime;
  final String postedAgo;
  final String status; // 'open' | 'inProgress' | 'completed' | 'cancelled'
  final List<JobBid> bids;
  final String? imageUrl;

  const JobPost({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerRating,
    required this.customerVerified,
    required this.title,
    required this.description,
    required this.category,
    required this.urgency,
    required this.location,
    required this.pincode,
    required this.distanceKm,
    required this.budgetMin,
    required this.budgetMax,
    required this.preferredDate,
    required this.preferredTime,
    required this.postedAgo,
    required this.status,
    required this.bids,
    this.imageUrl,
  });

  int get bidCount => bids.length;

  String get closesIn {
    // Demo logic; in production derive from a deadline timestamp
    switch (urgency) {
      case 'emergency':
        return 'Closes in 2 hrs';
      case 'today':
        return 'Closes in 8 hrs';
      case 'thisWeek':
        return 'Closes in 5 days';
      default:
        return 'Closes in 18 hrs';
    }
  }
}

// ─────────────────────────────────────────────────────────
//  JOB BID MODEL
// ─────────────────────────────────────────────────────────

class JobBid {
  final String providerId;
  final String providerName;
  final double providerRating;
  final int providerReviews;
  final int providerExperience;
  final int providerJobsDone;
  final bool providerVerified;
  final String message;
  final int bidAmount;
  final String postedAgo;
  String status; // 'pending' | 'accepted' | 'rejected' | 'negotiating'
  int? counterAmount;
  String? counterNote;
  int negotiationRound;

  JobBid({
    required this.providerId,
    required this.providerName,
    required this.providerRating,
    required this.providerReviews,
    required this.providerExperience,
    required this.providerJobsDone,
    required this.providerVerified,
    required this.message,
    required this.bidAmount,
    required this.postedAgo,
    this.status = 'pending',
    this.counterAmount,
    this.counterNote,
    this.negotiationRound = 0,
  });
}
