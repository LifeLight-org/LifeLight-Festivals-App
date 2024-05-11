import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lifelight_app/supabase_client.dart';

class SponsorAd extends StatefulWidget {
  @override
  _SponsorAdState createState() => _SponsorAdState();
}

Future<String> getRandomAd() async {
  final response = await supabase.from('HA-sponsors').select('advert');

  if (response == null) {
    throw Exception('Failed to fetch ads: ${response}');
  }

  final ads = response as List<dynamic>;
  if (ads.isEmpty) {
    throw Exception('No ads found');
  }

  // Filter out null and empty entries
  final nonNullAds = ads
      .where((ad) => ad['advert'] != null && ad['advert'].isNotEmpty)
      .toList();
  if (nonNullAds.isEmpty) {
    throw Exception('No non-null ads found');
  }
  print('Non-null ads: $nonNullAds');
  final randomAd = nonNullAds[Random().nextInt(nonNullAds.length)];
  print('Random ad: $randomAd');
  return randomAd['advert'] as String;
}

class _SponsorAdState extends State<SponsorAd> {
  late Future<String> _adFuture;

  @override
  void initState() {
    super.initState();
    _adFuture = getRandomAd();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _adFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Shrink the column to fit the content
                    children: <Widget>[
                      const SizedBox(height: 10),
                      const Text(
                        'Thank you to our incredible sponsors!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ), // Text at the top
                      const SizedBox(height: 10),
                      AspectRatio(
                        aspectRatio: 9 / 16, // Adjust this value as needed
                        child:
                            snapshot.connectionState == ConnectionState.waiting
                                ? const CircularProgressIndicator()
                                : FittedBox(
                                    child: Image.network(snapshot.data!),
                                    fit: BoxFit.contain,
                                  ), // Ad image
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white,
                      size: 30), // Change color and size here
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
