import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/models/booked_date_model.dart';

class BookedDatesRepository {
  static final BookedDatesRepository _instance =
      BookedDatesRepository._internal();
  factory BookedDatesRepository() => _instance;

  BookedDatesRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<BookedDate> _bookedDates = [];

  List<BookedDate> get bookedDates => List.unmodifiable(_bookedDates);

  Future<void> init() async {
    await _fetchBookedDates();
  }

  Future<void> addBookedDate(BookedDate bookedDate) async {
    try {
      await _firestore.collection('bookedDates').add(bookedDate.toMap());
      _bookedDates.add(bookedDate);
    } catch (e) {
      print("Error adding booked date: $e");
    }
  }

  Future<void> _fetchBookedDates() async {
    try {
      final snapshot = await _firestore.collection('bookedDates').get();
      _bookedDates.clear();
      _bookedDates.addAll(snapshot.docs.map(
          (doc) => BookedDate.fromMap(doc.data() as Map<String, dynamic>)));
    } catch (e) {
      print("Error fetching booked dates: $e");
    }
  }

  Future<void> refreshBookedDates() async => _fetchBookedDates();
}
