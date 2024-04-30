import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HeldProductsPage extends StatefulWidget {
  @override
  _HeldProductsPageState createState() => _HeldProductsPageState();
}

class _HeldProductsPageState extends State<HeldProductsPage> {
  List<dynamic> heldProducts = [];

  @override
  void initState() {
    super.initState();
    fetchHeldProducts();
  }

  Future<void> fetchHeldProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = "${selectedFestival ?? 'ha'}-producthold";
    String deviceUUID = prefs.getString('uuid') ?? 'defaultUUID'; // Replace with your device UUID

    final response = await Supabase.instance.client
        .from(tableName)
        .select()
        .eq('uuid', deviceUUID);

      setState(() {
        heldProducts = response as List<dynamic>;
    });
  }

@override
Widget build(BuildContext context) {
  DateTime now = DateTime.now();

  List<dynamic> unexpiredProducts = heldProducts.where((product) {
    DateTime expiresAt = DateTime.parse(product['expiresAt']);
    return expiresAt.isAfter(now);
  }).toList();

  return Scaffold(
    appBar: AppBar(
      title: Text('Held Products'),
    ),
    body: RefreshIndicator(
      onRefresh: fetchHeldProducts,
      child: ListView(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text('Order Code'),
                ),
                DataColumn(
                  label: Text('Expires At'),
                ),
              ],
              rows: List<DataRow>.generate(
                unexpiredProducts.length,
                (index) => DataRow(
                  cells: <DataCell>[
                    DataCell(
                        Text(unexpiredProducts[index]['orderCode'].toString())),
                    DataCell(Text(DateFormat('MM-dd-yyyy – KK:mm a').format(
                        DateTime.parse(unexpiredProducts[index]['expiresAt'])))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
