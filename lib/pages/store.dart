import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/component-widgets/product_popup.dart';
import 'package:lifelight_app/component-widgets/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/pages/held_product_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  StorePageState createState() => StorePageState();
}

class StorePageState extends State<StorePage> {
  List<StoreItem> StoreItems = [];

  @override
  void initState() {
    super.initState();
    fetchStoreItems();
  }

  Future<void> fetchStoreItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = "${selectedFestival ?? 'ha'}-store";

    final response = await Supabase.instance.client.from(tableName).select('*');

    if (response.isEmpty) {
      throw Exception('No artists found');
    }

    List<StoreItem> items = await Future.wait(
        response.map((item) => StoreItem.fromJson(item)).toList());

    setState(() {
      StoreItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HeldProductsPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchStoreItems,
        child: ListView.builder(
          itemCount: StoreItems.length,
          itemBuilder: (context, index) {
            final StoreItem = StoreItems[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ProductPopup(
                      productName: StoreItem.name,
                      productPrice: StoreItem.price,
                      imageUrl: StoreItem.image,
                      productId: StoreItem.id,
                    );
                  },
                );
              },
              child: ProductCard(
                title: StoreItem.name,
                price: StoreItem.price,
                imageUrl: StoreItem.image,
              ),
            );
          },
        ),
      ),
    );
  }
}

class StoreItem {
  final int id; // Add this line
  final String name;
  final String image;
  final String price;

  StoreItem({
    required this.id, // And this line
    required this.name,
    required this.image,
    required this.price,
  });

  static Future<StoreItem> fromJson(Map<String, dynamic> json) async {
    return StoreItem(
      id: json['id'], // And this line
      name: json['name'],
      image: json['image'],
      price: json['price'],
    );
  }
}
