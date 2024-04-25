import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lifelight_app/components/basepage.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate'),
      ),
      body: Stack(
        children: [
          InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri('https://lifelight.breezechms.com/give/online')),
        initialSettings: InAppWebViewSettings(
          userAgent:
              'Mozilla/5.0 (Linux; Android 10; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36',
          cacheEnabled: true,
        ),
            onWebViewCreated: (InAppWebViewController controller) {},
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
            onProgressChanged: (InAppWebViewController controller, int progress) {},
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
        ],
    ));
  }
}
