import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/pages/OrderDetailsPage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = initializeOrders();
  }

  Future<List<Map<String, dynamic>>> initializeOrders() async {
    await deleteOldOrders();
    return fetchOrders();
  }

  Future<void> deleteOldOrders() async {
    final response = await Supabase.instance.client.from('HA-orders').select();

    final orders =
        (response as List).map((item) => item as Map<String, dynamic>).toList();

    for (var order in orders) {
      final createdAt = DateTime.parse(order['created_at']);
      final difference = DateTime.now().difference(createdAt);

      if (difference.inMinutes > 30) {
        await Supabase.instance.client
            .from('HA-orders')
            .delete()
            .eq('id', order['id']);
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? uuid = sharedPreferences.getString('uuid');
    final response = await Supabase.instance.client
        .from('HA-orders')
        .select()
        .eq('uuid', uuid ?? '');

    List<Map<String, dynamic>> orders =
        (response as List).map((item) => item as Map<String, dynamic>).toList();

    for (var order in orders) {
      final productResponse = await Supabase.instance.client
          .from('HA-productline')
          .select()
          .eq('orderCode', order['orderCode']);
      order['products'] = (productResponse as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('You have no orders'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return ListTile(
                  title: Text('Order ${order['orderCode']}'),
                  subtitle: Text('Total: \$${order['total']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
