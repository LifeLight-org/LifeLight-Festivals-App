import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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