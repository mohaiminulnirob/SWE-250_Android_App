import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:project/repositories/event_requests_repo.dart';
import 'package:project/pages/event_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/widgets/custom_app_bar.dart';
import 'package:project/services/notification_service.dart';

class BookingApprovalPage extends StatefulWidget {
  const BookingApprovalPage({Key? key}) : super(key: key);

  @override
  State<BookingApprovalPage> createState() => _BookingApprovalPageState();
}

class _BookingApprovalPageState extends State<BookingApprovalPage> {
  final EventRequestsRepository _repository = EventRequestsRepository();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventRequests();
  }

  Future<void> _loadEventRequests() async {
    await _repository.refreshEventRequests();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendStatusEmail(Event event, String status) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final String toEmail = data['email'] ?? '';
        final String username = data['username'] ?? 'User';

        await _notificationService.sendBookingStatusEmail(
          toEmail: toEmail,
          username: username,
          spotName: event.title,
          date: event.date.toLocal().toString().split(' ')[0],
          session: event.session,
          status: status,
        );
      } else {
        debugPrint('User document not found for UID: ${event.uid}');
      }
    } catch (e) {
      debugPrint('Error sending status email: $e');
    }
  }

  Future<void> _approveEvent(Event event) async {
    try {
      await FirebaseFirestore.instance.collection('events').add(event.toMap());
      if (event.id != null) {
        await FirebaseFirestore.instance
            .collection('event_requests')
            .doc(event.id)
            .delete();
      }
      await _sendStatusEmail(event, 'approved');
      await _loadEventRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event approved and user notified."),
          backgroundColor: Color.fromARGB(255, 0, 12, 6),
        ),
      );
    } catch (e) {
      debugPrint("Error approving event: $e");
    }
  }

  Future<void> _rejectEvent(Event event) async {
    try {
      if (event.id != null) {
        await FirebaseFirestore.instance
            .collection('event_requests')
            .doc(event.id)
            .delete();
      }
      await _sendStatusEmail(event, 'rejected');
      await _loadEventRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event rejected and user notified."),
          backgroundColor: Color.fromARGB(255, 21, 0, 0),
        ),
      );
    } catch (e) {
      debugPrint("Error rejecting event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Event> eventRequests = _repository.eventRequests;

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Booking Requests",
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23232F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : eventRequests.isEmpty
                ? const Center(
                    child: Text(
                      "No booking requests found.",
                      style: TextStyle(
                          fontFamily: 'Urbanist', color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: eventRequests.length,
                    itemBuilder: (context, index) {
                      final event = eventRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 4,
                        color: Colors.white.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      "Organization: ${event.organizationName}",
                                      style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      "Date: ${event.date.toLocal().toString().split(' ')[0]}",
                                      style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          color: Colors.white70),
                                    ),
                                    Text(
                                      "Session: ${event.session}",
                                      style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white54),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailPage(event: event),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _approveEvent(event),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.greenAccent[400],
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text(
                                      "Approve",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () => _rejectEvent(event),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      "Reject",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
