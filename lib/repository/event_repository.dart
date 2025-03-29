import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';

class EventRepository {
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;

  EventRepository._internal() {
    _fetchEvents(); // Fetch events when the repository is initialized
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Event> _events = [];

  List<Event> get events =>
      List.unmodifiable(_events); // Prevent external modification

  Future<void> addEvent(Event event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
      _events.add(event); // Add to local list immediately
    } catch (e) {
      print("Error adding event: $e");
    }
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      _events.clear(); // Clear local list before updating
      _events.addAll(snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>);
      }));
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> refreshEvents() async {
    await _fetchEvents();
  }
}
