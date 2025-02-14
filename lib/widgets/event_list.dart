import 'package:flutter/material.dart';

class EventList extends StatefulWidget {
  final List<String> eventNames;

  const EventList({super.key, required this.eventNames});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.eventNames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ListTile(
                    leading:
                        const Icon(Icons.event, color: Colors.purpleAccent),
                    title: Text(widget.eventNames[index]),
                    subtitle: const Text("Click to view details"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
