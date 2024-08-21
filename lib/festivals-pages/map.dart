import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  String? _mapImageUrl;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity()..scale(1.0); // Set initial scale
    _fetchMapImageUrl();
  }

  Future<void> _fetchMapImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedfestId = prefs.getInt('selectedFestivalId');

    final response = await Supabase.instance.client
        .from('festivals')
        .select('map_image')
        .eq('id', selectedfestId!) // Replace with your actual condition
        .single();

    if (response != null) {
      setState(() {
        _mapImageUrl = response['map_image'];
        print('Map image URL: ${response}');
      });
    } else {
      // Handle error
      print('Error fetching map image URL: ${response}');
    }
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
                  child: _mapImageUrl == null
                      ? Center(child: CircularProgressIndicator())
                      : CachedNetworkImage(
                          imageUrl: _mapImageUrl!,
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.red),
                              ),
                            ],
                          ),
                          fadeInDuration: Duration(
                              milliseconds: 500), // Add fade transition
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
