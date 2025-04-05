import 'package:project/models/booked_date_model.dart';
import 'package:project/repositories/booked_dates_repository.dart';

class SpotBookedDatesRepository {
  static final SpotBookedDatesRepository _instance =
      SpotBookedDatesRepository._internal();
  factory SpotBookedDatesRepository() => _instance;

  final Map<String, List<BookedDate>> _spotBookedDates = {};

  SpotBookedDatesRepository._internal();

  Future<void> initializeFromBookedDatesRepository() async {
    _spotBookedDates.clear();
    await BookedDatesRepository().init();
    final bookedDates = BookedDatesRepository().bookedDates;

    for (var date in bookedDates) {
      _spotBookedDates.putIfAbsent(date.spotName, () => []).add(date);
    }
  }

  Future<void> refresh() async {
    await initializeFromBookedDatesRepository();
  }

  Future<List<BookedDate>> getBookedDatesForSpot(String spotName) async {
    if (_spotBookedDates.isEmpty) {
      await initializeFromBookedDatesRepository();
    }
    return _spotBookedDates[spotName] ?? [];
  }
}
