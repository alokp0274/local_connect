// features/jobs/models/job_post_model.dart
// Feature: Job Posts & Service Requests
//
// JobPost data model with title, description, budget, and status fields.

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
//  JOB POST + APPLY SYSTEM — Data Models
// ─────────────────────────────────────────────────────────

/// Urgency level for a job request.
enum JobUrgency { urgent, today, thisWeek, flexible }

extension JobUrgencyX on JobUrgency {
  String get label {
    switch (this) {
      case JobUrgency.urgent:
        return 'Urgent';
      case JobUrgency.today:
        return 'Today';
      case JobUrgency.thisWeek:
        return 'This Week';
      case JobUrgency.flexible:
        return 'Flexible';
    }
  }

  Color get color {
    switch (this) {
      case JobUrgency.urgent:
        return const Color(0xFFFF6B6B);
      case JobUrgency.today:
        return const Color(0xFFFFB800);
      case JobUrgency.thisWeek:
        return const Color(0xFF5B8DEF);
      case JobUrgency.flexible:
        return const Color(0xFF06D6A0);
    }
  }

  IconData get icon {
    switch (this) {
      case JobUrgency.urgent:
        return Icons.priority_high_rounded;
      case JobUrgency.today:
        return Icons.today_rounded;
      case JobUrgency.thisWeek:
        return Icons.date_range_rounded;
      case JobUrgency.flexible:
        return Icons.schedule_rounded;
    }
  }
}

/// Status of a posted job request.
enum JobStatus { active, inProgress, completed, closed }

extension JobStatusX on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.active:
        return 'Active';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case JobStatus.active:
        return const Color(0xFF06D6A0);
      case JobStatus.inProgress:
        return const Color(0xFF5B8DEF);
      case JobStatus.completed:
        return const Color(0xFFFFB800);
      case JobStatus.closed:
        return const Color(0xFF6B7280);
    }
  }
}

/// Status of a provider's application.
enum ApplicationStatus { pending, accepted, rejected, withdrawn }

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Declined';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return const Color(0xFFFFB800);
      case ApplicationStatus.accepted:
        return const Color(0xFF06D6A0);
      case ApplicationStatus.rejected:
        return const Color(0xFFFF6B6B);
      case ApplicationStatus.withdrawn:
        return const Color(0xFF6B7280);
    }
  }
}

/// A user-posted service request / job.
class JobPost {
  final String id;
  final String title;
  final String category;
  final String description;
  final JobUrgency urgency;
  final String preferredDate;
  final String preferredTime;
  final String? budget;
  final String pincode;
  final String area;
  final String contactPreference; // 'Chat', 'Call', 'Both'
  final String? imageUrl;
  final String postedBy;
  final String postedByInitial;
  final String timePosted;
  final JobStatus status;
  final int applicationCount;
  final double? latitude;
  final double? longitude;

  const JobPost({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.urgency,
    required this.preferredDate,
    required this.preferredTime,
    this.budget,
    required this.pincode,
    required this.area,
    this.contactPreference = 'Both',
    this.imageUrl,
    required this.postedBy,
    required this.postedByInitial,
    required this.timePosted,
    this.status = JobStatus.active,
    this.applicationCount = 0,
    this.latitude,
    this.longitude,
  });

  JobPost copyWith({JobStatus? status, int? applicationCount}) {
    return JobPost(
      id: id,
      title: title,
      category: category,
      description: description,
      urgency: urgency,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      budget: budget,
      pincode: pincode,
      area: area,
      contactPreference: contactPreference,
      imageUrl: imageUrl,
      postedBy: postedBy,
      postedByInitial: postedByInitial,
      timePosted: timePosted,
      status: status ?? this.status,
      applicationCount: applicationCount ?? this.applicationCount,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// A provider's application to a job post.
class JobApplication {
  final String id;
  final String jobId;
  final String providerName;
  final String providerService;
  final String providerInitial;
  final double providerRating;
  final int providerReviewCount;
  final String providerDistance;
  final String providerExperience;
  final bool providerVerified;
  final String priceOffer;
  final String message;
  final String eta;
  final bool canStartNow;
  final String appliedTime;
  final ApplicationStatus status;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.providerName,
    required this.providerService,
    required this.providerInitial,
    required this.providerRating,
    this.providerReviewCount = 0,
    required this.providerDistance,
    required this.providerExperience,
    this.providerVerified = false,
    required this.priceOffer,
    required this.message,
    required this.eta,
    this.canStartNow = false,
    required this.appliedTime,
    this.status = ApplicationStatus.pending,
  });
}

/// Contact preference options for the post form.
class ContactOption {
  final String label;
  final IconData icon;
  const ContactOption(this.label, this.icon);
}

const contactOptions = [
  ContactOption('Chat', Icons.chat_bubble_outline_rounded),
  ContactOption('Call', Icons.phone_rounded),
  ContactOption('Both', Icons.swap_horiz_rounded),
];
