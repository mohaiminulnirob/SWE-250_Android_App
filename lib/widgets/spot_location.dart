import 'package:flutter/material.dart';

class SpotLocation extends StatefulWidget {
  const SpotLocation({super.key});

  @override
  State<SpotLocation> createState() => _SpotLocationState();
}

class _SpotLocationState extends State<SpotLocation> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Location",
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
        ),
        if (_isOpen)
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Location details will be added here."),
          ),
      ],
    );
  }
}
