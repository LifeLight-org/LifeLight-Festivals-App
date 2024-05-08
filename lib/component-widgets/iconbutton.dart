import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconButtonCard extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Widget page;

  const IconButtonCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.page,
  }) : super(key: key);

  Widget iconWidget() {
    if (icon is IconData) {
      return Icon(icon, size: 50.0, color: Colors.black);
    } else if (icon is FaIcon) {
      return FaIcon(icon.icon, size: 40.0, color: Colors.black);
    } else {
      throw ArgumentError('icon must be of type IconData or FaIcon');
    }
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(1.0),
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 80.0, // Increased size
          width: 80.0, // Increased size
          decoration: BoxDecoration(
            color: Color(0xffFFD000),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: iconWidget(),
        ),
        Positioned(
          
          bottom: -3,
          child: Container(
            padding: EdgeInsets.only(top: 10.0), // Add padding here
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23.0),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ),
  );
}
}
