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
          const SkeletonLoader(width: 100, height: 16),
          const SizedBox(height: 20),

          // Stats card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const SkeletonLoader(width: 50, height: 32),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 60,
                        height: 14,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SkeletonLoader(width: 50, height: 32),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        width: 60,
                        height: 14,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attendance stats skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 120, height: 18),
                  const SizedBox(height: 16),
                  _buildStatRowSkeleton(),
                  const Divider(),
                  _buildStatRowSkeleton(),
                  const Divider(),
                  _buildStatRowSkeleton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Chart skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 100, height: 18),
                  const SizedBox(height: 16),
                  SkeletonLoader(
                    width: double.infinity,
                    height: 100,
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

  Widget _buildStatRowSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SkeletonLoader(width: 80, height: 16),
          Row(
            children: [
              const SkeletonLoader(width: 60, height: 16),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 50,
                height: 20,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
