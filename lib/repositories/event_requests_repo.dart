import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';

class EventRequestsRepository {
  static final EventRequestsRepository _instance =
      EventRequestsRepository._internal();
  factory EventRequestsRepository() => _instance;

  EventRequestsRepository._internal() {
    _fetchEventRequests();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Event> _eventRequests = [];

  List<Event> get eventRequests => List.unmodifiable(_eventRequests);

  Future<void> addEventRequest(Event event) async {
    try {
      final docRef =
          await _firestore.collection('event_requests').add(event.toMap());
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
      _eventRequests.add(newEvent);
    } catch (e) {
      print("Error adding event request: $e");
    }
  }

  Future<void> _fetchEventRequests() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('event_requests').get();
      _eventRequests.clear();
      _eventRequests.addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data, id: doc.id);
      }));
    } catch (e) {
      print("Error fetching event requests: $e");
    }
  }

  Future<void> refreshEventRequests() async {
    await _fetchEventRequests();
  }

  Future<void> updateEventRequest(Event event) async {
    if (event.id == null) {
      print("Cannot update event request: missing document ID.");
      return;
    }

    try {
      await _firestore
          .collection('event_requests')
          .doc(event.id)
          .update(event.toMap());
      final index = _eventRequests.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _eventRequests[index] = event;
      }
    } catch (e) {
      print("Error updating event request: $e");
    }
  }

  Future<void> deleteEventRequest(String id) async {
    try {
      await _firestore.collection('event_requests').doc(id).delete();
      _eventRequests.removeWhere((e) => e.id == id);
    } catch (e) {
      print("Error deleting event request: $e");
    }
  }
}
