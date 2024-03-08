import 'package:flutter/material.dart';
import 'sidebar.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final String title;

  const BasePage({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      drawer: const Sidebar(), // Your sidebar navigation widget
      body: child,
    );
  }
}