import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/event_model.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Future<void> addTodayEvents(List<Event> events) async {
    final today = DateTime.now();

    final todayEvents = events.where((event) =>
        event.date.year == today.year &&
        event.date.month == today.month &&
        event.date.day == today.day);

    final batch = _firestore.batch();

    for (var event in todayEvents) {
      final docRef = _firestore.collection(_collection).doc(event.id);
      batch.set(docRef, event.toMap());
    }

    await batch.commit();
  }

  Future<void> deletePastNotifications() async {
    final today = DateTime.now();

    final snapshot = await _firestore.collection(_collection).get();

    for (var doc in snapshot.docs) {
      final map = doc.data();
      final dateStr = map['date'];
      if (dateStr != null) {
        final eventDate = DateTime.parse(dateStr);
        final isToday = eventDate.year == today.year &&
            eventDate.month == today.month &&
            eventDate.day == today.day;

        if (!isToday) {
          await _firestore.collection(_collection).doc(doc.id).delete();
        }
      }
    }
  }

  Future<List<Event>> getTodaysNotifications() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => Event.fromMap(doc.data(), id: doc.id))
        .toList();
  }
}
