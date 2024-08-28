import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFestivalId = prefs.getInt('selectedFestivalId')!;

    final response = await Supabase.instance.client
        .from('schedule')
        .select("*, festival_dates(*), festival_locations(*)")
        .eq('festival', selectedFestivalId)
        .order('date', ascending: true)
        .order('time', ascending: true);
    return response as List<Map<String, dynamic>>;
  }

  String formatTime(String time) {
    final parsedTime = DateFormat.Hms().parse(time);
    return DateFormat.jm().format(parsedTime);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchSchedule(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Schedule'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Schedule'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Schedule'),
            ),
            body: Center(child: Text('No schedule items found.')),
          );
        } else {
          final scheduleItems = snapshot.data!;
          final uniqueDates = scheduleItems
              .map((item) => item['festival_dates']['date'])
              .toSet()
              .toList();

          return DefaultTabController(
            length: uniqueDates.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('SCHEDULE'),
                bottom: TabBar(
                  isScrollable: false,
                  tabs: uniqueDates
                      .map((date) => Tab(
                          text:
                              DateFormat.yMMMd().format(DateTime.parse(date))))
                      .toList(),
                ),
              ),
              body: TabBarView(
                children: uniqueDates.map((date) {
                  final filteredItemsByDate = scheduleItems
                      .where((item) => item['festival_dates']['date'] == date)
                      .toList();
                  final uniqueLocations = filteredItemsByDate
                      .map((item) => item['festival_locations']['location'])
                      .toSet()
                      .toList();

                  return DefaultTabController(
                    length: uniqueLocations.length,
                    child: Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(5.0),
                          child: Center(
                            child: TabBar(
                              isScrollable: false,
                              tabs: uniqueLocations
                                  .map((location) => Tab(text: location))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      body: TabBarView(
                        children: uniqueLocations.map((location) {
                          final filteredItemsByLocation = filteredItemsByDate
                              .where((item) =>
                                  item['festival_locations']['location'] ==
                                  location)
                              .toList();
                          return buildScheduleList(filteredItemsByLocation);
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildScheduleList(List<Map<String, dynamic>> scheduleItems) {
    return ListView.builder(
      itemCount: scheduleItems.length,
      itemBuilder: (context, index) {
        final item = scheduleItems[index];
        final formattedTime = formatTime(item['time']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[850],
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(item['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('${item['festival_locations']['location']}'),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: item['image_url'],
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ), // Optional placeholder
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error), // Optional error widget
                ),
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
