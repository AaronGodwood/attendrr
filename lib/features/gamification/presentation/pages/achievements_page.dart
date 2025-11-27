import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Template achievements data
    final achievements = [
      {
        'title': 'First Steps',
        'description': 'Attend your first lecture',
        'icon': Icons.school,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Week Warrior',
        'description': 'Attend all lectures in a week',
        'icon': Icons.calendar_month,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Streak Master',
        'description': 'Maintain a 7-day streak',
        'icon': Icons.local_fire_department,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Century Club',
        'description': 'Earn 100 points',
        'icon': Icons.star,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Perfect Month',
        'description': 'Attend all lectures in a month',
        'icon': Icons.emoji_events,
        'unlocked': false,
        'progress': 0.8,
      },
      {
        'title': 'Social Butterfly',
        'description': 'Add 10 friends',
        'icon': Icons.people,
        'unlocked': false,
        'progress': 0.4,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final unlocked = achievement['unlocked'] as bool;
          final progress = achievement['progress'] as double;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: unlocked ? Colors.amber : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: unlocked ? Colors.white : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              title: Text(
                achievement['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['description'] as String,
                    style: TextStyle(
                      color: unlocked ? Colors.grey.shade600 : Colors.grey,
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
              trailing: unlocked
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.lock, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
