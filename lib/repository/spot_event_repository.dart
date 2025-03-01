import 'package:project/models/event_model.dart';

class SpotEventRepository {
  static final SpotEventRepository _instance = SpotEventRepository._internal();

  factory SpotEventRepository() => _instance;

  SpotEventRepository._internal();

  final Map<String, List<Event>> _spotEvents = {};

  void addEvent(String spotName, Event event) {
    if (!_spotEvents.containsKey(spotName)) {
      _spotEvents[spotName] = [];
    }
    _spotEvents[spotName]!.add(event);
  }

  List<Event> getEventsForSpot(String spotName) {
    return _spotEvents[spotName] ?? [];
  }

  List<String> getAllSpots() {
    return _spotEvents.keys.toList();
  }

  List<Event> getAllEvents() {
    return _spotEvents.values.expand((events) => events).toList();
  }

  void clearEventsForSpot(String spotName) {
    _spotEvents[spotName]?.clear();
  }

  void clearAllEvents() {
    _spotEvents.clear();
  }
}
