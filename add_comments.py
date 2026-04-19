"""
Add professional file-level documentation headers to all Dart files.
Skips files that already have proper doc comments at the top.
"""
import os
import re

LIB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lib')

# Feature module descriptions
FEATURE_DESC = {
    'auth': 'Authentication & Onboarding',
    'home': 'Home & Dashboard',
    'search': 'Search & Discovery',
    'provider': 'Provider Browsing & Details',
    'provider_mode': 'Provider Mode (Business Dashboard)',
    'booking': 'Booking & Payment Flow',
    'chat': 'Messaging & Communication',
    'profile': 'User Profile & Account',
    'jobs': 'Job Posts & Service Requests',
    'rewards': 'Rewards, Wallet & Loyalty',
    'notifications': 'Notifications Center',
    'settings': 'App Settings & Legal',
}

# File-specific descriptions (basename → description)
FILE_DESC = {
    # ── main ──
    'main.dart': 'Application entry point. Initializes MaterialApp with theme and routing.',

    # ── core ──
    'app_theme.dart': 'Premium dark-navy design system with gold accent – colors, typography,\n/// gradients, spacing, shadows, and motion tokens used across the entire app.',
    'app_router.dart': 'Centralized named-route definitions and route generator.\n/// Maps route strings to screen widgets with animated page transitions.',
    'app_constants.dart': 'App-wide constants: app info, demo credentials, animation durations,\n/// and layout dimensions.',
    'account_mode.dart': 'Dual-mode account state (User ↔ Provider) with ChangeNotifier.\n/// Global singleton drives UI mode switching throughout the app.',
    'category_icons.dart': 'Maps service category names to Material Icons and gradient color pairs\n/// for consistent visual representation across screens.',
    'search_engine.dart': 'Smart search engine with suggestion system, problem-to-service mapping,\n/// provider matching, and multi-factor relevance ranking.',

    # ── shared widgets ──
    'animated_mesh_background.dart': 'Animated gradient mesh background used behind auth and splash screens.',
    'app_button.dart': 'Reusable primary action button with gold gradient, loading state, and haptics.',
    'app_text_field.dart': 'Styled text input field with glassmorphic design, validation, and icons.',
    'callback_request_sheet.dart': 'Bottom sheet for requesting a callback from a service provider.',
    'category_card.dart': 'Category tile with icon, gradient background, and tap handler.',
    'empty_state_widget.dart': 'Placeholder widget shown when a list or section has no data.',
    'glass_container.dart': 'Glassmorphic container with frosted backdrop blur and border glow.',
    'instant_connect_actions.dart': 'Quick-action buttons for instant call, chat, and callback with a provider.',
    'loading_card.dart': 'Shimmer loading skeleton card used as placeholder during data fetch.',
    'provider_card.dart': 'Provider listing card showing name, rating, service, distance, and actions.',
    'section_header.dart': 'Section title row with optional "View All" action link.',

    # ── shared data/models ──
    'dummy_data.dart': 'Master dummy dataset of service providers for development and demo purposes.',
    'provider_model.dart': 'ServiceProvider data model with all fields, including reviews and areas.',

    # ── home widgets ──
    'location_selector_sheet.dart': 'Bottom sheet to select or change the user\'s pincode/location.',
    'pincode_ecosystem.dart': 'Pincode-based local ecosystem banner showing nearby stats and services.',

    # ── auth screens ──
    'splash_screen.dart': 'Animated splash screen with logo reveal and auto-navigation.',
    'onboarding_screen.dart': 'Multi-step onboarding carousel introducing app features to new users.',
    'login_screen.dart': 'Login screen with email/password fields, demo login, and social sign-in.',
    'register_screen.dart': 'Registration screen with name, email, password, and terms acceptance.',
    'forgot_password_screen.dart': 'Forgot password screen – collects email to send OTP for password reset.',
    'otp_verification_screen.dart': 'OTP entry screen with auto-advance, resend timer, and verification logic.',
    'reset_password_screen.dart': 'New-password entry screen after successful OTP verification.',
    'location_screen.dart': 'Location/pincode selection screen shown during onboarding.',

    # ── home screens ──
    'home_screen.dart': 'Main home screen with category grid, nearby providers, promotions, and search.',
    'main_shell.dart': 'Bottom navigation shell that hosts Home, Search, Bookings, and Profile tabs.',
    'emergency_screen.dart': 'Emergency services screen for urgent/on-demand service requests.',
    'micro_zone_screen.dart': 'Micro-zone view showing hyper-local providers within a pincode area.',

    # ── search screens ──
    'search_screen.dart': 'Full search interface with live suggestions, recent/trending, and filters.',
    'search_results_screen.dart': 'Search results list with provider cards, sort controls, and empty state.',
    'filter_screen.dart': 'Filter panel for refining search by category, rating, distance, and price.',

    # ── provider screens ──
    'provider_detail_screen.dart': 'Detailed provider profile with services, reviews, gallery, and booking CTA.',
    'provider_list_screen.dart': 'Browsable list of providers in a category or area with sorting.',
    'reviews_screen.dart': 'Full reviews list for a provider with rating breakdown and filters.',

    # ── booking screens ──
    'select_slot_screen.dart': 'Date & time slot picker for scheduling a service appointment.',
    'checkout_screen.dart': 'Checkout summary with price breakdown, coupon entry, and payment options.',
    'payment_success_screen.dart': 'Payment confirmation screen with animated success state and booking ID.',
    'invoice_screen.dart': 'Detailed invoice view for a completed booking with download option.',
    'bookings_screen.dart': 'User\'s bookings list with tabs for upcoming, past, and cancelled bookings.',
    'booking_detail_screen.dart': 'Single booking detail view with status timeline, provider info, and actions.',

    # ── chat screens ──
    'messages_screen.dart': 'Chat inbox showing all active conversations with providers.',
    'chat_detail_screen.dart': 'Individual chat thread with message bubbles, input, and quick actions.',
    'audio_call_screen.dart': 'In-app audio call screen with timer, mute, and speaker controls.',
    'video_call_screen.dart': 'In-app video call screen with camera toggle and picture-in-picture.',

    # ── profile screens ──
    'profile_screen.dart': 'User profile overview with avatar, stats, settings links, and mode switch.',
    'edit_profile_screen.dart': 'Profile editing form for name, phone, email, and avatar.',
    'add_provider_screen.dart': 'Multi-step form to register as a new service provider.',
    'favorites_screen.dart': 'Saved/favorite providers list with quick-action buttons.',
    'my_reviews_screen.dart': 'Reviews written by the current user across all providers.',
    'saved_addresses_screen.dart': 'Manage saved addresses for service delivery locations.',

    # ── provider_mode screens ──
    'provider_dashboard_screen.dart': 'Provider home dashboard with stats, leads, and earnings overview.',
    'provider_lead_inbox_screen.dart': 'Incoming leads/requests inbox for the provider to accept or decline.',
    'provider_lead_detail_screen.dart': 'Detailed view of a single lead with customer info and response actions.',
    'provider_earnings_screen.dart': 'Earnings summary with charts, withdrawal, and transaction history.',
    'provider_insights_screen.dart': 'Business analytics dashboard with performance metrics and trends.',
    'provider_availability_screen.dart': 'Schedule and availability management for the provider.',
    'provider_business_profile_screen.dart': 'Provider business profile editor (bio, services, photos, certifications).',
    'provider_service_areas_screen.dart': 'Configure service area pincodes and coverage zone.',
    'provider_achievements_screen.dart': 'Badges, milestones, and achievement tracker for the provider.',
    'provider_reviews_received_screen.dart': 'Reviews and ratings received from customers.',
    'provider_notifications_screen.dart': 'Provider-specific notification feed (leads, payments, updates).',
    'provider_onboarding_screen.dart': 'Step-by-step onboarding flow for new provider registration.',
    'provider_mode_content.dart': 'Provider mode content widget for the profile screen\'s provider tab.',

    # ── provider_mode data/models ──
    'provider_dummy_data.dart': 'Mock data for provider-mode screens: leads, earnings, stats.',
    'lead_model.dart': 'Lead data model representing an incoming service request for a provider.',

    # ── jobs screens/widgets/data/models ──
    'open_jobs_screen.dart': 'Browse open job postings from users looking for service providers.',
    'post_request_screen.dart': 'Form to create a new service request/job post.',
    'my_requests_screen.dart': 'User\'s posted service requests with status tracking.',
    'applications_screen.dart': 'Applications received on a job post from providers.',
    'request_success_screen.dart': 'Success confirmation after posting a service request.',
    'apply_bottom_sheet.dart': 'Bottom sheet for a provider to apply/respond to a job posting.',
    'job_post_data.dart': 'Mock dataset of job posts for development and demo.',
    'job_post_model.dart': 'JobPost data model with title, description, budget, and status fields.',

    # ── rewards screens/data/models ──
    'rewards_screen.dart': 'Rewards hub with points balance, available rewards, and redemption.',
    'wallet_screen.dart': 'Digital wallet with balance, top-up, and transaction history.',
    'referral_screen.dart': 'Referral program screen with invite link, rewards, and leaderboard.',
    'offers_screen.dart': 'Active offers and promotional deals available to the user.',
    'membership_tiers_screen.dart': 'Membership tier comparison (Bronze, Silver, Gold, Platinum).',
    'streaks_badges_screen.dart': 'Streaks, badges, and gamification progress tracker.',
    'reward_notifications_screen.dart': 'Notifications related to rewards, points earned, and offers.',
    'rewards_dummy_data.dart': 'Mock data for rewards, tiers, offers, and streaks.',
    'rewards_model.dart': 'Data models for rewards: Reward, Tier, Offer, Badge.',

    # ── notifications ──
    'notifications_screen.dart': 'Central notification feed with categories and read/unread state.',

    # ── settings screens ──
    'settings_screen.dart': 'App settings hub with theme, notifications, privacy, and account options.',
    'help_support_screen.dart': 'Help & support center with FAQ, contact, and ticket creation.',
    'privacy_policy_screen.dart': 'Privacy policy display screen.',
    'terms_conditions_screen.dart': 'Terms and conditions display screen.',
    'about_app_screen.dart': 'About screen with app version, credits, and legal links.',
}


def get_feature_module(rel_path):
    """Extract feature module name from relative path."""
    parts = rel_path.replace('\\', '/').split('/')
    if len(parts) >= 3 and parts[0] == 'features':
        return parts[1]
    return None


def get_layer(rel_path):
    """Extract the layer (screens, widgets, models, data) from path."""
    parts = rel_path.replace('\\', '/').split('/')
    for p in parts:
        if p in ('screens', 'widgets', 'models', 'data'):
            return p
    return None


def get_module_path(rel_path):
    """Get a human-readable module path like 'features/auth/screens'."""
    parts = rel_path.replace('\\', '/').split('/')
    return '/'.join(parts[:-1]) if len(parts) > 1 else ''


def generate_header(rel_path, basename):
    """Generate a professional file header comment."""
    desc = FILE_DESC.get(basename, None)
    feature = get_feature_module(rel_path)
    layer = get_layer(rel_path)
    module_path = get_module_path(rel_path)

    lines = []
    lines.append(f'/// {module_path}/{basename}')

    if feature and feature in FEATURE_DESC:
        lines.append(f'/// Feature: {FEATURE_DESC[feature]}')
    elif 'core/' in rel_path:
        lines.append('/// Layer: Core (app-wide infrastructure)')
    elif 'shared/' in rel_path:
        lines.append('/// Layer: Shared (reusable across features)')

    if desc:
        lines.append('///')
        for dline in desc.split('\n'):
            lines.append(f'/// {dline.lstrip("/// ").strip()}' if not dline.startswith('///') else dline)

    return '\n'.join(lines)


def file_already_has_header(content):
    """Check if the file already starts with a doc comment or file header."""
    stripped = content.lstrip()
    if stripped.startswith('///') or stripped.startswith('/**') or stripped.startswith('// ──'):
        return True
    return False


def add_header_to_file(filepath, rel_path):
    """Add a header comment to a dart file if it doesn't have one."""
    basename = os.path.basename(rel_path)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Don't add if already has a header (before imports)
    lines = content.split('\n')
    first_non_empty = ''
    for line in lines:
        if line.strip():
            first_non_empty = line.strip()
            break

    if first_non_empty.startswith('///') or first_non_empty.startswith('/**') or first_non_empty.startswith('// ─'):
        # Already has a comment header
        return False

    header = generate_header(rel_path, basename)
    new_content = header + '\n\n' + content
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    return True


def main():
    print("=== Adding Professional File Headers ===\n")
    
    added = 0
    skipped = 0
    
    for root, dirs, files in os.walk(LIB_DIR):
        for f in sorted(files):
            if not f.endswith('.dart'):
                continue
            filepath = os.path.join(root, f)
            rel_path = os.path.relpath(filepath, LIB_DIR).replace('\\', '/')
            
            if add_header_to_file(filepath, rel_path):
                added += 1
                print(f"  + {rel_path}")
            else:
                skipped += 1
                print(f"  ~ {rel_path} (already has header)")
    
    print(f"\nDone! Added headers to {added} files, skipped {skipped}.")


if __name__ == '__main__':
    main()
