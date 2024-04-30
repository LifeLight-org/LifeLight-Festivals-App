import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SponsorPage extends StatefulWidget {
  const SponsorPage({super.key});

  @override
  SponsorPageState createState() => SponsorPageState();
}

class SponsorPageState extends State<SponsorPage> {
  List<Sponsor> sponsors = [];

  @override
  void initState() {
    super.initState();
    fetchSponsors();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sponsors'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return ListTile(
                  leading: SizedBox.shrink(), // Empty leading widget
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
                                    icon: Icon(Icons.close),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Click on the sponsor's logo to learn more about them.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
