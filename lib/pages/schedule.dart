import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/component-widgets/event_card.dart';
import 'package:intl/intl.dart';
import '/components/basepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  List<ScheduleItem> scheduleItems = [];

  @override
  void initState() {
    super.initState();
    fetchScheduleItems();
  }

  Future<void> fetchScheduleItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = "${selectedFestival ?? 'ha'}-schedule";

    final response = await Supabase.instance.client.from(tableName).select('*');

    if (response.isEmpty) {
      throw Exception('No artists found');
    }

    List<ScheduleItem> items = await Future.wait(
        response.map((item) => ScheduleItem.fromJson(item)).toList());

    setState(() {
      scheduleItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Schedule',
      child: ListView.builder(
        itemCount: scheduleItems.length,
        itemBuilder: (context, index) {
          final scheduleItem = scheduleItems[index];
          return EventCard(
            title: scheduleItem.title,
            imageUrl: scheduleItem.imageUrl,
            time: scheduleItem.time,
            date: scheduleItem.date,
            location: scheduleItem.location,
          );
        },
      ),
    );
  }
}

class ScheduleItem {
  final String title;
  final String time;
  final String date;
  final String location;
  final String imageUrl;

  ScheduleItem({
    required this.title,
    required this.time,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  static Future<ScheduleItem> fromJson(Map<String, dynamic> json) async {
    final timeFormat = DateFormat('HH:mm:ss');
    final displayFormat = DateFormat('h:mm a');

    final time = timeFormat.parse(json['time'], true);
    final formattedTime = displayFormat.format(time);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String defaultImageUrl =
        "https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/temp_images/${selectedFestival ?? 'HA'}-arial.jpg";

    return ScheduleItem(
      title: json['title'],
      imageUrl: json['imageUrl'] ?? defaultImageUrl,
      time: formattedTime,
      date: json['date'],
      location: json['location'],
    );
  }
}
