import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lifelight_app/components/basepage.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final TransformationController _controller = TransformationController();
  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity()..scale(1.0); // Set initial scale
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale:
              4.0, // Increase the maxScale to allow the user to zoom in more
          transformationController:
              _controller, // Set the transformation controller
          child: Stack(
            children: [
              Image.asset(
                'assets/images/map.png',
                fit: BoxFit
                    .fitHeight, // Scale the image to fit the height of the box
              ),
            ],
          ),
        ),
      ),
    );
  }
}
