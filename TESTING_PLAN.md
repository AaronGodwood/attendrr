# Attendrr Testing Plan (Lecture-Aligned)

## 1. Requirement-Based TDD Context
As for our testing, we knew it was essential to look at the wider scope of the project before we established any tests in line with TDD. We reviewed requirements derived from stakeholder engagement, and used these to decide which tests should be created and what coverage was needed.

Following on from our requirement-based TDD, we planned 5 key testing levels:
- Unit Testing
- Functional Testing
- Integration Testing
- System Testing
- Acceptance Testing

This gives a concrete foundation to map requirements to tests.

## 2. Test Levels at a Glance
| Level | Lecture classification | Primary goal | Main location | Representative files |
|---|---|---|---|---|
| Unit | White-box | Verify smallest components/logic branches | `test/unit/` | `test/unit/checkin_rules_test.dart`, `test/unit/white_box_checkin_rules_test.dart`, `test/unit/providers_services_repositories_test.dart` |
| Functional | Black-box | Verify page/component interface behavior | `test/functional/` | `test/functional/auth_test.dart`, `test/functional/checkin_page_test.dart`, `test/functional/navigation_test.dart` |
| Integration | Black-box | Verify module interactions (Flutter <-> Supabase) | `test/integration/` | `test/integration/security_test.dart` |
| System | Black-box | Verify whole app in controlled environment | `integration_test/system/` | `integration_test/system/location_permission_system_test.dart` |
| Acceptance | Black-box | Verify end-user journeys against acceptance intent | `integration_test/acceptance/` | `integration_test/acceptance/core_navigation_acceptance_test.dart`, `integration_test/acceptance/settings_actions_acceptance_test.dart` |

## 3. Test Level Definitions
- Unit Testing -> white-box, verifies the smallest component.
- Functional Testing -> black-box, tests interface behavior of a component/page.
- Integration Testing -> black-box, tests module interactions (e.g., Flutter <-> Supabase).
- System Testing -> black-box validation of the whole app in a controlled environment.
- Acceptance Testing -> black-box validation of key user journeys (proxy acceptance in this project).

Verification levels in this plan:
- Unit, Functional, Integration

Validation levels in this plan:
- Integration, System, Acceptance (proxy)

Why this matters:
- This uses the same test-level model from lectures, while keeping wording practical for day-to-day development.

## 4. Directory Organization
- `test/unit/` -> Unit tests
- `test/functional/` -> Functional tests
- `test/integration/` -> Integration tests
- `integration_test/system/` -> System tests
- `integration_test/acceptance/` -> Acceptance tests

Why there is a separate `integration_test/` folder:
- `test/` is for fast local test runner execution (unit/functional/integration checks that can run in test harness mode).
- `integration_test/` is reserved for full-app runtime tests that are executed on a simulator/device, where platform/runtime services (navigation stack, permissions, plugin/platform channels) are exercised end-to-end.

## 5. Testing Environment
The environment provides the software under test what it needs to run. It is stabilised to make tests repeatable and to allow expected and unexpected behavior to be tested in a controlled way.

Environment controls used:
- Consistent time/input values (fixed `DateTime` in many tests)
- Mocked local storage (`SharedPreferences.setMockInitialValues({})`)
- Mock providers for auth/profile/timetable/check-in/friends
- `.env.test` gates for external integration credentials (Supabase)

Driver/stub examples:
- Drivers: test harnesses in each test file execute the module under test.
- Stubs/mocks: provider doubles with same interfaces return pre-programmed values.
- Example files using drivers/stubs:
  - `test/functional/navigation_test.dart`
  - `test/functional/checkin_page_test.dart`
  - `integration_test/acceptance/core_navigation_acceptance_test.dart`

## 6. Unit Strategy: Top-Down
Our unit testing approach is top-down in intent: higher-level logic is tested first, then smaller subcomponents and boundary cases.

Top-down examples:
- Higher-level logic: `test/unit/providers_services_repositories_test.dart`
- Mid-level rule logic: `test/unit/checkin_rules_test.dart`, `test/unit/white_box_checkin_rules_test.dart`
- Low-level boundaries/negative cases: `test/unit/checkin_rules_invalid_boundary_test.dart`, `test/unit/checkin_refresh_boundary_invalid_test.dart`, `test/unit/location_lookup_invalid_input_test.dart`

Three stages used per test case:
| Stage | What we do | Example |
|---|---|---|
| Setting inputs | Prepare deterministic inputs/mock/session state | Fixed `DateTime`, IDs, mock SharedPreferences |
| Running software | Execute the unit under realistic branch conditions | Call provider/repository/rule methods |
| Checking outputs | Verify expected outcomes | `expect(...)` on return values, states, errors, and branch behavior |

## 7. Evidence of Required Techniques

### 7.1 Acceptance Testing
Evidence:
- `integration_test/acceptance/core_navigation_acceptance_test.dart`
- `integration_test/acceptance/settings_actions_acceptance_test.dart`
- Acceptance coverage includes a core authenticated navigation journey and account settings actions.

Note:
- This is acceptance-proxy automation (team-defined acceptance path). Formal stakeholder UAT can be added separately.

### 7.2 System Testing
Evidence:
- `integration_test/system/location_permission_system_test.dart`
- Tests whole-app behavior with runtime location service in controlled simulator/device setup.

### 7.3 Equivalence Partition Testing
Evidence:
- `test/unit/black_box_checkin_rules_test.dart`
- Partitions include:
  - valid time + valid distance -> allow
  - valid time + invalid distance -> reject
  - out-of-window timing -> reject

### 7.4 Branch Testing
Evidence:
- `test/unit/white_box_checkin_rules_test.dart`
- Branches covered in `canCheckInNow`:
  - null lecture
  - outside check-in window
  - no coordinates path
  - missing distance path
  - distance threshold pass/fail

### 7.5 Critical Cases
Evidence:
- `test/unit/performance_core_logic_test.dart`
- Critical-path runtime guards for:
  - `calculateCheckInPoints`
  - `canCheckInNow`
  - `LocationLookup.resolve`

### 7.6 Negative Test Cases
Evidence:
- `test/unit/checkin_rules_invalid_boundary_test.dart`
- `test/unit/checkin_refresh_boundary_invalid_test.dart`
- `test/unit/location_lookup_invalid_input_test.dart`
- `test/integration/security_test.dart`
- Negative/border examples include invalid duration, invalid timing, negative distance, null/empty/symbol-only location input, and unauthenticated access rejection.

### 7.7 Coverage Reached
Current automated suite inventory:
- 31 test files
- 105 test cases (`test` + `testWidgets`)
- Unit tests are majority:
  - Unit files: 17
  - Functional files: 10
  - Integration files: 1
  - System files: 1
  - Acceptance files: 2
  - Unit proportion: 54.8%

Latest run evidence:
- `flutter test --coverage` -> pass
- Unfiltered line coverage (`DA` records): `63.75%` (`3072/4819`)
- `flutter test test` -> pass
- `flutter test integration_test/acceptance/core_navigation_acceptance_test.dart` -> pass
- System test (`integration_test/system/location_permission_system_test.dart`) is environment-dependent on simulator/device location permission and mocked/available GPS state.

## 8. Requirement-Based Tests, Partitioning, Boundaries (Lecture Notes Applied)
Requirements-based tests:
- Specification-derived tests are used to map requirement statements to test cases.
- Example mapping:
  - Authentication requirement -> `test/functional/auth_test.dart`, `test/integration/security_test.dart`
  - Check-in requirement -> `test/unit/checkin_rules_test.dart`, `test/functional/checkin_page_test.dart`
  - Leaderboard/profile requirement -> `test/unit/leaderboard_defaults_test.dart`, `test/functional/leaderboard_entry_tile_test.dart`, `test/functional/profile_page_test.dart`

Equivalence partitioning tests:
- Inputs/outputs split into equivalent groups; each case targets a partition.
- Example: `test/unit/black_box_checkin_rules_test.dart`.

Boundary value tests:
- Cases designed at/around boundaries where defects are likely.
- Examples:
  - `test/unit/black_box_checkin_rules_test.dart` (window start/end +/- 1s)
  - `test/unit/checkin_refresh_boundary_invalid_test.dart` (`:15:01`, `:59:59`, exact `:00:00`)
  - `test/unit/checkin_rules_invalid_boundary_test.dart`

Condition testing and internal boundary testing evidence:
- Condition-focused behavior in `test/unit/white_box_checkin_rules_test.dart` (boolean gates).
- Internal boundary behavior in scoring/time-window tests under `test/unit/checkin_rules_test.dart` and boundary suites above.

## 9. Integration and System Strategy
System and integration testing come after unit-tested modules, so integration errors are typically interaction errors.

Current integration/system approach:
- Integration tests validate module interactions (e.g., app <-> Supabase auth/RLS) in `test/integration/security_test.dart`.
- System test validates whole-app behavior with external runtime dependency (location) in `integration_test/system/location_permission_system_test.dart`.
- Acceptance-proxy tests validate end-user journeys in `integration_test/acceptance/core_navigation_acceptance_test.dart` and `integration_test/acceptance/settings_actions_acceptance_test.dart`.

Top-down vs bottom-up note:
- Top-down integration requires stubs for called modules.
- Bottom-up integration requires drivers for invoking modules.
- This suite currently uses a top-down leaning approach in functional/acceptance tests via provider stubs.

## 10. Completion Criteria (When Code Is Fully Tested)
Code is considered fully tested for a release candidate when:
- All defined test cases pass.
- Any failing or incorrect test case is fixed and re-run.
- All affected tests are maintained and re-executed for the latest code version.
- All changes are covered by appropriate test levels (unit first, then higher levels as needed).

## 11. Iteration Workflow Used
During each development iteration we followed a clear testing cycle:
- Before development: tester in each pair designs requirement-based tests (TDD-first intent).
- During development: developer implements against tests and updates tests for new branches/boundaries.
- After development: suite is re-run and failures resolved before merge.

## 12. Test File Inventory

### Unit (`test/unit`)
- `test/unit/checkin_checkout_test.dart`
- `test/unit/checkin_refresh_test.dart`
- `test/unit/checkin_rules_test.dart`
- `test/unit/location_lookup_test.dart`
- `test/unit/models_test.dart`
- `test/unit/white_box_checkin_rules_test.dart`
- `test/unit/black_box_checkin_rules_test.dart`
- `test/unit/performance_core_logic_test.dart`
- `test/unit/checkin_rules_invalid_boundary_test.dart`
- `test/unit/checkin_refresh_boundary_invalid_test.dart`
- `test/unit/location_lookup_invalid_input_test.dart`
- `test/unit/leaderboard_defaults_test.dart`
- `test/unit/points_boost_test.dart`
- `test/unit/streak_evaluation_test.dart`
- `test/unit/models_comprehensive_test.dart`
- `test/unit/theme_and_shop_repository_test.dart`
- `test/unit/providers_services_repositories_test.dart`

### Functional (`test/functional`)
- `test/functional/auth_test.dart`
- `test/functional/checkin_page_test.dart`
- `test/functional/leaderboard_entry_tile_test.dart`
- `test/functional/navigation_test.dart`
- `test/functional/podium_widget_test.dart`
- `test/functional/timetable_page_test.dart`
- `test/functional/profile_page_test.dart`
- `test/functional/settings_page_test.dart`
- `test/functional/auth_and_shop_pages_test.dart`
- `test/functional/ui_components_test.dart`

### Integration (`test/integration`)
- `test/integration/security_test.dart`

### System (`integration_test/system`)
- `integration_test/system/location_permission_system_test.dart`

### Acceptance (`integration_test/acceptance`)
- `integration_test/acceptance/core_navigation_acceptance_test.dart`
- `integration_test/acceptance/settings_actions_acceptance_test.dart`

## 13. Commands
- Unit: `flutter test test/unit`
- Functional: `flutter test test/functional`
- Integration: `flutter test test/integration`
- Acceptance: `flutter test integration_test/acceptance`
- System: `flutter test integration_test/system`
- Full local suite: `flutter test test && flutter test integration_test`
- Coverage data (lcov): `flutter test --coverage`
- Coverage HTML (single command): `./scripts/generate_coverage_report.sh`
- Coverage HTML (manual steps):
  - `flutter test --coverage`
  - `python3 scripts/augment_lcov_functions.py --in coverage/lcov.info --out coverage/lcov.info --root .`
  - `genhtml --ignore-errors category coverage/lcov.info -o coverage/html`
