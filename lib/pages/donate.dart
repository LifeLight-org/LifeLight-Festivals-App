import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lifelight_app/components/basepage.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Donate',
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('https://lifelight.breezechms.com/give/online')),
        initialSettings: InAppWebViewSettings(
          userAgent: 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36',
        ),
        onWebViewCreated: (InAppWebViewController controller) {},
        onLoadStart: (InAppWebViewController controller, Uri? url) {},
        onLoadStop: (InAppWebViewController controller, Uri? url) {},
        onProgressChanged: (InAppWebViewController controller, int progress) {},
      ),
    );
  }
}