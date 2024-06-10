import 'package:flutter/material.dart';
import 'connectpage.dart';
import 'resourcespage.dart';

class KnowGodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KNOW GOD'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'HOW TO KNOW GOD',
              style: TextStyle(
                fontSize: 34,
                color: Color(0xffFFD000), // Set the color of the text
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing
            Text(
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
                fontSize: 20.0, // Increase the text size
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectPage()),
                );
              },
              child: Text(
                'Please let us know about your decision to accept Christ here.',
                style: TextStyle(
                  fontSize: 20.0,
                  color:
                      Color(0xffFFD000), // This makes the text look like a link
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 35.0), // Add some spacing
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResourcesPage()),
                );
              },
              child: Text(
                'For further resources click here.',
                style: TextStyle(
                  fontSize: 20.0,
                  color:
                      Color(0xffFFD000), // This makes the text look like a link
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}