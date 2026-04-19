# LocalConnect - Detailed Project Overview

## 1. What This Project Is

**LocalConnect** is a Flutter-based local services marketplace app concept.
It connects users with nearby service providers (plumbers, electricians, AC repair, cleaners, tutors, salon professionals, and more) and supports the full user journey:

- Discover providers by category and location
- Filter and sort providers by business criteria
- View full provider profile and reviews
- Chat/call/video call providers
- Manage bookings by status
- Save favorites and personal addresses
- Update profile and app preferences
- Register as a service partner/provider

The app currently behaves like a high-fidelity product prototype with realistic UX flows and in-memory data.

---

## 2. What The App Will Do (Functional Scope)

### Discovery & Search
- Lets users search providers by name/service
- Supports category-based browsing
- Shows providers available in the selected pincode first
- Allows advanced filtering (service type, price, rating, city, etc.)

### Provider Engagement
- Provider detail page with profile, stats, pricing/availability, and customer reviews
- Direct actions: phone call, WhatsApp, in-app chat
- Similar provider discovery from detail page

### Messaging & Calls
- Chat inbox with tabs (All, Booked, Unread, Archived)
- Search within conversations
- Pin/archive/delete chat actions with undo
- One-to-one chat detail with message timeline
- Audio and video call screens with live timer simulation

### Booking Management
- Booking tabs: Upcoming, Ongoing, Completed, Cancelled
- Detailed booking page with service/date/time/price/status

### Profile Ecosystem
- Profile dashboard with key stats and shortcuts
- Edit profile form
- Saved addresses management
- Favorites list management
- User review history
- Settings page (preferences, privacy, app info)

### Partner Onboarding
- "Add Partner" tab for registering providers
- Registration type selection (Individual/Company/Agency)
- Service, pincode coverage, and profile details capture

---

## 3. Current Tech & Architecture

## Stack
- **Framework:** Flutter
- **Language:** Dart
- **Navigation:** Material routes + Navigator.push/pop
- **State management:** Local `setState` (no external state package)
- **Data source:** In-memory dummy data (`dummy_data.dart`)
- **Theme system:** Centralized app theme (`app_theme.dart`) with custom colors/gradients

## Core Navigation Pattern
- App starts in `SplashScreen`
- Authentication and location flow precede main app shell
- Main experience uses **IndexedStack** inside `MainShell` to preserve tab state
- Inner pages open via route pushes, each with app bar/back behavior

---

## 4. Folder Structure (lib)

```text
lib/
  main.dart                         # App root and MaterialApp config
  data/
    dummy_data.dart                 # All sample providers/chats/reviews/categories
  models/
    provider_model.dart             # Domain models (provider, review, chat)
  screens/
    ...24 screen files...           # All user-facing pages and flows
  utils/
    app_theme.dart                  # Theme tokens, colors, gradients, spacing
    category_icons.dart             # Category icon + gradient mapping
  widgets/
    category_card.dart              # Reusable category tile
    custom_search_bar.dart          # Reusable search input widget
    provider_card.dart              # Reusable provider list card
```

---

## 5. Page Inventory (How Many Pages)

The project currently has:

- **24 screen files** in `lib/screens`
- **23 user-facing pages + 1 shell container**
  - Shell container: `MainShell` (hosts 5 tabs)

### 5.1 Primary Tab Pages (5)
1. HomeScreen (Discover)
2. MessagesScreen
3. AddProviderScreen (Add Partner)
4. BookingsScreen
5. ProfileScreen

### 5.2 Supporting Pages (19)
- SplashScreen
- LoginScreen
- RegisterScreen
- LocationScreen
- ProviderListScreen
- ProviderDetailScreen
- FilterScreen
- ChatDetailScreen
- AudioCallScreen
- VideoCallScreen
- BookingDetailScreen
- NotificationsScreen
- ReviewsScreen
- MyReviewsScreen
- FavoritesScreen
- EditProfileScreen
- SavedAddressesScreen
- SettingsScreen
- MainShell (navigation shell)

---

## 6. Detailed Explanation of Each Page

## 6.1 Entry & Authentication Flow

### SplashScreen
**Purpose:** Initial branded loading screen.
**What it does:** Displays startup visuals, then automatically transitions to login.
**Key behavior:** Timer-based auto-navigation.

### LoginScreen
**Purpose:** User sign-in.
**What it does:** Validates email/password and proceeds to location selection.
**Key behavior:** Form validation, password visibility toggle.

### RegisterScreen
**Purpose:** New account creation.
**What it does:** Collects user details and navigates to location selection.
**Key behavior:** Multi-field validation.

### LocationScreen
**Purpose:** Capture service location (pincode).
**What it does:** Lets user input/select a pincode and enters the main app.
**Key behavior:** Quick pincode chips + validation.

---

## 6.2 Main Shell & Tab Foundation

### MainShell (Container)
**Purpose:** Persistent bottom navigation host.
**What it does:** Holds 5 tab pages with IndexedStack for state preservation.
**Key behavior:** Unread badge on Messages tab based on chat state.

---

## 6.3 Discover Journey

### HomeScreen (Discover)
**Purpose:** Central discovery hub.
**What it does:**
- Category browsing
- Search providers
- Quick type filters (All/Individual/Company/...)
- Open advanced filters
- Provider card actions (call/chat/WhatsApp/detail)
**Key behavior:** Dynamic filtering and sorting based on pincode + user criteria.

### ProviderListScreen
**Purpose:** Category-specific listing page.
**What it does:**
- Shows providers for selected service
- Separates in-area and nearby-city providers
- Includes top-rated section
- Supports sorting options
**Key behavior:** Multi-strategy sorting and segmented rendering.

### ProviderDetailScreen
**Purpose:** Full provider profile and conversion page.
**What it does:**
- Displays provider details, stats, description, pricing, availability
- Shows review preview and review navigation
- Allows call/chat/share and similar provider discovery
**Key behavior:** Review metrics calculation + direct communication actions.

### FilterScreen
**Purpose:** Advanced filter controls.
**What it does:**
- Supports filter dimensions like service type, availability, price range, experience, rating, language, gender, verified only, city
- Returns selected filter payload back to caller
**Key behavior:** Stateful filter restore/reset/apply model.

### NotificationsScreen
**Purpose:** Notification feed.
**What it does:** Shows categorized updates (today/earlier) for bookings, offers, messages, reminders.
**Key behavior:** Notification-type visual states and mark-all-read action pattern.

### ReviewsScreen
**Purpose:** Full review analytics for a provider.
**What it does:**
- Shows average rating and rating distribution
- Lists individual reviews with time context
**Key behavior:** Runtime aggregation of review metrics.

---

## 6.4 Messaging & Calls

### MessagesScreen
**Purpose:** Conversation inbox.
**What it does:**
- Organizes chats into All / Booked / Unread / Archived
- Supports search, pinning, archiving, deleting, undo
**Key behavior:** Tab-controlled filtered views and pinned-first sorting.

### ChatDetailScreen
**Purpose:** One-to-one provider conversation.
**What it does:**
- Displays message thread
- Sends text messages
- Opens audio/video call screens
**Key behavior:** Typing/auto-reply simulation and scroll-to-latest behavior.

### AudioCallScreen
**Purpose:** Voice call interface.
**What it does:** Shows call state, duration timer, speaker/mute controls.
**Key behavior:** Simulated connection transition and live elapsed timer.

### VideoCallScreen
**Purpose:** Video call interface.
**What it does:** Full-screen call UI with controls (camera/mic/end call).
**Key behavior:** Simulated session state with call duration tracking.

---

## 6.5 Booking Journey

### BookingsScreen
**Purpose:** Booking overview by status.
**What it does:**
- Displays bookings across 4 tabs: Upcoming, Ongoing, Completed, Cancelled
- Opens booking detail page
**Key behavior:** TabController-driven segmented datasets.

### BookingDetailScreen
**Purpose:** Booking deep detail.
**What it does:** Shows booking status, provider details, schedule, and pricing information.
**Key behavior:** Status-color semantics (confirmed/pending/completed/cancelled).

---

## 6.6 Profile & Account Management

### ProfileScreen
**Purpose:** Personal account hub.
**What it does:**
- Displays profile hero section and summary stats
- Acts as gateway to Edit Profile, Reviews, Addresses, Favorites, Settings
**Key behavior:** UI state toggles and feature shortcuts.

### EditProfileScreen
**Purpose:** User information editing.
**What it does:** Updates profile fields and confirms save action.
**Key behavior:** Form validation + confirmation feedback.

### SavedAddressesScreen
**Purpose:** Address management.
**What it does:** Lists saved addresses, supports add/delete/default patterns.
**Key behavior:** Delete with undo UX.

### FavoritesScreen
**Purpose:** Favorite providers collection.
**What it does:** Displays and manages saved providers.
**Key behavior:** Remove/undo feedback cycle.

### MyReviewsScreen
**Purpose:** User review history.
**What it does:** Shows reviews written by the current user across providers.
**Key behavior:** Time formatting and compact review cards.

### SettingsScreen
**Purpose:** App preferences and policy access.
**What it does:**
- Preference toggles (e.g., mode/notifications)
- Language selection
- Privacy/legal/about sections
**Key behavior:** Local UI state for settings controls.

---

## 6.7 Partner Onboarding

### AddProviderScreen (Add Partner)
**Purpose:** Register providers into the marketplace.
**What it does:**
- Captures provider/business details
- Supports registration type, service, phone, description
- Supports multi-pincode coverage via chips
- Adds provider into in-memory data
**Key behavior:** Validation-heavy form flow + success feedback + recent additions.

---

## 7. End-to-End User Journey (Simplified)

1. App opens -> Splash
2. User logs in/registers
3. User chooses pincode
4. User lands in 5-tab marketplace shell
5. User discovers providers, filters/sorts, opens detail
6. User chats/calls provider or proceeds through bookings
7. User manages profile, settings, favorites, and addresses
8. Partners can register from Add Partner tab

---

## 8. Current Data & State Characteristics

- Data currently lives in local dummy collections (no backend API yet)
- Most UI state is local and screen-scoped
- Actions like add provider, archive chat, remove favorite are immediate in-memory updates
- Good for prototyping/demo; backend + persistent storage would be next production step

---

## 9. Strengths of Current Project Structure

- Clear separation of **data / models / utils / widgets / screens**
- Reusable components reduce duplication (`provider_card`, `category_card`, search widget)
- IndexedStack tab shell preserves UX continuity
- Feature-complete marketplace flow already modeled in UI
- Screen naming is intuitive and maintainable

---

## 10. Suggested Future Production Enhancements

1. Integrate backend services (auth, providers, bookings, chat)
2. Replace dummy data with repository/data-source layers
3. Add persistent local storage for session and preferences
4. Introduce scalable state management (Riverpod/BLoC/Provider)
5. Add robust form, API, and widget test coverage
6. Add analytics, crash reporting, and secure credential handling
7. Connect real-time messaging/call services

---

## 11. Quick Index of All Screen Files

- `lib/screens/splash_screen.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/register_screen.dart`
- `lib/screens/location_screen.dart`
- `lib/screens/main_shell.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/provider_list_screen.dart`
- `lib/screens/provider_detail_screen.dart`
- `lib/screens/filter_screen.dart`
- `lib/screens/messages_screen.dart`
- `lib/screens/chat_detail_screen.dart`
- `lib/screens/audio_call_screen.dart`
- `lib/screens/video_call_screen.dart`
- `lib/screens/bookings_screen.dart`
- `lib/screens/booking_detail_screen.dart`
- `lib/screens/notifications_screen.dart`
- `lib/screens/reviews_screen.dart`
- `lib/screens/my_reviews_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/edit_profile_screen.dart`
- `lib/screens/saved_addresses_screen.dart`
- `lib/screens/favorites_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/add_provider_screen.dart`

---

This document is intended to be a complete handoff/readme-style functional overview for current LocalConnect architecture and feature set.