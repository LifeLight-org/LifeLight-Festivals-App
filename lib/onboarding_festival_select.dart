import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingFestivalSelectPage extends StatefulWidget {
  const OnboardingFestivalSelectPage({super.key});

  @override
  _OnboardingFestivalSelectPageState createState() =>
      _OnboardingFestivalSelectPageState();
}

class _OnboardingFestivalSelectPageState
    extends State<OnboardingFestivalSelectPage> {
  List<Map<String, dynamic>> _festivals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFestivals();
  }

  Future<void> _fetchFestivals() async {
    final response = await Supabase.instance.client
        .from('festivals')
        .select('id, name, sub_heading, dark_logo, is_event')
        .eq('active', true)
        .order("tier", ascending: true);

    if (response != null) {
      setState(() {
        _festivals = response as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SELECT YOUR MAIN EVENT',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _festivals.length,
              itemBuilder: (context, index) {
                final festival = _festivals[index];
                return FestivalCard(
                  id: festival['id'],
                  festivalName: festival['name'],
                  lightLogoUrl: festival['dark_logo'],
                  isEvent: festival['is_event'],
                  sub_heading: festival['sub_heading'],
                );
              },
            ),
    );
  }
}

class FestivalCard extends StatelessWidget {
  final int id;
  final String festivalName;
  final String lightLogoUrl;
  final bool isEvent;
  final String? sub_heading; // Make sub_heading nullable

  const FestivalCard({
      required this.id,
      required this.festivalName,
      required this.lightLogoUrl,
      required this.isEvent,
      this.sub_heading, // Nullable sub_heading
      super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('selectedFestivalId', id);
          await prefs.setBool('homeEventSelected', true);
          await prefs.setBool('isSelectedFestivalTypeEvent', isEvent);
          await prefs.setString('subHeading', sub_heading ?? '');
          OneSignal.User.addTagWithKey("MainSelectedFestival", id);
          print('Selected Festival ID: $id');
          Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
        },
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), // Adjust the padding value as needed
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  lightLogoUrl,
                  width: 200,
                  height: 150,
                ),
                SizedBox(height: 10),
                Text(
                  festivalName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}