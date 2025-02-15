import 'package:flutter/material.dart';

class SpotUpcomingEvents extends StatefulWidget {
  const SpotUpcomingEvents({super.key});

  @override
  State<SpotUpcomingEvents> createState() => _SpotUpcomingEventsState();
}

class _SpotUpcomingEventsState extends State<SpotUpcomingEvents> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Upcoming Events",
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
            child: Text("Upcoming events will be listed here."),
          ),
      ],
    );
  }
}
