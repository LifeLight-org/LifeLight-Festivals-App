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
      body: ListView.builder(
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
                      child: Center(
                        child: Hero(
                          tag: 'imageHero',
                          child: Image.network(sponsor.advert),
                        ),
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
