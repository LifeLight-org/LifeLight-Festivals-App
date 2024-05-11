import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/component-widgets/event_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class SchedulePage extends StatefulWidget {
  SchedulePage({Key? key}) : super(key: key);

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  late SharedPreferences prefs;
  late String selectedFestival;
  List<ScheduleItem> scheduleItems = [];
  List<String> dates = [];
  final timeFormat = DateFormat('HH:mm:ss');
  final displayFormat = DateFormat('h:mm a');

  Future<List<String>> fetchDates() async {
    String tableName = "$selectedFestival-schedule";
    final response =
        await Supabase.instance.client.from(tableName).select('date');

    if (response == null) {
      throw Exception('Error fetching dates');
    }

    // Extract the dates and remove duplicates
    List<String> dates =
        response.map((item) => item['date'] as String).toSet().toList();

    // Format the dates
    DateFormat dateFormat = DateFormat('EEEE, MMM d');
    List<String> formattedDates = dates.map((date) {
      DateTime dateTime = DateTime.parse(date);
      return dateFormat.format(dateTime);
    }).toList();

    // Sort the dates
    formattedDates.sort((a, b) {
      DateTime dateTimeA = dateFormat.parse(a);
      DateTime dateTimeB = dateFormat.parse(b);
      return dateTimeA.compareTo(dateTimeB);
    });

    return formattedDates;
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await initPrefs();
    dates = await fetchDates();
    fetchScheduleItems();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    selectedFestival = prefs.getString('selectedFestivalDBPrefix') ?? 'ha';
  }

  Future<void> fetchScheduleItems() async {
    String tableName = "$selectedFestival-schedule";

    final response = await Supabase.instance.client.from(tableName).select('*');

    if (response.isEmpty) {
      throw Exception('No artists found');
    }

    List<ScheduleItem> items = await Future.wait(response
        .map((item) => ScheduleItem.fromJson(item, timeFormat, displayFormat))
        .toList());

    setState(() {
      scheduleItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dates.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          bottom: dates.length > 1
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0), // Adjust the padding as needed
                    child: TabBar(
                      isScrollable: true,
                      tabs: dates.map((date) => Tab(text: date)).toList(),
                    ),
                  ),
                )
              : null,
        ),
        body: TabBarView(
  children: dates.map((date) {
    // Filter the schedule items for the current date
    var itemsForDate =
        scheduleItems.where((item) => item.date == date).toList();

    // Group the items by time
    var itemsGroupedByTime = groupBy<ScheduleItem, String>(
      itemsForDate,
      (item) => item.time,
    );

    return ListView.builder(
      itemCount: itemsGroupedByTime.keys.length,
      itemBuilder: (context, index) {
        final time = itemsGroupedByTime.keys.elementAt(index);
        final itemsForTime = itemsGroupedByTime[time]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                time,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            ...itemsForTime.map((scheduleItem) {
              return EventCard(
                title: scheduleItem.title,
                imageUrl: scheduleItem.imageUrl,
                time: scheduleItem.time,
                date: scheduleItem.date,
                location: scheduleItem.location,
              );
            }).toList(),
          ],
        );
      },
    );
  }).toList(),
),
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

  static Future<ScheduleItem> fromJson(Map<String, dynamic> json,
      DateFormat timeFormat, DateFormat displayFormat) async {
    final time = timeFormat.parse(json['time'], true);
    final formattedTime = displayFormat.format(time);

    // Parse the date string into a DateTime object
    DateTime date = DateTime.parse(json['date']);

    // Format the date
    DateFormat dateFormat = DateFormat('EEEE, MMM d');
    String formattedDate = dateFormat.format(date);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String defaultImageUrl =
        "https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/temp_images/${selectedFestival ?? 'HA'}-arial.jpg";

    return ScheduleItem(
      title: json['title'],
      imageUrl: json['imageUrl'] ?? defaultImageUrl,
      time: formattedTime,
      date: formattedDate, // Use the formatted date
      location: json['location'],
    );
  }
}