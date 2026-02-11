import 'package:flutter/material.dart';
import '../common/skeleton_loader.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header skeleton
          const SkeletonCircle(size: 100),
          const SizedBox(height: 12),
          const SkeletonLoader(width: 150, height: 24),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: 80,
            height: 22,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 20),

          // Tier progress card skeleton
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonLoader(
                        width: 100,
                        height: 28,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const Spacer(),
                      const SkeletonLoader(width: 80, height: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SkeletonLoader(
                    width: double.infinity,
                    height: 10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: 120, height: 12),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonLoader(
                        width: 100,
                        height: 28,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 8),
                      SkeletonLoader(
                        width: 110,
                        height: 28,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Streak card skeleton
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SkeletonCircle(size: 64),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLoader(width: 130, height: 20),
                          const SizedBox(height: 8),
                          SkeletonLoader(
                            width: 70,
                            height: 20,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const SkeletonLoader(width: 40, height: 22),
                          const SizedBox(height: 4),
                          const SkeletonLoader(width: 50, height: 12),
                        ],
                      ),
                      Column(
                        children: [
                          const SkeletonLoader(width: 40, height: 22),
                          const SizedBox(height: 4),
                          const SkeletonLoader(width: 50, height: 12),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Attendance rings skeleton
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 100, height: 20),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const SkeletonCircle(size: 80),
                          const SizedBox(height: 8),
                          const SkeletonLoader(width: 50, height: 14),
                        ],
                      ),
                      Column(
                        children: [
                          const SkeletonCircle(size: 80),
                          const SizedBox(height: 8),
                          const SkeletonLoader(width: 50, height: 14),
                        ],
                      ),
                      Column(
                        children: [
                          const SkeletonCircle(size: 80),
                          const SizedBox(height: 8),
                          const SkeletonLoader(width: 50, height: 14),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chart skeleton
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 100, height: 20),
                  const SizedBox(height: 4),
                  const SkeletonLoader(width: 150, height: 12),
                  const SizedBox(height: 20),
                  SkeletonLoader(
                    width: double.infinity,
                    height: 140,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 24),
                  const SkeletonLoader(width: 110, height: 14),
                  const SizedBox(height: 12),
                  SkeletonLoader(
                    width: double.infinity,
                    height: 60,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
