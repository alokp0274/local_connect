// shared/models/request_model.dart
// Layer: Shared
//
// Data models for the dual-role Requests system.
// ServiceRequest represents a posted job/request.
// RequestApplicant represents a provider who applied to a request.

enum RequestStatus { open, inProgress, completed, cancelled }

enum RequestUrgency { normal, urgent, emergency }

class RequestApplicant {
  final String id;
  final String name;
  final String service;
  final double rating;
  final int reviewCount;
  final String experience;
  final String pricing;
  final String imageUrl;
  final String phone;
  final bool isVerified;
  final String message;
  final DateTime appliedAt;
  final int responseTimeMinutes;
  final int jobsCompleted;

  const RequestApplicant({
    required this.id,
    required this.name,
    required this.service,
    required this.rating,
    this.reviewCount = 0,
    this.experience = '',
    this.pricing = '',
    this.imageUrl = '',
    this.phone = '',
    this.isVerified = false,
    this.message = '',
    required this.appliedAt,
    this.responseTimeMinutes = 15,
    this.jobsCompleted = 0,
  });
}

class ServiceRequest {
  final String id;
  final String title;
  final String description;
  final String category;
  final String pincode;
  final String address;
  final RequestStatus status;
  final RequestUrgency urgency;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String budgetRange;
  final List<RequestApplicant> applicants;
  final String? assignedProviderId;
  final String postedByName;
  final String postedById;
  final bool isMyRequest; // true = I posted this, false = I can apply

  const ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pincode,
    this.address = '',
    this.status = RequestStatus.open,
    this.urgency = RequestUrgency.normal,
    required this.createdAt,
    this.scheduledDate,
    this.budgetRange = '',
    this.applicants = const [],
    this.assignedProviderId,
    this.postedByName = '',
    this.postedById = '',
    this.isMyRequest = true,
  });

  int get applicantCount => applicants.length;

  bool get isOpen => status == RequestStatus.open;
  bool get isAssigned => assignedProviderId != null;

  String get statusLabel {
    switch (status) {
      case RequestStatus.open:
        return 'Open';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case RequestUrgency.normal:
        return 'Normal';
      case RequestUrgency.urgent:
        return 'Urgent';
      case RequestUrgency.emergency:
        return 'Emergency';
    }
  }
}
