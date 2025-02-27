import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/widgets/event_list.dart';

class EventListPage extends StatelessWidget {
  final List<Event> events;

  const EventListPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "All Events", showBackButton: true),
      body: events.isEmpty
          ? const Center(child: Text("No events available."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: EventList(events: events),
            ),
    );
  }
}
