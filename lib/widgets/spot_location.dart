import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:project/data/spot_embed_urls.dart';

class SpotLocation extends StatefulWidget {
  final String spotName;
  const SpotLocation({super.key, required this.spotName});

  @override
  State<SpotLocation> createState() => _SpotLocationState();
}

class _SpotLocationState extends State<SpotLocation> {
  bool _isOpen = false;
  late final WebViewController _controller;

  @override
  @override
  void initState() {
    super.initState();
    final embedUrl = spotEmbedUrls[widget.spotName];

    if (embedUrl != null) {
      final html = '''
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body, html {
              margin: 0;
              padding: 0;
              height: 100%;
            }
            iframe {
              width: 100%;
              height: 100%;
              border: none;
            }
          </style>
        </head>
        <body>
          <iframe src="$embedUrl" allowfullscreen="" loading="lazy"></iframe>
        </body>
      </html>
    ''';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(html);
    }
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = spotEmbedUrls[widget.spotName];

    return Column(
      children: [
        ListTile(
          title: const Text(
            "Location",
            style:
                TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
          ),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
        ),
        if (_isOpen)
          SizedBox(
            height: 300,
            width: 600,
            child: embedUrl == null
                ? const Center(child: Text("Map not available for this spot."))
                : WebViewWidget(controller: _controller),
          ),
      ],
    );
  }
}
