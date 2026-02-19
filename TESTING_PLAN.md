# Attendrr Testing Plan (Aligned to Presentation Testing Section)

## Source Alignment
This plan is aligned to `Presentation.pdf` testing content:
- Page 11: requirement-based TDD and test levels
- Page 12: functional/non-functional requirement mapping
- Page 14: controlled testing environment with stubs/drivers
- Page 15: white-box and black-box techniques
- Page 16: positive, negative, critical, and wider-scope testing

## Test Strategy
- Requirement-based TDD: each requirement maps to test files.
- Majority unit-first policy: core logic is validated primarily at unit level.
- Functional testing: UI behavior as black-box checks.
- Integration/system/acceptance: end-to-end behavior, security, and runtime device capability.

## Test Distribution (Unit Majority)
- Unit test files: **14**
- Widget/functional test files: **8**
- Integration/system/acceptance test files: **3**
- Total test files: **25**
- Unit proportion: **56%** (majority)

## Testing Environment (Controlled)
- Framework/runtime:
  - Flutter test runner (`flutter test`)
  - Flutter integration test (`integration_test`)
- Isolation controls:
  - Mock providers for auth/profile/check-in/timetable/friends
  - `SharedPreferences.setMockInitialValues({})` for deterministic local storage
  - `.env.test` gated integration tests for Supabase credentials
- Driver/module/stub pattern:
  - Driver: test harness in each `test`/`integration_test` file
  - Module under test: utility/model/provider/page logic
  - Stubs/mocks: provider doubles and fake auth/user data
- Determinism controls:
  - Fixed DateTime values for timing/points windows
  - Explicit boundary timestamps (`:00`, `:05`, `:15`, end+1s, etc.)
  - Controlled location and account states in integration/system tests

## White-Box vs Black-Box Definition
- White-box: branch/condition/data-flow focused tests derived from internals.
- Black-box: input/output and behavior tests from observable outcomes.

## Existing Test Files and Classification

| File | Level | Type | Main Coverage |
|---|---|---|---|
| `test/unit/checkin_checkout_test.dart` | Unit | White-box | auto checkout timing logic |
| `test/unit/checkin_refresh_test.dart` | Unit | White-box | refresh scheduling logic |
| `test/unit/checkin_rules_test.dart` | Unit | Mixed (mostly white-box) | check-in window and points |
| `test/unit/leaderboard_defaults_test.dart` | Unit | White-box | provider default state |
| `test/unit/location_lookup_test.dart` | Unit | Mixed | alias resolution and iCal mapping |
| `test/unit/models_test.dart` | Unit | White-box | model parsing and derived state |
| `test/unit/points_boost_test.dart` | Unit | White-box | boost condition branches |
| `test/unit/streak_evaluation_test.dart` | Unit | White-box | parsing/default/flag logic |
| `test/unit/white_box_checkin_rules_test.dart` | Unit | White-box explicit | branch + condition coverage |
| `test/unit/black_box_checkin_rules_test.dart` | Unit | Black-box explicit | equivalence partition + boundaries |
| `test/unit/performance_core_logic_test.dart` | Unit | White-box critical/performance | perf regression guards on core logic |
| `test/unit/checkin_rules_invalid_boundary_test.dart` | Unit | White-box negative/boundary | invalid and edge timing/distance inputs |
| `test/unit/checkin_refresh_boundary_invalid_test.dart` | Unit | White-box boundary | refresh border times (`:15:01`, `:59:59`) |
| `test/unit/location_lookup_invalid_input_test.dart` | Unit | Black-box negative | null/empty/symbol/unknown location inputs |
| `test/widget/auth_test.dart` | Functional | Black-box | login form behavior |
| `test/widget/checkin_page_test.dart` | Functional | Black-box | check-in UI transitions |
| `test/widget/leaderboard_entry_tile_test.dart` | Functional | Black-box | leaderboard tile layout contract |
| `test/widget/navigation_test.dart` | Functional | Black-box | route navigation |
| `test/widget/podium_widget_test.dart` | Functional | Black-box | podium layout resilience |
| `test/widget/profile_page_test.dart` | Functional | Black-box | profile coin display |
| `test/widget/settings_page_test.dart` | Functional | Black-box | settings actions and dialogs |
| `test/widget/timetable_page_test.dart` | Functional | Black-box | timetable interactions |
| `test/integration/security_test.dart` | Integration | Black-box | auth + RLS policy behavior |
| `integration_test/location_permission_test.dart` | System/Integration | Black-box | runtime location retrieval |
| `integration_test/settings_actions_test.dart` | System/Acceptance | Black-box | settings user journey |

## Non-Project Artifacts (Exclude from Coverage Counts)
- `ios/RunnerTests/RunnerTests.swift`
- `macos/RunnerTests/RunnerTests.swift`
- files in `Pods/`, `build/`, `doc/`

## Requirement Coverage Snapshot

### Functional Requirements
- User Authentication:
  - `test/widget/auth_test.dart`
  - `test/integration/security_test.dart`
- Lecture Check-In:
  - `test/unit/checkin_rules_test.dart`
  - `test/unit/white_box_checkin_rules_test.dart`
  - `test/unit/black_box_checkin_rules_test.dart`
  - `test/unit/checkin_rules_invalid_boundary_test.dart`
  - `test/widget/checkin_page_test.dart`
- Peer-Network/Leaderboard:
  - `test/unit/leaderboard_defaults_test.dart`
  - `test/widget/leaderboard_entry_tile_test.dart`
  - `test/widget/podium_widget_test.dart`

### Non-Functional Requirements
- Performance:
  - `test/unit/performance_core_logic_test.dart` (critical-path regression guards)
- Accuracy:
  - check-in scoring/window tests + model parsing tests in unit suite
- Security:
  - `test/integration/security_test.dart` (RLS/auth)
- Accessibility:
  - partial coverage via widget behavior tests; dedicated a11y assertions still pending

## Additional Changes Implemented
- `lib/utils/checkin_rules.dart`
  - `canCheckInNow` now rejects negative distance values.
  - `calculateCheckInPoints` now returns `0` for non-positive lecture duration before applying early max-points branch.

## What Is Still Pending (Optional but Recommended)
- Dedicated accessibility assertions (semantics labels, focus order, color contrast checks).
- Load/stress tests for backend-attached flows beyond current unit performance guards.

## Execution Commands
- Unit tests (majority suite): `flutter test test/unit`
- Full unit + widget suite: `flutter test test`
- Security integration: `flutter test test/integration/security_test.dart`
- Device/system tests: `flutter test integration_test`
