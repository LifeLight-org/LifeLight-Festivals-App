import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class KnowGodPage extends StatefulWidget {
  @override
  _KnowGodPageState createState() => _KnowGodPageState();
}

class _KnowGodPageState extends State<KnowGodPage> {
  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = YoutubePlayerController(
      initialVideoId: 'hvtSrRIdjjs', // Replace with your first YouTube video ID
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _controller2 = YoutubePlayerController(
      initialVideoId:
          '769QeYDPY00', // Replace with your second YouTube video ID
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

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
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing
            Text(
              "These 4 symbols explain the message of the Bible",
              style: TextStyle(
                fontSize: 20.0, // Increase the text size
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/heart.svg',
                width: 25.0,
                color: Color(0xffFFD000),
              ),
              title: Text('God loves me. John 3:16, Genesis 1:27'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/divided.svg',
                width: 25.0,
                color: Color(0xffFFD000),
              ),
              title: Text(
                  'I live apart from God – Sin separates you from God and our default is a destination of Hell and a life of no meaning. Romans 3:23, Romans 6:23, Isaiah 59:2, Romans 3:20'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/cross.svg',
                width: 25.0,
                color: Color(0xffFFD000),
              ),
              title: Text(
                  'Jesus rescues us and gave everything for you by shedding His blood on the cross and taking the place for our sin. Romans 5:8, 1 Peter 3:18, 1 Corinthians 15:3-8'),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/question.svg',
                width: 25.0,
                color: Color(0xffFFD000),
              ),
              title: Text(
                  'Do I want to trust and follow Jesus? John 1:12, Romans 10:8,9'),
            ),
            SizedBox(height: 16.0), // Add some spacing
            Text(
              'If you want to be a follower of Jesus, you can do so now by simply talking to God through prayer.',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing
            Text('The gospel is as simple as ABC',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0), // Add some spacing
            Text('ADMIT...BELIEVE...CONFESS',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0), // Add some spacing
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.brightness_1, size: 8), // Bullet point icon
                      SizedBox(width: 8), // Space between bullet point and text
                      Expanded(
                        child: Text(
                          'ADMIT... that you need a Savior and are willing to turn (repent) from your sins.',
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.brightness_1, size: 8), // Bullet point icon
                      SizedBox(width: 8), // Space between bullet point and text
                      Expanded(
                        child: Text(
                          'BELIEVE...that Christ died and rose again so that you could be saved.',
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.brightness_1, size: 8), // Bullet point icon
                      SizedBox(width: 8), // Space between bullet point and text
                      Expanded(
                        child: Text(
                          'CONFESS...that Jesus Christ is your Lord and Savior.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0), // Add some spacing
            Text(
                'Pray this prayer, "Lord Jesus, I admit that I have sinned, I believe you died and rose again so I can be saved, I turn from my sin and confess you as Lord and Master of my life. Thank you for giving me eternal life. Amen"',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0), // Add some spacing
            Text(
                'If you prayed and sincerely meant it in your heart, you are a child of God and have eternal life!',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0), // Add some spacing
            YoutubePlayer(
              controller: _controller1,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              progressColors: ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
            ),
            SizedBox(height: 16.0), // Add some spacing
            GestureDetector(
              onTap: () {
                final ChromeSafariBrowser browser = ChromeSafariBrowser();
                browser.open(
                    url: WebUri(
                        'https://lifelight.breezechms.com/form/23d1f1'), // Use the `url` parameter here
                    options: ChromeSafariBrowserClassOptions(
                        android: AndroidChromeCustomTabsOptions(
                            addDefaultShareMenuItem: false),
                        ios: IOSSafariOptions(barCollapsingEnabled: true)));
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
            SizedBox(height: 16.0),
            Row(children: [
              Text("For further resources click ",
                  style: TextStyle(fontSize: 20.0)),
              GestureDetector(
                onTap: () {
                  final ChromeSafariBrowser browser = ChromeSafariBrowser();
                  browser.open(
                      url: WebUri(
                          'https://www.hopewithgod.com/'), // Use the `url` parameter here
                      options: ChromeSafariBrowserClassOptions(
                          android: AndroidChromeCustomTabsOptions(
                              addDefaultShareMenuItem: false),
                          ios: IOSSafariOptions(barCollapsingEnabled: true)));
                },
                child: Text(
                  'here.',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(
                        0xffFFD000), // This makes the text look like a link
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ]),
            Row(children: [
              Text("Additional resources ", style: TextStyle(fontSize: 20.0)),
              GestureDetector(
                onTap: () {
                  final ChromeSafariBrowser browser = ChromeSafariBrowser();
                  browser.open(
                      url: WebUri(
                          'https://livingwaters.com/are-you-a-good-person/'), // Use the `url` parameter here
                      options: ChromeSafariBrowserClassOptions(
                          android: AndroidChromeCustomTabsOptions(
                              addDefaultShareMenuItem: false),
                          ios: IOSSafariOptions(barCollapsingEnabled: true)));
                },
                child: Text(
                  'here.',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(
                        0xffFFD000), // This makes the text look like a link
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ]),
            SizedBox(height: 16.0),
            Text('One Minute Witness',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0),
            Text('Sharing your faith story in around a minute. For resources and training on how to learn to share your story email alang@lifelight.org',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0),
            Text('To schedule group training for your church or ministry team contact alang@lifelight.org',
                style: TextStyle(
                  fontSize: 20.0,
                )),
            SizedBox(height: 16.0),
            YoutubePlayer(
              controller: _controller2,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              progressColors: ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
