import 'package:project/models/event_model.dart';

class EventRepository {
  // Singleton instance
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;

  // Private constructor
  EventRepository._internal() {
    _initializeEvents();
  }

  // List to store all events
  final List<Event> _events = [];

  // Getter to access the events
  List<Event> get events => List.unmodifiable(_events);

  // Method to add a new event
  void addEvent(Event event) {
    _events.add(event);
  }

  // Initialize with some dummy events
  void _initializeEvents() {
    _events.addAll([
      Event(
        title: "Cultural Fest 2025",
        organizationName: "Cultural Club",
        date: DateTime(2025, 3, 10),
        session: "Evening",
        description: "A grand celebration of music, dance, and art.",
      ),
      Event(
        title: "Tech Carnival",
        organizationName: "CSE Society",
        date: DateTime(2025, 4, 15),
        session: "Morning",
        description: "Showcasing the latest in technology and innovation.",
      ),
      Event(
        title: "Sports Championship",
        organizationName: "Sports Club",
        date: DateTime(2025, 5, 20),
        session: "Afternoon",
        description: "Annual sports championship featuring multiple events.",
      ),
      Event(
        title: "Coding Contest",
        organizationName: "Programming Hub",
        date: DateTime(2025, 6, 5),
        session: "Morning",
        description: "A competitive coding contest with exciting prizes.",
      ),
      Event(
        title: "Music Night",
        organizationName: "Music Club",
        date: DateTime(2025, 7, 25),
        session: "Evening",
        description: "A night of musical performances and entertainment.",
      ),
    ]);
  }
}
