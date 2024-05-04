import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  bool _showLegends = false;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity()..scale(1.0); // Set initial scale

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_showLegends ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showLegends = !_showLegends;
                _showLegends
                    ? _slideController.forward()
                    : _slideController.reverse();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              transformationController: _controller,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/HA-map.png',
                    fit: BoxFit.fitHeight,
                  ),
                  ..._legendAreas.map((legend) {
                    return Positioned(
                      left: legend['left'], // X position of the clickable area
                      top: legend['top'], // Y position of the clickable area
                      child: Transform.rotate(
                        angle: legend['angle'] ??
                            0, // Rotate by the specified angle, or 0 if not specified
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(legend['label']),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width:
                                legend['width'], // Width of the clickable area
                            height: legend[
                                'height'], // Height of the clickable area
                            color: Colors.red
                                .withOpacity(0.5), // Make it semi-transparent
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(_slideController),
            child: Visibility(
              visible: _showLegends,
              child: Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _legends,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _legendAreas = [
    {
      'label': 'Kids Zone / Inflatables',
      'left': 85.0,
      'top': 447.0,
      'width': 190.0,
      'height': 110.0,
      'angle': 0.14,
    },
    {
      'label': 'Youth and Kids Area',
      'left': 176.0,
      'top': 587.0,
      'width': 125.0,
      'height': 85.0,
      'angle': 0.16,
    },
    // Add more maps for other legend entries
  ];

  List<Widget> _legends = [
    Row(
      children: const [
        Text(
          'I',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Information'),
      ],
    ),
    Row(
      children: const [
        Text(
          'F',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Food Vendors'),
      ],
    ),
    Row(
      children: const [
        Text(
          'V',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Merch Vendors'),
      ],
    ),
    Row(
      children: const [
        Text(
          'M',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Artist Merchandise'),
      ],
    ),
    Row(
      children: const [
        Text(
          'H',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Handicap Seating'),
      ],
    ),
    Row(
      children: const [
        Text(
          'A',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Autographs'),
      ],
    ),
    Row(
      children: const [
        Text(
          'K',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Kid Zone / Inflatables'),
      ],
    ),
    Row(
      children: const [
        Text(
          'C',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Children\'s Ministry Tent'),
      ],
    ),
    Row(
      children: const [
        Text(
          'Y',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Youth & Kids Area'),
      ],
    ),
    Row(
      children: const [
        Text(
          'P',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Prayer Tent'),
      ],
    ),
    Row(
      children: const [
        Text(
          'B',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('Exhibitor Booths'),
      ],
    ),
    Row(
      children: const [
        Text(
          'L',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 8.0),
        Text('LifeLight Hills Alive'),
      ],
    ),
    Row(children: const [
      Text(
        'O',
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      SizedBox(width: 8.0),
      Text('Adams Thermal Foundation'),
    ])
  ];
}
