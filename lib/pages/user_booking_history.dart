import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:project/repositories/event_repository.dart';
import 'package:project/repositories/event_requests_repo.dart';
import 'package:project/repositories/past_events_repo.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class UserBookingHistoryPage extends StatefulWidget {
  final String uid;

  const UserBookingHistoryPage({super.key, required this.uid});

  @override
  State<UserBookingHistoryPage> createState() => _UserBookingHistoryPageState();
}

class _UserBookingHistoryPageState extends State<UserBookingHistoryPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Event>> _userEventsFuture;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _userEventsFuture = _loadUserEvents();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Event>> _loadUserEvents() async {
    await EventRepository().refreshEvents();
    await EventRequestsRepository().refreshEventRequests();
    await PastEventsRepository().refreshPastEvents();

    final eventRequests = EventRequestsRepository().eventRequests;
    final events = EventRepository().events;
    final pastEvents = PastEventsRepository().pastEvents;

    final userEventRequests = eventRequests.where((e) => e.uid == widget.uid);
    final userApprovedEvents = events.where((e) => e.uid == widget.uid);
    final userPastEvents = pastEvents.where((e) => e.uid == widget.uid);

    return [
      ...userEventRequests,
      ...userApprovedEvents,
      ...userPastEvents,
    ];
  }

  void _deleteEvent(Event event) async {
    if (event.id != null) {
      await EventRequestsRepository().deleteEventRequest(event.id!);
      setState(() {
        _userEventsFuture = _loadUserEvents();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking request deleted.")),
      );
    }
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
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Edit Booking Request",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Urbanist')),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: organizationController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sessionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Session',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white)),
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

                        await EventRequestsRepository()
                            .updateEventRequest(updatedEvent);

                        Navigator.of(context).pop();

                        setState(() {
                          _userEventsFuture = _loadUserEvents();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Booking updated successfully.")),
                        );
                      },
                      child: const Text("Update"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        appBar: CustomAppBar(title: "SpotEase SUST", showBackButton: true),
        body: FutureBuilder<List<Event>>(
          future: _userEventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No booking history found.',
                  style: TextStyle(color: Colors.white),
                ),
              );
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
                          color: Colors.white,
                          fontFamily: 'Urbanist'),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userEvents.length,
                      itemBuilder: (context, index) {
                        final event = userEvents[index];
                        final isUpcoming = event.date.isAfter(DateTime.now());
                        final isEditable = EventRequestsRepository()
                            .eventRequests
                            .any((e) => e.id == event.id);
                        return Card(
                          color: Colors.grey[900],
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Urbanist')),
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
                                if (isUpcoming && isEditable)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _editEvent(event),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                          ),
                                          child: const Text("Edit",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Colors.white)),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () => _deleteEvent(event),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                          ),
                                          child: const Text("Delete",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Colors.white)),
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
      ),
    );
  }
}
