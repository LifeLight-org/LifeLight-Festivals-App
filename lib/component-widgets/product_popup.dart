import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProductPopup extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String imageUrl;
  final int productId;

  const ProductPopup({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.imageUrl,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  child: Image.network(
                    imageUrl,
                    width: 300.0,
                    height: 300.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 300.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '\$' + productPrice,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Generate the UUID and the 6 alphanumeric code
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? deviceId = prefs.getString('uuid');
                    final code = randomAlphaNumeric(6);

                    // Get the current time and add 20 minutes to it
                    final expiresAt = DateTime.now().add(Duration(minutes: 20));

                    // Format the DateTime object to the desired format
                    final expiresAtFormatted =
                        DateFormat("yyyy-MM-dd HH:mm:ss").format(expiresAt);

                    // Format the DateTime object to a more human-readable format
                    final expiresAtHumanReadable =
                        DateFormat("h:mm a 'on' MMMM d, yyyy")
                            .format(expiresAt);

                    // Send the data to Supabase
                    final response = await Supabase.instance.client
                        .from('HA-producthold')
                        .insert([
                      {
                        'uuid': deviceId,
                        'orderCode': code,
                        'productId': productId.toString(),
                        'expiresAt': expiresAtFormatted,
                      },
                    ]);

                    if (response == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Item Being Held',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Your code is $code and it expires at $expiresAtHumanReadable',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close AlertDialog
                                  Navigator.of(context)
                                      .pop(); // Close ProductPopup
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if (response.error != null) {
                      print('Error: ${response.error!.message}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: Size(240,
                        55), // Set the minimum width and height of the button
                  ),
                  child: Text(
                    'PLACE ITEM ON HOLD',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
