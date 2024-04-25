import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/components/basepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtistSigningSchedulePage extends StatefulWidget {
  const ArtistSigningSchedulePage({super.key});

  @override
  ArtistSigningSchedulePageState createState() => ArtistSigningSchedulePageState();
}

class ArtistSigningSchedulePageState extends State<ArtistSigningSchedulePage> {
  List<Artist> artists = [];

  @override
  void initState() {
    super.initState();
    fetchArtists();
  }

  Future<void> fetchArtists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = '${selectedFestival ?? 'ha'}-meet_and_greet';

    final response = await Supabase.instance.client.from(tableName).select('*');

    setState(() {
      artists = response.map((item) => Artist.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signing Schedule'),
      ),
      body: artists.isEmpty
          ? const Center(child: Text('Updates to Come'))
          : Scaffold(
              body: DefaultTabController(
                length: 2, // Number of tabs
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Saturday'),
                        Tab(text: 'Sunday'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildArtistList('2024-07-20'),
                          _buildArtistList('2024-07-21'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _buildArtistList(String day) {
    List<Artist> artistsByDay =
        artists.where((artist) => artist.day == day).toList();

    return ListView.builder(
      itemCount: artistsByDay.length,
      itemBuilder: (context, index) {
        return _buildArtistCard(artistsByDay[index]);
      },
    );
  }

  Widget _buildArtistCard(Artist artist) {
    // Split the artist.time string on both ':' and '-'
    final timeParts =
        artist.time.split(RegExp('[:-]')).map(int.parse).toList();
    final timeOfDay = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(artist.image),
          radius: 30.0,
        ),
        title: Text(
          artist.name,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          timeOfDay.format(context),
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}

// Model class for representing an artist
class Artist {
  final String name;
  final String image;
  final String day;
  final String time;

  Artist({
    required this.name,
    required this.image,
    required this.day,
    required this.time,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'],
      image: json['image'],
      day: json['day'],
      time: json['time'],
    );
  }
}
