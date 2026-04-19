# Flow Map — LocalConnect

User journeys and navigation flows through the application.

---

## 1. First Launch → Onboarding → Auth

```
App Launch
  └─ SplashScreen (/)
       ├─ [First time] → OnboardingScreen (/onboarding)
       │                    └─ "Get Started"
       │                         └─ LoginScreen (/login)
       └─ [Returning] → MainShell (/main)
```

### Authentication Flow

```
LoginScreen (/login)
  ├─ Login success → LocationScreen (/location) → MainShell (/main)
  ├─ "Register" → RegisterScreen (/register)
  │                  └─ Register success → LocationScreen → MainShell
  └─ "Forgot Password" → ForgotPasswordScreen (/forgot-password)
                            └─ OtpVerificationScreen (/otp-verification)
                                 └─ ResetPasswordScreen (/reset-password)
                                      └─ LoginScreen
```

---

## 2. Main Shell — Tab Navigation

```
MainShell (/main)
  ├─ Tab 0: HomeScreen
  ├─ Tab 1: SearchScreen         (or BookingsScreen depending on mode)
  ├─ Tab 2: BookingsScreen       (or Provider Dashboard)
  └─ Tab 3: ProfileScreen
```

---

## 3. Home → Discovery

```
HomeScreen
  ├─ Search bar tap → SearchScreen (/search)
  ├─ Category tap → ProviderListScreen (push)
  ├─ Provider card tap → ProviderDetailScreen (push)
  ├─ "Emergency" → EmergencyScreen (push)
  ├─ "Micro Zone" → MicroZoneScreen (push)
  ├─ Location chip → LocationSelectorSheet (bottom sheet)
  └─ Promotion banner → OffersScreen (/offers)
```

---

## 4. Search → Results → Provider

```
SearchScreen (/search)
  ├─ Type query → Live suggestions dropdown
  │    ├─ Tap service → SearchResultsScreen (/search-results)
  │    ├─ Tap provider name → ProviderDetailScreen (push)
  │    └─ Tap area/pincode → SearchResultsScreen (filtered)
  ├─ Filter icon → FilterScreen (push)
  │    └─ Apply filters → SearchResultsScreen (filtered)
  └─ Submit search → SearchResultsScreen (/search-results)

SearchResultsScreen
  └─ Tap provider card → ProviderDetailScreen (push)
```

---

## 5. Provider Detail → Booking

```
ProviderDetailScreen
  ├─ "Book Now" → SelectSlotScreen (/select-slot)
  ├─ "Call" → Phone dialer (url_launcher)
  ├─ "Chat" → ChatDetailScreen (push)
  ├─ "Request Callback" → CallbackRequestSheet (bottom sheet)
  ├─ "All Reviews" → ReviewsScreen (push)
  └─ "Share" → System share sheet
```

---

## 6. Booking Flow

```
SelectSlotScreen (/select-slot)
  └─ Select date + time → "Continue"
       └─ CheckoutScreen (/checkout)
            ├─ Apply coupon
            ├─ Select payment method
            └─ "Pay" → PaymentSuccessScreen (/payment-success)
                         └─ "View Invoice" → InvoiceScreen (/invoice)
                         └─ "Back to Home" → MainShell (/main)
```

### Booking Management

```
BookingsScreen (tab in MainShell)
  ├─ Upcoming tab → Booking cards
  ├─ Past tab → Completed bookings
  └─ Cancelled tab → Cancelled bookings
       └─ Tap any booking → BookingDetailScreen (push)
                              ├─ "Chat with Provider" → ChatDetailScreen
                              ├─ "View Invoice" → InvoiceScreen
                              └─ "Cancel Booking" → Confirmation dialog
```

---

## 7. Chat & Communication

```
MessagesScreen (push from profile/provider)
  └─ Tap conversation → ChatDetailScreen (push)
                           ├─ Send message
                           ├─ Audio call → AudioCallScreen (push)
                           └─ Video call → VideoCallScreen (push)
```

---

## 8. Profile & Account

```
ProfileScreen (tab in MainShell)
  ├─ "Edit Profile" → EditProfileScreen (push)
  ├─ "My Favorites" → FavoritesScreen (push)
  ├─ "My Reviews" → MyReviewsScreen (push)
  ├─ "Saved Addresses" → SavedAddressesScreen (push)
  ├─ "Become a Provider" → AddProviderScreen (push)
  ├─ "Provider Mode" toggle → Switch to Provider Dashboard
  ├─ "Settings" → SettingsScreen (push)
  ├─ "Wallet" → WalletScreen (/wallet)
  ├─ "Rewards" → RewardsScreen (/rewards)
  ├─ "Messages" → MessagesScreen (push)
  └─ "Notifications" → NotificationsScreen (push)
```

---

## 9. Provider Mode Flows

```
Provider Mode activated (via profile toggle or AddProviderScreen)
  └─ ProviderDashboardScreen (/provider-dashboard)
       ├─ "Lead Inbox" → ProviderLeadInboxScreen (push)
       │                    └─ Tap lead → ProviderLeadDetailScreen (push)
       │                                   ├─ "Accept" → Lead accepted
       │                                   └─ "Decline" → Lead declined
       ├─ "Earnings" → ProviderEarningsScreen (push)
       ├─ "Insights" → ProviderInsightsScreen (push)
       ├─ "Availability" → ProviderAvailabilityScreen (push)
       ├─ "Business Profile" → ProviderBusinessProfileScreen (push)
       ├─ "Service Areas" → ProviderServiceAreasScreen (push)
       ├─ "Achievements" → ProviderAchievementsScreen (/provider-achievements)
       ├─ "Reviews" → ProviderReviewsReceivedScreen (push)
       └─ "Notifications" → ProviderNotificationsScreen (push)

New Provider Onboarding:
  AddProviderScreen (from profile)
    └─ OR → ProviderOnboardingScreen (push)
               └─ Complete steps → ProviderDashboardScreen
```

---

## 10. Jobs & Service Requests

```
User posts a request:
  PostRequestScreen (/post-request)
    └─ Submit → RequestSuccessScreen (push)

User tracks requests:
  MyRequestsScreen (/my-requests)
    └─ Tap request → ApplicationsScreen (push)
                       └─ View provider applications

Provider browses jobs:
  OpenJobsScreen (/open-jobs)
    └─ Tap job → ApplyBottomSheet (bottom sheet)
                   └─ Submit application
```

---

## 11. Rewards & Wallet

```
RewardsScreen (/rewards)
  ├─ "Wallet" → WalletScreen (/wallet)
  ├─ "Referral" → ReferralScreen (/referral)
  ├─ "Offers" → OffersScreen (/offers)
  ├─ "Membership" → MembershipTiersScreen (push)
  ├─ "Streaks & Badges" → StreaksBadgesScreen (push)
  └─ "Notifications" → RewardNotificationsScreen (push)
```

---

## 12. Settings & Legal

```
SettingsScreen (push from profile)
  ├─ "Help & Support" → HelpSupportScreen (/help-support)
  ├─ "Privacy Policy" → PrivacyPolicyScreen (/privacy-policy)
  ├─ "Terms & Conditions" → TermsConditionsScreen (/terms-conditions)
  ├─ "About" → AboutAppScreen (/about-app)
  └─ "Logout" → LoginScreen (/login)
```

---

## Route Summary

| Route | Screen | Transition |
|-------|--------|------------|
| `/` | SplashScreen | fade+scale |
| `/onboarding` | OnboardingScreen | fade+scale |
| `/login` | LoginScreen | fade+scale |
| `/register` | RegisterScreen | slide+fade |
| `/forgot-password` | ForgotPasswordScreen | slide+fade |
| `/otp-verification` | OtpVerificationScreen | slide+fade |
| `/reset-password` | ResetPasswordScreen | slide+fade |
| `/location` | LocationScreen | fade+scale |
| `/main` | MainShell | fade+scale |
| `/search` | SearchScreen | slide+fade |
| `/search-results` | SearchResultsScreen | slide+fade |
| `/select-slot` | SelectSlotScreen | slide+fade |
| `/checkout` | CheckoutScreen | slide+fade |
| `/payment-success` | PaymentSuccessScreen | fade+scale |
| `/invoice` | InvoiceScreen | slide+fade |
| `/offers` | OffersScreen | slide+fade |
| `/help-support` | HelpSupportScreen | slide+fade |
| `/privacy-policy` | PrivacyPolicyScreen | slide+fade |
| `/terms-conditions` | TermsConditionsScreen | slide+fade |
| `/about-app` | AboutAppScreen | slide+fade |
| `/wallet` | WalletScreen | slide+fade |
| `/rewards` | RewardsScreen | slide+fade |
| `/referral` | ReferralScreen | slide+fade |
| `/provider-achievements` | ProviderAchievementsScreen | slide+fade |
| `/provider-dashboard` | ProviderDashboardScreen | slide+fade |
| `/post-request` | PostRequestScreen | slide+fade |
| `/my-requests` | MyRequestsScreen | slide+fade |
| `/open-jobs` | OpenJobsScreen | slide+fade |
