import 'dart:convert';
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
  bool isLoading = false;

  Future<List<String>> fetchDates() async {
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');
    final response = await Supabase.instance.client
        .from("schedule")
        .select('date')
        .eq("festival", selectedFestivalId!);

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
    isLoading = false;
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
    setState(() {
      isLoading = true; // Step 3: Set the loading state to true before fetching
    });
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');
    final response = await Supabase.instance.client
        .from("schedule")
        .select('*')
        .eq('festival', selectedFestivalId!);

    if (response.isEmpty) {
      throw Exception('No artists found');
    }

    List<ScheduleItem> items = await Future.wait(response
        .map((item) => ScheduleItem.fromJson(item, timeFormat, displayFormat))
        .toList());

    items.sort((a, b) {
      DateTime timeA = displayFormat.parse(a.time);
      DateTime timeB = displayFormat.parse(b.time);
      return timeA.compareTo(timeB);
    });

    setState(() {
      scheduleItems = items;
      isLoading = false; // Step 4: Reset the loading state after fetching
    });
  }

  Future<List<String>> fetchLocations(String date) async {
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');

    final response = await Supabase.instance.client
        .from("schedule")
        .select('location')
        .eq("festival", selectedFestivalId!);

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
          title: const Text('SCHEDULE'),
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
                  // This is where the loading indicator is shown
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

  Widget buildListView(Map<String, List<ScheduleItem>> itemsGroupedByTime,
      BuildContext context) {
    var sortedKeys = itemsGroupedByTime.keys.toList()
      ..sort((a, b) {
        DateTime timeA =
            displayFormat.parse(a); // Use displayFormat instead of timeFormat
        DateTime timeB =
            displayFormat.parse(b); // Use displayFormat instead of timeFormat
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
            ...itemsForTime.map((scheduleItem) {
              return EventCard(
                title: scheduleItem.title,
                imageUrl: scheduleItem.imageUrl,
                time: scheduleItem.time,
                date: scheduleItem.date,
                location: scheduleItem.location,
                onTap: () {
                  // Implement the logic to add the event to the user's schedule
                  // For example, add the scheduleItem to a list or save it in shared preferences
                  addToUserSchedule(scheduleItem);
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void addToUserSchedule(ScheduleItem item) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Assuming ScheduleItem has a method to convert to Map
    // If not, you'll need to implement it based on your ScheduleItem fields
    String itemJson = jsonEncode(item.toMap());

    // Retrieve existing schedule items from shared preferences
    List<String> scheduleList = prefs.getStringList('userSchedule') ?? [];

    // Add the new item
    scheduleList.add(itemJson);
    // Save the updated list back to shared preferences
    await prefs.setStringList('userSchedule', scheduleList);
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
    final DateTime time =
        timeFormat.parse(json['time'], true); // This is now a DateTime

    // Format the time
    final String formattedTime = displayFormat.format(time);

    // Parse the date string into a DateTime object
    final DateTime date = DateTime.parse(json['date']);

    // Format the date
    final DateFormat dateFormat = DateFormat('EEEE, MMM d');
    final String formattedDate = dateFormat.format(date);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? selectedFestival =
        prefs.getString('selectedFestivalDBPrefix');
    final String defaultImageUrl =
        "https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/temp_images/${selectedFestival ?? 'HA'}-arial.jpg";

    // Use formattedTime, formattedDate, and defaultImageUrl in creating a new ScheduleItem
    return ScheduleItem(
      title: json['title'],
      time: formattedTime,
      date: formattedDate,
      location: json['location'],
      imageUrl: json['imageUrl'] ??
          defaultImageUrl, // Use defaultImageUrl if imageUrl is not provided
    );
  }

  // Convert a ScheduleItem instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
