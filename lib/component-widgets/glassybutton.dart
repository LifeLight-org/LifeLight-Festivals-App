import 'package:flutter/material.dart';

class GlassyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final EdgeInsets padding;

  const GlassyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 0.5,
    this.padding = const EdgeInsets.all(10.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * width,
      decoration: BoxDecoration(
        color: const Color(0xFFFDD008),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: padding,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
