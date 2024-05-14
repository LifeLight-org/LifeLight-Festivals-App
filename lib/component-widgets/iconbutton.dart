import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconButtonCard extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Widget page;
  final double? width;

  IconButtonCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.page,
    this.width,
  })  : assert(icon is IconData || icon is FaIcon),
        super(key: key);

  Widget iconWidget() {
    if (icon is IconData) {
      return Icon(icon, size: 50.0, color: Colors.black);
    } else {
      return FaIcon(icon.icon, size: 40.0, color: Colors.black);
    }
  }

@override
Widget build(BuildContext context) {
  double actualWidth = width ?? MediaQuery.of(context).size.width * 0.2; // Use provided width or 20% of screen width

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1, // 10% of screen height
              width: actualWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xffFFD000),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            iconWidget(),
          ],
        ),
      ),
      Text(text, style: TextStyle(color: Colors.white, fontSize: 21.0)),
    ],
  );
}
}