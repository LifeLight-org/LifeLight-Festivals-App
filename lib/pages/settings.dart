import 'package:flutter/material.dart';
import 'package:lifelight_app/onboarding/festival_select_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import for opening a web browser
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    getAppVersion();
  }

  void getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.change_circle,
                    size: 35, // Increase the size of the icon
                  ),
                  title: Text(
                    'Change Festival',
                    style: TextStyle(fontSize: 24), // Increase the font size
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FestivalSelectScreen()),
                    );
                  },
                ),
                Spacer(), // Use Spacer to push the following widget to the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      ListTile(
                        title: Center(
                          child: Text(
                            'Powered By',
                            style:
                                TextStyle(fontSize: 24), // Increase the font size
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Your onTap action here
                          final ChromeSafariBrowser browser = ChromeSafariBrowser();
                          browser.open(
                            url: WebUri(
                                'https://brinkdesign.co/'),
                            options: ChromeSafariBrowserClassOptions(
                              android: AndroidChromeCustomTabsOptions(
                                  addDefaultShareMenuItem: false),
                              ios: IOSSafariOptions(barCollapsingEnabled: true),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/Brink-Design.png', // Replace with the actual path to your image
                          width: 90, // Adjust the width of the image
                          height: 90, // Adjust the height of the image
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 25,
            bottom: 25,
            child: Text('Version: $appVersion'),
          ),
        ],
      ),
    );
  }
}