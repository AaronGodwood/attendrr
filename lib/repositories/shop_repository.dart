import 'base_repository.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class ShopRepository extends BaseRepository {
  static final ShopRepository instance = ShopRepository._();
  ShopRepository._();

  static const List<ShopItem> _catalog = [
    ShopItem(type: ShopItemType.streakFreeze, cost: AppConstants.streakFreezeCost),
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
