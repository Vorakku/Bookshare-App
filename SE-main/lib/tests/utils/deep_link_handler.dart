import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class DeepLinkHandler extends StatefulWidget {
  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } on Exception {
      // Handle exception
    }

    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleIncomingLink(link);
      }
    }, onError: (err) {
      // Handle error
    });
  }

  void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    if (uri.path == '/details') {
      Navigator.pushNamed(context, '/detailsScreen');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Deep Linking Example')),
    );
  }
}
