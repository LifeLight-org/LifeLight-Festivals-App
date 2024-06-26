import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Import for opening a web browser
import 'package:auto_size_text/auto_size_text.dart';

// Step 1: Update the enum to include a web browser option
enum NavigationType { page, popupToWebBrowser, webBrowser }

class IconButtonCard extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Widget? page;
  final double? width;
  final NavigationType navigationType;
  final String? url;
  final String? dialogTitle;
  final String? dialogMessage;

  IconButtonCard({
    Key? key,
    this.icon, // make icon optional
    required this.text,
    this.page, // Remove `required` keyword
    this.width,
    this.navigationType =
        NavigationType.page, // Default to navigating to a page
    this.url = "https://lifelight.org/", // Default URL value
    this.dialogTitle,
    this.dialogMessage,
  })  : assert(icon is IconData ||
            icon is FaIcon ||
            icon == null), // add null check
        assert(!(navigationType == NavigationType.webBrowser && url == null),
            'URL must not be null when navigation type is webBrowser.'),
        super(key: key);

  Widget iconWidget() {
    if (icon == null) {
      return Text(text,
          style: TextStyle(
              color: Colors.black,
              fontSize: 21.0)); // return Text widget if icon is null
    } else if (icon is IconData) {
      return Icon(icon, size: 50.0, color: Colors.black);
    } else {
      return FaIcon(icon.icon, size: 40.0, color: Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    double actualWidth = width ??
        MediaQuery.of(context).size.width *
            0.2; // Use provided width or 20% of screen width

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            if (navigationType == NavigationType.page) {
              if (page == null)
                throw Exception(
                    'Page navigation selected but no page provided.');
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => page!));
            } else if (navigationType == NavigationType.popupToWebBrowser) {
              if (url == null) throw Exception('No URL provided.');
              print(dialogTitle);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(dialogTitle!),
                    content: Text(dialogMessage!),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Next'),
                        onPressed: () {
                          final ChromeSafariBrowser browser =
                              ChromeSafariBrowser();
                          browser.open(
                              url: WebUri(url!), // Use the `url` parameter here
                              options: ChromeSafariBrowserClassOptions(
                                  android: AndroidChromeCustomTabsOptions(
                                      addDefaultShareMenuItem: false),
                                  ios: IOSSafariOptions(
                                      barCollapsingEnabled: true)));
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            } else if (navigationType == NavigationType.webBrowser) {
              if (url == null)
                throw Exception(
                    'Web browser navigation selected but no URL provided.');
              final ChromeSafariBrowser browser = ChromeSafariBrowser();
              await browser.open(
                  url: WebUri(url!), // Use the `url` parameter here
                  options: ChromeSafariBrowserClassOptions(
                      android: AndroidChromeCustomTabsOptions(
                          addDefaultShareMenuItem: false),
                      ios: IOSSafariOptions(barCollapsingEnabled: true)));
              print('Opened web browser ' + url!);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.1, // 10% of screen height
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
        if (icon != null) // Show text only if icon is not null
          AutoSizeText(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18.0),
            minFontSize: 10, // Minimum text size
            stepGranularity: 1, // The step size for scaling the font
            maxLines: 1, // Ensures the text does not wrap
            overflow: TextOverflow
                .ellipsis, // Adds an ellipsis if the text still overflows
          ),
      ],
    );
  }
}
