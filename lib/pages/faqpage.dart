import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FAQPage extends StatefulWidget {
  FAQPage({Key? key}) : super(key: key);

  @override
  FAQPageState createState() => FAQPageState();
}

class FAQPageState extends State<FAQPage> {
  List<FAQItem> faqItems = [];

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedFestival = prefs.getString('selectedFestivalDBPrefix');
    String tableName = "${selectedFestival ?? 'ha'}-faq";


    final response = await Supabase.instance.client.from(tableName).select();

    setState(() {
      faqItems = (response as List).map((faq) => FAQItem(section: faq['section'], question: faq['question'], answer: faq['answer'])).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: faqItems.fold(<Widget>[], (previousValue, element) {
                if (previousValue.isEmpty || (previousValue.last as FAQItem).section != element.section) {
                  String sectionTitle;
                  switch (element.section) {
                    case 0:
                      sectionTitle = 'GENERAL INFO';
                      break;
                    case 1:
                      sectionTitle = 'FESTIVAL GUIDELINES';
                      break;
                    default:
                      sectionTitle = 'OTHER';
                  }
                  previousValue.add(Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      sectionTitle,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
                previousValue.add(element);
                return previousValue;
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'NO VIDEO OR AUDIO RECORDINGS ON FESTIVAL GROUNDS',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.red),
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

  FAQItem({Key? key, required this.section, required this.question, required this.answer}) : super(key: key);

  @override
  FAQItemState createState() => FAQItemState();
}

class FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(widget.question),
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