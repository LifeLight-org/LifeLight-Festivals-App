import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/festival_select_screen.dart';
import 'pages/home.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:convert'; // For jsonDecode
import 'package:json_theme/json_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:lifelight_app/models/cart.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifelight_app/geo_fence.dart';

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

  final themeStr = await rootBundle.loadString('assets/theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  final sharedPreferences = await SharedPreferences.getInstance();
  final hasOnboarded = sharedPreferences.getBool('onboarding') ?? false;

  // Load or generate UUID
  String? uuid = sharedPreferences.getString('uuid');
  if (uuid == null) {
    uuid = const Uuid().v4();
    await sharedPreferences.setString('uuid', uuid);
  }

  await Hive.initFlutter();

  runApp(
    MaterialApp(
      theme: theme,
      home: OverlaySupport(
        child: ChangeNotifierProvider(
          create: (context) => Cart(),
          child: MyApp(
            theme: theme,
            hasOnboarded: hasOnboarded,
          ),
        ),
      ),
      builder: EasyLoading.init(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  final bool hasOnboarded;

  const MyApp({Key? key, required this.theme, required this.hasOnboarded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //    WidgetsBinding.instance?.addPostFrameCallback((_) {
    //      showDialog(
    //        context: context,
    //        builder: (context) => SponsorAd(),
    //      );
    //    });

    //WidgetsBinding.instance.addPostFrameCallback((_) {
    //  GeoFenceService().start();
    //});

    Widget initialScreen;

    if (hasOnboarded) {
      initialScreen = const HomePage();
    } else {
      initialScreen = const FestivalSelectScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: initialScreen,
      builder: EasyLoading.init(),
    );
  }
}
