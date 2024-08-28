import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Default festival DB prefix
const defaultFestivalDBPrefix = 'ha';

class FAQPage extends StatefulWidget {
  FAQPage({Key? key}) : super(key: key);

  @override
  FAQPageState createState() => FAQPageState();
}

class FAQPageState extends State<FAQPage> {
  List<FAQItem> faqItems = [];
  Map<int, String> faqSections = {};
  bool isLoading = true;
  bool isSelectedFestivalTypeEvent = false;

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? selectedFestivalId = prefs.getInt('selectedFestivalId');
      isSelectedFestivalTypeEvent = prefs.getBool('isSelectedFestivalTypeEvent') ?? false;

      // Fetch sections
      final sectionsResponse = await Supabase.instance.client.from("faq_sections").select("*");
      Map<int, String> sections = {};
      for (var section in sectionsResponse) {
        sections[section['id']] = section['title'];
      }

      // Fetch FAQs
      final faqResponse = await Supabase.instance.client.from("faq").select("*").eq("festival", selectedFestivalId!);

      // Map the response to FAQItem and sort the items by section
      List<FAQItem> items = (faqResponse as List)
          .map((faq) => FAQItem(
              section: faq['section'],
              question: faq['question'],
              answer: faq['answer']))
          .toList();
      items.sort((a, b) => a.section.compareTo(b.section));

      setState(() {
        faqItems = items;
        faqSections = sections;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch FAQs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: faqItems.fold(<Widget>[], (previousValue, element) {
                      if (previousValue.isEmpty ||
                          (previousValue.last as FAQItem).section !=
                              element.section) {
                        String sectionTitle = faqSections[element.section] ?? 'OTHER';
                        previousValue.add(Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            sectionTitle,
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ));
                      }
                      previousValue.add(element);
                      return previousValue;
                    }),
                  ),
                ),
                if (!isSelectedFestivalTypeEvent)
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'NO VIDEO OR AUDIO RECORDINGS ON FESTIVAL GROUNDS',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final int section;
  final String question;
  final String answer;

  FAQItem(
      {Key? key,
      required this.section,
      required this.question,
      required this.answer})
      : super(key: key);

  @override
  FAQItemState createState() => FAQItemState();
}

class FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(widget.question, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              widget.answer,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        initiallyExpanded: isExpanded,
      ),
    );
  }
}