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
import 'package:lifelight_app/pages/impact.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Stream<Map<String, String>> festivalData;
  String? uuid;
  List<Map<String, dynamic>> buttons = []; // Initialize as empty

  Future<void> loadButtons() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final selectedFestivalDBPrefix =
        sharedPreferences.getString('selectedFestivalDBPrefix');

    // Define the common buttons here
    buttons = [
      {'icon': Icons.map, 'text': 'MAP', 'page': MapPage()},
      {'icon': Icons.people, 'text': 'ARTISTS', 'page': ArtistLineupPage()},
      {
        'icon': Icons.calendar_today,
        'text': 'SCHEDULE',
        'page': SchedulePage()
      },
      {'icon': Icons.star, 'text': 'SPONSORS', 'page': SponsorPage()},
      {'icon': Icons.question_mark, 'text': 'FAQ', 'page': FAQPage()},
      {'icon': Icons.monetization_on, 'text': 'DONATE', 'page': DonatePage()},
      {
        'icon': FaIcon(FontAwesomeIcons.handsPraying),
        'text': 'KNOW GOD',
        'page': KnowGodPage()
      },
      {'icon': Icons.info, 'text': 'RESOURCES', 'page': ResourcesPage()},
      // Conditionally add the IMPACT button
      {'text': 'CONNECT CARD', 'width': 355.0, 'page': ConnectPage()},
    ];

    // Check the condition and add the IMPACT button if necessary
    if (selectedFestivalDBPrefix != 'LL') {
      buttons.insert(
        buttons.length - 1, // Insert before the last item
        {'icon': Icons.trending_up, 'text': 'IMPACT', 'page': ImpactPage()},
      );
    }
  }

  @override
  void initState() {
    festivalData = getFestival();
    super.initState();
    loadUuid();
    loadButtons();
  }

  void loadUuid() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    uuid = sharedPreferences.getString('uuid');
    debugPrint('UUID: $uuid');
    debugPrint(
        'Festival: ${sharedPreferences.getString('selectedFestivalDBPrefix')}');
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
      buildBackground(),
      buildScaffold(context),
    ]);
  }

  Container buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  PreferredSize buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  StreamBuilder<Map<String, String>> buildBody(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: getFestival(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data!['logo'] == '') {
          return buildLoadingIndicator(context);
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return buildContent(snapshot);
          }
        }
      },
    );
  }

  Center buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Column buildContent(AsyncSnapshot<Map<String, String>> snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (snapshot.data!['logo']!.isNotEmpty) buildHero(snapshot),
        buildPadding(),
        Container(
          height: MediaQuery.of(context).size.shortestSide < 600
              ? MediaQuery.of(context).size.height * 0.65 // For phones
              : MediaQuery.of(context).size.height * 0.75, // For tablets
          child: Stack(
            children: [
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: buttons.length - 1, // Exclude the last button
                itemBuilder: (BuildContext context, int index) {
                  return IconButtonCard(
                    icon: buttons[index]['icon'],
                    text: buttons[index]['text'],
                    page: buttons[index]['page'],
                  );
                },
              ),
              // The last button
              Align(
                alignment: Alignment.bottomCenter,
                child: IconButtonCard(
                  icon: buttons[buttons.length - 1]['icon'],
                  text: buttons[buttons.length - 1]['text'],
                  width: buttons[buttons.length - 1]['width'],
                  page: buttons[buttons.length - 1]['page'],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<double> fetchLogoHeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestivalDBPrefix =
        prefs.getString('selectedFestivalDBPrefix');
    print('Selected Festival DB Prefix: $selectedFestivalDBPrefix');
    if (selectedFestivalDBPrefix == 'LL') {
      return 85.0;
    } else {
      return 125.0;
    }
  }

  Widget buildHero(AsyncSnapshot<Map<String, String>> snapshot) {
    return FutureBuilder<double>(
      future: fetchLogoHeight(),
      builder: (context, logoHeightSnapshot) {
        if (logoHeightSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return Hero(
            tag: 'eventLogo',
            child: Image.network(
              snapshot.data!['logo']!,
              height: logoHeightSnapshot.data, // use the data from the Future
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/LL-Logo.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.contain,
                );
              },
            ),
          );
        }
      },
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Text(
        'BRINGING LIGHT INTO DARKNESS',
        style: TextStyle(
          fontFamily: 'HelveticaNeueLT',
          fontSize: 19,
          letterSpacing: -2.0,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5
            ..color = Colors.white,
          shadows: const [
            Shadow(
              offset: Offset(0.5, 0.5),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
