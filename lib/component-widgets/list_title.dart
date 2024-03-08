import 'package:flutter/material.dart';

class SideBarListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;

  const SideBarListTile({super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}