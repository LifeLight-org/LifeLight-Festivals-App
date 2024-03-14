import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/pages/home.dart';
import 'package:lifelight_app/pages/map.dart';
import 'package:lifelight_app/pages/artist_lineup.dart';
import 'package:lifelight_app/pages/artist_signing_schedule.dart';
import 'package:lifelight_app/pages/schedule.dart';
import 'package:lifelight_app/pages/donate.dart';

import 'package:lifelight_app/component-widgets/list_title.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  Future<String> getSelectedFestivalLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedFestivalLogo = prefs.getString('selectedFestivalLogo') ?? '';
    return selectedFestivalLogo;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: const Color.fromRGBO(30, 30, 30, 1),
      child: ListTileTheme(
        textColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(30, 30, 30, 1),
              ),
              child: FutureBuilder<String>(
                future: getSelectedFestivalLogo(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Image.asset(
                      snapshot.data!,
                      width: 150,
                      height: 150,
                    );
                  } else {
                    return Container(); // Placeholder widget while loading
                  }
                },
              ),
            ),
            SideBarListTile(
              title: 'Home',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            SideBarListTile(
              title: 'Map',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
            ),
            SideBarListTile(
              title: 'Artist Lineup',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ArtistLineupPage()),
                );
              },
            ),
            SideBarListTile(
              title: 'Meet and Greet Schedule',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ArtistSigningSchedulePage()),
                );
              },
            ),
            SideBarListTile(
              title: 'Schedule',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulePage()),
                );
              },
            ),
                        SideBarListTile(
              title: 'Donate',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DonatePage()),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}
