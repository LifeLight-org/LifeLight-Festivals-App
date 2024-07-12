import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourcesPage extends StatefulWidget {
  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<MinistryPartner> ministryPartners = [];
  bool isLoading = true; // Step 1: Add a loading state variable
  var festivalName = '';

  @override
  void initState() {
    super.initState();
    fetchMinistryPartners();
  }

  Future<void> fetchMinistryPartners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedFestivalId = prefs.getInt('selectedFestivalId');

    final response = await Supabase.instance.client
        .from('ministry_partners')
        .select('*')
        .eq('festival', selectedFestivalId!)
        .order('name', ascending: true);
    final data = response as List<dynamic>;
    setState(() {
      ministryPartners =
          data.map((item) => MinistryPartner.fromJson(item)).toList();
      isLoading = false; // Step 2: Set loading to false after data is fetched
    });
  }

  Future<String> _getFestival() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedFestival') ?? 'default';
  }

  void _launchAppURL(BuildContext context) async {
    String url;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/us/app/apple-store/id1535457204';
    } else {
      url = 'https://play.google.com/store/apps/details?id=org.ptl.app';
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ministryPartners.isEmpty
              ? Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Pocket Testament League'),
                      _buildSectionContent(
                        "The Pocket Testament League app is your digital tool for sharing the message of the Bible. Access digital New Testaments, get tips for effective evangelism.",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: ElevatedButton(
                          onPressed: () => _launchAppURL(context),
                          child: const Text('Open The PTL App'),
                        ),
                      ),
                      _buildSectionTitle('Hope With God'),
                      _buildSectionContent(
                        "Hope With God is an online platform that provides resources and support for individuals seeking spiritual guidance and encouragement. It helps people face life's challenges with faith and hope, providing inspiration, answers, and a supportive community for spiritual growth.",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            const url = 'https://www.hopewithgod.com';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: const Text('Open hopewithgod.com'),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: ministryPartners.length +
                      1, // Add two for the extra containers at the end
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // This is the extra container at the start
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Our Ministry Partners'),
                          ],
                        ),
                      );
                    } else if (index == ministryPartners.length) {
                      // This is the first extra container
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Pocket Testament League'),
                            _buildSectionContent(
                              "The Pocket Testament League app is your digital tool for sharing the message of the Bible. Access digital New Testaments, get tips for effective evangelism.",
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: ElevatedButton(
                                onPressed: () => _launchAppURL(context),
                                child: const Text('Open The PTL App'),
                              ),
                            ),
                            _buildSectionTitle('Hope With God'),
                            _buildSectionContent(
                              "Hope With God is an online platform that provides resources and support for individuals seeking spiritual guidance and encouragement. It helps people face life's challenges with faith and hope, providing inspiration, answers, and a supportive community for spiritual growth.",
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  const url = 'https://www.hopewithgod.com';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: const Text('Open hopewithgod.com'),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Return a ListTile for ministryPartners items
                      final partner = ministryPartners[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(
                                  0xFFFFDD00), // Color of the border using hex value
                              width: 1.0, // Width of the border
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(partner.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(partner.address),
                              Text(partner.phone ??
                                  ''), // Use null-aware operator for optional fields
                              Text(partner.website ??
                                  ''), // Use null-aware operator for optional fields
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            final Uri _url =
                                Uri.parse('http://${partner.website}/');
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                        ),
                      );
                    }
                  },
                ),
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xffFFD000), // Change the color of the title
        decoration: TextDecoration.underline, // Underline the title
      ),
    ),
  );
}

Widget _buildSectionContent(String content) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Text(
      content,
      style: TextStyle(
        fontSize: 16, // Increase the font size
        color: Colors.white, // Change the color of the content
        fontStyle: FontStyle.italic, // Make the content italic
      ),
    ),
  );
}

class MinistryPartner {
  final String name;
  final String address;
  final String? phone;
  final String? website;

  MinistryPartner({
    required this.name,
    required this.address,
    this.phone,
    this.website,
  });

  factory MinistryPartner.fromJson(Map<String, dynamic> json) {
    return MinistryPartner(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
    );
  }
}
