import 'package:flutter/material.dart';
import 'package:project/models/event_model.dart';

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

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Text(
          "Organization: ${event.organizationName}\n"
          "Date: ${event.date.day}-${event.date.month}-${event.date.year}\n"
          "Session: ${event.session}\n\n"
          "Description: ${event.description}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("Upcoming Events",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
          trailing: Icon(_isOpen ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event,
                              color: Colors.purpleAccent),
                          title: Text(event.title),
                          subtitle: Text(
                              "${event.organizationName} • ${event.session}"),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
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
                        color: Color.fromARGB(231, 9, 9, 9)),
                    onPressed: _scrollUp,
                  ),
                ),
              if (_showDownArrow)
                Positioned(
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_downward,
                        color: Color.fromARGB(231, 9, 9, 9)),
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
