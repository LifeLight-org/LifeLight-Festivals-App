import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourcesPage extends StatelessWidget {
  // Add a key parameter to the constructor
  const ResourcesPage({Key? key}) : super(key: key);

  // This function launches the URL
  void _launchAppURL(BuildContext context) async {
    String url;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/us/app/apple-store/id1535457204';
    } else {
      url = 'https://play.google.com/store/apps/details?id=org.ptl.app';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> _getFestival() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedFestival') ?? 'default';
  }

  void _launchFBURL(BuildContext context) async {
    String festival = await _getFestival();
    String url;
    switch (festival) {
      case 'Hills Alive':
        url = 'https://www.facebook.com/hillsalive';
        break;
      case 'LifeLight Festival':
        url = 'https://www.facebook.com/LifeLightmovement';
        break;
      default:
        url = 'https://lifelight.org';
        break;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchIGURL(BuildContext context) async {
    String festival = await _getFestival();
    String url;
    switch (festival) {
      case 'Hills Alive':
        url = 'https://www.instagram.com/hills.alive/';
        break;
      case 'LifeLight Festival':
        url = 'https://www.instagram.com/lifelightmovement/';
        break;
      default:
        url = 'https://lifelight.org';
        break;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildSectionTitle('Pocket Testament League'),
                    _buildSectionContent(
                      "The Pocket Testament League app is your digital tool for sharing the message of the Bible. Access digital New Testaments, get tips for effective evangelism.",
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: ElevatedButton(
                        onPressed: () => _launchAppURL(context),
                        child: const Text('Open The PTL App'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xffFFD000), // Change the color of the title
          decoration: TextDecoration.underline, // Underline the title
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16, // Increase the font size
          color: Colors.white, // Change the color of the content
          fontStyle: FontStyle.italic, // Make the content italic
        ),
      ),
    );
  }
}
