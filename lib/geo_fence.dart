import 'package:background_location/background_location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lifelight_app/supabase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GeoFenceChecker {

  Future<Map<int, Polygon>> fetchGeofences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  var festival = sharedPreferences.getInt('selectedFestivalId');
    final response = await supabase
        .from('festivalfencepoints')
        .select().eq('festival', festival!);

    if (response != null) {
      Map<int, List<Point>> geofencePoints = {};
      for (var row in response) {
        int geofenceId = row['geofenceid'];
        Point point = Point(row['latitude'], row['longitude']);
        geofencePoints.putIfAbsent(geofenceId, () => []).add(point);
      }

      Map<int, Polygon> geofences = {};
      geofencePoints.forEach((id, points) {
        geofences[id] = Polygon(points);
      });

      return geofences;
    } else {
      throw Exception('Failed to fetch geofences: $response');
    }
  }

Future<int?> checkIfEnteredGeoFence(double latitude, double longitude) async {
  var userLocation = Point(latitude, longitude);
  var geofences = await fetchGeofences();
  for (var entry in geofences.entries) {
    if (entry.value.contains(userLocation)) {
      return entry.key; // Return the geofenceId
    }
  }
  return null; // Return null if not inside any geofence
}

  Future<bool> checkIfExitedGeoFence(double latitude, double longitude) async {
    var userLocation = Point(latitude, longitude);
    var geofences = await fetchGeofences();
    for (var geofence in geofences.values) {
      if (!geofence.contains(userLocation)) {
        return true;
      }
    }
    return false;
  }
}

// Moved Point and Polygon classes to the top-level
class Point {
  final double latitude;
  final double longitude;

  Point(this.latitude, this.longitude);
}

class Polygon {
  final List<Point> vertices;

  Polygon(this.vertices);

  bool contains(Point point) {
    var count = 0;
    for (int i = 0; i < vertices.length; i++) {
      var start = vertices[i];
      var end = vertices[(i + 1) % vertices.length];
      if ((point.latitude > start.latitude) !=
          (point.latitude > end.latitude)) {
        var intersectLongitude = (end.longitude - start.longitude) *
                (point.latitude - start.latitude) /
                (end.latitude - start.latitude) +
            start.longitude;
        if (point.longitude < intersectLongitude) {
          count++;
        }
      }
    }
    return count % 2 == 1;
  }
}

class GeoFenceService {
  bool isInsideGeoFence =
      false; // Track the user's state regarding the geofence
      final GeoFenceChecker geoFenceChecker = GeoFenceChecker(); // Instance of GeoFenceChecker
  Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
  }

  void start() async {
    await requestLocationPermission();
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      BackgroundLocation.setAndroidNotification(
        icon: "@drawable/ic_stat_onesignal_default",
      );
      BackgroundLocation.stopLocationService();
      BackgroundLocation.startLocationService(
          distanceFilter: 20); // Set a distance filter if needed

BackgroundLocation.getLocationUpdates((location) async {
  print("Location: Latitude: ${location.latitude}, Longitude: ${location.longitude}");
  double latitude = location.latitude ?? 0.0; // Default value or handle null as needed
  double longitude = location.longitude ?? 0.0; // Default value or handle null as needed

  int? geofenceId = await geoFenceChecker.checkIfEnteredGeoFence(latitude, longitude);
  if (geofenceId != null && !isInsideGeoFence) {
    isInsideGeoFence = true;
    final sharedPreferences = await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('uuid');
    final festival = sharedPreferences.getString('selectedFestivalDBPrefix');
    logGeoFenceEntry(uuid!, geofenceId, festival!); // Use geofenceId here
  } else if (geofenceId == null && isInsideGeoFence) {
    isInsideGeoFence = false;
    final sharedPreferences = await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('uuid');
    logGeoFenceExit(uuid!); // Adjust as needed for exiting logic, providing a default value for geofenceId if null
  }
});
    } else {
      print("Location permission not granted");
    }
  }

  void stop() {
    BackgroundLocation.stopLocationService();
  }

Future<void> logGeoFenceEntry(String uuid, int zone, String festival) async {
  // Generate a new UUID for this entry
  var entryUuid = Uuid().v4();
  
  final now = DateTime.now().toIso8601String();
  final response = await supabase.from('attendance').insert({
    'UUID': entryUuid,
    'zone': zone,
    'entered': now,
  }).select();
  print(response);

  // Store the entry UUID in SharedPreferences for later use
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('entryUUID', entryUuid);

  if (response == null) {
    print('Error inserting entry: $response');
  } else {
    print("Entered GeoFence with entry UUID: $entryUuid");
  }
}

Future<void> logGeoFenceExit(String uuid) async {
  // Retrieve the entry UUID from SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final entryUuid = sharedPreferences.getString('entryUUID');

  if (entryUuid != null) {
    final response = await supabase
        .from('attendance')
        .update({'left': DateTime.now().toIso8601String()})
        .eq('UUID', entryUuid).isFilter('left', null).select();
    print(response);
    if (response == null) {
      print('Error updating exit: $response');
    } else {
      print("Left GeoFence with entry UUID: $entryUuid");
      // Optionally, clear the entryUUID from SharedPreferences if it's no longer needed
      await sharedPreferences.remove('entryUUID');
    }
  } else {
    print("No entry UUID found for exiting GeoFence");
  }
}
}
