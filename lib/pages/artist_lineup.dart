import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/component-widgets/artist_card.dart';
import 'package:lifelight_app/components/basepage.dart';
import 'package:lifelight_app/component-widgets/artist_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtistLineupPage extends StatefulWidget {
  const ArtistLineupPage({super.key});

  @override
  ArtistLineupPageState createState() => ArtistLineupPageState();
}

class ArtistLineupPageState extends State<ArtistLineupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Artist Lineup',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Saturday'),
              Tab(text: 'Sunday'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<Widget>(
                  future: _buildArtistList('2024-07-20'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data!;
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                FutureBuilder<Widget>(
                  future: _buildArtistList('2024-07-21'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return snapshot.data!;
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildArtistList(String day) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = '${selectedFestival ?? 'ha'}-artist_lineup';

    return FutureBuilder(
      future: Supabase.instance.client.from(tableName).select().eq('day', day),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final artists = snapshot.data as List<dynamic>;
          if (artists.isEmpty) {
            return const Center(child: Text('Updates to Come'));
          } else {
            return ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];

                final timeParts = artist['time']
                    .split(RegExp('[-:]'))
                    .map(int.parse)
                    .toList();
                final timeOfDay =
                    TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
                final formattedTime = timeOfDay.format(context);

                return ArtistCard(
                  artist: Artist(
                    name: artist['name'],
                    image: artist['image'],
                    day: artist['day'],
                    time: formattedTime,
                    stage: artist['stage'],
                    link: artist['link'],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ArtistPopup(
                          artistName: artist['name'],
                          playtime: formattedTime,
                          imageUrl: artist['image'],
                          aboutText: (artist['about'] == null ||
                                  artist['about'].isEmpty)
                              ? 'No information available'
                              : artist['about'],
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
