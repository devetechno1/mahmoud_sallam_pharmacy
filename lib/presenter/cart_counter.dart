// import 'dart:async';

// import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
// import 'package:flutter/material.dart';

// class CartCounter extends ChangeNotifier {
//   int cartCounter = 0;

//   getCount() async {
//     var res = await CartRepository().getCartCount();
//     cartCounter = res.count;
//     notifyListeners();
//   }
// }
import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/repositories/cart_repository.dart';
import 'package:flutter/material.dart';

class CartCounter extends ChangeNotifier {
  int cartCounter = 0;

  Future<void> getCount() async {
    final res = await CartRepository().getCartCount();
    // Ensure res.count is not null
    cartCounter = res.count ?? 0; // Default to 0 if count is null
    notifyListeners();
  }
}
