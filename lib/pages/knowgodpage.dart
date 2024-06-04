import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'connectpage.dart';
import 'resourcespage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnowGodPage extends StatelessWidget {
  const KnowGodPage({Key? key}) : super(key: key);


  // This function launches the URL
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

  Future<String> _getFestival() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedFestival') ?? 'default';
  }

  void _launchFBURL(BuildContext context) async {
    String festival = await _getFestival();
    String url;
    switch (festival) {
      case 'Hills Alive':
        url = 'https://www.facebook.com/hillsalive';
        break;
      case 'LifeLight Festival':
        url = 'https://www.facebook.com/LifeLightmovement';
        break;
      default:
        url = 'https://lifelight.org';
        break;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchIGURL(BuildContext context) async {
    String festival = await _getFestival();
    String url;
    switch (festival) {
      case 'Hills Alive':
        url = 'https://www.instagram.com/hills.alive/';
        break;
      case 'LifeLight Festival':
        url = 'https://www.instagram.com/lifelightmovement/';
        break;
      default:
        url = 'https://lifelight.org';
        break;
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
        title: const Text('Know God'),
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'HOW TO KNOW GOD',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xffFFD000),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'The Bible says we can know God through a relationship with his Son Jesus Christ.\n\n'
              'John 17:3 “Now this is eternal life: that they may know you, the only true God, and Jesus Christ, whom you have sent.”\n\n'
              'Not only are believers promised eternal life, but once we receive Christ, the joy of knowing God starts immediately. The life of a Christian may not always be easy, but God through His Spirit will be with you always. Once you are adopted as a child of God you are promised eternal life.\n\n'
              'John 1:12 “Yet to all who received Him, to those who believed in His name, He gave the right to become children of God.”\n\n'
              'I John 5:11-13 “And this is the testimony: God has given us eternal life, and this life is in his Son. He who has the Son has life; he who does not have the Son of God does not have life. I write these things to you who believe in the name of the Son of God so that you may know that you have eternal life.”\n\n'
              'Want to Know God and have a relationship with Him? You can do that now.\n\n'
              'It’s this simple:\n\n'
              'Realize you are a sinner: The Bible says that no one is good enough and we can’t earn/work our way to heaven. Romans 3:10 “As it is written: There is no one righteous, not even one.” Romans 3:23 “for all have sinned and fall short of the glory of God.”\n\n'
              'Acknowledge that Jesus died on the cross for you. Romans 5:8 “But God demonstrates his own love for us in this: While we were still sinners, Christ died for us.”\n\n'
              'Be willing to turn from your sin and change direction. Instead of running from God, run towards Him; the Bible calls this repentance. Acts 3:19 “Repent, then, and turn to God, so that your sins may be wiped out, that times of refreshing may come from the Lord.”\n\n'
              'Receive Jesus into your life. It’s not about reciting a creed or going to church. It is having Jesus Christ himself, take residence in your life. He says: Rev 3:20 “I stand at the door of your heart and knock if anyone hears my voice and opens the door. I will come in.” John 1:12 “Yet to all who received him, to those who believed in his name, he gave the right to become children of God.”\n\n'
              'Pray this prayer: Lord Jesus, I know that I am a sinner. I know that you died for my sins and rose again from the dead to save me. Right now, I turn from my sins and open the door of my heart and life. I want you to be my Lord and Master. Jesus, I fully surrender myself to you.\n\n'
              'If you prayed and sincerely meant it in your heart, you are a child of God and have eternal life!\n\n',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectPage()),
                );
              },
              child: const Text(
                'Please let us know about your decision to accept Christ here.',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color(0xffFFD000),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 35.0),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
      ),
    ],
  ),
),
    );
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
}
