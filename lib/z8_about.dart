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
                'Z8 is a ministry of Lifelight geared towards reaching GenZ through events and evangelism. We aim to unite the local church and ‘Make Jesus Famous’!',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'a movement to equip Generation z to reach their own generation through a variety of platforms',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView(shrinkWrap: true, children: [
                ListTile(
                  leading: Icon(Icons.brightness_1, size: 8),
                  title: Text(
                      'Win – We want to discover young world changers and ignite a fire for the gospel in them.'),
                ),
                ListTile(
                  leading: Icon(Icons.brightness_1, size: 8),
                  title: Text(
                      'Empower – We want to teach young world changers to be baptized and obey the commands of Jesus. '),
                ),
                ListTile(
                  leading: Icon(Icons.brightness_1, size: 8),
                  title: Text(
                      'Send –  We want to send you back out into the harvest to reach the lost for Jesus.'),
                ),
                ListTile(
                  leading: Icon(Icons.brightness_1, size: 8),
                  title: Text(
                      'Multiply – We want you to make disciples that make disciples that go out into the world.'),
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
