import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/event_list.dart';

class PastEventsPage extends StatefulWidget {
  const PastEventsPage({super.key});

  @override
  State<PastEventsPage> createState() => _PastEventsPageState();
}

class _PastEventsPageState extends State<PastEventsPage> {
  final List<String> _spots = [
    'Auditorium',
    'Central Field',
    'Basketball Ground',
    'Handball Ground',
    'Mini Auditorium',
  ];

  Map<String, List<Event>> _spotwiseEvents = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPastEvents();
  }

  Future<void> _loadPastEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('past_events')
          .orderBy('date', descending: true)
          .get();

      Map<String, List<Event>> grouped = {
        for (var spot in _spots) spot: [],
      };

      for (var doc in snapshot.docs) {
        final event = Event.fromMap(doc.data());
        if (grouped.containsKey(event.spotName)) {
          grouped[event.spotName]!.add(event);
        }
      }

      setState(() {
        _spotwiseEvents = grouped;
        _loading = false;
      });
    } catch (e) {
      print("Error loading past events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      appBar: const CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildExpandableSpotwiseEvents(),
    );
  }

  Widget _buildExpandableSpotwiseEvents() {
    return SingleChildScrollView(
      child: Column(
        children: _spots.map((spot) {
          final events = _spotwiseEvents[spot]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ExpansionTile(
                title: Text(
                  spot,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: events.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No past events found.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : EventList(events: events),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
