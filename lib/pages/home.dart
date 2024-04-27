import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifelight_app/pages/artist_lineup.dart';
import 'package:lifelight_app/pages/store.dart';
import 'package:lifelight_app/pages/donate.dart';
import 'package:lifelight_app/pages/map.dart';
import 'package:lifelight_app/pages/schedule.dart';
import 'package:lifelight_app/pages/settings.dart';
import 'package:lifelight_app/pages/sponsors.dart';
import 'package:lifelight_app/pages/faqpage.dart';
import 'package:lifelight_app/pages/resourcespage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

final List<Map<String, dynamic>> buttons = [
  {'icon': Icons.map, 'text': 'MAP', 'page': MapPage()},
  {'icon': Icons.people, 'text': 'ARTISTS', 'page': ArtistLineupPage()},
  {'icon': Icons.shopping_bag, 'text': 'STORE', 'page': StorePage()},
  {'icon': Icons.calendar_today, 'text': 'SCHEDULE', 'page': SchedulePage()},
  {'icon': Icons.question_mark, 'text': 'INFO', 'page': FAQPage()},
  {'icon': Icons.info, 'text': 'RESOURCES', 'page': ResourcesPage()},
  {'icon': Icons.star, 'text': 'SPONSORS', 'page': SponsorPage()},
  {'icon': Icons.monetization_on, 'text': 'DONATE', 'page': DonatePage()},
];

class HomePageState extends State<HomePage> {
  late Stream<Map<String, String>> festivalData;
  String? uuid;

  @override
  void initState() {
    super.initState();
    festivalData = getFestival();
    loadUuid();
  }

  void loadUuid() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    uuid = sharedPreferences.getString('uuid');
    debugPrint('UUID: $uuid');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Set AppBar background to transparent
        elevation: 0, // Remove shadow
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/background.jpg"), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (snapshot.data!['logo']!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 60.0), // Add padding to the top
                          child: Hero(
                            tag: 'eventLogo',
                            child: Image.asset(
                              snapshot.data!['logo']!,
                              height: 120, // Adjust the height as needed
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
                        ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10.0), // Add top padding
                        child: Text(
                          'BRINGING LIGHT INTO DARKNESS',
                          style: TextStyle(
                            fontFamily: 'HelveticaNeueLT',
                            fontSize: 19,
                            letterSpacing: -2.0, // Adjust the letter spacing
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 0.5 // Set a thin outline
                              ..color = Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0.5, 0.5),
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          padding: const EdgeInsets.only(
                              top: 0.0, left: 40.0, right: 40.0),
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 30.0,
                          children: <Widget>[
                            for (var i = 0; i < buttons.length; i++)
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 70.0, // adjust the height as needed
                                    width: 70.0, // adjust the width as needed
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          5), // add this line
                                    ),
                                  ),
                                  Container(
                                    height: 70.0, // adjust the height as needed
                                    width: 70.0, // adjust the width as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          5), // add this line
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/Lights.png'), // path to your image
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      elevation: MaterialStateProperty.all(0),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // add this line
                                      )),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                buttons[i]['page']),
                                      );
                                    },
                                    child: Icon(
                                      buttons[i]['icon'],
                                      size: 50.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top:
                                              5.0), // adjust the padding as needed
                                      child: Text(
                                        buttons[i]['text'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
