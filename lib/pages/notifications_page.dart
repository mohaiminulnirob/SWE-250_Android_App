import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/event_model.dart';
import 'package:project/repositories/notifications_repo.dart';
import 'package:project/widgets/custom_app_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Event>> _notificationsFuture;
  final NotificationsRepository _notificationsRepo = NotificationsRepository();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationsRepo.getTodaysNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      appBar: const CustomAppBar(
        title: 'SpotEase SUST',
        showBackButton: true,
      ),
      body: FutureBuilder<List<Event>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Urbanist'),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications for today.',
                style: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
              ),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Event: ${event.title}",
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.organizationName} | ${event.spotName} | ${event.session}',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Date: ${DateFormat('dd-MM-yyyy').format(event.date)}",
                      style: const TextStyle(
                          fontFamily: 'Urbanist', color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
