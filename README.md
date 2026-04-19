# LocalConnect

**Your Local Services Marketplace** — A premium Flutter mobile application connecting users with trusted local service providers (plumbers, electricians, tutors, salons, and more) through a hyper-local, pincode-based discovery system.

---

## Architecture

LocalConnect follows a **feature-first modular architecture** for scalability and maintainability:

```
lib/
├── main.dart                          # App entry point
├── core/                              # App-wide infrastructure
│   ├── constants/app_constants.dart   # Global constants
│   ├── routes/app_router.dart         # Centralized named routing
│   ├── theme/app_theme.dart           # Design system tokens
│   └── utils/                         # Account mode, category icons, search engine
├── shared/                            # Reusable across all features
│   ├── data/dummy_data.dart           # Master provider dataset
│   ├── models/provider_model.dart     # ServiceProvider model
│   └── widgets/                       # 11 shared UI components
└── features/                          # Feature modules
    ├── auth/screens/                  # 8 screens — Splash → Onboarding → Login → Register → OTP → Location
    ├── home/screens/ + widgets/       # 4 screens + 2 widgets — Main shell, home, emergency, micro-zone
    ├── search/screens/                # 3 screens — Search, results, filters
    ├── provider/screens/              # 3 screens — Provider list, detail, reviews
    ├── provider_mode/                 # 12 screens + widget + model + data — Full provider business dashboard
    ├── booking/screens/               # 6 screens — Slot selection → Checkout → Payment → Invoice
    ├── chat/screens/                  # 4 screens — Messages, chat detail, audio/video calls
    ├── profile/screens/               # 6 screens — Profile, edit, favorites, reviews, addresses, add provider
    ├── jobs/                          # 5 screens + widget + model + data — Job posts & service requests
    ├── rewards/                       # 7 screens + model + data — Wallet, referrals, tiers, badges, offers
    ├── notifications/screens/         # 1 screen — Central notification feed
    └── settings/screens/              # 5 screens — Settings, help, privacy, terms, about
```

**Total: 94 Dart files** across 12 feature modules + core + shared layers.

---

## Design System

The app uses a **premium dark-navy glassmorphic** design language defined in `core/theme/app_theme.dart`:

| Token | Value | Usage |
|-------|-------|-------|
| `primaryDeep` | `#0A0E27` | Scaffold background |
| `accentGold` | `#FFB800` | Primary CTA, highlights |
| `accentTeal` | `#06D6A0` | Success, online status |
| `accentCoral` | `#FF6B6B` | Errors, urgent badges |
| Typography | Sora (headings) + Inter (body) | Google Fonts |
| Motion | 150–600ms with easeOutCubic | Smooth animations |

Glass containers, gold gradients, soft shadows, and subtle shimmer effects create an Apple-inspired premium feel.

---

## Navigation

- **Named routes** via `AppRoutes` in `core/routes/app_router.dart` (29 routes)
- **Page transitions**: Fade+scale for top-level, slide+fade for inner pages
- **Bottom navigation shell**: `MainShell` hosts Home, Search, Bookings, and Profile tabs
- **Direct push navigation**: Used for detail screens and context-specific flows

---

## Key Features

### User Mode
- **Hyper-local discovery**: Pincode-based provider search with smart matching
- **Smart search**: Problem-to-service mapping ("leaking tap" → Plumber)
- **Booking flow**: Select slot → Checkout → Payment → Invoice
- **Real-time chat**: 1:1 messaging with audio/video call support
- **Rewards system**: Points, wallet, referrals, membership tiers, streaks & badges
- **Job posting**: Post service requests, track applications

### Provider Mode
- **Business dashboard**: Leads, earnings, insights, and analytics
- **Lead management**: Accept/decline incoming service requests
- **Availability control**: Set schedule and service area pincodes
- **Achievement system**: Badges and milestones for business growth

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `google_fonts` | Sora + Inter typography |
| `flutter_animate` | Declarative animations |
| `shimmer` | Loading skeleton effects |
| `url_launcher` | External links (phone, web) |
| `cached_network_image` | Network image caching |
| `geolocator` | GPS location services |
| `permission_handler` | Runtime permissions |
| `timeago` | Relative time formatting |
| `intl` | Number/date formatting |

---

## Getting Started

```bash
# Clone and install
git clone <repo-url>
cd local_connect
flutter pub get

# Run
flutter run

# Analyze
flutter analyze

# Test
flutter test
```

**Demo login**: `demo@localconnect.app` / `123456`

---

## Project Conventions

- **Package imports**: All imports use `package:local_connect/...` (absolute)
- **File naming**: `snake_case.dart` with `_screen`, `_widget`, `_model`, `_data` suffixes
- **Feature isolation**: Each feature module is self-contained with screens/, widgets/, models/, data/ subfolders as needed
- **State management**: `ChangeNotifier` with global singleton for account mode
- **Theme centralization**: All colors, spacing, typography, and motion tokens in `AppTheme`

---

*Built with Flutter 3.11+ • Dart 3.11+ • Material Design 3*
