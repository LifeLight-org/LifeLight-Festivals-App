import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifelight_festivals/z8_events.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  EventDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.image != null && event.image!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  event.image!,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              event.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('MMMM d, yyyy').format(event.date)} @ ${event.time.format(context)}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Doors open at: ${event.doors_open_time.format(context)}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Add more detailed information about the event here
            Text(
              event.description ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}