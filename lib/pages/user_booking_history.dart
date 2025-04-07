import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/widgets/custom_app_bar.dart'; // Import your custom app bar

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "SpotEase SUST", showBackButton: true),
      body: FutureBuilder<List<Event>>(
        future: _userEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      final event = userEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Spot: ${event.spotName}"),
                              Text(
                                  "Date: ${event.date.day}-${event.date.month}-${event.date.year}"),
                              Text("Session: ${event.session}"),
                              Text("Organization: ${event.organizationName}"),
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
