import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  bool isLoading = true;
  String? festival;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  void loadFestival() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      festival = sharedPreferences.getString('selectedFestival');
      debugPrint(
          'Festival: ${sharedPreferences.getString('selectedFestival')}');
      if (webViewController != null) {
        webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(getDonateUrl())));
      }
    });
  }

  String getDonateUrl() {
    switch (festival) {
      case 'Hills Alive':
        return 'https://lifelight.breezechms.com/give/online/?fund_id=1822623';
      case 'LifeLight Festival':
        return 'https://lifelight.breezechms.com/give/online/?fund_id=1827270';
      default:
        return 'https://lifelight.breezechms.com/give/online';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(getDonateUrl())),
            initialSettings: InAppWebViewSettings(
              userAgent:
                  'Mozilla/5.0 (Linux; Android 10; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36',
              cacheEnabled: true,
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
              loadFestival();
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              setState(() {
                isLoading = false;
              });
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {},
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}