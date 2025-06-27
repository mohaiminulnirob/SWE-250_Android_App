import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';
import 'package:intl/intl.dart';

class SpotUpcomingEvents extends StatefulWidget {
  final List<Event> events;

  const SpotUpcomingEvents({super.key, required this.events});

  @override
  State<SpotUpcomingEvents> createState() => _SpotUpcomingEventsState();
}

class _SpotUpcomingEventsState extends State<SpotUpcomingEvents> {
  bool _isOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _showUpArrow = false;
  bool _showDownArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
  }

  void _updateScrollArrows() {
    setState(() {
      _showUpArrow = _scrollController.offset > 0;
      _showDownArrow =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
    } else if (difference.inDays <= -1) {
      return "Ended";
    } else {
      return "Started";
    }
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListTile(
            title: const Text(
              "Upcoming Events",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              _isOpen ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
          ),
        ),
        if (_isOpen)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 300,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.events.length,
                  itemBuilder: (context, index) {
                    final event = widget.events[index];
                    final remainingTime = _getRemainingTime(event.date);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color.fromARGB(255, 15, 127, 152),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event,
                              color: Colors.purpleAccent),
                          title: Text(
                            event.title,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "${event.spotName} • ${event.organizationName}",
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
              ),
              if (_showUpArrow)
                Positioned(
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward,
                        color: Color.fromARGB(231, 255, 255, 255)),
                    onPressed: _scrollUp,
                  ),
                ),
              if (_showDownArrow)
                Positioned(
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_downward,
                        color: Color.fromARGB(231, 255, 255, 255)),
                    onPressed: _scrollDown,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
