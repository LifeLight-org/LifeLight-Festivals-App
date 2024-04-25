import 'package:flutter/material.dart';
import 'package:lifelight_app/pages/artist_lineup.dart';
import 'package:lifelight_app/pages/artist_signing_schedule.dart';
import 'package:lifelight_app/pages/donate.dart';
import 'package:lifelight_app/pages/map.dart';
import 'package:lifelight_app/pages/schedule.dart';
import 'package:lifelight_app/pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/components/basepage.dart';
import 'package:lifelight_app/pages/sponsors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

final List<Map<String, dynamic>> buttons = [
  {'icon': Icons.map, 'text': 'MAP', 'page': MapPage()},
  {'icon': Icons.people, 'text': 'ARTISTS', 'page': ArtistLineupPage()},
  {'icon': Icons.edit, 'text': 'SIGNINGS', 'page': ArtistSigningSchedulePage()},
  {'icon': Icons.info, 'text': 'SCHEDULE', 'page': SchedulePage()},
  {'icon': Icons.star, 'text': 'SPONSORS', 'page': SponsorPage()},
  {'icon': Icons.monetization_on, 'text': 'DONATE', 'page': DonatePage()},
];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0x1C1C1C), // Change this to your desired color
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1C1C1C),
              Color.fromARGB(169, 253, 208, 8)
            ], // Gradient colors
            stops: const [0.8, 1.0], // Adjust the stops
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
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          padding: const EdgeInsets.all(30.0),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: <Widget>[
                            for (var i = 0; i < buttons.length; i++)
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 90.0, // adjust the height as needed
                                    width: 90.0, // adjust the width as needed
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    height: 90.0, // adjust the height as needed
                                    width: 90.0, // adjust the width as needed
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
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
                                              10.0), // adjust the padding as needed
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
