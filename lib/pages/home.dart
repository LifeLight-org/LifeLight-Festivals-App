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
import 'package:lifelight_app/pages/connectpage.dart';
import 'package:lifelight_app/pages/knowgodpage.dart';
import 'package:lifelight_app/component-widgets/iconbutton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  {'icon': Icons.question_mark, 'text': 'FAQ', 'page': FAQPage()},
  {'icon': Icons.info, 'text': 'RESOURCES', 'page': ResourcesPage()},
  {'icon': Icons.star, 'text': 'SPONSORS', 'page': SponsorPage()},
  {'icon': Icons.monetization_on, 'text': 'DONATE', 'page': DonatePage()},
  {
    'icon': FaIcon(FontAwesomeIcons.handsPraying),
    'text': 'KNOW GOD',
    'page': KnowGodPage()
  },
  {
    'icon': FaIcon(FontAwesomeIcons.solidPaperPlane),
    'text': 'CONNECT',
    'page': ConnectPage()
  },
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
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.transparent, // Set your desired color
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
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
        ),
        body: StreamBuilder<Map<String, String>>(
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 7.0), // Add top padding
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
                    Container(
                      height: MediaQuery.of(context).size.height *
                          0.67, // 80% of the screen height
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: buttons.length,
                        itemBuilder: (context, index) {
                          return IconButtonCard(
                            icon: buttons[index]['icon'],
                            text: buttons[index]['text'],
                            page: buttons[index]['page'],
                          );
                        },
                      ),
                    )
                  ],
                );
              }
            }
          },
        ),
      ),
    ]);
  }
}
