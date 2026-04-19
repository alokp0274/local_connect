// features/provider_mode/models/lead_model.dart
// Feature: Provider Mode (Business Dashboard)
//
// Lead data model representing an incoming service request for a provider.

// Data models for Provider Growth System — Leads, Earnings, Insights, Notifications.

class ServiceLead {
  final String id;
  final String serviceNeeded;
  final String customerName;
  final String pincode;
  final String area;
  final String distance;
  final String timePosted;
  final String? budget;
  final String? notes;
  final String? preferredTime;
  final double customerRating;
  final int customerJobs;
  final LeadUrgency urgency;
  final LeadStatus status;

  const ServiceLead({
    required this.id,
    required this.serviceNeeded,
    required this.customerName,
    required this.pincode,
    required this.area,
    required this.distance,
    required this.timePosted,
    this.budget,
    this.notes,
    this.preferredTime,
    this.customerRating = 4.0,
    this.customerJobs = 0,
    this.urgency = LeadUrgency.normal,
    this.status = LeadStatus.pending,
  });
}

enum LeadUrgency { urgent, normal, flexible }

enum LeadStatus { pending, accepted, ignored, completed }

class ProviderEarning {
  final String id;
  final String service;
  final String customerName;
  final double amount;
  final String date;
  final EarningStatus status;

  const ProviderEarning({
    required this.id,
    required this.service,
    required this.customerName,
    required this.amount,
    required this.date,
    this.status = EarningStatus.completed,
  });
}

enum EarningStatus { completed, pending, processing }

class GrowthInsight {
  final String title;
  final String subtitle;
  final String icon;
  final InsightType type;

  const GrowthInsight({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.type = InsightType.growth,
  });
}

enum InsightType { growth, tip, achievement, demand }

class ProviderNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final ProviderNotifType type;
  final bool isRead;

  const ProviderNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

enum ProviderNotifType { lead, message, review, demand, ranking, system }
