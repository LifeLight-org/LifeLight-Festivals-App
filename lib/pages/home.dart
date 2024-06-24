import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/pages/artist_lineup.dart';
import 'package:lifelight_app/pages/map.dart';
import 'package:lifelight_app/pages/schedule.dart';
import 'package:lifelight_app/pages/settings.dart';
import 'package:lifelight_app/pages/sponsors.dart';
import 'package:lifelight_app/pages/faqpage.dart';
import 'package:lifelight_app/pages/resourcespage.dart';
import 'package:lifelight_app/pages/knowgodpage.dart';
import 'package:lifelight_app/component-widgets/iconbutton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Stream<Map<String, String>> festivalData;
  String? uuid;
  String? festivalShortName;
  List<Map<String, dynamic>> buttons = []; // Initialize as empty
  
  Future<void> loadButtons() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final selectedFestivalDBPrefix =
        sharedPreferences.getString('selectedFestivalDBPrefix');

  String getDonateUrl() {
    switch (selectedFestivalDBPrefix) {
      case 'HA':
        return 'https://lifelight.breezechms.com/give/online/?fund_id=1822623';
      case 'LL':
        return 'https://lifelight.breezechms.com/give/online/?fund_id=1827270';
      default:
        return 'https://lifelight.breezechms.com/give/online';
    }
  }

    // Define the common buttons here
    buttons = [
      {'icon': Icons.map, 'type': NavigationType.page, 'text': 'MAP', 'page': MapPage()},
      {'icon': Icons.people, 'type': NavigationType.page, 'text': 'ARTISTS', 'page': ArtistLineupPage()},
      {
        'icon': Icons.calendar_today,
        'text': 'SCHEDULE',
        'type': NavigationType.page,
        'page': SchedulePage()
      },
      {'icon': Icons.star, 'type': NavigationType.page, 'text': 'SPONSORS', 'page': SponsorPage()},
      {'icon': Icons.question_mark, 'type': NavigationType.page, 'text': 'FAQ', 'page': FAQPage()},
      {'icon': Icons.attach_money, 'type': NavigationType.webBrowser, 'url': getDonateUrl(), 'text': 'DONATE'},
      {
        'icon': FaIcon(FontAwesomeIcons.handsPraying),
        'type': NavigationType.page,
        'text': 'KNOW GOD',
        'page': KnowGodPage()
      },
      {'icon': Icons.info, 'type': NavigationType.page, 'text': 'RESOURCES', 'page': ResourcesPage()},
      // Conditionally add the IMPACT button
      {'text': 'CONNECT CARD', 'type': NavigationType.webBrowser, 'url': 'https://lifelight.breezechms.com/form/23d1f1', 'width': 355.00},
    ];

    // Check the condition and add the IMPACT button if necessary
    if (selectedFestivalDBPrefix != 'LL') {
      buttons.insert(
        buttons.length - 1, // Insert before the last item
        {'icon': Icons.currency_exchange, 'type': NavigationType.webBrowser, 'url': 'https://lifelight.breezechms.com/give/online/?fund_id=1882935&frequency=M', 'text': 'IMPACT'},
      );
    }
  }

  @override
  void initState() {
    festivalData = getFestival();
    super.initState();
    loadUuid();
  }

  void loadUuid() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    uuid = sharedPreferences.getString('uuid');
    debugPrint('UUID: $uuid');
    debugPrint(
        'Festival: ${sharedPreferences.getString('selectedFestivalDBPrefix')}');
            loadButtons();
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
                    navigationType: buttons[index]['type'],
                    url: buttons[index]['url'],
                    text: buttons[index]['text'],
                    page: buttons[index]['page'],
                  );
                },
              ),
              // The last button
              Align(
                alignment: Alignment(0, 0.85),
                child: IconButtonCard(
                  icon: buttons[buttons.length - 1]['icon'],
                  navigationType: buttons[buttons.length - 1]['type'],
                  url: buttons[buttons.length - 1]['url'],
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


  Widget buildHero(AsyncSnapshot<Map<String, String>> snapshot) {
    return FutureBuilder<double>(
      future: Future<double>.value(MediaQuery.of(context).size.height * 0.16),
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
    child: AutoSizeText(
      'BRINGING LIGHT INTO DARKNESS',
      style: TextStyle(
        fontFamily: 'HelveticaNeueLT',
        fontSize: 20,
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
      minFontSize: 10, // Minimum text size
      stepGranularity: 1, // The step size for scaling the font
      maxLines: 1, // Ensures the text does not wrap
      overflow: TextOverflow.ellipsis, // Adds an ellipsis if the text still overflows
    ),
  );
}
}
