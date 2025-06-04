import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';

class EventRepository {
  static final EventRepository _instance = EventRepository._internal();
  factory EventRepository() => _instance;

  EventRepository._internal() {
    _fetchEvents();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  Future<void> addEvent(Event event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toMap());
      final newEvent = Event(
        id: docRef.id,
        uid: event.uid,
        spotName: event.spotName,
        title: event.title,
        organizationName: event.organizationName,
        date: event.date,
        session: event.session,
        description: event.description,
        applicationImageUrl: event.applicationImageUrl,
      );
      _events.add(newEvent);
    } catch (e) {
      print("Error adding event: $e");
    }
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) {
      print("Cannot update event: missing document ID.");
      return;
    }

    try {
      await _firestore.collection('events').doc(event.id).update(event.toMap());
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
      }
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      _events.clear();
      _events.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data, id: doc.id);
      }));
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> refreshEvents() async {
    await _fetchEvents();
  }
}
