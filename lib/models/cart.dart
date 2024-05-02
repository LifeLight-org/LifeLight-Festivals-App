import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Add this line
import 'package:lifelight_app/models/product.dart';
import 'package:lifelight_app/pages/home.dart';
import 'package:lifelight_app/pages/store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'package:logging/logging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lifelight_app/pages/orderspage.dart';

class CartItem extends ChangeNotifier {
  final Product product;
  int quantity;
  String? _size;
  int sizeId;

  CartItem(
      {required this.product,
      this.quantity = 1,
      String? size,
      required this.sizeId})
      : _size = size;

  String? get size => _size;

  void incrementQuantity() {
    quantity++;
  }

  set size(String? newSize) {
    _size = newSize;
    notifyListeners();
  }

  void decrementQuantity() {
    quantity--;
  }
}

class Cart extends ChangeNotifier {
  String? uuid;
  List<CartItem> items = [];

  void addItem(Product product, String? size, int sizeId) {
    try {
      final item = items
          .firstWhere((item) => item.product == product && item.size == size);
      item.incrementQuantity();
    } catch (e) {
      items.add(CartItem(product: product, size: size, sizeId: sizeId));
    }
    notifyListeners(); // Add this line
  }

  double getTotal() {
    return items.fold(
        0, (total, item) => total + item.product.price * item.quantity);
  }

  void updateItemSize(CartItem item, String newSize, int newSizeId) {
    final index = items.indexWhere((i) => i == item);
    if (index != -1) {
      items[index].size = newSize;
      items[index].sizeId = newSizeId;
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void incrementItemQuantity(Product product, String size) {
    final index = items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);
    if (index != -1) {
      items[index].quantity++;
    } else {
      items.add(CartItem(
          product: product,
          quantity: 1,
          size: size,
          sizeId: 0)); // Add sizeId here
    }
    notifyListeners();
  }

  void decrementItemQuantity(Product product, String size) {
    final index = items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        items.removeAt(index);
      }
    }
    notifyListeners();
  }

void checkout(BuildContext context) async {
  if (items.isEmpty) {
    EasyLoading.showInfo('Your cart is empty. Add items before checking out.');
    return;
  }

  EasyLoading.show(status: 'Placing order...');

  final sharedPreferences = await SharedPreferences.getInstance();
  uuid = sharedPreferences.getString('uuid');

  final code = randomAlphaNumeric(5);
  final total = getTotal();

  final response = await Supabase.instance.client.from('HA-orders').insert([
    {'uuid': uuid, 'orderCode': code, 'total': total},
  ]);

  if (response != null) {
    Logger('Cart').severe('Checkout error: $response');
    EasyLoading.showError('Checkout error: $response');
  } else {
    Logger('Cart').info('Checkout successful');
  }

  // Create a copy of the list for iteration
  final itemsCopy = List<CartItem>.from(items);

  for (var item in itemsCopy) {
    final response1 =
        await Supabase.instance.client.from('HA-productline').insert([
      {
        'productId': item.product.id,
        'orderCode': code,
        'sizeId': item.sizeId
      },
    ]);

    if (response1 != null) {
      Logger('Cart')
          .severe('Checkout error for item ${item.product.id}: $response1');
    } else {
      Logger('Cart').info('Checkout successful for item ${item.product.id}');
    }
  }

  await Future.delayed(const Duration(milliseconds: 500));
  items.clear();
  notifyListeners();
  EasyLoading.dismiss(); // Close the progress dialog

  EasyLoading.showInfo('Order placed! Your order number is $code');
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => HomePage()),
  (Route<dynamic> route) => false,
);

// Problem 2: Replace 'StorePage' with the correct widget
// Problem 5: Use the stored context
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => StorePage()),
);

// Problem 6: Use the stored context
// Problem 7: Add 'const' to the constructor invocation
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => OrdersPage()),
);
}
}