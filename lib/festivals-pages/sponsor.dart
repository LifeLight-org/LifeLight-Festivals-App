import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SponsorPage extends StatefulWidget {
  @override
  _SponsorPageState createState() => _SponsorPageState();
}

class _SponsorPageState extends State<SponsorPage> {
  List<Sponsor> sponsors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSponsors();
  }

  Future<void> fetchSponsors() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedFestivalId = prefs.getInt('selectedFestivalId')!;

    final response = await Supabase.instance.client
        .from('sponsors')
        .select('*, sponsors_levels(tier_level)')
        .eq('festival', selectedFestivalId);

    if (response != null) {
      final data = response as List<dynamic>;
      setState(() {
        sponsors = data.map((json) => Sponsor.fromJson(json)).toList();
        sponsors.sort((a, b) => a.tier.compareTo(b.tier)); // Sort by tier
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
        title: Text('SPONSORS'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Thank you to our incredible sponsors!',
                    style: TextStyle(fontSize: 24,
                    fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: sponsors.length,
                      itemBuilder: (context, index) {
                        final sponsor = sponsors[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: sponsor.logo,
                            fit: BoxFit.contain,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class Sponsor {
  final String name;
  final String logo;
  final int tier;

  Sponsor({required this.name, required this.logo, required this.tier});

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      name: json['name'],
      logo: json['logo'],
      tier: json['sponsors_levels']['tier_level'],
    );
  }
}
