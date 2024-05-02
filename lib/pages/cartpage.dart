import 'package:flutter/material.dart';
import 'package:lifelight_app/models/cart.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> sizesFuture;

  Future<List<Map<String, dynamic>>> fetchSizes() async {
    final response = await Supabase.instance.client.from('HA-sizes').select();
    return (response as List)
        .map((item) =>
            {'size_name': item['size_name'], 'size_id': item['id']})
        .toList();
  }

  @override
  void initState() {
    super.initState();
    sizesFuture = fetchSizes();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        double total = cart.items.fold(
            0,
            (previousValue, item) =>
                previousValue + item.product.price * item.quantity);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart'),
          ),
          body: Stack(
            children: [
              cart.items.isEmpty
                  ? const Center(
                      child: Text('Your cart is empty.',
                          style: TextStyle(fontSize: 20, color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(item.product.title,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      width: 155,
                                      color: const Color(0xffFFD000),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                                item.quantity == 1
                                                    ? Icons.delete
                                                    : Icons.remove,
                                                size: 35,
                                                color: Colors.black),
                                            onPressed: () {
                                              if (item.size != null) {
                                                cart.decrementItemQuantity(
                                                    item.product, item.size!);
                                              }
                                            },
                                            padding: const EdgeInsets.all(13),
                                          ),
                                          Text(item.quantity.toString(),
                                              style: const TextStyle(
                                                  fontSize: 35,
                                                  color: Colors.black)),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 35, color: Colors.black),
                                            onPressed: () {
                                              if (item.size != null) {
                                                cart.incrementItemQuantity(
                                                    item.product, item.size!);
                                              }
                                            },
                                            padding: const EdgeInsets.all(13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.grey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${item.product.price * item.quantity}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                      future: sizesFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return DropdownButton<String>(
                                            value: item.size,
                                            items: snapshot.data!.map<
                                                    DropdownMenuItem<String>>(
                                                (Map<String, dynamic> value) {
                                              return DropdownMenuItem<String>(
                                                value: value['size_name'],
                                                child: Text(value['size_name']),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                final sizeId = snapshot.data!
                                                        .firstWhere((size) =>
                                                            size['size_name'] ==
                                                            newValue)['size_id'];
                                                Provider.of<Cart>(context,
                                                        listen: false)
                                                    .updateItemSize(
                                                        item, newValue, sizeId);
                                              }
                                            },
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 60,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  child: Text('Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 16,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      cart.checkout(context);
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
