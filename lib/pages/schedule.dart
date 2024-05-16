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

  // Sort the items by time
  items.sort((a, b) {
    DateTime timeA = displayFormat.parse(a.time); // Use displayFormat instead of timeFormat
    DateTime timeB = displayFormat.parse(b.time); // Use displayFormat instead of timeFormat
    return timeA.compareTo(timeB); // Compare DateTime objects
  });

  setState(() {
    scheduleItems = items;
  });
}

  Future<List<String>> fetchLocations(String date) async {
    String tableName = "$selectedFestival-schedule";
    final response =
        await Supabase.instance.client.from(tableName).select('location');

    // Extract the locations and remove duplicates
    List<String> locations =
        response.map((item) => item['location'] as String).toSet().toList();

    // Filter out locations that don't have any associated schedule items
    locations = locations.where((location) {
      return scheduleItems
          .any((item) => item.location == location && item.date == date);
    }).toList();

    return locations;
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dates.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          bottom: dates.length > 1
              ? PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),

                    child: TabBar(
                      tabs: dates.map((date) => Tab(text: date)).toList(),
                    ),
                )
              : null,
        ),
        body: TabBarView(
          children: dates.map((date) {
            return FutureBuilder<List<String>>(
              future: fetchLocations(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If there is only one location, hide the location TabBar
                  if (snapshot.data!.length == 1) {
                    var location = snapshot.data!.first;
                    var itemsForLocation = scheduleItems
                        .where((item) =>
                            item.date == date && item.location == location)
                        .toList();
                    var itemsGroupedByTime = groupBy<ScheduleItem, String>(
                      itemsForLocation,
                      (item) => item.time,
                    );
                    return buildListView(itemsGroupedByTime, context);
                  } else {
                    return DefaultTabController(
                      length: snapshot.data!.length,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: snapshot.data!
                                .map((location) => Tab(text: location))
                                .toList(),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: snapshot.data!.map((location) {
                                // Filter the schedule items for the current date and location
                                var itemsForLocation = scheduleItems
                                    .where((item) =>
                                        item.date == date &&
                                        item.location == location)
                                    .toList();

                                // Group the items by time
                                var itemsGroupedByTime =
                                    groupBy<ScheduleItem, String>(
                                  itemsForLocation,
                                  (item) => item.time,
                                );

                                return buildListView(
                                    itemsGroupedByTime, context);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

Widget buildListView(Map<String, List<ScheduleItem>> itemsGroupedByTime, BuildContext context) {
  var sortedKeys = itemsGroupedByTime.keys.toList()
    ..sort((a, b) {
      DateTime timeA = displayFormat.parse(a); // Use displayFormat instead of timeFormat
      DateTime timeB = displayFormat.parse(b); // Use displayFormat instead of timeFormat
      return timeA.compareTo(timeB);
    });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final time = sortedKeys[index];
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
  }
}

class ScheduleItem {
  final String title;
  final String time; // Change this back to String
  final String date;
  final String location;
  final String imageUrl;

  ScheduleItem({
    required this.title,
    required this.time, // Change this back to String
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  static Future<ScheduleItem> fromJson(Map<String, dynamic> json,
      DateFormat timeFormat, DateFormat displayFormat) async {
    final time = timeFormat.parse(json['time'], true); // This is now a DateTime

    // Format the time
    String formattedTime = displayFormat.format(time);

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
      time: formattedTime, // Use the formatted time
      date: formattedDate, // Use the formatted date
      location: json['location'],
    );
  }
}
