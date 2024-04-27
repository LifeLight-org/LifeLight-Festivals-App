import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources'),
      ),
      body: Center(
        child: Text(
          'This is the resources page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}