# Terra Scholar — Design System Implementation Guide

## Overview

This document defines the complete design system for the Lecture Tracker app, codenamed **Terra Scholar**. It is intended as a direct implementation guide — follow it precisely when restyling the app.

The app is a Flutter mobile application for university students (18–22) that gamifies lecture attendance tracking with streaks, points, tiers, and leaderboards. The design should feel **warm, gamified, and rewarding** — like a candlelit library that celebrates your progress.

**Design personality:** Warm earth tones meet gamified learning. Cozy but motivating. Academic but modern.

**Key inspirations:** Duolingo (gamification and delight), Spotify Wrapped (gradient text, data storytelling), Headspace (warmth, approachability).

---

## 1. Color System

All colors should be defined as a centralized theme using Flutter's `ThemeData` and `ColorScheme`, extended with custom semantic colors via a `ThemeExtension`. Dark mode is the **default**. Both themes share the same hue family but shift in lightness and saturation.

### 1.1 Dark Theme (Default)

```
Background (scaffold):    #1A1714  — Deep warm charcoal, never cold grey
Surface (cards):          #252118  — Slightly lighter, warm brown undertone
Surface variant:          #302A22  — For elevated cards, dialogs, bottom sheets
Surface tint:             #3A322A  — For hover/pressed states on surfaces

Primary:                  #C67B4E  — Terracotta — CTAs, active states, primary buttons
Primary light:            #E8A87C  — Lighter terracotta — highlights, selected states
Primary container:        #3D2A1E  — Dark terracotta — chip backgrounds, subtle fills

Secondary:                #7A9A6D  — Sage green — success, streaks, points, check marks
Secondary light:          #A3C496  — Light sage — progress bars, positive text
Secondary container:      #1E2E1A  — Dark sage — success card backgrounds

Accent:                   #E8D5B7  — Warm cream — badges, special highlights, tier labels
Accent muted:             #B8A898  — Muted sand — secondary text, timestamps

Text primary:             #F2EAE0  — Warm off-white — main readable text
Text secondary:           #9B8E80  — Warm grey — subtitles, labels, captions
Text disabled:            #5C544B  — Faded — disabled states, placeholders

Danger:                   #C45C4A  — Warm red — errors, missed lectures, destructive actions
Danger container:         #3A1F1A  — Dark red — error card backgrounds

Warning:                  #D4A24E  — Amber — warnings, approaching deadlines
Warning container:        #3A2E1A  — Dark amber — warning card backgrounds

Outline:                  #3D362E  — Subtle borders on cards
Outline variant:          #4A4238  — Slightly more visible borders
```

### 1.2 Light Theme

```
Background (scaffold):    #FAF6F1  — Warm cream-white, never pure white
Surface (cards):          #FFFFFF  — White cards on cream background
Surface variant:          #F0EAE2  — Slightly warm off-white for sections
Surface tint:             #E8E0D6  — Hover/pressed states

Primary:                  #B5693E  — Slightly deeper terracotta for contrast on light
Primary light:            #C67B4E  — Same as dark primary, used for fills
Primary container:        #FCEADD  — Very light terracotta tint

Secondary:                #5E8352  — Deeper sage for contrast on light
Secondary light:          #7A9A6D  — Same as dark secondary
Secondary container:      #E6F0E2  — Very light sage tint

Accent:                   #8B7355  — Warm brown — for badges/labels on light bg
Accent muted:             #A09080  — Muted warm — secondary text

Text primary:             #1A1714  — Dark warm charcoal (inverted from dark bg)
Text secondary:           #6B5F53  — Warm medium brown
Text disabled:            #B0A89E  — Faded warm

Danger:                   #B84A38  — Warm red
Danger container:         #FCEAE6  — Light red tint

Warning:                  #B8862A  — Amber
Warning container:        #FFF3DC  — Light amber tint

Outline:                  #DDD5CB  — Subtle warm borders
Outline variant:          #C8BEB2  — More visible borders
```

### 1.3 Gradient Definitions

Gradients are used for **key motivational numbers only** — points, streaks, tier progress. Never overuse them.

```
Streak gradient:          LinearGradient(135°, #C67B4E → #E8A87C → #F0C27F)
Points gradient:          LinearGradient(135°, #7A9A6D → #A3C496)
Tier/rank gradient:       LinearGradient(135°, #E8D5B7 → #C67B4E)
Check-in success:         LinearGradient(180°, #7A9A6D → #5E8352)

Light mode adjustments:
Streak gradient:          LinearGradient(135°, #B5693E → #C67B4E → #D4955E)
Points gradient:          LinearGradient(135°, #5E8352 → #7A9A6D)
```

Use `ShaderMask` with `BlendMode.srcIn` for gradient text in Flutter.

### 1.4 Module Colors

Lecture/module cards need distinct colors. Use this earthy palette that complements the theme:

```
Module palette (use for lecture card left-borders and module code chips):
  #C67B4E  — Terracotta
  #7A9A6D  — Sage
  #7B8EAA  — Dusty blue
  #AA7EA8  — Muted plum
  #C4956A  — Warm tan
  #6B9B9B  — Teal sage
  #B8845E  — Copper
  #8B9A6D  — Olive sage
```

---

## 2. Typography

### 2.1 Font Families

```
Display / Headings:   Fraunces  (Google Fonts — optical size serif)
Body / UI:            DM Sans   (Google Fonts — clean geometric sans)
Mono / Code:          JetBrains Mono  (if ever needed)
```

Add to `pubspec.yaml` via `google_fonts` package or bundle the font files.

### 2.2 Type Scale

All sizes in logical pixels. Weights reference Fraunces variable font (400–900) and DM Sans (400–700).

```
Display Large:    Fraunces  36px  w800  — Splash screen title
Display Medium:   Fraunces  32px  w800  — Big numbers (streak count, points total)
Display Small:    Fraunces  28px  w700  — Page titles when emphasised

Headline Large:   Fraunces  24px  w700  — Section headers (e.g., "No Lecture Right Now")
Headline Medium:  Fraunces  20px  w700  — Card titles, dialog titles
Headline Small:   Fraunces  18px  w600  — Sub-section headers

Title Large:      DM Sans   18px  w700  — List item titles, lecture names
Title Medium:     DM Sans   16px  w600  — Button text, tab labels
Title Small:      DM Sans   14px  w600  — Chip text, small titles

Body Large:       DM Sans   16px  w400  — Primary body text
Body Medium:      DM Sans   14px  w400  — Secondary body text, descriptions
Body Small:       DM Sans   12px  w400  — Captions, timestamps, metadata

Label Large:      DM Sans   14px  w700  — Button labels
Label Medium:     DM Sans   12px  w600  — Badges, tags, small labels
Label Small:      DM Sans   10px  w500  — Tiny annotations
```

### 2.3 Usage Rules

- **Fraunces** is ONLY for headings, big numbers, and display moments. Never use it for body text or UI labels.
- **Gradient text** is ONLY for key motivational numbers: streak count, points earned, tier name on profile. Use `ShaderMask`.
- Letter spacing: Fraunces at -0.5 for large display, DM Sans at 0 for body, +0.5 for all-caps labels.
- Line height: 1.2 for headings, 1.5 for body text.

---

## 3. Shape & Spacing

### 3.1 Border Radius

```
Cards / Containers:    16px  — Main content cards, dialogs
Buttons (large):       14px  — Primary CTAs, check-in button
Buttons (small):       10px  — Text buttons, outline buttons
Chips / Badges:        20px  — Pill-shaped, fully rounded
Input fields:          12px  — Text fields, search bars
Bottom sheets:         24px  (top-left, top-right only)
Module code chips:     6px   — Compact, slightly rounded
Avatar:                Full circle
```

### 3.2 Spacing Scale

Use multiples of 4, with standard stops:

```
4px   — Tight internal gaps (icon to text in a row)
8px   — Small gaps (between label and value)
12px  — Medium-small (between related items in a card)
16px  — Standard padding (card internal padding, list item padding)
20px  — Medium-large (between card sections)
24px  — Section gaps (between cards in a scroll view)
32px  — Large section gaps (between major page sections)
48px  — Extra large (top of page content, splash spacing)
```

### 3.3 Card Styling

Cards are the primary content containers. They should feel **warm and slightly elevated**, not flat.

```
Dark mode card:
  Background:     Surface color (#252118)
  Border:         1px solid Outline (#3D362E)
  Border radius:  16px
  Padding:        16px
  Shadow:         BoxShadow(color: #000000 @ 15% opacity, blurRadius: 8, offset: 0,2)

Light mode card:
  Background:     #FFFFFF
  Border:         1px solid Outline (#DDD5CB)
  Border radius:  16px
  Padding:        16px
  Shadow:         BoxShadow(color: #1A1714 @ 8% opacity, blurRadius: 12, offset: 0,4)

Lecture cards specifically:
  Same as above, but add a 3px left border in the module's assigned color.
  This left-border accent is a key visual signature of the app.

Elevated/highlighted cards (e.g., streak card, check-in prompt):
  Add a subtle gradient border or use the Primary Container fill.
```

---

## 4. Component Specifications

### 4.1 Bottom Navigation Bar

```
Dark:
  Background:     #1A1714 (same as scaffold, blends seamlessly)
  Selected icon:  Primary (#C67B4E)
  Selected label: Primary (#C67B4E)
  Unselected:     Text secondary (#9B8E80)
  Indicator:      Primary container (#3D2A1E) as a rounded pill behind selected icon

Light:
  Background:     #FFFFFF
  Selected icon:  Primary (#B5693E)
  Selected label: Primary (#B5693E)
  Unselected:     Text secondary (#6B5F53)
  Indicator:      Primary container (#FCEADD)

Type: Fixed (4 items)
Elevation: 0 (use a top border instead: 1px Outline color)
Label style: Label Small (DM Sans 10px w500)
Icon size: 24px
```

### 4.2 App Bar

```
Dark:
  Background:     Transparent / scaffold color (no elevation)
  Title:          Fraunces Headline Medium (20px w700), Text primary
  Icon buttons:   Text secondary (#9B8E80), 24px

Light:
  Background:     Transparent / scaffold color
  Title:          Fraunces Headline Medium, Text primary
  Icon buttons:   Text secondary

Elevation: 0 always. Use a bottom border (1px Outline) only when scroll content is behind it.
Center title: false (left-aligned)
```

### 4.3 Buttons

**Primary Button (Check-in, Sign In, main CTAs):**
```
Background:       Primary (#C67B4E)
Text:             White (#FFFFFF), DM Sans 16px w700
Border radius:    14px
Height:           56px (standard), 60px (check-in emphasis)
Pressed:          Primary darkened 10%
Disabled:         Surface variant (#302A22), Text disabled (#5C544B)
Shadow:           Subtle, 4px blur, primary color @ 20% opacity

When representing points (e.g., "Check In (15 pts)"):
  Background:     Gradient (Streak gradient) instead of solid primary
```

**Secondary / Outline Button:**
```
Background:       Transparent
Border:           1.5px solid Outline variant (#4A4238)
Text:             Text primary, DM Sans 14px w600
Border radius:    12px
Pressed:          Surface variant fill
```

**Destructive Button (End Session, Sign Out):**
```
Background:       Transparent
Border:           1.5px solid Danger (#C45C4A)
Text:             Danger (#C45C4A), DM Sans 14px w600
Border radius:    12px
```

**Text Button:**
```
No background or border.
Text:             Primary (#C67B4E), DM Sans 14px w600
Pressed:          Primary container fill as splash
```

### 4.4 Input Fields

```
Dark:
  Fill:           Surface (#252118)
  Border:         1.5px solid Outline (#3D362E)
  Focused border: 2px solid Primary (#C67B4E)
  Text:           Text primary (#F2EAE0)
  Label/Hint:     Text secondary (#9B8E80)
  Prefix icon:    Text secondary (#9B8E80)
  Error border:   Danger (#C45C4A)
  Error text:     Danger (#C45C4A)
  Border radius:  12px

Light:
  Fill:           #FFFFFF
  Border:         1.5px solid Outline (#DDD5CB)
  Focused border: 2px solid Primary (#B5693E)
  Text:           Text primary (#1A1714)
  Label/Hint:     Text secondary (#6B5F53)
```

### 4.5 Dialogs & Bottom Sheets

```
Dark:
  Background:     Surface variant (#302A22)
  Border radius:  24px (bottom sheets top corners), 20px (dialogs)
  Title:          Fraunces Headline Medium
  Body:           DM Sans Body Medium
  Scrim:          #000000 @ 50% opacity

Light:
  Background:     #FFFFFF
  Scrim:          #1A1714 @ 30% opacity
```

### 4.6 Chips & Badges

**Module Code Chip (on lecture cards):**
```
Background:       Module's assigned color
Text:             White, DM Sans Label Medium (12px w600)
Border radius:    6px
Padding:          horizontal 8px, vertical 4px
```

**Tier Badge (on profile):**
```
Background:       Primary container (#3D2A1E)
Text:             Primary light (#E8A87C), DM Sans Label Medium
Border radius:    20px (pill)
Padding:          horizontal 12px, vertical 4px
```

**Status Badges (attended/missed):**
```
Attended:         Secondary container bg, Secondary text, check icon
Missed:           Danger container bg, Danger text, X icon
```

### 4.7 Tab Bar

```
Dark:
  Background:       Transparent
  Selected tab:     Primary (#C67B4E) text, 2px Primary underline
  Unselected tab:   Text secondary (#9B8E80)
  Indicator:        2px thick, Primary color, rounded ends

Light:
  Selected tab:     Primary (#B5693E), 2px underline
  Unselected tab:   Text secondary

Font:   DM Sans Title Medium (16px w600)
```

### 4.8 Segmented Button (Leaderboard toggle)

```
Dark:
  Selected segment:     Primary (#C67B4E) fill, White text
  Unselected segment:   Surface (#252118) fill, Text secondary
  Border:               Outline (#3D362E)
  Border radius:        10px

Light:
  Selected segment:     Primary (#B5693E) fill, White text
  Unselected segment:   Surface variant fill, Text secondary
```

---

## 5. Screen-by-Screen Specifications

### 5.1 Splash Page

- Full-screen gradient background: `LinearGradient(topCenter → bottomCenter, #C67B4E → #1A1714)`
- App icon: White rounded square (30px radius) with school icon in Primary color
- Title: "Lecture Tracker" — Fraunces Display Large (36px w800), white
- Subtitle: "Track your attendance, build your streak" — DM Sans Body Medium, white @ 80%
- Loading indicator: Circular, white, thin stroke (2px)
- **Light mode:** Same gradient, it's a branded screen

### 5.2 Login Page

- Scaffold background, no app bar
- "Welcome Back" — Fraunces Display Small (28px w700)
- Subtitle — DM Sans Body Large, Text secondary
- Error banner: Danger container bg, Danger text, rounded 12px, left border 3px Danger
- Input fields per spec 4.4
- "Sign In" button: Primary button per spec 4.3, full width
- Divider with "Or continue with" — DM Sans Body Small, Text secondary
- Google button: Outline button with Google logo
- "Don't have an account? Sign Up" — Body Medium + Text Button

### 5.3 Sign Up Page

- Same layout language as Login
- "Create Account" — Fraunces Display Small
- Password strength bar: use Streak gradient colors (red → orange → green)
- Terms checkbox: standard with Primary accent
- Verification dialog: use Fraunces for "Verify Your Email" title

### 5.4 Forgot Password Page

- Lock icon in Primary container circle
- "Forgot Password?" — Fraunces Display Small, centered
- Success state: Green check circle, "Check Your Email" — Fraunces

### 5.5 Home Page (Shell with Bottom Nav)

- Bottom nav per spec 4.1
- **Tab icons suggestion:**
  - Timetable: `Icons.calendar_today`
  - Check In: `Icons.location_on`
  - Friends: `Icons.people` (changed from leaderboard to feel more social)
  - Profile: `Icons.person`
- Smooth fade transition between tab pages (not instant swap)

### 5.6 Timetable Page

**App bar:**
- Month/year in Fraunces Headline Medium
- "Today" button with Primary tint

**Day selector:**
- Horizontal strip, warm surface background
- Selected day: Primary fill, white text, rounded pill (22px radius)
- Today (not selected): Primary container fill, Primary text
- Other days: Transparent, Text secondary
- Day name: DM Sans 11px w600
- Day number: DM Sans 16px w700
- Left/right arrows: Text secondary icons
- **Day transition animation:** Slide in from direction of navigation (left/right)

**Timeline view:**
- Hour labels: DM Sans Body Small (12px), Text secondary, right-aligned in 60px column
- Hour lines: 1px Outline color
- Current time indicator: Danger (red) dot + line — same as current but using theme danger color
- **Lecture blocks — this is a key visual moment:**
  - Background: Module's color @ 12% opacity (light) or custom dark shade (dark)
  - Left border: 3px solid module's color (accent stripe — signature element)
  - Border radius: 10px
  - Module code: DM Sans 12px w700
  - Title: DM Sans 12px w400
  - Location row: Icon 11px + DM Sans 11px, muted color
  - Attended: Green check icon, green-tinted background
  - Missed: Red X icon, red-tinted background
  - In progress: Primary-tinted, slightly brighter

**Empty states:**
- Illustration-style icon (large, 64px, Text disabled color)
- Message in DM Sans Body Large
- Suggestion in DM Sans Body Medium, Text secondary

### 5.7 Check-In Page

This is the **hero screen** — it should feel exciting and rewarding.

**App bar:** "Check In" in Fraunces, refresh button

**Loading state:** Skeleton shimmer with warm surface colors (not grey)

**No lecture state:**
- Large calendar icon, Text disabled
- "No Lecture Right Now" — Fraunces Headline Large
- Next lecture card with module left-border accent
- "Starts in X" — DM Sans Title Large, Primary color
- Time until next uses count-down feel

**Ready to check in:**
- Lecture card with left-border accent
- Location status banner:
  - Verified: Secondary container bg, secondary icon + text
  - Too far: Warning container bg, warning icon + text
  - No coordinates: Warning container bg, info text
- Window status banner: Primary container bg if not yet open
- **Check-in button (star of the show):**
  - Full width, 60px height
  - When ready: Gradient background (Streak gradient), white text
  - Text: "Check In (15 pts)" — DM Sans 18px w700
  - **Subtle pulse/glow animation** when check-in is available — the button should feel alive
  - When disabled: Surface variant, Text disabled
- Points display above button: Fraunces Display Medium, gradient text via ShaderMask

**Checking in state:**
- Centered loading with Primary-colored spinner
- "Checking in..." — DM Sans Title Medium

**Checked in (success) state:**
- Large green check icon (80px) — use Secondary color, not raw green
- "Checked In!" — Fraunces Display Small
- Points: "+15 points" — Fraunces Display Medium, gradient text (Points gradient)
- **Number count-up animation** on the points
- Lecture card below
- Time remaining: Fraunces Display Medium in Primary color, inside a Primary container card
- "End Session Early" — Destructive outline button

**Subtle background texture:** On the check-in page specifically, add a very faint grain/noise overlay for warmth. Implement with a semi-transparent noise image asset overlaid on the scaffold.

### 5.8 Friends Page

**App bar:** "Friends & Leaderboard" — Fraunces, add friend icon in Primary

**Tab bar:** Per spec 4.7

**Friends tab:**
- Section headers: DM Sans Title Large w700
- Friend request cards:
  - Surface card with Primary container left-border accent
  - Username, avatar
  - Accept: Small Primary filled button
  - Reject: Small outline button
- Friend cards:
  - Surface card
  - Avatar (circle), username, points or streak info
  - Tap navigates to user profile
- Empty state: People icon, "No friends yet", Primary text button to add

**Leaderboard tab:**
- Segmented button per spec 4.8 (Global / Friends)
- **Podium for top 3 (key visual moment):**
  - Use gradient backgrounds (Tier gradient) for the #1 position
  - Gold (#E8D5B7), Silver (#B8A898), Bronze (#C67B4E) accents
  - Avatars with rank numbers
  - Points in Fraunces with gradient text
- Remaining entries:
  - List tiles with rank number, avatar, username, points
  - **Stagger animation:** Each tile slides up + fades in with 50ms delay per item
  - Current user's row: highlighted with Primary container background

### 5.9 Profile Page

**This is a showcase screen — it should feel like a personal stats dashboard.**

**Profile header:**
- Avatar: 50px radius circle, camera overlay with Primary bg
- Username: Fraunces Headline Large
- University ID: DM Sans Body Medium, Text secondary
- Tier badge: Pill chip per spec 4.6

**Stat cards (all with stagger entry animation):**

Tier Progress Card:
- Card with subtle gradient border (Tier gradient)
- Tier name in Fraunces, gradient text
- Progress bar: Rounded, Streak gradient fill on Surface variant track
- Points: Fraunces numbers with **count-up animation** on load
- "X points to next tier" — DM Sans Body Small, Text secondary

Streak Card:
- Card with Secondary container subtle bg
- Streak number: Fraunces Display Medium, gradient text (Streak gradient)
- "day streak 🔥" label
- Weekly dots: Row of 7 circles, filled (Secondary) or empty (Surface variant)
- **Count-up animation** on the streak number

Attendance Ring Card:
- Circular progress rings using earthy colors:
  - Overall: Primary (#C67B4E)
  - Weekly: Secondary (#7A9A6D)
  - Today: Accent (#E8D5B7)
- Percentages: Fraunces, with **count-up animation**
- Ring background track: Surface variant

Attendance Chart:
- Line or bar chart
- Use Primary color for main line/bars
- Grid lines: Outline color
- Labels: DM Sans Label Small, Text secondary
- Background: Card surface

**Subtle background texture:** Apply faint grain overlay on profile page as well.

### 5.10 User Profile Page (Viewing Another User)

- Same layout as own profile but without edit controls
- AppBar title: username in Fraunces
- Same stat cards and animations

### 5.11 Settings Page

- Standard list layout on scaffold
- Section headers: DM Sans Label Large, Text secondary, uppercase, letter-spacing +1
- List tiles:
  - Title: DM Sans Title Medium
  - Subtitle: DM Sans Body Small, Text secondary
  - Trailing icons: Text secondary
- Dividers: Outline color
- Sign out tile: Danger colored leading icon and text
- Theme dialog: Radio buttons with Primary accent
- Edit dialogs: Per dialog spec 4.5

---

## 6. Animations & Micro-Interactions

Animations are essential to the feel of this app. They should be **smooth, warm, and rewarding** — never jarring or slow.

### 6.1 Page Transitions (Tab Navigation)

```dart
// Use a fade-through transition between bottom nav tabs
// Duration: 300ms, Curve: Curves.easeInOut
// Incoming page fades in + slight slide up (20px)
// Outgoing page fades out

// For the timetable day-to-day swipe:
// SlideTransition from left/right based on direction
// Duration: 300ms, Curve: Curves.easeInOut
```

### 6.2 Staggered List Animations

```dart
// Cards/list items slide up + fade in sequentially
// Each item: translate Y from 20px → 0, opacity 0 → 1
// Base duration: 400ms
// Stagger delay: 80ms per item (index * 80)
// Curve: Curves.easeOut
// Use TweenAnimationBuilder or AnimationController with intervals
// Cap the stagger at 8 items (items beyond 8 use same delay as item 8)
```

### 6.3 Number Count-Up Animations

```dart
// For points, streak numbers, percentages, and ranks
// Animate from 0 to target value over 800ms
// Curve: Curves.easeOutCubic (fast start, gentle landing)
// Use a Tween<int> or Tween<double> with AnimationController
// Display with Fraunces font + gradient ShaderMask where applicable
// Trigger on first build or when value changes
```

### 6.4 Check-In Button

```dart
// When check-in is available (canCheckIn == true):
// Subtle scale pulse: 1.0 → 1.02 → 1.0, duration 2s, repeat
// Plus a soft glow shadow that breathes in sync
// Use AnimationController with repeat() and a custom curve

// On tap: quick scale down to 0.95, then release
// Feedback: HapticFeedback.mediumImpact()
```

### 6.5 Success Celebrations

```dart
// On successful check-in:
// 1. Check icon scales up with bounce (Curves.elasticOut, 600ms)
// 2. Points text counts up from 0
// 3. Subtle radial burst of small particles (optional — implement if time allows)

// On streak milestone:
// Brief shake + scale pop on the streak number
```

### 6.6 Skeleton Loading

```dart
// Replace all loading states with skeleton shimmer
// Shimmer color: Surface → Surface variant → Surface (warm, not grey)
// Shimmer direction: left to right
// Duration: 1500ms, repeat
// Shape: Match the layout of the content being loaded (cards, text lines, circles)
```

### 6.7 Pull-to-Refresh

```dart
// Use RefreshIndicator with Primary color spinner
// Background of indicator: Surface variant
```

---

## 7. Background Texture

Apply a subtle grain/noise texture on the **Check-In page** and **Profile page** backgrounds only. This adds tactile warmth.

### Implementation

```
Option A (Preferred — asset-based):
1. Create a 200x200 PNG noise texture (very low opacity, warm-tinted)
2. Tile it across the background using a Stack with Opacity(0.03-0.05)
3. Use BoxDecoration with ImageRepeat.repeat

Option B (Shader-based):
1. Use a CustomPainter that generates subtle perlin noise
2. Apply with very low opacity
3. Performance consideration: cache the painted result

Either way:
- Opacity should be 3-5% — barely perceptible, just enough to add texture
- Tint the noise warm (#C67B4E at near-zero opacity) so it doesn't read as grey static
- The texture sits BEHIND all content but ON TOP of the scaffold background color
```

---

## 8. Prerequisites — Before You Start

Before beginning implementation, ensure the following are in place:

1. **Google Fonts package:** Add `google_fonts` to `pubspec.yaml` if not already present (`google_fonts: ^6.0.0` or latest). This is required for Fraunces and DM Sans. Alternatively, download the font files from Google Fonts and bundle them in `assets/fonts/` — bundling avoids a network fetch on first launch.

2. **Grain texture asset:** For the background texture on Check-In and Profile pages, you need a small tileable noise PNG. Create or source a ~200x200px warm-tinted noise image and place it at `assets/images/grain_texture.png`. If you cannot source one, generate it programmatically with a CustomPainter as described in Section 7 Option B — but the asset approach is simpler and more performant.

3. **Existing ThemeProvider:** The app already has a `ThemeProvider` with `AppThemeMode` (system, light, dark, highContrast). The new theme system should integrate with this — replace the existing theme definitions but keep the provider's mode-switching logic intact. High contrast mode can map to light theme with increased contrast ratios for now.

4. **Package compatibility:** Ensure any chart libraries used for the attendance chart (e.g., `fl_chart`) support custom colors — you'll need to pass the theme's earthy palette rather than relying on library defaults.

5. **Font loading considerations:** Fraunces is a variable font with optical sizing. When using `google_fonts`, request specific weights (400, 600, 700, 800, 900) to avoid loading the entire variable font file. DM Sans needs weights 400, 500, 600, 700.

---

## 9. Implementation Plan **complete overhaul** in this order. Each step should be fully working before moving on.

### Step 1: Theme Foundation

1. Create `lib/theme/` directory with:
   - `colors.dart` — All color constants for dark and light
   - `typography.dart` — TextTheme using Fraunces + DM Sans
   - `app_theme.dart` — Complete ThemeData for dark and light modes
   - `theme_extensions.dart` — Custom `ThemeExtension` for semantic colors not in ColorScheme (streak gradient, points gradient, module colors, etc.)
2. Add `google_fonts` package to `pubspec.yaml` (or bundle Fraunces + DM Sans font files)
3. Wire up the theme in `main.dart` — dark as default, respect user's theme preference from ThemeProvider
4. Verify: Every screen should immediately pick up the new background, text, and primary colors

### Step 2: Common Components

1. Create `lib/widgets/common/` with reusable themed components:
   - `gradient_text.dart` — ShaderMask wrapper for gradient text
   - `themed_card.dart` — Card with consistent styling, optional left-border accent
   - `count_up_text.dart` — Animated number display with Fraunces + optional gradient
   - `skeleton_shimmer.dart` — Warm-toned shimmer loading widget
   - `staggered_list.dart` — Helper for stagger animations on lists
2. Update existing skeleton widgets to use warm shimmer colors

### Step 3: Navigation Shell (Home Page)

1. Restyle `BottomNavigationBar` per spec 4.1
2. Add fade-through page transitions between tabs
3. Remove default elevation, add top border

### Step 4: Timetable Page

1. Restyle day selector with pill-shaped selected state
2. Update lecture blocks with left-border accent, proper colors per status
3. Update empty states with new typography
4. Ensure slide transitions between days work smoothly
5. Restyle lecture detail bottom sheet / dialog

### Step 5: Check-In Page

1. Apply new card styling, location banners with semantic colors
2. Implement gradient check-in button with pulse animation
3. Add gradient text for points display
4. Implement success state with count-up animation on points
5. Update checked-in state with time remaining in Fraunces
6. Add background grain texture
7. Update skeleton loading with warm shimmer

### Step 6: Friends & Leaderboard Page

1. Restyle tab bar per spec
2. Update friend cards and request cards
3. Restyle leaderboard podium with gradient accents and earthy medal colors
4. Implement stagger animation on leaderboard entries
5. Update segmented button
6. Update search/add friend dialogs

### Step 7: Profile Page

1. Restyle profile header with new typography and tier badge
2. Update all stat cards (tier, streak, attendance rings, chart) with:
   - New colors and gradients
   - Count-up animations on numbers
   - Stagger entry animations
3. Add background grain texture
4. Update avatar picker bottom sheet

### Step 8: Auth Pages (Login, Sign Up, Forgot Password)

1. Apply new typography (Fraunces headings, DM Sans body)
2. Restyle input fields per spec
3. Restyle buttons and error states
4. Update splash page gradient

### Step 9: Settings Page

1. Apply section header styling
2. Restyle list tiles with proper text hierarchy
3. Update all dialogs (username, password, iCal, theme, sign out)

### Step 10: Polish & Consistency Pass

1. Review every screen for consistent spacing (use the 4px grid)
2. Verify all colors match the spec in both light and dark modes
3. Test all animations for smoothness (no jank, proper curves)
4. Ensure all text uses the correct font family (no stray default fonts)
5. Check empty states, error states, and loading states on every screen
6. Test accessibility: contrast ratios should meet WCAG AA for all text

---

## 10. Key Principles — Read This Before Starting

1. **Warm, never cold.** Every grey should have a brown/amber undertone. No pure greys (#888, #ccc) anywhere. If you reach for `Colors.grey`, stop and use the theme's text secondary or surface colors instead.

2. **Fraunces is precious.** Only use it for headings and big display numbers. If you're tempted to use it for a button label or body text, use DM Sans instead.

3. **Gradients are celebrations.** Only use gradient text for: streak count, points earned, tier name, rank number. If everything is gradient, nothing is special.

4. **The left-border accent is the signature.** Lecture cards, module references, and important callout cards should have that 3px coloured left border. It's the most recognizable visual element.

5. **Animations should feel natural.** Use easeOut for entrances (things arriving), easeInOut for transitions (things moving), and elasticOut only for celebratory moments. Never use linear curves.

6. **Dark mode is home base.** Design and test dark first. Light mode should feel like the same app, just inverted — same warmth, same personality.

7. **Consistency over creativity.** If a component exists in the spec, use that spec. Don't improvise new color combinations or spacing values. The system works because everything relates.

---

## Appendix: Quick Color Reference

### Dark Mode Cheat Sheet
| Use Case | Color | Hex |
|---|---|---|
| Page background | bg | #1A1714 |
| Card fill | surface | #252118 |
| Primary buttons / active states | primary | #C67B4E |
| Success / streaks / check marks | secondary | #7A9A6D |
| Special highlights / badges | accent | #E8D5B7 |
| Main text | text primary | #F2EAE0 |
| Subtle text / labels | text secondary | #9B8E80 |
| Errors / missed / destructive | danger | #C45C4A |
| Card borders | outline | #3D362E |

### Light Mode Cheat Sheet
| Use Case | Color | Hex |
|---|---|---|
| Page background | bg | #FAF6F1 |
| Card fill | surface | #FFFFFF |
| Primary buttons / active states | primary | #B5693E |
| Success / streaks / check marks | secondary | #5E8352 |
| Special highlights / badges | accent | #8B7355 |
| Main text | text primary | #1A1714 |
| Subtle text / labels | text secondary | #6B5F53 |
| Errors / missed / destructive | danger | #B84A38 |
| Card borders | outline | #DDD5CB |
