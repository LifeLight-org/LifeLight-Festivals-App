import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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
        child: Column(
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
            SizedBox(
              width: 350, // Set a larger width for the cards
              child: FestivalCard(
                festivalName: 'LifeLight Festival',
                festivalLogo: 'assets/images/LL-Logo.png',
                festivalDBPrefix: 'SF',
                onFestivalSelected: (festivalLogo, festivalDBPrefix) async {
                  removeUserTag('festival');
                  await setOnboardingStatus('LifeLight Festival',
                      'assets/images/LL-Logo.png', 'SF', true);
                  setUserTag('festival', 'Souix Falls Festival');
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
            SizedBox(
              width: 350, // Set a larger width for the cards
              child: FestivalCard(
                festivalName: 'LifeLight Hills Alive',
                festivalLogo: 'assets/images/HA-Logo-W.png',
                festivalDBPrefix: 'HA',
                onFestivalSelected: (festivalLogo, festivalDBPrefix) async {
                  removeUserTag('festival');
                  await setOnboardingStatus(
                      'Hills Alive', 'assets/images/HA-Logo-B.png', 'HA', true);
                  setUserTag('festival', 'Hills Alive');
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setOnboardingStatus(
      String festivalName, festivalLogo, festivalDBPrefix, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFestival', festivalName);
    await prefs.setString('selectedFestivalLogo', festivalLogo);
    await prefs.setString('selectedFestivalDBPrefix', festivalDBPrefix);
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
      width: double.infinity, // Set the container width to match the parent
      child: Card(
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(10.0), // Add border radius if desired
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
                      vertical: 5.0, horizontal: 5.0),
                  child: InkWell(
                    onTap: () =>
                        onFestivalSelected(festivalLogo, festivalDBPrefix),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize:
                          MainAxisSize.min, // Center the column vertically
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            festivalLogo,
                            width: 150, // Set a larger width for the image
                            height: 140, // Set a larger height for the image
                          ),
                        ),
                        Text(
                          festivalName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
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
