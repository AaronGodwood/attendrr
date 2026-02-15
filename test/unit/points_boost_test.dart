import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/models/points.dart';

void main() {
  test('UT-08 Weekly boost active when multiplier > 1 and not expired', () {
    final now = DateTime.now();
    final points = Points(
      id: 'p1',
      userId: 'u1',
      totalPoints: 0,
      weeklyPoints: 0,
      monthlyPoints: 0,
      weeklyBoostMultiplier: 1.1,
      weeklyBoostExpiresAt: now.add(const Duration(days: 1)),
      createdAt: now,
      updatedAt: now,
    );

    expect(points.weeklyBoostActive, isTrue);
  });

  test('UT-08 Weekly boost inactive when expired', () {
    final now = DateTime.now();
    final points = Points(
      id: 'p2',
      userId: 'u2',
      totalPoints: 0,
      weeklyPoints: 0,
      monthlyPoints: 0,
      weeklyBoostMultiplier: 1.1,
      weeklyBoostExpiresAt: now.subtract(const Duration(minutes: 1)),
      createdAt: now,
      updatedAt: now,
    );

    expect(points.weeklyBoostActive, isFalse);
  });
}
