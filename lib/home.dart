import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lifelight_festivals/components/countdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _images = {};
  bool _isLoading = true;
  List<Map<String, String>> _buttonConfig = [];
  String? _selectedFestivalId;
  Map<String, dynamic> _DonateUrl = {};
  Map<String, dynamic> _ImpactData = {};
  Map<String, dynamic> _ConnectCardData = {};
  Map<String, dynamic> _CountdownData = {};
  Map<String, dynamic> _ContactFormData = {};
  String _selectedFestivalSubHeading = ''; // Define the variable here

  @override
  void initState() {
    super.initState();
    _initializeHomePage();
  }

  Future<void> _fetchImages() async {
    if (_selectedFestivalId == null) return;

    setState(() {
      _isLoading = true;
    });

    final response = await Supabase.instance.client
        .from('festivals')
        .select('name, background_image, light_logo')
        .eq('id', _selectedFestivalId!)
        .single();

    if (response != null) {
      setState(() {
        _images = response as Map<String, dynamic>;
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDonateUrl() async {
    if (_selectedFestivalId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('festivals')
          .select('donate_url')
          .eq('id', _selectedFestivalId!)
          .single();

      if (response != null) {
        setState(() {
          _DonateUrl = response as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Error: No data found for the selected festival.');
      }
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching donate URL: $error');
    }
  }

  Future<void> _fetchImpactData() async {
    if (_selectedFestivalId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('festivals')
          .select('impact_message, impact_next_button_text, impact_url')
          .eq('id', _selectedFestivalId!)
          .single();

      if (response != null) {
        setState(() {
          _ImpactData = response as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Error: No data found for the selected festival.');
      }
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching impact URL: $error');
    }
  }

  Future<void> _fetchConnectCardUrl() async {
    if (_selectedFestivalId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('festivals')
          .select('connect_card_url')
          .eq('id', _selectedFestivalId!)
          .single();

      if (response != null) {
        setState(() {
          _ConnectCardData = response as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Error: No data found for the selected festival.');
      }
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching Connect Card URL: $error');
    }
  }

  Future<void> _fetchContactFormData() async {
    if (_selectedFestivalId == null) return;
    final sharedPrefs = await SharedPreferences.getInstance();

    try {
      final response = await Supabase.instance.client
          .from('festivals')
          .select('contact_form_from, contact_form_from_email, contact_form_to, contact_form_subject')
          .eq('id', _selectedFestivalId!)
          .single();
      if (response != null) {
        setState(() {
          _ContactFormData = response as Map<String, dynamic>;
          print(_ContactFormData);
          sharedPrefs.setString('contactFormFrom', response['contact_form_from']);
          sharedPrefs.setString('contactFormFromEmail', response['contact_form_from_email']);
          sharedPrefs.setString('contactFormTo', response['contact_form_to']);
          sharedPrefs.setString('contactFormSubject', response['contact_form_subject']);
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Error: No data found for the selected festival.');
      }
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching Contact Form URL: $error');
    }
  }

  Future<void> _fetchCountdown() async {
    if (_selectedFestivalId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('festivals')
          .select(
              'countdown_message, after_countdown_message, show_countdown_after_message_date, countdown_date')
          .eq('id', _selectedFestivalId!)
          .single();
      print(response);
      if (response != null) {
        setState(() {
          _CountdownData = response as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Error: No data found for the selected festival.');
      }
    } catch (error) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error fetching Countdown Date: $error');
    }
  }

  Future<void> _initializeHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFestivalId = prefs.getInt('selectedFestivalId')?.toString();
    _selectedFestivalSubHeading = prefs.getString('subHeading') ?? '';

    await _fetchImages();
    _loadButtonConfig();
    _fetchDonateUrl();
    _fetchImpactData();
    _fetchConnectCardUrl();
    _fetchCountdown();
    _fetchContactFormData();
  }

  Future<void> _loadButtonConfig() async {
    if (_selectedFestivalId == null) return;

    final String response =
        await rootBundle.loadString('assets/button_config.json');
    final data = await json.decode(response);

    if (data[_selectedFestivalId] != null) {
      setState(() {
        _buttonConfig = List<Map<String, String>>.from(
            (data[_selectedFestivalId] as List)
                .map((item) => Map<String, String>.from(item)));
      });
    } else {
      // Handle the case where the key does not exist
      setState(() {
        _buttonConfig = [];
      });
    }
  }

  void _showImpactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Impact', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(_ImpactData['impact_message']),
          actions: <Widget>[
            TextButton(
              child: Text(_ImpactData['impact_next_button_text']),
              onPressed: () async {
                final url = _ImpactData['impact_url'];
                if (url != null) {
                  final ChromeSafariBrowser browser = ChromeSafariBrowser();
                  await browser.open(
                    url: WebUri(url),
                    options: ChromeSafariBrowserClassOptions(
                      android: AndroidChromeCustomTabsOptions(
                        addDefaultShareMenuItem: false,
                      ),
                      ios: IOSSafariOptions(
                        barCollapsingEnabled: true,
                      ),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: _images['background_image'] != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              _images['background_image'],
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0, // Optional: Remove the shadow
                      actions: [
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, "/settings");
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: CachedNetworkImage(
                              imageUrl: _images['light_logo'],
                              height:
                                  MediaQuery.of(context).size.shortestSide > 600
                                      ? 210
                                      : 140,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          AutoSizeText(
                            _selectedFestivalSubHeading,
                            style: TextStyle(
                              fontFamily: 'HelveticaNeueLT',
                              fontSize:
                                  MediaQuery.of(context).size.shortestSide > 600
                                      ? 30
                                      : 20, // Larger font size on iPad
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
                            stepGranularity:
                                1, // The step size for scaling the font
                            maxLines: 1, // Ensures the text does not wrap
                            overflow: TextOverflow
                                .ellipsis, // Adds an ellipsis if the text still overflows
                          ),
                          if (_CountdownData['countdown_date'] != null)
                            Countdown(
                              targetDate: DateTime.parse(
                                  _CountdownData['countdown_date']),
                              showCountdownAfterMessageDate: DateTime.parse(
                                  _CountdownData[
                                      'show_countdown_after_message_date']),
                              afterCountdownMessage:
                                  _CountdownData['after_countdown_message'],
                            ),
                          if (_CountdownData['countdown_date'] == null)
                            SizedBox(
                              height: MediaQuery.of(context).size.width > 670
                                  ? 130
                                  : MediaQuery.of(context).size.width > 540
                                      ? 120
                                      : 70,
                            ),
                          SizedBox(height: 20),
                          Container(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Wrap(
                                  spacing:
                                      10.0, // Horizontal spacing between buttons
                                  runSpacing:
                                      10.0, // Vertical spacing between buttons
                                  children: List.generate(_buttonConfig.length,
                                      (index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (_buttonConfig[index]['type'] ==
                                            'donate') {
                                          final url = _DonateUrl['donate_url'];
                                          if (url != null) {
                                            final ChromeSafariBrowser browser =
                                                ChromeSafariBrowser();
                                            await browser.open(
                                              url: WebUri(url),
                                              options:
                                                  ChromeSafariBrowserClassOptions(
                                                android:
                                                    AndroidChromeCustomTabsOptions(
                                                  addDefaultShareMenuItem:
                                                      false,
                                                ),
                                                ios: IOSSafariOptions(
                                                  barCollapsingEnabled: true,
                                                ),
                                              ),
                                            );
                                          }
                                        } else if (_buttonConfig[index]
                                                ['type'] ==
                                            'impact') {
                                          _showImpactDialog();
                                        } else if (_buttonConfig[index]
                                                ['type'] ==
                                            'url') {
                                          final url =
                                              _buttonConfig[index]['route'];
                                          if (url != null) {
                                            final ChromeSafariBrowser browser =
                                                ChromeSafariBrowser();
                                            await browser.open(
                                              url: WebUri(url),
                                              options:
                                                  ChromeSafariBrowserClassOptions(
                                                android:
                                                    AndroidChromeCustomTabsOptions(
                                                  addDefaultShareMenuItem:
                                                      false,
                                                ),
                                                ios: IOSSafariOptions(
                                                  barCollapsingEnabled: true,
                                                ),
                                              ),
                                            );
                                          }
                                        } else if (_buttonConfig[index]
                                                ['type'] ==
                                            'email') {
                                          final email =
                                              _buttonConfig[index]['email'];
                                        } else {
                                          Navigator.pushNamed(context,
                                              _buttonConfig[index]['route']!);
                                        }
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                600
                                            ? 200
                                            : 100, // Set the width larger on iPad
                                        height: MediaQuery.of(context)
                                                    .size
                                                    .shortestSide >
                                                600
                                            ? 200
                                            : 100, // Set the height larger on iPad
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 255, 208,
                                              0), // Background color
                                          borderRadius: BorderRadius.circular(
                                              3), // Rounded corners
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _getIconData(_buttonConfig[index]
                                                  ['icon']!),
                                              color: Colors.black,
                                              size: 30.0,
                                            ),
                                            SizedBox(
                                                height:
                                                    8.0), // Space between icon and text
                                            AutoSizeText(
                                              _buttonConfig[index]['label']!,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black),
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    // Other widgets in your layout
                    Align(
                      alignment: MediaQuery.of(context).size.shortestSide > 600
                          ? Alignment(0.0, 1.0) // Keep alignment as is on iPad
                          : MediaQuery.of(context).size.shortestSide > 420
                              ? Alignment(
                                  0.0, 0.9) // Move up on 6.7-inch screens
                              : Alignment(0.0,
                                  1.0), // Default alignment on other devices
                      child: Padding(
                        padding: MediaQuery.of(context).size.shortestSide > 600
                            ? const EdgeInsets.all(
                                15.0) // Larger padding on iPad
                            : MediaQuery.of(context).size.shortestSide > 430
                                ? const EdgeInsets.all(
                                    50.0) // Move up on 6.7-inch screens
                                : const EdgeInsets.all(
                                    2.0), // Default padding on other devices
                        child: GestureDetector(
                          onTap: () async {
                            final url = _ConnectCardData[
                                'connect_card_url']; // Replace with your URL
                            final ChromeSafariBrowser browser =
                                ChromeSafariBrowser();
                            await browser.open(
                              url: WebUri(url),
                              options: ChromeSafariBrowserClassOptions(
                                android: AndroidChromeCustomTabsOptions(
                                  addDefaultShareMenuItem: false,
                                ),
                                ios: IOSSafariOptions(
                                  barCollapsingEnabled: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            height:
                                MediaQuery.of(context).size.shortestSide > 600
                                    ? 150
                                    : 70, // Larger height on iPad
                            padding: EdgeInsets.symmetric(vertical: 0.0),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 208, 0),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Center(
                              child: Text(
                                'CONNECT CARD',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.shortestSide >
                                              600
                                          ? 24.0
                                          : 16.0, // Larger font size on iPad
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'schedule':
        return Icons.calendar_today;
      case 'donate':
        return Icons.attach_money;
      case 'about':
        return Icons.info;
      case 'fa_pray':
        return FontAwesomeIcons.handsPraying;
      case 'resouces':
        return Icons.library_books;
      case 'fa_follow_us':
        return FontAwesomeIcons.userPlus;
      case 'faq':
        return Icons.help;
      case 'contact':
        return Icons.email;
      case 'map':
        return Icons.map;
      case 'artists':
        return Icons.people;
      case 'sponsors':
        return Icons.star;
      case 'impact':
        return Icons.currency_exchange;
      case 'fa_instagram':
        return FontAwesomeIcons.instagram;
      case 'fa_facebook':
        return FontAwesomeIcons.facebook;
      default:
        return Icons.star;
    }
  }
}
