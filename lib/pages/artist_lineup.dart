import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifelight_app/component-widgets/artist_card.dart';
import 'package:intl/intl.dart';
import 'package:lifelight_app/component-widgets/artist_popup.dart';

class Artist {
  final String name;
  final String date;
  final String location;
  final String time;
  final String image;
  final String? bio;

  Artist(
      {required this.name,
      required this.date,
      required this.time,
      required this.location,
      required this.image,
      this.bio});

factory Artist.fromJson(Map<String, dynamic> json) {
  var inputFormat = DateFormat('HH:mm:ss');
  var outputFormat = DateFormat('h:mm a');
  var time = outputFormat.format(inputFormat.parse(json['time']));

  if (time == '12:00 AM') {
    time = 'TBD';
  }

  String bio = json['about'] ?? 'Bio Coming Soon!';

  return Artist(
    name: json['name'],
    date: json['day'],
    time: time,
    location: json['stage'],
    image: json['image'],
    bio: bio,
  );
}
}

Future<List<Artist>> fetchArtists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
  String tableName = "${selectedFestival ?? 'ha'}-artist_lineup";
  final response = await Supabase.instance.client.from(tableName).select('*');

  return (response as List).map((item) => Artist.fromJson(item)).toList();
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

  @override
  void initState() {
    super.initState();
    fetchArtists().then((artists) {
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
  }

  String formatDate(String date) {
    var inputFormat = DateFormat('yyyy-MM-dd');
    var inputDate = inputFormat.parse(date);

    var outputFormat = DateFormat('EEEE');
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
        bottom: _buildTabBar(uniqueDates, _dateController, formatDate),
      ),
      body: _buildBody(uniqueDates),
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
              playtime: artist.time,
              imageUrl: artist.image,
              aboutText: artist.bio ?? 'Coming Soon!',
            );
          },
        );
      },
    );
  }
}
