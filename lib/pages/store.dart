import 'package:flutter/material.dart';
import 'package:lifelight_app/component-widgets/productcard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Product {
  final String title;
  final int price;
  final String imageUrl;

  Product({
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['name'],
      price: json['price'],
      imageUrl: json['image'],
    );
  }
}

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
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {

                  },
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ProductCard(
                  title: product.title,
                  price: product.price,
                  imageUrl: product.imageUrl,
                );
              },
            ),
          );
        }
      },
    );
  }
}
