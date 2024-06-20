import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifelight_app/config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SponsorPage extends StatefulWidget {
  const SponsorPage({Key? key}) : super(key: key);

  @override
  SponsorPageState createState() => SponsorPageState();
}

class SponsorPageState extends State<SponsorPage> {
  List<Sponsor> sponsors = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSponsors();
  }

  Future<void> fetchSponsors() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');

    final response = await Supabase.instance.client
        .from("sponsors")
        .select('*')
        .eq("festival", selectedFestivalId!);

    if (response.isEmpty) {
      throw Exception('No sponsors found');
    }

    List<Sponsor> items = await Future.wait(
        response.map((item) => Sponsor.fromJson(item)).toList());

    items.sort((a, b) => Config.tierOrder
        .indexOf(a.tier)
        .compareTo(Config.tierOrder.indexOf(b.tier)));

    setState(() {
      sponsors = items;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPONSORS'),
      ),
      body: isLoading // Step 3: Check isLoading to decide what to display
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Thank You to our incredible sponsors click on their logos below to learn more.",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SponsorGrid(
                      key: UniqueKey(), sponsors: sponsors, onTap: _handleTap),
                ),
              ],
            ),
    );
  }

  Future<void> _handleTap(Sponsor sponsor) async {
    if ((sponsor.advert == null || sponsor.advert!.isEmpty) &&
        sponsor.link != null) {
      final ChromeSafariBrowser browser = ChromeSafariBrowser();
      browser.open(
        url: WebUri(sponsor.link!), // Corrected to Uri.parse for the URL
        options: ChromeSafariBrowserClassOptions(
          android:
              AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
          ios: IOSSafariOptions(barCollapsingEnabled: true),
        ),
      );
    } else if (sponsor.advert != null && sponsor.advert!.isNotEmpty) {
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
  }
}

class SponsorGrid extends StatelessWidget {
  final List<Sponsor> sponsors;
  final Function(Sponsor) onTap;

  const SponsorGrid({Key? key, required this.sponsors, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: sponsors.length,
      itemBuilder: (context, index) {
        final sponsor = sponsors[index];
        return GestureDetector(
          onTap: () => onTap(sponsor),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.network(
              sponsor.logo,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
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
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      advert: json['advert'],
      link: json['link'],
      tier: json['tier'] ?? '',
    );
  }
}
