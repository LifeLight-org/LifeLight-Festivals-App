import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  String _selectedfestmap = 'HA';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity()..scale(1.0); // Set initial scale
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedfestmap = _prefs.getString('selectedFestivalDBPrefix') ?? 'HA';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAP'),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Calculate the scale
              double scale = constraints.maxWidth /
                  1000; // Replace 1000 with the actual width of your image

              // Calculate the aspect ratio
              double aspectRatio = constraints.maxWidth / constraints.maxHeight;

              return InteractiveViewer(
                minScale: scale,
                maxScale: 4.0,
                transformationController: _controller,
                child: AspectRatio(
                  aspectRatio: aspectRatio, // Use the calculated aspect ratio
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://bjywcdylkgnaxsbgtrpr.supabase.co/storage/v1/object/public/maps/${_selectedfestmap}-Map.png',
                    fit: BoxFit.scaleDown,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 50, color: Colors.red),
                        SizedBox(height: 8),
                        Text(
                          "Can't Display Map",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                    fadeInDuration:
                        Duration(milliseconds: 500), // Add fade transition
                    fadeOutDuration: Duration(milliseconds: 500),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
