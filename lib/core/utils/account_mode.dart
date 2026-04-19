// core/utils/account_mode.dart
// Layer: Core (app-wide infrastructure)
//
// Dual-mode account state (User ↔ Provider) with ChangeNotifier.
// Global singleton drives UI mode switching throughout the app.

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────
//  DUAL ACCOUNT MODE — User / Provider
// ─────────────────────────────────────────────────────────

enum AccountMode { user, provider }

/// Simple local state holder for dual-mode account switching.
/// In production, this would be backed by SharedPreferences or a backend.
class AccountModeNotifier extends ChangeNotifier {
  AccountMode _mode = AccountMode.user;
  bool _providerProfileCreated = false;

  // ── Mock provider profile data ──
  String _providerName = '';
  String _providerService = '';
  String _providerPhone = '';
  String _providerDescription = '';
  List<String> _providerPincodes = [];
  bool _providerAvailable = true;

  // ── Getters ──
  AccountMode get mode => _mode;
  bool get isUserMode => _mode == AccountMode.user;
  bool get isProviderMode => _mode == AccountMode.provider;
  bool get providerProfileCreated => _providerProfileCreated;
  String get providerName => _providerName;
  String get providerService => _providerService;
  String get providerPhone => _providerPhone;
  String get providerDescription => _providerDescription;
  List<String> get providerPincodes => List.unmodifiable(_providerPincodes);
  bool get providerAvailable => _providerAvailable;

  // ── Mock stats ──
  int get leadsReceived => 23;
  int get activeChats => 8;
  double get providerRating => 4.7;
  int get jobsCompleted => 156;
  String get earnings => '\u20b942,800';

  void switchMode(AccountMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }

  void toggleMode() {
    _mode = _mode == AccountMode.user ? AccountMode.provider : AccountMode.user;
    notifyListeners();
  }

  void toggleAvailability() {
    _providerAvailable = !_providerAvailable;
    notifyListeners();
  }

  void completeProviderProfile({
    required String name,
    required String service,
    required String phone,
    required String description,
    required List<String> pincodes,
  }) {
    _providerName = name;
    _providerService = service;
    _providerPhone = phone;
    _providerDescription = description;
    _providerPincodes = pincodes;
    _providerProfileCreated = true;
    _mode = AccountMode.provider;
    notifyListeners();
  }
}

/// Singleton instance accessible across the app.
final accountMode = AccountModeNotifier();
