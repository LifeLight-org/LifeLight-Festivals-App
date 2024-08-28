import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upgrader/upgrader.dart';

import 'onboarding_festival_select.dart';
import 'home.dart';
import 'faq.dart';
import 'festivals-pages/artist.dart';
import 'festivals-pages/map.dart';
import 'festivals-pages/sponsor.dart';
import 'know_god.dart';
import 'resources.dart';
import 'settings.dart';
import 'z8_events.dart';
import 'z8_about.dart';
import 'festivals-pages/schedule.dart';
import 'contact_form.dart';
import 'theme.dart'; // Import the theme file

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  OneSignal.Notifications.requestPermission(true);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Use the theme from theme.dart
      home: UpgradeAlert(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkOnboardingStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool('homeEventSelected') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading app'));
        } else {
          final hasOnboarded = snapshot.data ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme, // Use the theme from theme.dart
            initialRoute: '/',
            routes: {
              '/': (context) => hasOnboarded ? const HomePage() : const OnboardingFestivalSelectPage(),
              '/home': (context) => const HomePage(),
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
              '/contact-form': (context) => ContactForm(),
            },
          );
        }
      },
    );
  }
}