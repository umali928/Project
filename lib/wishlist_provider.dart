import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistedProductIds = {};

  bool isWishlisted(String productId) {
    return _wishlistedProductIds.contains(productId);
  }

  void addToWishlist(String productId) {
    _wishlistedProductIds.add(productId);
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistedProductIds.remove(productId);
    notifyListeners();
  }

  void setInitialWishlist(List<String> ids) {
    _wishlistedProductIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }
}
