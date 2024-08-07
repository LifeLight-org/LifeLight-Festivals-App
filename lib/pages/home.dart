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
import 'package:lifelight_app/supabase_client.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? uuid;
  String? festivalShortName;
  List<Map<String, dynamic>> buttons = [];
  Map<String, dynamic> festivalData = {}; // Change to Map<String, dynamic>

  Future<void> loadButtons() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final selectedFestivalDBPrefix =
        sharedPreferences.getString('selectedFestivalDBPrefix');
    final selectedFestivalId = sharedPreferences.getInt('selectedFestivalId');

    final donateUrl = await supabase
        .from('festivals')
        .select('donateUrl')
        .eq('id', selectedFestivalId!)
        .single();

    String getDonateUrl() {
      if (donateUrl != null) {
        return donateUrl['donateUrl'] as String;
      } else {
        return 'https://lifelight.breezechms.com/give/online';
      }
    }

    // Define the common buttons here
    List<Map<String, dynamic>> loadedButtons = [
      {
        'icon': Icons.map,
        'type': NavigationType.page,
        'text': 'MAP',
        'page': MapPage()
      },
      {
        'icon': Icons.people,
        'type': NavigationType.page,
        'text': 'ARTISTS',
        'page': ArtistLineupPage()
      },
      {
        'icon': Icons.calendar_today,
        'type': NavigationType.page,
        'text': 'SCHEDULE',
        'page': SchedulePage()
      },
      {
        'icon': Icons.star,
        'type': NavigationType.page,
        'text': 'SPONSORS',
        'page': SponsorPage()
      },
      {
        'icon': Icons.question_mark,
        'type': NavigationType.page,
        'text': 'FAQ',
        'page': FAQPage()
      },
      {
        'icon': Icons.attach_money,
        'type': NavigationType.webBrowser,
        'url': getDonateUrl(),
        'text': 'DONATE'
      },
      {
        'icon': FaIcon(FontAwesomeIcons.handsPraying),
        'type': NavigationType.page,
        'text': 'KNOW GOD',
        'page': KnowGodPage()
      },
      {
        'icon': Icons.info,
        'type': NavigationType.page,
        'text': 'RESOURCES',
        'page': ResourcesPage()
      },
      // Conditionally add the IMPACT button
      {
        'text': 'CONNECT CARD',
        'type': NavigationType.webBrowser,
        'url': 'https://lifelight.breezechms.com/form/23d1f1',
        'width': 355.00
      },
    ];

    final impactUrl = await supabase
        .from('festivals')
        .select('impactUrl, impactMessage, impactNextButtonText')
        .eq('id', selectedFestivalId!)
        .single();

    print('$selectedFestivalId, Impact URL: $impactUrl');

    if (impactUrl != null && impactUrl['impactUrl'] != null) {
      loadedButtons.insert(
        loadedButtons.length - 1, // Insert before the last item
        {
          'icon': Icons.currency_exchange,
          'type': NavigationType.popupToWebBrowser,
          'nextButtonText': impactUrl['impactNextButtonText'],
          'dialogTitle': 'Impact',
          'dialogMessage': impactUrl['impactMessage'],
          'url': impactUrl['impactUrl'],
          'text': 'IMPACT'
        },
      );
    }

    setState(() {
      buttons = loadedButtons;
    });
  }

  Future<Map<String, dynamic>> fetchFestivals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');
    final response = await supabase
        .from('festivals')
        .select()
        .eq('id', selectedFestivalId!)
        .single();
    if (response != null) {
      print(response);
      setState(() {
        festivalData =
            response as Map<String, dynamic>; // Store the fetched data
      });
      print(festivalData);
      return response as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load festivals');
    }
  }

  @override
  void initState() {
    super.initState();
    loadUuid();
    loadButtons();
    fetchFestivals();
  }

  void loadUuid() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    uuid = sharedPreferences.getString('uuid');
    debugPrint('UUID: $uuid');
    debugPrint(
        'Festival: ${sharedPreferences.getString('selectedFestivalDBPrefix')}');
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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            festivalData['backgroundImage']?.isNotEmpty == true
                ? festivalData['backgroundImage']
                : 'https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/images/backgrounds/LifeLight_Hills_Alive-background-1722003740977', // Provide a default image URL
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(),
      body: buildContent(),
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

  Center buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Column buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildHero(),
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
                itemCount: (buttons.length - 1)
                    .clamp(0, buttons.length), // Ensure non-negative itemCount
                itemBuilder: (BuildContext context, int index) {
                  return IconButtonCard(
                    icon: buttons[index]['icon'],
                    navigationType: buttons[index]['type'],
                    dialogTitle: buttons[index]['dialogTitle'],
                    dialogMessage: buttons[index]['dialogMessage'],
                    nextButtonText: buttons[index]['nextButtonText'],
                    url: buttons[index]['url'],
                    text: buttons[index]['text'],
                    page: buttons[index]['page'],
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buttons.isNotEmpty
                    ? IconButtonCard(
                        icon: buttons.last['icon'],
                        navigationType: buttons.last['type'],
                        dialogTitle: buttons.last['dialogTitle'],
                        dialogMessage: buttons.last['dialogMessage'],
                        nextButtonText: buttons.last['nextButtonText'],
                        url: buttons.last['url'],
                        text: buttons.last['text'],
                        width: buttons.last['width'],
                      )
                    : Container(), // or any other widget you want to show when buttons is empty
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildHero() {
    return Hero(
      tag: 'eventLogo',
      child: CachedNetworkImage(
        imageUrl: festivalData['light_logo_url'] ?? '',
        height: MediaQuery.of(context).size.height * 0.16,
        width: double.infinity,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) =>
            Image.asset('assets/images/LL-Logo.png'),
        fadeInDuration: Duration(milliseconds: 500), // Add fade transition
        fadeOutDuration: Duration(milliseconds: 500),
      ),
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
        overflow: TextOverflow
            .ellipsis, // Adds an ellipsis if the text still overflows
      ),
    );
  }
}
