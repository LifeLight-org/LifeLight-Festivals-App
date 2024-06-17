import 'package:flutter/material.dart';
import 'package:lifelight_app/onboarding/festival_select_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import for opening a web browser

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
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
                            'https://brinkdesign.co/'), // Corrected to Uri.parse for the URL
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
    );
  }
}
