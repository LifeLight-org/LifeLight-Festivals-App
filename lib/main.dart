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
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:lifelight_app/component-widgets/advert.dart';

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

  bool pointInPolygon(List<List<double>> polygon, List<double> point) {
    bool isInside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i][1] > point[1]) != (polygon[j][1] > point[1])) &&
          (point[0] <
              (polygon[j][0] - polygon[i][0]) *
                      (point[1] - polygon[i][1]) /
                      (polygon[j][1] - polygon[i][1]) +
                  polygon[i][0])) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  bool? wasInside;

  List<List<double>> polygon = [
    [44.086063, -103.223201],
    [44.085666, -103.223606],
    [44.085031, -103.223928],
    [44.084608, -103.224048],
    [44.084859, -103.225788],
    [44.085013, -103.225763],
    [44.085287, -103.225505],
    [44.085643, -103.225274],
    [44.085906, -103.225258],
    [44.086131, -103.22542],
    [44.086198, -103.2253],
    [44.086359, -103.225171],
    [44.086403, -103.224997],
    [44.086388, -103.224901],
    [44.086311, -103.224431],
    [44.086077, -103.223176],
    [44.086063, -103.223199],
    [44.086062, -103.223197],
  ];

  Timer.periodic(Duration(seconds: 1), (Timer t) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    List<double> point = [userLatitude, userLongitude];

    bool isInside = pointInPolygon(polygon, point);

    if (wasInside != null) {
      if (isInside && !wasInside!) {
        print('User entered the GEO Fence at ${DateTime.now()}');
      } else if (!isInside && wasInside!) {
        print('User left the GEO Fence at ${DateTime.now()}');
      }
    }

    wasInside = isInside;
  });

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
    void openAppSettings() async {
      openAppSettings();
    }

    void showPermissionDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission'),
            content: const Text(
                'This app needs location permission to function. Please grant location permission in the app settings.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> requestLocationPermission(BuildContext context) async {
      PermissionStatus permission = await Permission.location.request();
      if (permission.isDenied || permission.isPermanentlyDenied) {
        showPermissionDialog(context);
      } else {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print('Location: ${position.latitude}, ${position.longitude}');
      }
    }

    requestLocationPermission(context);

    //    WidgetsBinding.instance?.addPostFrameCallback((_) {
    //      showDialog(
    //        context: context,
    //        builder: (context) => SponsorAd(),
    //      );
    //    });

    Widget initialScreen;

    if (hasOnboarded) {
      initialScreen = const HomePage();
    } else {
      initialScreen = const FestivalSelectScreen();
    }

    return MaterialApp(
      theme: theme,
      home: initialScreen,
      builder: EasyLoading.init(),
    );
  }
}
