import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconButtonCard extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Widget page;
  final double? width;

  IconButtonCard({
    Key? key,
    this.icon, // make icon optional
    required this.text,
    required this.page,
    this.width,
  })  : assert(icon is IconData || icon is FaIcon || icon == null), // add null check
        super(key: key);

  Widget iconWidget() {
    if (icon == null) {
      return Text(text, style: TextStyle(color: Colors.black, fontSize: 21.0)); // return Text widget if icon is null
    } else if (icon is IconData) {
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
      if (icon != null) // add this if statement to show text only if icon is not null (or not a IconData)
      Text(text, style: TextStyle(color: Colors.white, fontSize: 21.0)),
    ],
  );
}
}