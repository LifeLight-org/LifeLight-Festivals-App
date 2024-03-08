import 'package:flutter/material.dart';

class ArtistPopup extends StatelessWidget {
  final String artistName;
  final String playtime;
  final String imageUrl;
  final String aboutText;

  const ArtistPopup({super.key,
    required this.artistName,
    required this.playtime,
    required this.imageUrl,
    required this.aboutText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Add padding around the whole popup
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
                      padding: const EdgeInsets.only(
                          right: 16.0), // Add padding to the right of the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align the text to the left
                        children: [
                          Text(
                            artistName,
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            playtime,
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(), // Pushes the image to the far right
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
                  padding: const EdgeInsets.only(
                      top: 16.0), // Adjust the value as needed
                  child: Text(
                    'About $artistName',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold, // Add this line
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                      bottom: 8.0), // Adjust the value as needed
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
