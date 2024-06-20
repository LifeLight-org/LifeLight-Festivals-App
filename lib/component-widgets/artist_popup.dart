import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ArtistPopup extends StatelessWidget {
  final String artistName;
  final String stage;
  final String playtime;
  final String imageUrl;
  final String aboutText;
  final String? link;

  const ArtistPopup({
    Key? key,
    required this.artistName,
    required this.stage,
    required this.playtime,
    required this.imageUrl,
    required this.aboutText,
    this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Stack(
          children: [
            Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50), // adjust the height as needed
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  artistName,
                                  style: TextStyle(fontSize: 20),
                                  minFontSize: 14,
                                  stepGranularity: 1,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16.0,
                                      color: Colors.grey,
                                    ),
                                    AutoSizeText(
                                      stage,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey,
                                      ),
                                      minFontSize: 16,
                                      stepGranularity: 1,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16.0,
                                      color: Colors.grey,
                                    ),
                                    AutoSizeText(
                                      playtime,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey,
                                      ),
                                      minFontSize: 16,
                                      stepGranularity: 1,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [linkIcon()],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          child: Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width *
                                0.3, // 40% of screen width
                            height: MediaQuery.of(context).size.width *
                                0.3, // Same as width to maintain aspect ratio
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: AutoSizeText(
                        'About $artistName',
                        style: TextStyle(fontSize: 20),
                        minFontSize: 14,
                        stepGranularity: 1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Divider(thickness: 1.0),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AutoSizeText(
                          aboutText,
                          style: TextStyle(fontSize: 25),
                          minFontSize: 20,
                          stepGranularity: 10,
                          maxLines: 100,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget linkIcon() {
    print(link);
    final ChromeSafariBrowser browser = ChromeSafariBrowser();
    if (link != null && link!.isNotEmpty) {
      return InkWell(
        onTap: () {
          browser.open(
            url: WebUri(link!), // Corrected to Uri.parse for the URL
            options: ChromeSafariBrowserClassOptions(
              android: AndroidChromeCustomTabsOptions(
                  addDefaultShareMenuItem: false),
              ios: IOSSafariOptions(barCollapsingEnabled: true),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            Icons.public,
            size: 20.0, // Increased size for easier clicking
            color: Colors.grey,
          ),
        ),
      );
    } else {
      return SizedBox
          .shrink(); // Return an empty widget if spotify is null or empty
    }
  }
}
