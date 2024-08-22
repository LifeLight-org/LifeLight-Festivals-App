import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT Z8'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Z8 is a ministry of LifeLight geared towards reaching Gen Z through events and evangelism. We aim to unite the local church and Make Jesus Famous!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'A movement to equip Gen Z to reach their own generation through a variety of platforms',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 221, 0)),
                    textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      leading: Icon(Icons.brightness_1, size: 8),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Win',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 221, 0),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' – We want to discover young world changers and ignite a fire for the gospel in them.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16), // Default text color
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.brightness_1, size: 8),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Empower',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 221, 0),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' – We want to teach young world changers to be baptized and obey the commands of Jesus.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16), // Default text color
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.brightness_1, size: 8),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Send',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 221, 0),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' – We want to send you back out into the harvest to reach the lost for Jesus.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16), // Default text color
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.brightness_1, size: 8),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Multiply',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 221, 0),
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' – We want you to make disciples that make disciples that go out into the world',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16), // Default text color
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
              SizedBox(height: 16),
              Text(
                  'Through the Z8 Initiatiative we are on a mission to reach Generation Z for Jesus while empowering world changers all around the world to do the same.',
                  style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
