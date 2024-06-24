import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/component-widgets/artist_card.dart';
import 'package:intl/intl.dart';
import 'package:lifelight_app/component-widgets/artist_popup.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Artist {
  final String name;
  final String date;
  final String location;
  final String time;
  String displayTime;
  final String image;
  final String? bio;
  final String? link;

  Artist({
    required this.name,
    required this.date,
    required this.time,
    required this.displayTime,
    required this.location,
    required this.image,
    this.bio,
    this.link,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    var inputFormat = DateFormat('HH:mm:ss');
    var outputFormat = DateFormat('h:mm a');
    var time = json['time'];
    var displayTime = outputFormat.format(inputFormat.parse(time));

    if (time == '00:00:00') {
      displayTime = 'TBA';
    }

    String bio = json['about'] ?? 'Bio Coming Soon!';
    return Artist(
      name: json['name'],
      date: json['date'],
      time: time,
      displayTime: displayTime,
      location: json['stage'],
      image: json['image'],
      bio: bio,
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'time': time,
      'displayTime': displayTime,
      'location': location,
      'image': image,
      'bio': bio,
      'link': link, 
    };
  }
}

Future<List<Artist>> fetchArtists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? selectedFestivalId = prefs.getInt('selectedFestivalId');
  var box = await Hive.openBox('artistBox');

  try {
    final response = await Supabase.instance.client
        .from("artist_lineup")
        .select('*')
        .eq('festival', selectedFestivalId!);
    List<Artist> artists = List<Artist>.from(
        (response as List).map((item) => Artist.fromJson(item)));
    // Store the artists in Hive
    box.put('artists', artists.map((artist) => artist.toJson()).toList());
    artists.sort((a, b) {
      var adate = DateFormat('yyyy-MM-dd').parse(a.date);
      var bdate = DateFormat('yyyy-MM-dd').parse(b.date);
      var atime = DateFormat('HH:mm:ss').parse(a.time);
      var btime = DateFormat('HH:mm:ss').parse(b.time);
      return adate.compareTo(bdate) == 0
          ? atime.compareTo(btime)
          : adate.compareTo(bdate);
    });

    return artists;
  } catch (e) {
    // Fetch from Hive
    var artistsJson = box.get('artists', defaultValue: []);
    return List<Artist>.from(artistsJson.map((item) => Artist.fromJson(item)));
  }
}

class ArtistLineupPage extends StatefulWidget {
  const ArtistLineupPage({super.key});

  @override
  ArtistLineupPageState createState() => ArtistLineupPageState();
}

class ArtistLineupPageState extends State<ArtistLineupPage>
    with TickerProviderStateMixin {
  late TabController _dateController = TabController(length: 0, vsync: this);
  final Map<String, TabController> _locationControllers = {};
  List<Artist> _artists = [];
  bool _isLoading = true; // Step 1: Add a loading state variable

  @override
  void initState() {
    super.initState();
    _isLoading = true; // Step 2: Set loading to true before fetching
    fetchArtists().then((artists) {
      setState(() {
        _artists = artists;
        _dateController =
            TabController(length: _getUniqueDates().length, vsync: this);
        _getUniqueDates().forEach((date) {
          _locationControllers[date] = TabController(
              length: _getUniqueLocationsForDate(date).length, vsync: this);
        });
        _isLoading = false; // Step 3: Set loading to false after fetching
      });
    });
  }

  String formatDate(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(date);

    var outputFormat = DateFormat('EEEE, MMM d');
    var outputDate = outputFormat.format(inputDate);

    return outputDate;
  }

  List<String> _getUniqueDates() {
    return _artists.map((artist) => artist.date).toSet().toList();
  }

  List<String> _getUniqueLocationsForDate(String date) {
    return _artists
        .where((artist) => artist.date == date)
        .map((artist) => artist.location)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (var controller in _locationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var uniqueDates = _getUniqueDates();
    return Scaffold(
      appBar: AppBar(
        title: Text('ARTIST LINEUP AND BIOS'),
        bottom: _buildTabBar(uniqueDates, _dateController, formatDate),
      ),
      body: _isLoading // Step 4: Conditional rendering based on loading state
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : _buildBody(uniqueDates), // Show actual content
    );
  }

  Widget _buildBody(List<String> uniqueDates) {
    return uniqueDates.length > 1
        ? _buildTabBarView(uniqueDates)
        : _buildSingleDateView(uniqueDates);
  }

  Widget _buildSingleDateView(List<String> uniqueDates) {
    if (uniqueDates.isEmpty) {
      return Container(); // return an empty Container or some other widget
    }
    var date = uniqueDates[0];
    var locationsForDate = _getUniqueLocationsForDate(date);
    return _buildListView(locationsForDate, date); // use locationsForDate
  }

  Widget _buildListView(List<String> locationsForDate, String date) {
    if (locationsForDate.isEmpty) {
      return Container(); // return an empty Container or some other widget
    }
    return locationsForDate.length > 1
        ? TabBarView(
            controller: _locationControllers[date], // Add this line
            children: locationsForDate
                .map((location) => _buildArtistList(date, location))
                .toList(),
          )
        : _buildArtistList(date, locationsForDate[0]);
  }

  PreferredSizeWidget? _buildTabBar(List<String> items,
      TabController controller, String Function(String) format) {
    return items.length > 1
        ? PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: controller,
              tabs: items.map((item) => Tab(text: format(item))).toList(),
            ),
          )
        : const PreferredSize(
            preferredSize: Size.zero, child: SizedBox.shrink());
  }

  Widget _buildTabBarView(List<String> uniqueDates) {
    return TabBarView(
      controller: _dateController,
      children: uniqueDates.map((date) {
        var locationsForDate = _getUniqueLocationsForDate(date);
        return Column(
          children: [
            _buildTabBar(locationsForDate, _locationControllers[date]!,
                    (item) => item) ??
                const SizedBox.shrink(),
            Expanded(
              child: _buildListView(locationsForDate, date),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildArtistList(String date, String location) {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchArtists().then((artists) {
          setState(() {
            _artists = artists;
            _dateController =
                TabController(length: _getUniqueDates().length, vsync: this);
            _getUniqueDates().forEach((date) {
              _locationControllers[date] = TabController(
                  length: _getUniqueLocationsForDate(date).length, vsync: this);
            });
          });
        });
      },
      child: ListView(
        children: _artists
            .where(
                (artist) => artist.date == date && artist.location == location)
            .map((artist) => _buildArtistCard(artist))
            .toList(),
      ),
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return ArtistCard(
      artist: artist,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ArtistPopup(
              artistName: artist.name,
              stage: artist.location,
              playtime: artist.displayTime,
              imageUrl: artist.image,
              aboutText: artist.bio ?? 'Coming Soon!',
              link: artist.link,
            );
          },
        );
      },
    );
  }
}
