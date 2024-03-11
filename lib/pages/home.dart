import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/onboarding/festival_select_screen.dart';
import '/components/basepage.dart';
import 'map.dart';
import 'package:lifelight_app/component-widgets/glassybutton.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Stream<Map<String, String>> festivalData;

  @override
  void initState() {
    super.initState();
    festivalData = getFestival();
  }

  Stream<Map<String, String>> getFestival() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String festival =
        prefs.getString('selectedFestival') ?? 'No Festival Selected';
    String selectedFestivalLogo = prefs.getString('selectedFestivalLogo') ?? '';

    // Retry logic
    int retryCount = 0;
    while (selectedFestivalLogo.isEmpty && retryCount < 3) {
      yield {
        'name': festival,
        'logo': ''
      }; // Emit an empty logo to show loading indicator
      await Future.delayed(const Duration(
          milliseconds: 500)); // wait for half a second before retrying
      selectedFestivalLogo = prefs.getString('selectedFestivalLogo') ?? '';
      retryCount++;
    }

    yield {'name': festival, 'logo': selectedFestivalLogo};
  }

void removeUserTag(String tagKey) async {
  OneSignal.User.removeTag(tagKey);
}

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home',
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add padding to the top
        child: StreamBuilder<Map<String, String>>(
          stream: getFestival(),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.data!['logo'] == '') {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary),
                ),
              );
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Column(
                  children: [
                    if (snapshot.data!['logo']!.isNotEmpty)
                      Hero(
                        tag: 'eventLogo',
                        child: Image.asset(
                          snapshot.data!['logo']!,
                          height: 150, // Adjust the height as needed
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/LL-Logo.png', // path to your default logo
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20.0),
                    GlassyButton(
                      text: "Map",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10.0),
                    GlassyButton(
                      text: "Go back to Festival Select",
                      onPressed: () async {
                        if (mounted) {
                          BuildContext localContext = context;
                          removeUserTag('festival');
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            localContext,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FestivalSelectScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}
