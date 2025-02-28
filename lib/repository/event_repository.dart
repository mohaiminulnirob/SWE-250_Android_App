import 'package:project/models/event_model.dart';

class EventRepository {
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;

  EventRepository._internal() {
    _initializeEvents();
  }

  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events.add(event);
  }

  void _initializeEvents() {
    _events.addAll([
      Event(
        spotName: "Auditorium",
        title: "Cultural Fest 2025",
        organizationName: "Cultural Club",
        date: DateTime(2025, 3, 10),
        session: "Evening",
        description: "A grand celebration of music, dance, and art.",
      ),
      Event(
        spotName: "Mini Auditorium",
        title: "Tech Carnival",
        organizationName: "CSE Society",
        date: DateTime(2025, 4, 15),
        session: "Morning",
        description: "Showcasing the latest in technology and innovation.",
      ),
      Event(
        spotName: "Central Field",
        title: "Sports Championship",
        organizationName: "Sports Club",
        date: DateTime(2025, 5, 20),
        session: "Afternoon",
        description: "Annual sports championship featuring multiple events.",
      ),
      Event(
        spotName: "Mini Auditorium",
        title: "Coding Contest",
        organizationName: "Programming Hub",
        date: DateTime(2025, 6, 5),
        session: "Morning",
        description: "A competitive coding contest with exciting prizes.",
      ),
      Event(
        spotName: "Handball Ground",
        title: "Music Night",
        organizationName: "Music Club",
        date: DateTime(2025, 7, 25),
        session: "Evening",
        description: "A night of musical performances and entertainment.",
      ),
    ]);
  }
}
