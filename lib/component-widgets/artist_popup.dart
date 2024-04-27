import 'package:flutter/material.dart';

class ArtistPopup extends StatelessWidget {
  final String artistName;
  final String stage;
  final String playtime;
  final String imageUrl;
  final String aboutText;

  const ArtistPopup({
    Key? key,
    required this.artistName,
    required this.stage,
    required this.playtime,
    required this.imageUrl,
    required this.aboutText,
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
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artistName,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.0,
                                color: Colors.grey,
                              ),
                              Text(
                                stage,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.0,
                                color: Colors.grey,
                              ),
                              Text(
                                playtime,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ClipRRect(
                      child: Image.network(
                        imageUrl,
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'About $artistName',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Divider(thickness: 1.0),
                ),
                Text(aboutText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
