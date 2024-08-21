import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lifelight_festivals/components/EventDetailsPage.dart';

// Define the Event class
class Event {
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String? image;
  final String? description;
  final TimeOfDay doors_open_time;

  Event(
      {required this.name,
      required this.date,
      required this.time,
      this.image,
      this.description,
      required this.doors_open_time});

  static TimeOfDay parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}

// Define the DatabaseHelper class with a getEvents method
class DatabaseHelper {
  Future<List<Event>> getEvents() async {
    final response = await Supabase.instance.client
        .from('events')
        .select('*')
        .order('date', ascending: true);
    final data = response as List<dynamic>;
    return data.map((item) {
      return Event(
        name: item['name'] as String,
        date: DateTime.parse(item['date'] as String),
        time: Event.parseTime(item['time'] as String),
        image: item['image'] as String?,
        description: item['description'] as String?,
        doors_open_time: Event.parseTime(item['doors_open_time'] as String),
      );
    }).toList();
  }
}

class EventsPage extends StatefulWidget {
  final Key? key;

  EventsPage({this.key}) : super(key: key);

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = DatabaseHelper().getEvents();
  }

  String formatDate(DateTime date) {
    final daySuffix = (int day) {
      if (day >= 11 && day <= 13) {
        return 'th';
      }
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    };

    final formattedDate = DateFormat('MMMM d').format(date);
    final day = date.day;
    return '$formattedDate${daySuffix(day)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVENTS'),
      ),
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(event: event),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Card(
                            elevation: 4,
                            child: Stack(
                              children: [
                                // Background image
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: event.image ??
                                        'https://xsssdjpayiloazwsamfu.supabase.co/storage/v1/object/public/festival_media/event_images/Z8_Event_Default_Background.png',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                // Gradient overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.7),
                                          Colors.transparent
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                // Text content
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${formatDate(event.date)} @ ${event.time.format(context)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
