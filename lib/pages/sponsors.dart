import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

    List<String> tierOrder = [
      'Partner',
      'Bronze',
      'Silver',
      'Gold',
      'Platinum',
      'Diamond',
      'Kingdom',
    ];

    // Sort the sponsors by tier
// Sort the sponsors by tier
    items.sort((a, b) =>
        tierOrder.indexOf(a.tier).compareTo(tierOrder.indexOf(b.tier)));

// Reverse the list
    items = items.reversed.toList();

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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Discover more about our incredible sponsors by clicking on their logos below.",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Adjust the number of items per row
              ),
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return GestureDetector(
                  onTap: () async {
                    if ((sponsor.advert == null || sponsor.advert!.isEmpty) &&
                        sponsor.link != null) {
                      if (await canLaunch(sponsor.link!)) {
                        await launch(sponsor.link!);
                      } else {
                        throw 'Could not launch ${sponsor.link}';
                      }
                    } else if (sponsor.advert != null &&
                        sponsor.advert!.isNotEmpty) {
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
                                      child: Image.network(sponsor.advert!),
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
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(
                        20.0), // Adjust the padding as needed
                    child: Image.network(
                      sponsor.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
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
  final String? advert;
  final String? link;
  final String tier;

  Sponsor({
    required this.name,
    required this.logo,
    this.advert,
    this.link,
    required this.tier,
  });

  static Future<Sponsor> fromJson(Map<String, dynamic> json) async {
    return Sponsor(
      name: json['name'],
      logo: json['logo'],
      advert: json['advert'],
      link: json['link'],
      tier: json['tier'],
    );
  }
}
