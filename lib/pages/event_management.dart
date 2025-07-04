import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/pages/event_detail_page.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/repositories/notifications_repo.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<Event>> _loadEvents() async {
    await EventRepository().refreshEvents();
    return EventRepository().events;
  }

  Future<void> _movePastEvents() async {
    final today = DateTime.now();
    final pastEvents = EventRepository().events.where((event) {
      final eventDate = event.date;
      return (eventDate.year < today.year) ||
          (eventDate.year == today.year && eventDate.month < today.month) ||
          (eventDate.year == today.year &&
              eventDate.month == today.month &&
              eventDate.day < today.day);
    }).toList();

    for (final event in pastEvents) {
      await FirebaseFirestore.instance
          .collection('past_events')
          .doc(event.id)
          .set(event.toMap());

      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .delete();
    }

    setState(() {
      final today = DateTime.now();
      EventRepository().events.removeWhere((event) {
        final eventDate = event.date;
        return (eventDate.year < today.year) ||
            (eventDate.year == today.year && eventDate.month < today.month) ||
            (eventDate.year == today.year &&
                eventDate.month == today.month &&
                eventDate.day < today.day);
      });
      _eventsFuture = _loadEvents();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Past events moved successfully.")),
    );
  }

  void _editEvent(Event event) {
    final titleController = TextEditingController(text: event.title);
    final descriptionController =
        TextEditingController(text: event.description);
    final organizationController =
        TextEditingController(text: event.organizationName);
    final sessionController = TextEditingController(text: event.session);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Edit Event Details",
              style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(
                        fontFamily: 'Urbanist', color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                        fontFamily: 'Urbanist', color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: organizationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    labelStyle: TextStyle(
                        fontFamily: 'Urbanist', color: Colors.white70),
                  ),
                ),
                TextField(
                  controller: sessionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Session',
                    labelStyle: TextStyle(
                        fontFamily: 'Urbanist', color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEvent = Event(
                  id: event.id,
                  uid: event.uid,
                  spotName: event.spotName,
                  title: titleController.text,
                  organizationName: organizationController.text,
                  date: event.date,
                  session: sessionController.text,
                  description: descriptionController.text,
                  applicationImageUrl: event.applicationImageUrl,
                );

                await EventRepository().updateEvent(updatedEvent);
                Navigator.of(context).pop();

                setState(() {
                  _eventsFuture = _loadEvents();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event updated successfully.")),
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Event Management", showBackButton: true),
      body: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _movePastEvents,
                icon: const Icon(Icons.archive, color: Colors.white),
                label: const Text(
                  "Remove Past Events",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final notificationsRepo = NotificationsRepository();
                  final events = await _eventsFuture;

                  await notificationsRepo.deletePastNotifications();
                  await notificationsRepo.addTodayEvents(events);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Event notifications updated successfully.",
                        style: TextStyle(fontFamily: 'Urbanist'),
                      ),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.notifications_active, color: Colors.white),
                label: const Text(
                  "Update Event Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No current events available.'));
                  } else {
                    final events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];

                        return Card(
                          color: Colors.black.withOpacity(0.3),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Urbanist',
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Spot: ${event.spotName}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text(
                                          "Date: ${DateFormat('dd-MM-yyyy').format(event.date)}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text("Session: ${event.session}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      Text(
                                          "Organization: ${event.organizationName}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EventDetailPage(
                                                  event: event)),
                                        );
                                      },
                                      icon: const Icon(Icons.visibility),
                                      label: const Text("View Details",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist')),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _editEvent(event),
                                      icon: const Icon(Icons.edit),
                                      label: const Text("Edit Details",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist')),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
