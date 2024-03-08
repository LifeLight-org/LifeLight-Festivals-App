import 'package:flutter/material.dart';

class Artist {
  final String name;
  final String image;
  final String day;
  final String time;
  final String stage;
  final String link;

  Artist({
    required this.name,
    required this.image,
    required this.day,
    required this.time,
    required this.stage,
    required this.link,
  });
}

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistCard({super.key, required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(artist.image, // Placeholder image URL
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      artist.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}