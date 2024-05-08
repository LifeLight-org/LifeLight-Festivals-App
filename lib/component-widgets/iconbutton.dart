import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconButtonCard extends StatelessWidget {
  final dynamic icon; // Change this from Widget to dynamic
  final String text;
  final Widget page;

  const IconButtonCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.page,
  }) : super(key: key);

  Widget iconWidget() {
    // Helper function to return the correct widget
    if (icon is IconData) {
      return Icon(icon, size: 50.0); // Increase the size here
    } else if (icon is FaIcon) {
      return FaIcon(icon.icon, size: 40.0); // Increase the size here
    } else {
      throw ArgumentError('icon must be of type IconData or FaIcon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 70.0,
          decoration: BoxDecoration(
            color: Color(0xffFFD000),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        Container(
          height: 70.0,
          width: 70.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: iconWidget(), // Use the helper function here
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: 150.0, // Set a fixed width for the container
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23.0),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
