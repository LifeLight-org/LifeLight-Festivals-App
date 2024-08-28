import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ArtistLineupPage extends StatefulWidget {
  @override
  _ArtistLineupPageState createState() => _ArtistLineupPageState();
}

class _ArtistLineupPageState extends State<ArtistLineupPage> {
  List<Artist> artists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArtists();
  }

  Future<void> fetchArtists() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFestivalId = prefs.getInt('selectedFestivalId')!;

    final response = await Supabase.instance.client
        .from('artist_lineup')
        .select('*, festival_dates(*), festival_locations(location)')
        .eq('festival', selectedFestivalId)
        .order('festival_dates(date)', ascending: true)
        .order('time', ascending: true)
        .order('name', ascending: true);

    if (response != null) {
      final data = response as List<dynamic>;
      setState(() {
        artists = data.map((json) => Artist.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ARTIST LINEUP'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ArtistCard(
                  artistName: artist.name,
                  imageUrl: artist.image,
                  location: artist.location,
                  date: artist.date,
                  about: artist.about,
                );
              },
            ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final String artistName;
  final String imageUrl;
  final String location;
  final String date;
  final String? about;

  const ArtistCard({
    required this.artistName,
    required this.imageUrl,
    required this.location,
    required this.date,
    this.about,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ArtistPopup(
              artistName: artistName,
              stage: location,
              playtime: date,
              imageUrl: imageUrl,
              aboutText: about ?? 'No information available',
              isCancelled: false, // Assuming this value for now
            );
          },
        );
      },
      child: Card(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      artistName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArtistPopup extends StatelessWidget {
  final String artistName;
  final String stage;
  final String playtime;
  final String imageUrl;
  final String aboutText;
  final String? link;
  final bool isCancelled;

  const ArtistPopup({
    Key? key,
    required this.artistName,
    required this.stage,
    required this.playtime,
    required this.imageUrl,
    required this.aboutText,
    this.link,
    required this.isCancelled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Stack(
          children: [
            Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50), // adjust the height as needed
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isCancelled
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical:
                                                4), // Adjust padding as needed
                                        color: Colors
                                            .red, // Choose a background color for the banner
                                        child: Text(
                                          'Cancelled',
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Choose text color
                                            fontWeight: FontWeight
                                                .bold, // Adjust text style as needed
                                          ),
                                        ),
                                      )
                                    : SizedBox
                                        .shrink(), // Or Container() if you prefer
                                AutoSizeText(
                                  artistName,
                                  style: TextStyle(fontSize: 20),
                                  minFontSize: 14,
                                  stepGranularity: 1,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: MediaQuery.of(context).size.width *
                                0.3, // 30% of screen width
                            height: MediaQuery.of(context).size.width *
                                0.3, // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: AutoSizeText(
                        'About $artistName',
                        style: TextStyle(fontSize: 17),
                        minFontSize: 14,
                        stepGranularity: 1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Divider(thickness: 1.0),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AutoSizeText(
                          aboutText,
                          style: TextStyle(fontSize: 20),
                          minFontSize: 20,
                          stepGranularity: 10,
                          maxLines: 100,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Artist {
  final String name;
  final String image;
  final String? about;
  final String location;
  final String date;

  Artist({
    required this.name,
    required this.image,
    this.about,
    required this.location,
    required this.date,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'],
      image: json['image'],
      about: json['about'],
      location: json['festival_locations']['location'],
      date: json['festival_dates']['date'],
    );
  }
}
