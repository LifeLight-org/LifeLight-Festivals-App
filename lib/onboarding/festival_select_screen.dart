import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:lifelight_app/supabase_client.dart';
import 'package:lifelight_app/pages/home.dart';

class FestivalSelectScreen extends StatelessWidget {
  const FestivalSelectScreen({super.key});

  Future<String> getOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onboardingStatus = prefs.getBool('onboarding') ?? false;
    return onboardingStatus ? 'Onboarded True' : 'Onboarded False';
  }

  Future<String> getFestival() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String festival =
        prefs.getString('selectedFestival') ?? 'No Festival Selected';
    return festival;
  }

  Future<List<dynamic>> fetchFestivals() async {
    final response = await supabase.from('festivals').select().eq('active', true);
    if (response != null) {
      print(response);
      return response as List<dynamic>;
    } else {
      throw Exception('Failed to load festivals');
    }
  }

  void setUserTag(String tagKey, String tagValue) async {
    OneSignal.User.addTagWithKey(tagKey, tagValue);
  }

  void removeUserTag(String tagKey) async {
    OneSignal.User.removeTag(tagKey);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SingleChildScrollView( // Allows the column to be scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensure the column's content is centered vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Select Your Festival',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            FutureBuilder<List<dynamic>>(
              future: fetchFestivals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Removed Expanded widget to avoid layout issues
                  return ListView.builder(
                    shrinkWrap: true, // Makes the ListView take up only as much space as it needs
                    physics: NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      var festival = snapshot.data![index];
                      return FestivalCard(
                        festivalName: festival['name'],
                        festivalLogo: festival['dark_logo_url'],
                        festivalDBPrefix: festival['short_name'],
                        onFestivalSelected:
                            (festivalLogo, festivalDBPrefix) async {
                          removeUserTag('festival');
                          await setOnboardingStatus(festival['name'],
                              festival['light_logo_url'], festival['short_name'], festival['id'], true);
                          setUserTag('festival', festival['short_name']);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
  Future<void> setOnboardingStatus(
      String festivalName, festivalLogo, festivalDBPrefix, festivalId, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFestival', festivalName);
    await prefs.setString('selectedFestivalLogo', festivalLogo);
    await prefs.setString('selectedFestivalDBPrefix', festivalDBPrefix);
    await prefs.setInt('selectedFestivalId', festivalId);
    await prefs.setBool('onboarding', status);
  }
}

class FestivalCard extends StatelessWidget {
  final String festivalName;
  final String festivalLogo;
  final String festivalDBPrefix;
  final Function(String, String) onFestivalSelected;

  const FestivalCard({
    super.key,
    required this.festivalName,
    required this.festivalLogo,
    required this.festivalDBPrefix,
    required this.onFestivalSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(5.0), // Add border radius if desired
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
              // Background Image with blur effect
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(
                        0.5), // Adjust the opacity and color if needed
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 2.0),
                  child: InkWell(
                    onTap: () =>
                        onFestivalSelected(festivalLogo, festivalDBPrefix),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize:
                          MainAxisSize.min, // Center the column vertically
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Image.network(
                            festivalLogo,
                            width: 170, // Set a larger width for the image
                            height: 160, // Set a larger height for the image
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
