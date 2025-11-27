import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakDetailsPage extends StatelessWidget {
  const StreakDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Template streak data
    final currentStreak = 12;
    final longestStreak = 18;
    final streakFreezes = 2;

    // Last 30 days attendance (1 = attended, 0 = missed, null = no lecture)
    final last30Days = List.generate(30, (index) {
      if (index % 7 == 6) return null; // No lectures on Sunday
      if (index < 3) return 0; // Missed first 3 days
      return 1; // Attended rest
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Streak Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Day Streak',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                          const SizedBox(height: 8),
                          Text(
                            '$longestStreak',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Longest Streak',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.ac_unit, size: 40, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            '$streakFreezes',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Freezes Left',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // How Streaks Work
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How Streaks Work',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.check_circle,
                      Colors.green,
                      'Attend at least one lecture each day to maintain your streak',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.ac_unit,
                      Colors.blue,
                      'Use a freeze to protect your streak if you miss a day',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.star,
                      Colors.amber,
                      'Earn freezes by maintaining long streaks',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Last 30 Days Calendar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last 30 Days',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final status = last30Days[29 - index];
                        final date = DateTime.now().subtract(Duration(days: 29 - index));

                        Color color;
                        if (status == null) {
                          color = Colors.grey.shade200;
                        } else if (status == 1) {
                          color = Colors.green;
                        } else {
                          color = Colors.red;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: status == null ? Colors.grey : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(Colors.green, 'Attended'),
                        _buildLegendItem(Colors.red, 'Missed'),
                        _buildLegendItem(Colors.grey.shade200, 'No Lecture'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Use Freeze Button
            if (streakFreezes > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUseFreezeDialog(context),
                  icon: const Icon(Icons.ac_unit),
                  label: const Text('Use Streak Freeze'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showUseFreezeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Streak Freeze'),
        content: const Text(
          'Are you sure you want to use a streak freeze? This will protect your streak for one missed day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Streak freeze activated!')),
              );
            },
            child: const Text('Use Freeze'),
          ),
        ],
      ),
    );
  }
}
