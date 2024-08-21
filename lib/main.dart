import 'package:flutter/material.dart';
import 'package:lifelight_festivals/faq.dart';
import 'package:lifelight_festivals/festivals-pages/artist.dart';
import 'package:lifelight_festivals/festivals-pages/map.dart';
import 'package:lifelight_festivals/festivals-pages/sponsor.dart';
import 'package:lifelight_festivals/know_god.dart';
import 'package:lifelight_festivals/resources.dart';
import 'package:lifelight_festivals/settings.dart';
import 'package:lifelight_festivals/z8_events.dart';
import 'package:lifelight_festivals/z8_about.dart';
import 'package:lifelight_festivals/festivals-pages/schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_festivals/onboarding_festival_select.dart';
import 'package:lifelight_festivals/home.dart';
import 'util.dart';
import 'theme.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xsssdjpayiloazwsamfu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhzc3NkanBheWlsb2F6d3NhbWZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3NDYxMTMsImV4cCI6MjAzOTMyMjExM30.p0G8rKz7RDUTeCw7sxofaxYD7rBV1PpvbaW5QFHk37U',
  );

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("ebe57ffe-e90d-4aa4-9c58-3d8f93c568f2");

  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(context, "Raleway", "Raleway");

    MaterialTheme theme = MaterialTheme(textTheme);
    return UpgradeAlert(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/event-change': (context) => const OnboardingFestivalSelectPage(),
          '/z8-events': (context) => EventsPage(),
          '/z8-about': (context) => AboutPage(),
          '/know-god': (context) => KnowGodPage(),
          '/resources': (context) => ResourcesPage(),
          '/faq': (context) => FAQPage(),
          '/map': (context) => const MapPage(),
          '/sponsors': (context) => SponsorPage(),
          '/artists': (context) => ArtistLineupPage(),
          '/schedule': (context) => SchedulePage(),
          '/onboarding': (context) => const OnboardingFestivalSelectPage(),
          '/settings': (context) => SettingsPage(),
        },
        theme: theme.dark(),
      ),
    );
  }
}