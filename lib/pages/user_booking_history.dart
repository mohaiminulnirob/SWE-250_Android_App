import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class UserBookingHistoryPage extends StatefulWidget {
  final String uid;

  const UserBookingHistoryPage({super.key, required this.uid});

  @override
  State<UserBookingHistoryPage> createState() => _UserBookingHistoryPageState();
}

class _UserBookingHistoryPageState extends State<UserBookingHistoryPage> {
  late Future<List<Event>> _userEventsFuture;

  @override
  void initState() {
    super.initState();
    _userEventsFuture = _loadUserEvents();
  }

  Future<List<Event>> _loadUserEvents() async {
    await EventRepository().refreshEvents();
    final allEvents = EventRepository().events;
    return allEvents.where((event) => event.uid == widget.uid).toList();
  }

  void _deleteEvent(Event event) {
    // You can add Firestore deletion logic here if needed.
    setState(() {
      EventRepository().events.remove(event);
      _userEventsFuture = _loadUserEvents();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking request deleted.")),
    );
  }

  void _editEvent(Event event) {
    // Navigate to edit page or show a dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit request tapped.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: FutureBuilder<List<Event>>(
        future: _userEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No booking history found.'));
          } else {
            final userEvents = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Your Booking History",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      final event = userEvents[index];
                      final isUpcoming = event.date.isAfter(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(event.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Spot: ${event.spotName}"),
                                    Text(
                                        "Date: ${DateFormat('dd-MM-yyyy').format(event.date)}"),
                                    Text("Session: ${event.session}"),
                                    Text(
                                        "Organization: ${event.organizationName}"),
                                  ],
                                ),
                              ),
                              if (isUpcoming)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _editEvent(event),
                                        icon: const Icon(Icons.edit),
                                        label: const Text(
                                          "Edit Request",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Urbanist'),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        onPressed: () => _deleteEvent(event),
                                        icon: const Icon(Icons.delete),
                                        label: const Text(
                                          "Delete Request",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Urbanist'),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
