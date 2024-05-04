import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SponsorPage extends StatefulWidget {
  const SponsorPage({Key? key}) : super(key: key);

  @override
  SponsorPageState createState() => SponsorPageState();
}

class SponsorPageState extends State<SponsorPage> {
  List<Sponsor> sponsors = [];
  bool isScrolling = false;
  double opacity = 1.0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSponsors();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset <= 0) {
      if (isScrolling) {
        setState(() {
          isScrolling = false;
          opacity = 1.0;
        });
      }
    } else {
      if (!isScrolling) {
        setState(() {
          isScrolling = true;
          opacity = 0.0;
        });
      }
    }
  }

  Future<void> fetchSponsors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = "${selectedFestival ?? 'ha'}-sponsors";

    final response = await Supabase.instance.client.from(tableName).select('*');

    if (response.isEmpty) {
      throw Exception('No sponsors found');
    }

    List<Sponsor> items = await Future.wait(
        response.map((item) => Sponsor.fromJson(item)).toList());

    setState(() {
      sponsors = items;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsors'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return ListTile(
                  leading: const SizedBox.shrink(), // Empty leading widget
                  title: Center(
                    child: Image.network(
                      sponsor.logo,
                      width: 130, // You can adjust the size as needed
                      height: 130, // You can adjust the size as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: GestureDetector(
                            child: Stack(
                              children: [
                                Center(
                                  child: Hero(
                                    tag: 'imageHero',
                                    child: Image.network(sponsor.advert),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 55,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          AnimatedOpacity(
            opacity: opacity,
            duration: Duration(milliseconds: 700),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Click on the sponsor's logo to learn more about them.",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Sponsor {
  final String name;
  final String logo;
  final String advert;

  Sponsor({
    required this.name,
    required this.logo,
    required this.advert,
  });

  static Future<Sponsor> fromJson(Map<String, dynamic> json) async {
    return Sponsor(
      name: json['name'],
      logo: json['logo'],
      advert: json['advert'],
    );
  }
}
