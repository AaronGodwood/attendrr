import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/shop_repository.dart';
import '../repositories/user_repository.dart';

class ShopProvider extends ChangeNotifier {
  final _shopRepo = ShopRepository.instance;
  final _userRepo = UserRepository.instance;

  List<ShopItem> _items = [];
  int _userPoints = 0;
  int _userFreezes = 0;
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _error;

  List<ShopItem> get items => _items;
  int get userPoints => _userPoints;
  int get userFreezes => _userFreezes;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;

  Future<void> loadShop() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _userRepo.getCurrentPoints(),
        _userRepo.getCurrentStreak(),
      ]);

      final points = results[0] as Points;
      final streak = results[1] as Streak;

      _userPoints = points.totalPoints;
      _userFreezes = streak.streakFreezes;

      _items = _shopRepo.getCatalog().map((item) {
        if (item.type == ShopItemType.streakFreeze) {
          return item.copyWith(userQuantity: _userFreezes);
        }
        return item;
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> purchaseStreakFreeze() async {
    _isPurchasing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _shopRepo.purchaseStreakFreeze();
      _userPoints = result.newPoints;
      _userFreezes = result.newFreezes;

      // Refresh items with new quantity
      _items = _shopRepo.getCatalog().map((item) {
        if (item.type == ShopItemType.streakFreeze) {
          return item.copyWith(userQuantity: _userFreezes);
        }
        return item;
      }).toList();

      _isPurchasing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isPurchasing = false;
      _error = e.toString().contains('Insufficient points')
          ? 'Not enough points!'
          : 'Purchase failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
