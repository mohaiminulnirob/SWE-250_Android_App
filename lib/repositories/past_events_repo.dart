import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';

class PastEventsRepository {
  static final PastEventsRepository _instance =
      PastEventsRepository._internal();
  factory PastEventsRepository() => _instance;

  PastEventsRepository._internal() {
    _fetchPastEvents();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Event> _pastEvents = [];

  List<Event> get pastEvents => List.unmodifiable(_pastEvents);

  Future<void> addPastEvent(Event event) async {
    try {
      final docRef =
          await _firestore.collection('past_events').add(event.toMap());
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
      _pastEvents.add(newEvent);
    } catch (e) {
      print("Error adding past event: $e");
    }
  }

  Future<void> _fetchPastEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('past_events').get();
      _pastEvents.clear();
      _pastEvents.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data, id: doc.id);
      }));
    } catch (e) {
      print("Error fetching past events: $e");
    }
  }

  Future<void> refreshPastEvents() async {
    await _fetchPastEvents();
  }

  Future<void> updatePastEvent(Event event) async {
    if (event.id == null) {
      print("Cannot update past event: missing document ID.");
      return;
    }

    try {
      await _firestore
          .collection('past_events')
          .doc(event.id)
          .update(event.toMap());
      final index = _pastEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _pastEvents[index] = event;
      }
    } catch (e) {
      print("Error updating past event: $e");
    }
  }

  Future<void> deletePastEvent(String id) async {
    try {
      await _firestore.collection('past_events').doc(id).delete();
      _pastEvents.removeWhere((e) => e.id == id);
    } catch (e) {
      print("Error deleting past event: $e");
    }
  }
}
