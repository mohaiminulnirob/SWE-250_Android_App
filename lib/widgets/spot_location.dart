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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            title: const Text(
              "Location",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              _isOpen ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
          ),
        ),
        if (_isOpen)
          SizedBox(
            height: 300,
            width: 600,
            child: embedUrl == null
                ? const Center(
                    child: Text(
                      "Map not available for this spot.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : WebViewWidget(controller: _controller),
          ),
      ],
    );
  }
}
