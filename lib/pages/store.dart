import 'package:flutter/material.dart';
import 'package:lifelight_app/component-widgets/productcard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/models/cart.dart';
import 'package:lifelight_app/pages/cartpage.dart';
import 'package:lifelight_app/models/product.dart';
import 'package:lifelight_app/pages/orderspage.dart';
import 'package:provider/provider.dart';

class StorePage extends StatelessWidget {
  StorePage({Key? key}) : super(key: key);

  Future<List<Product>> _getProducts() async {
    final response =
        await Supabase.instance.client.from('HA-products').select();

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Store'),
              actions: <Widget>[
                Consumer<Cart>(
                  builder: (context, cart, child) {
                    return Stack(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartPage(),
                              ),
                            );
                          },
                        ),
                        if (cart.items.length > 0)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 10.0,
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              child: Text(
                                cart.items.length.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.receipt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ProductCard(
                  product: product,
                );
              },
            ),
          );
        }
      },
    );
  }
}