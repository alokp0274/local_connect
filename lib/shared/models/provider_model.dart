// Model class representing a service provider.
class ServiceProvider {
  final String id;
  final String name;
  final String service;
  final String phone;
  final String pincode;
  final List<String> servicePincodes;
  final double rating;
  final String distance;
  final String description;
  final String experience;
  final String imageUrl;
  final String providerType; // "individual" or "company"
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final List<ProviderReview> reviews;
  final String city;
  final bool isVerified;
  final int reviewCount;
  final String pricing;
  final String availability;

  // ── Trust & Credibility Fields ──
  final int completionRate;
  final int repeatClientPercent;
  final List<String> languages;
  final List<String> certifications;
  final int responseTimeMinutes;
  final int hiredNearbyCount;
  final int jobsCompleted;
  final String aboutHighlight;
  final String estimatedArrival;
  final bool backgroundChecked;
  final List<String> serviceAreas;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.phone,
    required this.pincode,
    this.servicePincodes = const [],
    required this.rating,
    required this.distance,
    required this.description,
    required this.experience,
    required this.imageUrl,
    this.providerType = 'individual',
    this.isOnline = false,
    this.latitude,
    this.longitude,
    this.reviews = const [],
    this.city = '',
    this.isVerified = false,
    this.reviewCount = 0,
    this.pricing = '',
    this.availability = 'Available',
    this.completionRate = 95,
    this.repeatClientPercent = 75,
    this.languages = const ['Hindi', 'English'],
    this.certifications = const [],
    this.responseTimeMinutes = 15,
    this.hiredNearbyCount = 0,
    this.jobsCompleted = 0,
    this.aboutHighlight = '',
    this.estimatedArrival = '',
    this.backgroundChecked = false,
    this.serviceAreas = const [],
  });

  /// Returns true if provider serves the given pincode.
  bool servesPincode(String targetPincode) {
    if (pincode == targetPincode) {
      return true;
    }
    return servicePincodes.contains(targetPincode);
  }

  /// Combined list of primary + additional service pincodes.
  List<String> get allServicePincodes {
    final merged = <String>[pincode, ...servicePincodes];
    return merged.toSet().toList();
  }
}

class ProviderReview {
  final String reviewerName;
  final String reviewerInitials;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ProviderReview({
    required this.reviewerName,
    required this.reviewerInitials,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
  });
}

class ChatThread {
  final ServiceProvider provider;
  final List<ChatMessage> messages;
  final bool hasUnread;

  const ChatThread({
    required this.provider,
    required this.messages,
    this.hasUnread = false,
  });

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
