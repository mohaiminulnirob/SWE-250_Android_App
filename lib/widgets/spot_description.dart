import 'package:flutter/material.dart';

class SpotDescription extends StatefulWidget {
  final String title;
  final Widget content;

  const SpotDescription(
      {super.key, required this.title, required this.content});

  @override
  State<SpotDescription> createState() => _SpotDescriptionState();
}

class _SpotDescriptionState extends State<SpotDescription> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
        ),
        if (_isOpen) widget.content,
      ],
    );
  }
}
