import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String? imageUrl;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.imageUrl = '', // Default value
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            children: [
              Image.network(
                imageUrl!.isEmpty
                    ? 'https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/temp_images/HA-arial.jpg'
                    : imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
              ),
              Container(
                width: double.infinity, // Full width
                height: 200.0, // Same height as the image
                color:
                    Colors.black.withOpacity(0.5), // Semi-transparent overlay
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Ensure text visibility
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16.0, color: Colors.white),
                          const SizedBox(width: 8.0),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.white, // Ensure text visibility
                            ),
                          ),
                        ],
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
