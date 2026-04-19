"""
LocalConnect Project Restructuring Script
==========================================
Moves all files from flat structure to feature-based modular architecture.
Then rewrites all import statements to use the new paths.
"""
import os
import shutil
import re

BASE = r'd:\MyWorkers\local_connect\lib'

# ─────────────────────────────────────────────────────────
# FILE MAPPING: old_path -> new_path (relative to lib/)
# ─────────────────────────────────────────────────────────
FILE_MAP = {
    # ── CORE ──
    'main.dart':                          'main.dart',
    'core/routes/app_router.dart':        'core/routes/app_router.dart',
    'core/constants/app_constants.dart':   'core/constants/app_constants.dart',
    'core/theme/app_theme.dart':           'core/theme/app_theme.dart',
    'utils/app_theme.dart':                'core/theme/app_theme.dart',   # merges into same target
    'utils/account_mode.dart':             'core/utils/account_mode.dart',
    'utils/category_icons.dart':           'core/utils/category_icons.dart',
    'utils/search_engine.dart':            'core/utils/search_engine.dart',

    # ── SHARED WIDGETS ──
    'widgets/animated_mesh_background.dart': 'shared/widgets/animated_mesh_background.dart',
    'widgets/glass_container.dart':          'shared/widgets/glass_container.dart',
    'widgets/provider_card.dart':            'shared/widgets/provider_card.dart',
    'widgets/app_button.dart':               'shared/widgets/app_button.dart',
    'widgets/app_text_field.dart':           'shared/widgets/app_text_field.dart',
    'widgets/category_card.dart':            'shared/widgets/category_card.dart',
    'widgets/empty_state_widget.dart':       'shared/widgets/empty_state_widget.dart',
    'widgets/loading_card.dart':             'shared/widgets/loading_card.dart',
    'widgets/section_header.dart':           'shared/widgets/section_header.dart',
    'widgets/callback_request_sheet.dart':   'shared/widgets/callback_request_sheet.dart',
    'widgets/instant_connect_actions.dart':  'shared/widgets/instant_connect_actions.dart',

    # ── SHARED MODELS ──
    'models/provider_model.dart':            'shared/models/provider_model.dart',

    # ── SHARED DATA ──
    'data/dummy_data.dart':                  'shared/data/dummy_data.dart',

    # ── AUTH FEATURE ──
    'screens/splash_screen.dart':            'features/auth/screens/splash_screen.dart',
    'screens/onboarding_screen.dart':        'features/auth/screens/onboarding_screen.dart',
    'screens/login_screen.dart':             'features/auth/screens/login_screen.dart',
    'screens/register_screen.dart':          'features/auth/screens/register_screen.dart',
    'screens/forgot_password_screen.dart':   'features/auth/screens/forgot_password_screen.dart',
    'screens/otp_verification_screen.dart':  'features/auth/screens/otp_verification_screen.dart',
    'screens/reset_password_screen.dart':    'features/auth/screens/reset_password_screen.dart',
    'screens/location_screen.dart':          'features/auth/screens/location_screen.dart',

    # ── HOME FEATURE ──
    'screens/main_shell.dart':               'features/home/screens/main_shell.dart',
    'screens/home_screen.dart':              'features/home/screens/home_screen.dart',
    'screens/emergency_screen.dart':         'features/home/screens/emergency_screen.dart',
    'screens/micro_zone_screen.dart':        'features/home/screens/micro_zone_screen.dart',
    'widgets/pincode_ecosystem.dart':        'features/home/widgets/pincode_ecosystem.dart',
    'widgets/location_selector_sheet.dart':  'features/home/widgets/location_selector_sheet.dart',

    # ── SEARCH FEATURE ──
    'screens/search_screen.dart':            'features/search/screens/search_screen.dart',
    'screens/search_results_screen.dart':    'features/search/screens/search_results_screen.dart',
    'screens/filter_screen.dart':            'features/search/screens/filter_screen.dart',

    # ── PROVIDER FEATURE (discovery) ──
    'screens/provider_list_screen.dart':     'features/provider/screens/provider_list_screen.dart',
    'screens/provider_detail_screen.dart':   'features/provider/screens/provider_detail_screen.dart',
    'screens/reviews_screen.dart':           'features/provider/screens/reviews_screen.dart',

    # ── PROVIDER MODE FEATURE (provider dashboard) ──
    'screens/provider_onboarding_screen.dart':       'features/provider_mode/screens/provider_onboarding_screen.dart',
    'screens/provider_dashboard_screen.dart':        'features/provider_mode/screens/provider_dashboard_screen.dart',
    'screens/provider_lead_inbox_screen.dart':       'features/provider_mode/screens/provider_lead_inbox_screen.dart',
    'screens/provider_lead_detail_screen.dart':      'features/provider_mode/screens/provider_lead_detail_screen.dart',
    'screens/provider_earnings_screen.dart':         'features/provider_mode/screens/provider_earnings_screen.dart',
    'screens/provider_insights_screen.dart':         'features/provider_mode/screens/provider_insights_screen.dart',
    'screens/provider_notifications_screen.dart':    'features/provider_mode/screens/provider_notifications_screen.dart',
    'screens/provider_availability_screen.dart':     'features/provider_mode/screens/provider_availability_screen.dart',
    'screens/provider_service_areas_screen.dart':    'features/provider_mode/screens/provider_service_areas_screen.dart',
    'screens/provider_business_profile_screen.dart': 'features/provider_mode/screens/provider_business_profile_screen.dart',
    'screens/provider_reviews_received_screen.dart': 'features/provider_mode/screens/provider_reviews_received_screen.dart',
    'screens/provider_achievements_screen.dart':     'features/provider_mode/screens/provider_achievements_screen.dart',
    'widgets/provider_mode_content.dart':            'features/provider_mode/widgets/provider_mode_content.dart',
    'models/lead_model.dart':                        'features/provider_mode/models/lead_model.dart',
    'data/provider_dummy_data.dart':                 'features/provider_mode/data/provider_dummy_data.dart',

    # ── BOOKING FEATURE ──
    'screens/bookings_screen.dart':          'features/booking/screens/bookings_screen.dart',
    'screens/booking_detail_screen.dart':    'features/booking/screens/booking_detail_screen.dart',
    'screens/select_slot_screen.dart':       'features/booking/screens/select_slot_screen.dart',
    'screens/checkout_screen.dart':          'features/booking/screens/checkout_screen.dart',
    'screens/payment_success_screen.dart':   'features/booking/screens/payment_success_screen.dart',
    'screens/invoice_screen.dart':           'features/booking/screens/invoice_screen.dart',

    # ── CHAT FEATURE ──
    'screens/messages_screen.dart':          'features/chat/screens/messages_screen.dart',
    'screens/chat_detail_screen.dart':       'features/chat/screens/chat_detail_screen.dart',
    'screens/audio_call_screen.dart':        'features/chat/screens/audio_call_screen.dart',
    'screens/video_call_screen.dart':        'features/chat/screens/video_call_screen.dart',

    # ── PROFILE FEATURE ──
    'screens/profile_screen.dart':           'features/profile/screens/profile_screen.dart',
    'screens/edit_profile_screen.dart':      'features/profile/screens/edit_profile_screen.dart',
    'screens/favorites_screen.dart':         'features/profile/screens/favorites_screen.dart',
    'screens/saved_addresses_screen.dart':   'features/profile/screens/saved_addresses_screen.dart',
    'screens/my_reviews_screen.dart':        'features/profile/screens/my_reviews_screen.dart',
    'screens/add_provider_screen.dart':      'features/profile/screens/add_provider_screen.dart',

    # ── JOBS FEATURE ──
    'screens/post_request_screen.dart':      'features/jobs/screens/post_request_screen.dart',
    'screens/request_success_screen.dart':   'features/jobs/screens/request_success_screen.dart',
    'screens/my_requests_screen.dart':       'features/jobs/screens/my_requests_screen.dart',
    'screens/applications_screen.dart':      'features/jobs/screens/applications_screen.dart',
    'screens/open_jobs_screen.dart':         'features/jobs/screens/open_jobs_screen.dart',
    'screens/apply_bottom_sheet.dart':       'features/jobs/widgets/apply_bottom_sheet.dart',
    'models/job_post_model.dart':            'features/jobs/models/job_post_model.dart',
    'data/job_post_data.dart':               'features/jobs/data/job_post_data.dart',

    # ── REWARDS FEATURE ──
    'screens/rewards_screen.dart':           'features/rewards/screens/rewards_screen.dart',
    'screens/wallet_screen.dart':            'features/rewards/screens/wallet_screen.dart',
    'screens/offers_screen.dart':            'features/rewards/screens/offers_screen.dart',
    'screens/referral_screen.dart':          'features/rewards/screens/referral_screen.dart',
    'screens/membership_tiers_screen.dart':  'features/rewards/screens/membership_tiers_screen.dart',
    'screens/streaks_badges_screen.dart':    'features/rewards/screens/streaks_badges_screen.dart',
    'screens/reward_notifications_screen.dart': 'features/rewards/screens/reward_notifications_screen.dart',
    'models/rewards_model.dart':             'features/rewards/models/rewards_model.dart',
    'data/rewards_dummy_data.dart':          'features/rewards/data/rewards_dummy_data.dart',

    # ── NOTIFICATIONS FEATURE ──
    'screens/notifications_screen.dart':     'features/notifications/screens/notifications_screen.dart',

    # ── SETTINGS FEATURE ──
    'screens/settings_screen.dart':          'features/settings/screens/settings_screen.dart',
    'screens/help_support_screen.dart':      'features/settings/screens/help_support_screen.dart',
    'screens/privacy_policy_screen.dart':    'features/settings/screens/privacy_policy_screen.dart',
    'screens/terms_conditions_screen.dart':  'features/settings/screens/terms_conditions_screen.dart',
    'screens/about_app_screen.dart':         'features/settings/screens/about_app_screen.dart',
}

# Files to DELETE (dead code)
DELETE_FILES = [
    'utils/app_theme_backup.dart',
    'widgets/custom_search_bar.dart',
]

# ─────────────────────────────────────────────────────────
# IMPORT REWRITING MAP
# Maps old import segments to new import paths
# ─────────────────────────────────────────────────────────

def build_import_map():
    """Build mapping from old import path to new import path (package-relative)."""
    imap = {}
    for old_path, new_path in FILE_MAP.items():
        # skip the utils/app_theme.dart → core/theme/app_theme.dart merge
        # (both point to same target, we handle both old patterns)
        old_pkg = old_path  # e.g. 'utils/app_theme.dart'
        new_pkg = new_path  # e.g. 'core/theme/app_theme.dart'
        if old_pkg != new_pkg:
            imap[old_pkg] = new_pkg
    return imap

def compute_relative_import(from_file, to_file):
    """Compute relative import path from from_file to to_file (both relative to lib/)."""
    from_dir = os.path.dirname(from_file)
    rel = os.path.relpath(to_file, from_dir).replace('\\', '/')
    if not rel.startswith('.'):
        rel = './' + rel
    return rel

def rewrite_imports_in_file(filepath, new_rel_path, import_map):
    """Rewrite all local imports in a file from old paths to new paths."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    new_lines = []
    changed = False

    for line in lines:
        # Match import statements with relative paths
        m = re.match(r"^(import\s+')([^']+)(';\s*)$", line)
        if m:
            prefix = m.group(1)
            import_path = m.group(2)
            suffix = m.group(3)

            # Skip package/dart imports
            if import_path.startswith('package:') or import_path.startswith('dart:'):
                new_lines.append(line)
                continue

            # Resolve relative import to absolute (relative to lib/)
            from_dir = os.path.dirname(new_rel_path)
            resolved = os.path.normpath(os.path.join(from_dir, import_path)).replace('\\', '/')

            # Check if this resolved path matches any old path in our map
            new_target = import_map.get(resolved, None)
            if new_target is None:
                # Maybe it's already the new path
                if resolved in [v for v in FILE_MAP.values()]:
                    new_target = resolved
                else:
                    # Try direct match
                    new_target = resolved

            if new_target and new_target != resolved:
                # Compute new relative import
                new_rel_import = compute_relative_import(new_rel_path, new_target)
                new_line = f"{prefix}{new_rel_import}{suffix}"
                new_lines.append(new_line)
                changed = True
            else:
                # Path is already correct or unmapped, recompute relative anyway
                new_rel_import = compute_relative_import(new_rel_path, resolved)
                if new_rel_import != import_path:
                    new_line = f"{prefix}{new_rel_import}{suffix}"
                    new_lines.append(new_line)
                    changed = True
                else:
                    new_lines.append(line)
        else:
            new_lines.append(line)

    if changed:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(new_lines))

    return changed


def main():
    import_map = build_import_map()

    # Also add these shortcuts for common patterns where import uses '../'
    # We'll resolve them properly in the rewrite function

    print("=" * 60)
    print("STEP 1: Delete dead code")
    print("=" * 60)
    for f in DELETE_FILES:
        fp = os.path.join(BASE, f)
        if os.path.exists(fp):
            os.remove(fp)
            print(f"  DELETED: {f}")

    print()
    print("=" * 60)
    print("STEP 2: Create directory structure")
    print("=" * 60)
    dirs_needed = set()
    for new_path in FILE_MAP.values():
        d = os.path.dirname(new_path)
        if d:
            dirs_needed.add(d)
    for d in sorted(dirs_needed):
        full = os.path.join(BASE, d)
        os.makedirs(full, exist_ok=True)
        print(f"  DIR: {d}/")

    print()
    print("=" * 60)
    print("STEP 3: Move files to new locations")
    print("=" * 60)

    # Handle the special case: utils/app_theme.dart and core/theme/app_theme.dart point to same target
    # The real content is in utils/app_theme.dart. core/theme/app_theme.dart is just a re-export.
    # We keep utils/app_theme.dart content as the canonical file.

    moved = 0
    skipped = 0
    for old_path, new_path in FILE_MAP.items():
        old_full = os.path.join(BASE, old_path)
        new_full = os.path.join(BASE, new_path)

        if old_path == new_path:
            skipped += 1
            continue

        if not os.path.exists(old_full):
            # Source doesn't exist (maybe already moved or merged)
            continue

        if os.path.exists(new_full) and old_full != new_full:
            # Target already exists - check which is the real content file
            # For app_theme.dart: prefer utils/ version over core/theme/ re-export
            old_size = os.path.getsize(old_full)
            new_size = os.path.getsize(new_full)
            if old_size > new_size:
                # Old file has more content, overwrite
                shutil.move(old_full, new_full)
                print(f"  OVERWRITE: {old_path} -> {new_path}")
                moved += 1
            else:
                # Keep existing, just delete old
                os.remove(old_full)
                print(f"  REMOVED DUP: {old_path} (kept {new_path})")
        else:
            os.makedirs(os.path.dirname(new_full), exist_ok=True)
            shutil.move(old_full, new_full)
            print(f"  MOVED: {old_path} -> {new_path}")
            moved += 1

    print(f"\n  Moved: {moved}, Skipped (same path): {skipped}")

    print()
    print("=" * 60)
    print("STEP 4: Clean up empty directories")
    print("=" * 60)
    for dirpath, dirnames, filenames in os.walk(BASE, topdown=False):
        if not dirnames and not filenames:
            rel = os.path.relpath(dirpath, BASE)
            if rel != '.':
                os.rmdir(dirpath)
                print(f"  RMDIR: {rel}")

    print()
    print("=" * 60)
    print("STEP 5: Rewrite all imports")
    print("=" * 60)

    # Build full import map with all old->new mappings
    full_import_map = {}
    for old_path, new_path in FILE_MAP.items():
        if old_path != new_path:
            full_import_map[old_path] = new_path

    # Process every .dart file in the new structure
    rewrites = 0
    import_errors = []
    for root, dirs, files in os.walk(BASE):
        for fname in files:
            if not fname.endswith('.dart'):
                continue
            filepath = os.path.join(root, fname)
            rel_path = os.path.relpath(filepath, BASE).replace('\\', '/')
            try:
                if rewrite_imports_in_file(filepath, rel_path, full_import_map):
                    print(f"  REWROTE: {rel_path}")
                    rewrites += 1
            except Exception as e:
                import_errors.append((rel_path, str(e)))
                print(f"  ERROR: {rel_path}: {e}")

    print(f"\n  Files with import changes: {rewrites}")
    if import_errors:
        print(f"  Errors: {len(import_errors)}")
        for p, e in import_errors:
            print(f"    {p}: {e}")

    print()
    print("=" * 60)
    print("STEP 6: Verify structure")
    print("=" * 60)
    total = 0
    for root, dirs, files in os.walk(BASE):
        for fname in files:
            if fname.endswith('.dart'):
                total += 1
                rel = os.path.relpath(os.path.join(root, fname), BASE).replace('\\', '/')

    print(f"  Total .dart files: {total}")
    print()
    print("RESTRUCTURING COMPLETE!")
    print("Run 'flutter analyze' to verify.")

if __name__ == '__main__':
    main()
