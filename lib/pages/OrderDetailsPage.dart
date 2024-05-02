import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  OrderDetailsPage({required this.order});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<List<Map<String, dynamic>>> _productsFuture;
  late Future<List<Map<String, dynamic>>> _sizesFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
    _sizesFuture = fetchSizes();
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response =
        await Supabase.instance.client.from('HA-products').select();
    print(response);
    return (response as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchSizes() async {
    final response = await Supabase.instance.client.from('HA-sizes').select();
    print(response);
    return (response as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_productsFuture, _sizesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final products = snapshot.data![0] as List<Map<String, dynamic>>;
            final sizes = snapshot.data![1] as List<Map<String, dynamic>>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Order ID: ${widget.order['id']}'),
                  Text('Order Code: ${widget.order['orderCode']}'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.order['products'].length,
                      itemBuilder: (context, index) {
                        final product = widget.order['products'][index];
                        print(product);
                        final productName = products.firstWhere(
                          (p) => p['id'] == product['productId'],
                          orElse: () => {'name': 'Unknown product'},
                        )['name'];

                        final sizeName = sizes.firstWhere(
                          (s) => s['id'] == product['sizeId'],
                          orElse: () => {'size_name': 'Unknown size'},
                        )['size_name'];
                        return ListTile(
                          title: Text('Product Name: $productName'),
                          subtitle: Text('Size Name: $sizeName'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
