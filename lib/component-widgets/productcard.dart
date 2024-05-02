import 'package:flutter/material.dart';
import 'package:lifelight_app/models/cart.dart';
import 'package:lifelight_app/models/product.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:overlay_support/overlay_support.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Future<List<Map<String, dynamic>>> fetchSizes() async {
    final response = await Supabase.instance.client.from('HA-sizes').select();

    return (response as List)
        .map((item) => {
              'size_name': item['size_name'] as String,
              'id': item['id'] is int ? item['id'] as int : null
            })
        .toList();
  }

  String? selectedSize;
  int? selectedSizeId;

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 340,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchSizes(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return DropdownButton<String>(
                          value: selectedSize,
                          hint: const Text('Select size'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSize = newValue;
                              selectedSizeId = snapshot.data!.firstWhere(
                                  (item) => item['size_name'] == newValue,
                                  orElse: () => {'size_id': null})['id'];
                            });
                          },
                          items: snapshot.data!.map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> value) {
                            return DropdownMenuItem<String>(
                              value: value['size_name'],
                              child: Text(value['size_name']),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width:
                      double.infinity, // Makes the button span the full width
                  child: ElevatedButton(
                    onPressed: selectedSizeId != null
                        ? () {
                            var cart =
                                Provider.of<Cart>(context, listen: false);
                            if (selectedSize != null) {
                              cart.addItem(widget.product, selectedSize!,
                                  selectedSizeId!);
                              showSimpleNotification(
                                DefaultTextStyle(
                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                  child: Text(
                                      '${widget.product.title} Added to cart'),
                                ),
                                background: Color(0xffFFD000),
                                position: NotificationPosition.top,
                              );
                            }
                          }
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFD000),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ));
  }
}
