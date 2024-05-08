import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconButtonCard extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Widget page;

  IconButtonCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.page,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: 80.0,
                width: 80.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xffFFD000),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                },
                child: iconWidget(),
              ),
            ],
          ),
        ),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 21.0)),
      ],
    );
  }
}
