import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:intl/intl.dart';

class EventList extends StatefulWidget {
  final List<Event> events;

  const EventList({super.key, required this.events});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final ScrollController _scrollController = ScrollController();
  late List<Event> _eventList;

  @override
  void initState() {
    super.initState();
    _eventList = List.from(widget.events);
  }

  String _getRemainingTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return "${difference.inDays}d left";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h left";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m left";
    } else {
      return "Started";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _eventList.length,
        itemBuilder: (context, index) {
          final event = _eventList[index];
          final remainingTime = _getRemainingTime(event.date);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 15, 127, 152),
              ),
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.purpleAccent),
                title: Text(
                  event.title,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  "${event.organizationName} • ${event.session}",
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  remainingTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Colors.white,
                  ),
                ),
                onTap: () => _showEventDetails(event),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEventDetails(Event event) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(event.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 44, 49, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        content: Text(
          "📅 Date: $formattedDate\n"
          "🏢 Organization: ${event.organizationName}\n"
          "📘 Session: ${event.session}\n\n"
          "📝 Description:\n${event.description}",
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
