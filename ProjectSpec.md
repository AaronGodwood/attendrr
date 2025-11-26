# Lecture Attendance Tracker - Complete Implementation Specification

## Table of Contents
1. [Project Overview](#project-overview)
2. [Navigation Structure](#navigation-structure)
3. [Page Implementations](#page-implementations)
4. [Data Models](#data-models)
5. [State Management](#state-management)
6. [Supabase Integration](#supabase-integration)
7. [Services Implementation](#services-implementation)
8. [Component Specifications](#component-specifications)

---

## Project Overview

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **State Management**: Provider
- **Navigation**: GoRouter with bottom navigation
- **Location Services**: Geolocator package
- **Local Storage**: SharedPreferences for settings
- **Architecture**: Clean Architecture with Repository Pattern

### App Structure
The app has 4 main pages accessible via bottom navigation:
1. **Profile** - User profile, stats, settings access
2. **Timetable** - Calendar view of lectures
3. **Current Lecture** - Check-in functionality
4. **Friends & Leaderboard** - Social features and rankings

---

## Navigation Structure

### Bottom Navigation Implementation
```dart
// Bottom Navigation Bar Configuration
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(icon: Icons.person, label: 'Profile'),
    BottomNavigationBarItem(icon: Icons.calendar_today, label: 'Timetable'),
    BottomNavigationBarItem(icon: Icons.location_on, label: 'Check In'),
    BottomNavigationBarItem(icon: Icons.leaderboard, label: 'Friends'),
  ],
  currentIndex: selectedIndex,
  onTap: (index) => navigateToPage(index),
)
```

### Route Definitions
- `/profile` - Profile page
- `/profile/settings` - Settings page (navigated from profile)
- `/timetable` - Timetable calendar view
- `/checkin` - Current lecture check-in
- `/friends` - Friends and leaderboard

---

## Page Implementations

### 1. Profile Page (`/profile`)

#### Layout Structure
```
ProfilePage
├── AppBar (with settings icon button)
├── Body
│   ├── ProfileHeader
│   │   ├── Avatar/Profile Picture
│   │   ├── Username
│   │   └── University ID
│   ├── StatsCard
│   │   ├── Current Streak (with fire icon)
│   │   ├── Total Points
│   │   └── Streak Freezes Available
│   ├── AttendanceStatsSection
│   │   ├── This Week: X/Y lectures attended
│   │   ├── This Month: X/Y lectures attended
│   │   ├── Overall Attendance Rate: XX%
│   │   └── MiniChart (showing last 30 days)
│   └── QuickActions
│       ├── View Achievements
│       ├── Attendance History
│       └── Settings
```

#### Implementation Details
```dart
class ProfilePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileHeader(),
            SizedBox(height: 20),
            StatsCard(),
            SizedBox(height: 20),
            AttendanceStatsSection(),
            SizedBox(height: 20),
            QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}
```

#### Data Requirements
- Fetch user profile from Supabase `profiles` table
- Get current streak from `streaks` table
- Calculate attendance statistics from `attendance` table
- Get total points from `points` table

#### StatsCard Component
```dart
class StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
              value: '${streak.currentStreak}',
              label: 'Day Streak',
            ),
            _StatItem(
              icon: Icons.star,
              iconColor: Colors.amber,
              value: '${points.totalPoints}',
              label: 'Points',
            ),
            _StatItem(
              icon: Icons.ac_unit,
              iconColor: Colors.blue,
              value: '${streak.freezes}',
              label: 'Freezes',
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Settings Page (`/profile/settings`)

#### Layout Structure
```
SettingsPage
├── AppBar (with back button)
├── Body
│   ├── AccountSection
│   │   ├── Email (read-only)
│   │   ├── Username (editable)
│   │   ├── Change Password
│   │   └── Link/Update Timetable
│   ├── AppearanceSection
│   │   ├── Theme Toggle (Light/Dark/System)
│   │   └── Color Accent Selector
│   ├── NotificationSection
│   │   ├── Lecture Reminders Toggle
│   │   ├── Reminder Time Before Lecture
│   │   └── Friend Request Notifications
│   ├── AppLockSection
│   │   ├── Enable App Locking Toggle
│   │   └── Manage Allowed Apps
│   └── DangerZone
│       ├── Clear Cache
│       ├── Sign Out
│       └── Delete Account
```

#### Implementation Details
```dart
class SettingsPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                title: Text('Email'),
                subtitle: Text(user.email),
                trailing: Icon(Icons.lock_outline, size: 20),
              ),
              ListTile(
                title: Text('Username'),
                subtitle: Text(user.username),
                trailing: Icon(Icons.edit),
                onTap: () => _showEditUsernameDialog(),
              ),
              ListTile(
                title: Text('Change Password'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showChangePasswordDialog(),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                title: Text('Theme'),
                subtitle: Text(_getThemeText()),
                trailing: DropdownButton<ThemeMode>(
                  value: currentTheme,
                  items: [
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  ],
                  onChanged: (value) => _updateTheme(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### SharedPreferences Keys
```dart
class SettingsKeys {
  static const String THEME_MODE = 'theme_mode';
  static const String NOTIFICATION_ENABLED = 'notifications_enabled';
  static const String REMINDER_TIME = 'reminder_time_minutes';
  static const String APP_LOCK_ENABLED = 'app_lock_enabled';
}
```

### 3. Timetable Page (`/timetable`)

#### Layout Structure
```
TimetablePage
├── AppBar (with week selector)
├── Body
│   ├── WeekView (default) / MonthView (optional)
│   │   ├── DayHeaders (Mon-Fri)
│   │   └── TimeSlots (8am-6pm)
│   │       └── LectureCards (positioned by time)
│   └── FloatingActionButton (Sync Timetable)
```

#### Implementation Details
```dart
class TimetablePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_view_week),
            onPressed: () => _toggleViewMode(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: WeekSelector(
            currentWeek: selectedWeek,
            onWeekChanged: (week) => setState(() => selectedWeek = week),
          ),
        ),
      ),
      body: WeekViewCalendar(
        lectures: weekLectures,
        onLectureTap: (lecture) => _showLectureDetails(lecture),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.sync),
        onPressed: () => _syncTimetable(),
      ),
    );
  }
}
```

#### Calendar Component (Week View)
```dart
class WeekViewCalendar extends StatelessWidget {
  final List<Lecture> lectures;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day headers
        Container(
          height: 40,
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                .map((day) => Expanded(
                  child: Center(
                    child: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ))
                .toList(),
          ),
        ),
        // Time slots and lectures
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Time indicators (8am - 6pm)
                _buildTimeIndicators(),
                // Lecture cards positioned absolutely
                ..._buildLectureCards(lectures),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildLectureCards(List<Lecture> lectures) {
    return lectures.map((lecture) {
      final dayIndex = lecture.startTime.weekday - 1;
      final startMinutes = lecture.startTime.hour * 60 + lecture.startTime.minute;
      final duration = lecture.endTime.difference(lecture.startTime).inMinutes;
      
      return Positioned(
        left: (MediaQuery.of(context).size.width / 5) * dayIndex,
        top: (startMinutes - 480) * 2, // 480 = 8am in minutes
        width: MediaQuery.of(context).size.width / 5 - 4,
        height: duration * 2,
        child: LectureCard(lecture: lecture),
      );
    }).toList();
  }
}
```

#### Lecture Card
```dart
class LectureCard extends StatelessWidget {
  final Lecture lecture;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getLectureColor(lecture),
      child: InkWell(
        onTap: () => _showLectureDetails(lecture),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lecture.moduleCode,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                lecture.title,
                style: TextStyle(fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.location_on, size: 10),
                  SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      lecture.location,
                      style: TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getLectureColor(Lecture lecture) {
    // Check if attended
    if (lecture.attended) return Colors.green.shade100;
    // Check if missed
    if (lecture.endTime.isBefore(DateTime.now())) return Colors.red.shade100;
    // Upcoming
    return Colors.blue.shade100;
  }
}
```

### 4. Current Lecture Page (`/checkin`)

#### Layout Structure
```
CurrentLecturePage
├── AppBar
├── Body (Conditional based on state)
│   ├── IF current lecture exists:
│   │   ├── CurrentLectureCard
│   │   │   ├── Module Code & Title
│   │   │   ├── Time (Start - End)
│   │   │   ├── Location
│   │   │   └── Distance from location
│   │   ├── CheckInButton (large, prominent)
│   │   └── AppLockSettings
│   │       └── Selected apps to keep unlocked
│   ├── ELSE IF no current lecture:
│   │   ├── NoLectureMessage
│   │   └── NextLectureCard
│   │       ├── Time until next lecture
│   │       └── Lecture details
│   └── IF checked in:
│       ├── CheckedInConfirmation
│       ├── Timer (showing remaining time)
│       └── BreakLockButton (with warning)
```

#### Implementation States
```dart
enum CheckInState {
  noLecture,
  readyToCheckIn,
  checkingIn,
  checkedIn,
  lectureEnded,
}
```

#### Implementation Details
```dart
class CurrentLecturePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final checkInProvider = Provider.of<CheckInProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In'),
      ),
      body: _buildBody(checkInProvider.state),
    );
  }
  
  Widget _buildBody(CheckInState state) {
    switch (state) {
      case CheckInState.noLecture:
        return _NoLectureView();
      case CheckInState.readyToCheckIn:
        return _ReadyToCheckInView();
      case CheckInState.checkingIn:
        return _CheckingInView();
      case CheckInState.checkedIn:
        return _CheckedInView();
      case CheckInState.lectureEnded:
        return _LectureEndedView();
    }
  }
}
```

#### Ready to Check In View
```dart
class _ReadyToCheckInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lecture = context.watch<CheckInProvider>().currentLecture;
    final distance = context.watch<LocationProvider>().distanceToLecture;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Lecture Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Theme.of(context).primaryColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lecture.moduleCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              lecture.title,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(lecture.startTime)} - ${DateFormat('HH:mm').format(lecture.endTime)}',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Expanded(child: Text(lecture.location)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.navigation, size: 16),
                      SizedBox(width: 4),
                      Text(
                        distance != null 
                          ? '${distance.toStringAsFixed(0)}m away'
                          : 'Calculating distance...',
                        style: TextStyle(
                          color: distance != null && distance <= 50
                            ? Colors.green
                            : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 32),
          
          // Check In Button
          Container(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: distance != null && distance <= 50
                ? () => context.read<CheckInProvider>().checkIn()
                : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                distance != null && distance <= 50
                  ? 'CHECK IN'
                  : 'Move closer to check in',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // App Lock Settings
          Card(
            child: ExpansionTile(
              title: Text('App Lock Settings'),
              subtitle: Text('Apps will be locked during lecture'),
              children: [
                SwitchListTile(
                  title: Text('Enable App Lock'),
                  value: appLockEnabled,
                  onChanged: (value) => _toggleAppLock(value),
                ),
                if (appLockEnabled)
                  ListTile(
                    title: Text('Manage Allowed Apps'),
                    subtitle: Text('${allowedApps.length} apps allowed'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _showAppSelector(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Checked In View
```dart
class _CheckedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final endTime = context.watch<CheckInProvider>().currentLecture.endTime;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 24),
          Text(
            'Checked In Successfully!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Your apps are locked until the lecture ends',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 32),
          StreamBuilder<int>(
            stream: _getRemainingTimeStream(endTime),
            builder: (context, snapshot) {
              final minutes = snapshot.data ?? 0;
              return Column(
                children: [
                  Text(
                    'Time Remaining',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${minutes ~/ 60}h ${minutes % 60}m',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 48),
          TextButton(
            onPressed: () => _showBreakLockWarning(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Emergency: Break Lock'),
          ),
        ],
      ),
    );
  }
}
```

### 5. Friends & Leaderboard Page (`/friends`)

#### Layout Structure
```
FriendsLeaderboardPage
├── AppBar (with add friend button)
├── TabBar
│   ├── Friends Tab
│   └── Leaderboard Tab
├── TabBarView
│   ├── FriendsView
│   │   ├── Friend Requests Section (if any)
│   │   └── Friends List
│   │       └── FriendCard (avatar, name, points, streak)
│   └── LeaderboardView
│       ├── Toggle (Global/Friends)
│       └── LeaderboardList
│           └── LeaderboardEntry (rank, user, points)
```

#### Implementation Details
```dart
class FriendsLeaderboardPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Friends & Leaderboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () => _showAddFriendDialog(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsView(),
            LeaderboardView(),
          ],
        ),
      ),
    );
  }
}
```

#### Friends View
```dart
class FriendsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final friendsProvider = Provider.of<FriendsProvider>(context);
    
    return RefreshIndicator(
      onRefresh: () => friendsProvider.refreshFriends(),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Friend Requests Section
          if (friendsProvider.pendingRequests.isNotEmpty) ...[
            Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...friendsProvider.pendingRequests.map((request) =>
              FriendRequestCard(request: request),
            ),
            SizedBox(height: 24),
          ],
          
          // Friends List
          Text(
            'My Friends (${friendsProvider.friends.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (friendsProvider.friends.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No friends yet'),
                  TextButton(
                    onPressed: () => _showAddFriendDialog(),
                    child: Text('Add Friends'),
                  ),
                ],
              ),
            )
          else
            ...friendsProvider.friends.map((friend) =>
              FriendCard(friend: friend),
            ),
        ],
      ),
    );
  }
}
```

#### Friend Card Component
```dart
class FriendCard extends StatelessWidget {
  final Friend friend;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: friend.avatarUrl != null
            ? NetworkImage(friend.avatarUrl!)
            : null,
          child: friend.avatarUrl == null
            ? Text(friend.username[0].toUpperCase())
            : null,
        ),
        title: Text(friend.username),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber),
            SizedBox(width: 4),
            Text('${friend.points} pts'),
            SizedBox(width: 16),
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            SizedBox(width: 4),
            Text('${friend.streak} days'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Text('View Profile'),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Text('Remove Friend'),
            ),
          ],
          onSelected: (value) => _handleFriendAction(value, friend),
        ),
      ),
    );
  }
}
```

#### Leaderboard View
```dart
class LeaderboardView extends StatefulWidget {
  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  bool showGlobal = true;
  
  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);
    
    return Column(
      children: [
        // Toggle between Global and Friends
        Container(
          padding: EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text('Global')),
              ButtonSegment(value: false, label: Text('Friends')),
            ],
            selected: {showGlobal},
            onSelectionChanged: (Set<bool> selection) {
              setState(() => showGlobal = selection.first);
            },
          ),
        ),
        
        // Leaderboard List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => leaderboardProvider.refreshLeaderboard(showGlobal),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: leaderboardProvider.entries.length,
              itemBuilder: (context, index) {
                final entry = leaderboardProvider.entries[index];
                final isCurrentUser = entry.userId == currentUserId;
                
                return LeaderboardEntry(
                  rank: index + 1,
                  entry: entry,
                  isHighlighted: isCurrentUser,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
```

#### Leaderboard Entry Component
```dart
class LeaderboardEntry extends StatelessWidget {
  final int rank;
  final LeaderboardEntryModel entry;
  final bool isHighlighted;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlighted 
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
        border: isHighlighted
          ? Border.all(color: Theme.of(context).primaryColor, width: 2)
          : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          entry.username,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${entry.attendanceRate}% attendance'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.points}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'points',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.blue;
    }
  }
}
```

---

## Data Models

### User Model
```dart
class User {
  final String id;
  final String email;
  final String username;
  final String? universityId;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  User({
    required this.id,
    required this.email,
    required this.username,
    this.universityId,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      universityId: json['university_id'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
```

### Lecture Model
```dart
class Lecture {
  final String id;
  final String timetableId;
  final String title;
  final String moduleCode;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  bool? attended; // Populated from attendance table
  
  Lecture({
    required this.id,
    required this.timetableId,
    required this.title,
    required this.moduleCode,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    this.attended,
  });
  
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
  
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }
  
  bool get isPast {
    return DateTime.now().isAfter(endTime);
  }
}
```

### Attendance Model
```dart
class Attendance {
  final String id;
  final String userId;
  final String lectureId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final bool locationVerified;
  final bool appsLocked;
  final bool lockBroken;
  final int pointsEarned;
  
  Attendance({
    required this.id,
    required this.userId,
    required this.lectureId,
    required this.checkInTime,
    this.checkOutTime,
    required this.locationVerified,
    required this.appsLocked,
    required this.lockBroken,
    required this.pointsEarned,
  });
  
  bool get isActive => checkOutTime == null;
}
```

### Streak Model
```dart
class Streak {
  final String id;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int streakFreezes;
  final DateTime? lastAttendanceDate;
  
  Streak({
    required this.id,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezes,
    this.lastAttendanceDate,
  });
  
  bool get canUseFreeze => streakFreezes > 0;
}
```

---

## State Management

### Provider Structure

#### CheckInProvider
```dart
class CheckInProvider extends ChangeNotifier {
  CheckInState _state = CheckInState.noLecture;
  Lecture? _currentLecture;
  Attendance? _currentAttendance;
  
  CheckInState get state => _state;
  Lecture? get currentLecture => _currentLecture;
  Attendance? get currentAttendance => _currentAttendance;
  
  Future<void> loadCurrentLecture() async {
    try {
      // Get current time lectures from Supabase
      final now = DateTime.now();
      final response = await supabase
          .from('lectures')
          .select()
          .lte('start_time', now.toIso8601String())
          .gte('end_time', now.toIso8601String())
          .single();
      
      if (response != null) {
        _currentLecture = Lecture.fromJson(response);
        _state = CheckInState.readyToCheckIn;
      } else {
        _state = CheckInState.noLecture;
        _loadNextLecture();
      }
      notifyListeners();
    } catch (e) {
      _state = CheckInState.noLecture;
      notifyListeners();
    }
  }
  
  Future<void> checkIn() async {
    if (_currentLecture == null) return;
    
    _state = CheckInState.checkingIn;
    notifyListeners();
    
    try {
      // Verify location
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _currentLecture!.latitude,
        _currentLecture!.longitude,
      );
      
      if (distance > 50) {
        throw Exception('Too far from lecture location');
      }
      
      // Create attendance record
      final attendance = await supabase
          .from('attendance')
          .insert({
            'user_id': supabase.auth.currentUser!.id,
            'lecture_id': _currentLecture!.id,
            'check_in_time': DateTime.now().toIso8601String(),
            'location_verified': true,
            'apps_locked': true,
            'points_earned': 10,
          })
          .select()
          .single();
      
      _currentAttendance = Attendance.fromJson(attendance);
      _state = CheckInState.checkedIn;
      
      // Start app lock
      await AppLockService.instance.startLock(_currentLecture!.endTime);
      
      // Update streak
      await _updateStreak();
      
      notifyListeners();
    } catch (e) {
      _state = CheckInState.readyToCheckIn;
      notifyListeners();
      throw e;
    }
  }
  
  Future<void> breakLock() async {
    if (_currentAttendance == null) return;
    
    // Update attendance record
    await supabase
        .from('attendance')
        .update({
          'lock_broken': true,
          'check_out_time': DateTime.now().toIso8601String(),
          'points_earned': 5, // Reduced points for breaking lock
        })
        .eq('id', _currentAttendance!.id);
    
    // Stop app lock
    await AppLockService.instance.stopLock();
    
    _state = CheckInState.lectureEnded;
    notifyListeners();
  }
}
```

#### TimetableProvider
```dart
class TimetableProvider extends ChangeNotifier {
  List<Lecture> _lectures = [];
  DateTime _selectedWeek = DateTime.now();
  bool _isLoading = false;
  
  List<Lecture> get lectures => _lectures;
  List<Lecture> get weekLectures => _getWeekLectures();
  DateTime get selectedWeek => _selectedWeek;
  bool get isLoading => _isLoading;
  
  List<Lecture> _getWeekLectures() {
    final weekStart = _getWeekStart(_selectedWeek);
    final weekEnd = weekStart.add(Duration(days: 7));
    
    return _lectures.where((lecture) =>
      lecture.startTime.isAfter(weekStart) &&
      lecture.startTime.isBefore(weekEnd)
    ).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  Future<void> loadTimetable() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get user's timetable
      final timetable = await supabase
          .from('timetables')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      
      // Get lectures for this timetable
      final lecturesResponse = await supabase
          .from('lectures')
          .select('*, attendance!left(*)')
          .eq('timetable_id', timetable['id'])
          .order('start_time');
      
      _lectures = (lecturesResponse as List)
          .map((json) => Lecture.fromJson(json))
          .toList();
      
      // Mark attended lectures
      for (var lecture in _lectures) {
        final attendance = await _checkAttendance(lecture.id);
        lecture.attended = attendance != null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
  
  Future<void> syncWithUniversity() async {
    // Call university API to get updated timetable
    // Update local database with changes
  }
  
  void changeWeek(DateTime newWeek) {
    _selectedWeek = newWeek;
    notifyListeners();
  }
}
```

---

## Supabase Integration

### Initialize Supabase
```dart
// main.dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);

final supabase = Supabase.instance.client;
```

### Authentication Flow
```dart
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Sign up with Supabase Auth
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Create profile
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'username': username,
        });
        
        // Initialize streak record
        await _client.from('streaks').insert({
          'user_id': response.user!.id,
          'current_streak': 0,
          'longest_streak': 0,
          'streak_freezes': 3,
        });
        
        // Initialize points record
        await _client.from('points').insert({
          'user_id': response.user!.id,
          'total_points': 0,
          'weekly_points': 0,
          'monthly_points': 0,
        });
      }
      
      return response.user;
    } catch (e) {
      throw e;
    }
  }
  
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      throw e;
    }
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

### Real-time Subscriptions
```dart
class RealtimeService {
  StreamSubscription? _attendanceSubscription;
  StreamSubscription? _friendRequestSubscription;
  
  void subscribeToAttendance(String userId) {
    _attendanceSubscription = supabase
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          // Handle real-time attendance updates
        });
  }
  
  void subscribeToFriendRequests(String userId) {
    _friendRequestSubscription = supabase
        .from('friendships')
        .stream(primaryKey: ['id'])
        .eq('friend_id', userId)
        .eq('status', 'pending')
        .listen((List<Map<String, dynamic>> data) {
          // Handle new friend requests
        });
  }
  
  void dispose() {
    _attendanceSubscription?.cancel();
    _friendRequestSubscription?.cancel();
  }
}
```

---

## Services Implementation

### Location Service
```dart
class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();
  
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
```

### App Lock Service (Conceptual - Platform Specific)
```dart
class AppLockService {
  static final AppLockService instance = AppLockService._();
  AppLockService._();
  
  List<String> _allowedApps = [];
  Timer? _lockTimer;
  
  Future<void> startLock(DateTime endTime) async {
    // Load allowed apps from preferences
    final prefs = await SharedPreferences.getInstance();
    _allowedApps = prefs.getStringList('allowed_apps') ?? [];
    
    // Platform specific implementation needed
    // Android: Use DevicePolicyManager or AccessibilityService
    // iOS: Use Screen Time API (requires special entitlements)
    
    // Set timer to auto-unlock
    final duration = endTime.difference(DateTime.now());
    _lockTimer = Timer(duration, () {
      stopLock();
    });
  }
  
  Future<void> stopLock() async {
    _lockTimer?.cancel();
    // Platform specific unlock implementation
  }
  
  Future<List<AppInfo>> getInstalledApps() async {
    // Platform specific - get list of installed apps
    // Return mock data for now
    return [
      AppInfo(name: 'Notes', packageName: 'com.example.notes'),
      AppInfo(name: 'Calculator', packageName: 'com.example.calc'),
      AppInfo(name: 'Canvas', packageName: 'com.instructure.canvas'),
    ];
  }
}
```

### Notification Service
```dart
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }
  
  Future<void> scheduleL lectureReminder(Lecture lecture) async {
    final reminderTime = lecture.startTime.subtract(Duration(minutes: 15));
    
    await _notifications.zonedSchedule(
      lecture.id.hashCode,
      'Lecture Starting Soon',
      '${lecture.moduleCode} - ${lecture.title} at ${lecture.location}',
      TZDateTime.from(reminderTime, local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'lecture_reminders',
          'Lecture Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  Future<void> showCheckInSuccess(int pointsEarned) async {
    await _notifications.show(
      0,
      'Check-in Successful!',
      'You earned $pointsEarned points. Your apps are now locked.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'check_in',
          'Check In',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
```

---

## Component Specifications

### Common Components

#### Custom App Bar
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: actions,
      bottom: bottom,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.headlineLarge?.color,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null ? 100.0 : 56.0,
  );
}
```

#### Loading Indicator
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

#### Empty State Widget
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

#### Stats Card
```dart
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Error Handling

### Global Error Handler
```dart
class ErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An error occurred';
    
    if (error is PostgrestException) {
      message = error.message;
    } else if (error is AuthException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  static Widget errorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
```

---

## Testing Approach

### Unit Tests
- Test all providers
- Test data models
- Test services

### Widget Tests
- Test individual pages
- Test navigation
- Test state changes

### Integration Tests
- Test complete user flows
- Test Supabase integration
- Test location services

---

This specification provides complete implementation details for every page and component. Each section includes the exact layout, required functionality, data flow, and code structure needed to build the app. Use this as your reference when implementing each feature.