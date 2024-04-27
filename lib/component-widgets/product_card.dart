import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? imageUrl;

  const ProductCard({
    Key? key,
    required this.title,
    required this.price,
    this.imageUrl = '', // Default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: Image.network(
              imageUrl!.isEmpty
                  ? 'https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/temp_images/HA-arial.jpg'
                  : imageUrl!,
              fit: BoxFit.scaleDown,
              width: 300,
              height: 300.0,
            ),
          ),
          Container(
            width: 300,
            color: const Color(0x2c2c2c), // Grey background
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}