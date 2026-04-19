// core/utils/search_engine.dart
// Layer: Core (app-wide infrastructure)
//
// Smart search engine with suggestion system, problem-to-service mapping,
// provider matching, and multi-factor relevance ranking.

import 'package:local_connect/shared/data/dummy_data.dart';
import 'package:local_connect/shared/models/provider_model.dart';

/// Search data, suggestion engine, and smart matching logic.
class SearchEngine {
  SearchEngine._();

  // ── STATIC SUGGESTION DATA ──

  static const List<String> recentSearches = [
    'plumber near me',
    'tutor in 110001',
    'AC repair urgent',
    'salon at home',
    'electrician for inverter',
  ];

  static const List<String> trendingSearches = [
    'electrician nearby',
    'home cleaning',
    'salon near me',
    'AC servicing',
    'plumber emergency',
    'maths tutor',
  ];

  static const List<String> popularCategories = [
    'Plumber',
    'Electrician',
    'Tutor',
    'AC Repair',
    'Salon',
    'Cleaning',
    'Carpenter',
    'Painter',
    'Bike Repair',
  ];

  static const List<String> quickProblems = [
    'leaking tap',
    'fan not working',
    'no water supply',
    'maths tutor class 10',
    'AC not cooling',
    'wiring issue',
    'broken lock',
    'hair coloring at home',
    'deep cleaning before Diwali',
  ];

  static const List<Map<String, String>> areaSuggestions = [
    {'name': 'Connaught Place', 'pincode': '110001'},
    {'name': 'Karol Bagh', 'pincode': '110005'},
    {'name': 'Lajpat Nagar', 'pincode': '110024'},
    {'name': 'South Extension', 'pincode': '110049'},
    {'name': 'Koramangala', 'pincode': '560034'},
    {'name': 'Indiranagar', 'pincode': '560038'},
  ];

  static const List<String> pincodeSuggestions = [
    '110001',
    '110005',
    '110024',
    '110049',
    '560001',
    '560034',
    '400001',
  ];

  /// Problem → service keyword mapping for smart matching.
  static const Map<String, String> _problemMap = {
    'leaking tap': 'plumber',
    'leaking pipe': 'plumber',
    'water leakage': 'plumber',
    'blocked drain': 'plumber',
    'no water supply': 'plumber',
    'toilet repair': 'plumber',
    'fan not working': 'electrician',
    'wiring issue': 'electrician',
    'short circuit': 'electrician',
    'power failure': 'electrician',
    'switch repair': 'electrician',
    'inverter setup': 'electrician',
    'ac not cooling': 'ac repair',
    'ac servicing': 'ac repair',
    'ac gas refill': 'ac repair',
    'ac installation': 'ac repair',
    'maths tutor': 'tutor',
    'science tutor': 'tutor',
    'english tutor': 'tutor',
    'tutor class 10': 'tutor',
    'board exam tutor': 'tutor',
    'jee coaching': 'tutor',
    'bike service': 'bike repair',
    'bike puncture': 'bike repair',
    'engine repair': 'bike repair',
    'brake repair': 'bike repair',
    'hair coloring': 'salon',
    'haircut at home': 'salon',
    'facial at home': 'salon',
    'salon at home': 'salon',
    'bridal makeup': 'salon',
    'deep cleaning': 'cleaning',
    'sofa cleaning': 'cleaning',
    'home cleaning': 'cleaning',
    'office cleaning': 'cleaning',
    'furniture repair': 'carpenter',
    'wardrobe design': 'carpenter',
    'modular kitchen': 'carpenter',
    'door repair': 'carpenter',
    'wall painting': 'painter',
    'texture painting': 'painter',
    'waterproofing': 'painter',
    'broken lock': 'carpenter',
  };

  // ── LIVE SUGGESTIONS ──

  /// Returns structured suggestions as user types.
  static List<SearchSuggestion> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();
    final results = <SearchSuggestion>[];

    // Service matches
    for (final cat in popularCategories) {
      if (cat.toLowerCase().contains(q)) {
        results.add(SearchSuggestion(
          text: cat,
          type: SuggestionType.service,
          icon: 'work',
        ));
      }
    }

    // Problem matches
    for (final entry in _problemMap.entries) {
      if (entry.key.contains(q) && results.length < 12) {
        results.add(SearchSuggestion(
          text: entry.key,
          type: SuggestionType.problem,
          subtitle: 'Try "${entry.value}"',
          icon: 'build',
        ));
      }
    }

    // Provider name matches
    for (final p in dummyProviders) {
      if (p.name.toLowerCase().contains(q) && results.length < 12) {
        results.add(SearchSuggestion(
          text: p.name,
          type: SuggestionType.provider,
          subtitle: '${p.service} · ${p.distance}',
          icon: 'person',
        ));
      }
    }

    // Area matches
    for (final area in areaSuggestions) {
      if (area['name']!.toLowerCase().contains(q) && results.length < 12) {
        results.add(SearchSuggestion(
          text: area['name']!,
          type: SuggestionType.area,
          subtitle: 'PIN ${area['pincode']}',
          icon: 'location',
        ));
      }
    }

    // Pincode matches
    for (final pin in pincodeSuggestions) {
      if (pin.contains(q) && results.length < 12) {
        results.add(SearchSuggestion(
          text: pin,
          type: SuggestionType.pincode,
          subtitle: 'Search in this pincode',
          icon: 'pin',
        ));
      }
    }

    return results.take(8).toList();
  }

  // ── SMART MATCHING ──

  /// Runs smart search against all providers with intelligent ranking.
  static List<ServiceProvider> search({
    required String query,
    String userPincode = '110001',
    Set<String> activeFilters = const {},
    String sortBy = 'best_match',
  }) {
    final q = query.toLowerCase().trim();

    // Resolve problem → service
    String resolvedQuery = q;
    for (final entry in _problemMap.entries) {
      if (q.contains(entry.key)) {
        resolvedQuery = entry.value;
        break;
      }
    }

    // Filter providers matching query
    var results = dummyProviders.where((p) {
      final fields = [
        p.name.toLowerCase(),
        p.service.toLowerCase(),
        p.description.toLowerCase(),
        p.city.toLowerCase(),
        p.pincode,
        ...p.serviceAreas.map((a) => a.toLowerCase()),
        ...p.certifications.map((c) => c.toLowerCase()),
      ];
      return fields.any((f) => f.contains(resolvedQuery) || f.contains(q));
    }).toList();

    // Apply quick filters
    if (activeFilters.contains('verified')) {
      results = results.where((p) => p.isVerified).toList();
    }
    if (activeFilters.contains('available_now')) {
      results = results.where((p) => p.isOnline).toList();
    }
    if (activeFilters.contains('under_500')) {
      results = results.where((p) {
        final price = int.tryParse(
          RegExp(r'\d+').firstMatch(p.pricing)?.group(0) ?? '9999',
        ) ?? 9999;
        return price < 500;
      }).toList();
    }
    if (activeFilters.contains('top_rated')) {
      results = results.where((p) => p.rating >= 4.5).toList();
    }
    if (activeFilters.contains('nearby')) {
      results = results.where((p) {
        final d = double.tryParse(p.distance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 99;
        return d <= 3.0;
      }).toList();
    }
    if (activeFilters.contains('fast_response')) {
      results = results.where((p) => p.responseTimeMinutes <= 15).toList();
    }
    if (activeFilters.contains('same_pin')) {
      results = results.where((p) => p.servesPincode(userPincode)).toList();
    }
    if (activeFilters.contains('individual')) {
      results = results.where((p) => p.providerType == 'individual').toList();
    }
    if (activeFilters.contains('company')) {
      results = results.where((p) => p.providerType == 'company').toList();
    }

    // Sort
    switch (sortBy) {
      case 'best_match':
        results.sort((a, b) => _matchScore(b, userPincode).compareTo(_matchScore(a, userPincode)));
        break;
      case 'nearest':
        results.sort((a, b) => _distKm(a).compareTo(_distKm(b)));
        break;
      case 'top_rated':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest_price':
        results.sort((a, b) => _priceNum(a).compareTo(_priceNum(b)));
        break;
      case 'fastest_response':
        results.sort((a, b) => a.responseTimeMinutes.compareTo(b.responseTimeMinutes));
        break;
      case 'most_experienced':
        results.sort((a, b) {
          final ea = int.tryParse(RegExp(r'\d+').firstMatch(a.experience)?.group(0) ?? '0') ?? 0;
          final eb = int.tryParse(RegExp(r'\d+').firstMatch(b.experience)?.group(0) ?? '0') ?? 0;
          return eb.compareTo(ea);
        });
        break;
    }

    return results;
  }

  /// Composite score for "best match" ranking.
  static double _matchScore(ServiceProvider p, String userPincode) {
    double score = 0;
    // Same pincode first
    if (p.pincode == userPincode) score += 50;
    if (p.servicePincodes.contains(userPincode)) score += 30;
    // Distance (closer = higher)
    score += (10 - _distKm(p)).clamp(0, 10);
    // Verified
    if (p.isVerified) score += 15;
    // Rating
    score += p.rating * 5;
    // Fast response
    if (p.responseTimeMinutes <= 10) score += 10;
    // Online
    if (p.isOnline) score += 8;
    // Background checked
    if (p.backgroundChecked) score += 5;
    // Reviews volume
    score += (p.reviewCount / 20).clamp(0, 10);
    return score;
  }

  static double _distKm(ServiceProvider p) {
    return double.tryParse(p.distance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 99;
  }

  static int _priceNum(ServiceProvider p) {
    return int.tryParse(
      RegExp(r'\d+').firstMatch(p.pricing)?.group(0) ?? '9999',
    ) ?? 9999;
  }

  /// Contextual hyperlocal header for results.
  static String getLocalHeader(String query, String pincode, int count) {
    final q = query.trim();
    if (q.isEmpty) return 'Explore nearby providers';
    if (count == 0) return 'No $q found near you';
    final service = q[0].toUpperCase() + q.substring(1);
    final headers = [
      'Best ${service}s in $pincode',
      'Trusted ${service}s near you',
      '$count ${service}s available in your area',
      'Fastest $service service nearby',
      'Popular ${service}s in your locality',
    ];
    return headers[q.length % headers.length];
  }
}

enum SuggestionType { service, problem, provider, area, pincode }

class SearchSuggestion {
  final String text;
  final SuggestionType type;
  final String? subtitle;
  final String icon;

  const SearchSuggestion({
    required this.text,
    required this.type,
    this.subtitle,
    this.icon = 'search',
  });
}
