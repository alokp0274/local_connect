# Screen Guide — LocalConnect

Every screen in the app, organized by feature module.

---

## Auth (8 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Splash | `features/auth/screens/splash_screen.dart` | `/` | Animated logo reveal, auto-navigates to onboarding or home |
| Onboarding | `features/auth/screens/onboarding_screen.dart` | `/onboarding` | 3-step carousel introducing app features to new users |
| Login | `features/auth/screens/login_screen.dart` | `/login` | Email + password login with demo shortcut and social options |
| Register | `features/auth/screens/register_screen.dart` | `/register` | Name, email, password registration with terms acceptance |
| Forgot Password | `features/auth/screens/forgot_password_screen.dart` | `/forgot-password` | Email input to trigger OTP for password reset |
| OTP Verification | `features/auth/screens/otp_verification_screen.dart` | `/otp-verification` | 6-digit OTP entry with auto-advance and resend timer |
| Reset Password | `features/auth/screens/reset_password_screen.dart` | `/reset-password` | New password entry after OTP verification |
| Location | `features/auth/screens/location_screen.dart` | `/location` | Pincode/location selection during onboarding |

---

## Home (4 screens + 2 widgets)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Main Shell | `features/home/screens/main_shell.dart` | `/main` | Bottom nav shell hosting Home, Search, Bookings, Profile tabs |
| Home | `features/home/screens/home_screen.dart` | — (tab) | Category grid, nearby providers, promotions, and search entry |
| Emergency | `features/home/screens/emergency_screen.dart` | — (push) | Urgent/on-demand service request interface |
| Micro Zone | `features/home/screens/micro_zone_screen.dart` | — (push) | Hyper-local providers view within a pincode area |

**Widgets:**
- `location_selector_sheet.dart` — Bottom sheet for changing pincode/location
- `pincode_ecosystem.dart` — Local ecosystem stats banner

---

## Search (3 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Search | `features/search/screens/search_screen.dart` | `/search` | Live suggestions, trending, recent, category shortcuts |
| Search Results | `features/search/screens/search_results_screen.dart` | `/search-results` | Provider cards list with sort controls |
| Filters | `features/search/screens/filter_screen.dart` | — (push) | Category, rating, distance, and price filter panel |

---

## Provider (3 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Provider List | `features/provider/screens/provider_list_screen.dart` | — (push) | Browsable provider listing by category/area |
| Provider Detail | `features/provider/screens/provider_detail_screen.dart` | — (push) | Full profile: services, reviews, gallery, booking CTA |
| Reviews | `features/provider/screens/reviews_screen.dart` | — (push) | Complete reviews list with rating breakdown |

---

## Booking (6 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Select Slot | `features/booking/screens/select_slot_screen.dart` | `/select-slot` | Calendar date picker + time slot grid |
| Checkout | `features/booking/screens/checkout_screen.dart` | `/checkout` | Price summary, coupon entry, payment method selection |
| Payment Success | `features/booking/screens/payment_success_screen.dart` | `/payment-success` | Animated confirmation with booking ID |
| Invoice | `features/booking/screens/invoice_screen.dart` | `/invoice` | Detailed invoice with line items and download |
| Bookings | `features/booking/screens/bookings_screen.dart` | — (tab) | Upcoming / Past / Cancelled bookings tabs |
| Booking Detail | `features/booking/screens/booking_detail_screen.dart` | — (push) | Status timeline, provider info, and actions |

---

## Chat (4 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Messages | `features/chat/screens/messages_screen.dart` | — (push) | All active conversations inbox |
| Chat Detail | `features/chat/screens/chat_detail_screen.dart` | — (push) | 1:1 chat thread with input and quick actions |
| Audio Call | `features/chat/screens/audio_call_screen.dart` | — (push) | Voice call with timer, mute, speaker |
| Video Call | `features/chat/screens/video_call_screen.dart` | — (push) | Video call with camera toggle |

---

## Profile (6 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Profile | `features/profile/screens/profile_screen.dart` | — (tab) | User overview: avatar, stats, settings, mode switch |
| Edit Profile | `features/profile/screens/edit_profile_screen.dart` | — (push) | Edit name, phone, email, and avatar |
| Add Provider | `features/profile/screens/add_provider_screen.dart` | — (push) | Multi-step provider registration from user account |
| Favorites | `features/profile/screens/favorites_screen.dart` | — (push) | Saved/favorite providers with quick actions |
| My Reviews | `features/profile/screens/my_reviews_screen.dart` | — (push) | Reviews written by the user |
| Saved Addresses | `features/profile/screens/saved_addresses_screen.dart` | — (push) | Manage delivery/service addresses |

---

## Provider Mode (12 screens + 1 widget)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Dashboard | `features/provider_mode/screens/provider_dashboard_screen.dart` | `/provider-dashboard` | Stats, leads, earnings overview |
| Lead Inbox | `features/provider_mode/screens/provider_lead_inbox_screen.dart` | — (push) | Incoming service request queue |
| Lead Detail | `features/provider_mode/screens/provider_lead_detail_screen.dart` | — (push) | Single lead with customer info, accept/decline |
| Earnings | `features/provider_mode/screens/provider_earnings_screen.dart` | — (push) | Revenue charts, withdrawal, transactions |
| Insights | `features/provider_mode/screens/provider_insights_screen.dart` | — (push) | Performance analytics and trends |
| Availability | `features/provider_mode/screens/provider_availability_screen.dart` | — (push) | Schedule and hours management |
| Business Profile | `features/provider_mode/screens/provider_business_profile_screen.dart` | — (push) | Edit bio, services, photos, certs |
| Service Areas | `features/provider_mode/screens/provider_service_areas_screen.dart` | — (push) | Pincode coverage zone setup |
| Achievements | `features/provider_mode/screens/provider_achievements_screen.dart` | `/provider-achievements` | Badges and milestones tracker |
| Reviews Received | `features/provider_mode/screens/provider_reviews_received_screen.dart` | — (push) | Customer reviews and ratings |
| Notifications | `features/provider_mode/screens/provider_notifications_screen.dart` | — (push) | Provider-specific notification feed |
| Onboarding | `features/provider_mode/screens/provider_onboarding_screen.dart` | — (push) | New provider registration wizard |

**Widget:** `provider_mode_content.dart` — Provider tab content for profile screen

**Data:** `provider_dummy_data.dart` — Mock leads, earnings, stats

**Model:** `lead_model.dart` — Lead data structure

---

## Jobs (5 screens + 1 widget)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Open Jobs | `features/jobs/screens/open_jobs_screen.dart` | `/open-jobs` | Browse available job postings |
| Post Request | `features/jobs/screens/post_request_screen.dart` | `/post-request` | Create new service request form |
| My Requests | `features/jobs/screens/my_requests_screen.dart` | `/my-requests` | User's posted requests with status |
| Applications | `features/jobs/screens/applications_screen.dart` | — (push) | Provider applications on a job |
| Request Success | `features/jobs/screens/request_success_screen.dart` | — (push) | Post-submission confirmation |

**Widget:** `apply_bottom_sheet.dart` — Provider apply/respond sheet

**Data:** `job_post_data.dart` • **Model:** `job_post_model.dart`

---

## Rewards (7 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Rewards | `features/rewards/screens/rewards_screen.dart` | `/rewards` | Points balance, available rewards, redemption |
| Wallet | `features/rewards/screens/wallet_screen.dart` | `/wallet` | Balance, top-up, transaction history |
| Referral | `features/rewards/screens/referral_screen.dart` | `/referral` | Invite link, reward tiers, leaderboard |
| Offers | `features/rewards/screens/offers_screen.dart` | `/offers` | Active promotional deals |
| Membership Tiers | `features/rewards/screens/membership_tiers_screen.dart` | — (push) | Bronze → Silver → Gold → Platinum comparison |
| Streaks & Badges | `features/rewards/screens/streaks_badges_screen.dart` | — (push) | Gamification progress tracker |
| Reward Notifications | `features/rewards/screens/reward_notifications_screen.dart` | — (push) | Points earned, offers, expiry alerts |

**Data:** `rewards_dummy_data.dart` • **Model:** `rewards_model.dart`

---

## Notifications (1 screen)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Notifications | `features/notifications/screens/notifications_screen.dart` | — (push) | Central feed with categories and read/unread state |

---

## Settings (5 screens)

| Screen | File | Route | Description |
|--------|------|-------|-------------|
| Settings | `features/settings/screens/settings_screen.dart` | — (push) | Theme, notifications, privacy, account options |
| Help & Support | `features/settings/screens/help_support_screen.dart` | `/help-support` | FAQ, contact, ticket creation |
| Privacy Policy | `features/settings/screens/privacy_policy_screen.dart` | `/privacy-policy` | Full privacy policy text |
| Terms & Conditions | `features/settings/screens/terms_conditions_screen.dart` | `/terms-conditions` | Terms of service text |
| About | `features/settings/screens/about_app_screen.dart` | `/about-app` | App version, credits, legal links |

---

## Shared Widgets (11)

| Widget | File | Description |
|--------|------|-------------|
| AnimatedMeshBackground | `shared/widgets/animated_mesh_background.dart` | Gradient mesh behind auth screens |
| AppButton | `shared/widgets/app_button.dart` | Gold gradient CTA with loading state |
| AppTextField | `shared/widgets/app_text_field.dart` | Glassmorphic input field |
| CallbackRequestSheet | `shared/widgets/callback_request_sheet.dart` | Request callback bottom sheet |
| CategoryCard | `shared/widgets/category_card.dart` | Service category tile |
| EmptyStateWidget | `shared/widgets/empty_state_widget.dart` | No-data placeholder |
| GlassContainer | `shared/widgets/glass_container.dart` | Frosted glass card |
| InstantConnectActions | `shared/widgets/instant_connect_actions.dart` | Quick call/chat/callback buttons |
| LoadingCard | `shared/widgets/loading_card.dart` | Shimmer skeleton loader |
| ProviderCard | `shared/widgets/provider_card.dart` | Provider listing card |
| SectionHeader | `shared/widgets/section_header.dart` | Title + "View All" row |
