// core/routes/app_router.dart
// Layer: Core (app-wide infrastructure)
//
// Centralized named-route definitions and route generator.
// Maps route strings to screen widgets with animated page transitions.

import 'package:flutter/material.dart';

// ── Auth Flow ──
import 'package:local_connect/features/auth/screens/splash_screen.dart';
import 'package:local_connect/features/auth/screens/onboarding_screen.dart';
import 'package:local_connect/features/auth/screens/login_screen.dart';
import 'package:local_connect/features/auth/screens/register_screen.dart';
import 'package:local_connect/features/auth/screens/forgot_password_screen.dart';
import 'package:local_connect/features/auth/screens/otp_verification_screen.dart';
import 'package:local_connect/features/auth/screens/reset_password_screen.dart';
import 'package:local_connect/features/auth/screens/location_screen.dart';

// ── Main Shell ──
import 'package:local_connect/features/home/screens/main_shell.dart';

// ── Discovery ──
import 'package:local_connect/features/search/screens/search_screen.dart';
import 'package:local_connect/features/search/screens/search_results_screen.dart';

// ── Booking Flow ──
import 'package:local_connect/features/booking/screens/select_slot_screen.dart';
import 'package:local_connect/features/booking/screens/checkout_screen.dart';
import 'package:local_connect/features/booking/screens/payment_success_screen.dart';
import 'package:local_connect/features/booking/screens/invoice_screen.dart';

// ── Info / Legal ──
import 'package:local_connect/features/rewards/screens/offers_screen.dart';
import 'package:local_connect/features/settings/screens/help_support_screen.dart';
import 'package:local_connect/features/settings/screens/privacy_policy_screen.dart';
import 'package:local_connect/features/settings/screens/terms_conditions_screen.dart';
import 'package:local_connect/features/settings/screens/about_app_screen.dart';

// ── Growth ──
import 'package:local_connect/features/rewards/screens/wallet_screen.dart';
import 'package:local_connect/features/rewards/screens/rewards_screen.dart';
import 'package:local_connect/features/rewards/screens/referral_screen.dart';
import 'package:local_connect/features/provider_mode/screens/provider_achievements_screen.dart';

// ── Job Post System ──
import 'package:local_connect/features/jobs/screens/post_request_screen.dart';
import 'package:local_connect/features/jobs/screens/my_requests_screen.dart';
import 'package:local_connect/features/jobs/screens/open_jobs_screen.dart';
import 'package:local_connect/features/jobs/screens/request_detail_screen.dart';
import 'package:local_connect/features/jobs/models/job_post_model.dart';

// ── Jobs Feed (Marketplace) ──
import 'package:local_connect/features/jobs/screens/job_detail_screen.dart';
import 'package:local_connect/features/jobs/screens/post_job_screen.dart';
import 'package:local_connect/features/jobs/screens/job_search_screen.dart';
import 'package:local_connect/features/jobs/models/job_model.dart' as jobfeed;

// ── Provider Side ──
import 'package:local_connect/features/provider_mode/screens/provider_dashboard_screen.dart';

/// Named route constants and route generator for the app.
class AppRoutes {
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String location = '/location';
  static const String mainShell = '/main';
  static const String search = '/search';
  static const String searchResults = '/search-results';
  static const String selectSlot = '/select-slot';
  static const String checkout = '/checkout';
  static const String paymentSuccess = '/payment-success';
  static const String invoice = '/invoice';
  static const String offers = '/offers';
  static const String helpSupport = '/help-support';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String aboutApp = '/about-app';
  static const String wallet = '/wallet';
  static const String rewards = '/rewards';
  static const String referral = '/referral';
  static const String providerAchievements = '/provider-achievements';
  static const String providerDashboard = '/provider-dashboard';
  static const String postRequest = '/post-request';
  static const String myRequests = '/my-requests';
  static const String openJobs = '/open-jobs';
  static const String requestDetail = '/request-detail';
  static const String jobDetail = '/job-detail';
  static const String postJob = '/post-job';
  static const String jobSearch = '/job-search';

  /// Generate route based on [RouteSettings].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());
      case onboarding:
        return _fade(const OnboardingScreen());
      case login:
        return _fade(const LoginScreen());
      case register:
        return _depthSlide(const RegisterScreen());
      case forgotPassword:
        return _slide(const ForgotPasswordScreen());
      case otpVerification:
        final email = settings.arguments as String? ?? '';
        return _slide(OtpVerificationScreen(email: email));
      case resetPassword:
        return _slide(const ResetPasswordScreen());
      case location:
        return _fade(const LocationScreen());
      case mainShell:
        final pincode = settings.arguments as String? ?? '110001';
        return _fade(MainShell(pincode: pincode));
      case search:
        return _slide(const SearchScreen());
      case searchResults:
        final query = settings.arguments as String? ?? '';
        return _depthSlide(SearchResultsScreen(query: query));
      case selectSlot:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _depthSlide(
          SelectSlotScreen(providerName: args['providerName'] ?? ''),
        );
      case checkout:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _depthSlide(
          CheckoutScreen(
            providerName: args['providerName'] ?? '',
            serviceName: args['serviceName'] ?? '',
            date: args['date'] ?? '',
            time: args['time'] ?? '',
            price: args['price'] ?? '₹499',
          ),
        );
      case paymentSuccess:
        return _fade(const PaymentSuccessScreen());
      case invoice:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(InvoiceScreen(bookingId: args['bookingId'] ?? 'BK-001'));
      case offers:
        return _depthSlide(const OffersScreen());
      case helpSupport:
        return _slide(const HelpSupportScreen());
      case privacyPolicy:
        return _slide(const PrivacyPolicyScreen());
      case termsConditions:
        return _slide(const TermsConditionsScreen());
      case aboutApp:
        return _slide(const AboutAppScreen());
      case wallet:
        return _depthSlide(const WalletScreen());
      case rewards:
        return _depthSlide(const RewardsScreen());
      case referral:
        return _depthSlide(const ReferralScreen());
      case providerAchievements:
        return _depthSlide(const ProviderAchievementsScreen());
      case providerDashboard:
        return _depthSlide(const ProviderDashboardScreen());
      case postRequest:
        return _depthSlide(const PostRequestScreen());
      case myRequests:
        return _slide(const MyRequestsScreen());
      case openJobs:
        return _slide(const OpenJobsScreen());
      case requestDetail:
        final jobPost = settings.arguments as JobPost;
        return _depthSlide(RequestDetailScreen(jobPost: jobPost));
      case jobDetail:
        final jobModel = settings.arguments as jobfeed.JobPost;
        return _depthSlide(JobDetailScreen(job: jobModel));
      case postJob:
        return _depthSlide(const PostJobScreen());
      case jobSearch:
        return _slide(const JobSearchScreen());
      default:
        return _fade(const SplashScreen());
    }
  }

  /// Fade transition with scale.
  static PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a2, a3) => page,
      transitionsBuilder: (_, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Slide-up transition for inner pages with fade.
  static PageRouteBuilder _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a2, a3) => page,
      transitionsBuilder: (_, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }

  /// Depth slide for immersive detail pages — lateral motion + scale + fade.
  static PageRouteBuilder _depthSlide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a2, a3) => page,
      transitionsBuilder: (_, anim, a2, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
