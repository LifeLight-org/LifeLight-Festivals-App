import 'package:flutter/material.dart';
import 'package:lifelight_app/onboarding/festival_select_screen.dart';

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
            Expanded(
              child: ListTile(
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
                MaterialPageRoute(builder: (context) => FestivalSelectScreen()),
              );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}