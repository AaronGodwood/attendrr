import 'base_repository.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class ShopRepository extends BaseRepository {
  static final ShopRepository instance = ShopRepository._();
  ShopRepository._();

  static const List<ShopItem> _catalog = [
    ShopItem(
      type: ShopItemType.streakFreeze,
      cost: AppConstants.streakFreezeCost,
    ),
    ShopItem(
      type: ShopItemType.weeklyPointsBoost,
      cost: AppConstants.weeklyBoostCost,
    ),
  ];

  List<ShopItem> getCatalog() => _catalog;

  Future<({int newPoints, int newFreezes})> purchaseStreakFreeze() async {
    requireAuth();
    final result = await client.rpc(
      'purchase_streak_freeze',
      params: {
        'p_user_id': currentUserId!,
        'p_cost': AppConstants.streakFreezeCost,
      },
    );

    final map = result as Map<String, dynamic>;
    return (
      newPoints: map['new_points'] as int,
      newFreezes: map['new_freezes'] as int,
    );
  }

  Future<({int newPoints, DateTime? boostExpiresAt})>
  purchaseWeeklyBoost() async {
    requireAuth();
    final result = await client.rpc(
      'purchase_weekly_boost',
      params: {
        'p_user_id': currentUserId!,
        'p_cost': AppConstants.weeklyBoostCost,
        'p_multiplier': AppConstants.weeklyBoostMultiplier,
      },
    );

    final map = result as Map<String, dynamic>;
    final expiresAt =
        map['boost_expires_at'] != null
            ? DateTime.parse(map['boost_expires_at'] as String)
            : null;
    return (newPoints: map['new_points'] as int, boostExpiresAt: expiresAt);
  }

  Future<List<Purchase>> getPurchaseHistory() async {
    requireAuth();
    final response = await client
        .from('purchases')
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((j) => Purchase.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
