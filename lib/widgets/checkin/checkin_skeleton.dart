import 'package:flutter/material.dart';
import '../common/skeleton_loader.dart';

class CheckInSkeleton extends StatelessWidget {
  const CheckInSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Lecture card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonLoader(
                        width: 80,
                        height: 28,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: SkeletonLoader(height: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SkeletonCircle(size: 16),
                      SizedBox(width: 4),
                      SkeletonLoader(width: 100, height: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      SkeletonCircle(size: 16),
                      SizedBox(width: 4),
                      SkeletonLoader(width: 120, height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Location status skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SkeletonCircle(size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonLoader(
                    height: 16,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Check-in button skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 60,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}
