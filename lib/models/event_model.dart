class Event {
  final String spotName;
  final String title;
  final String organizationName;
  final DateTime date;
  final String session;
  final String description;

  Event({
    required this.spotName,
    required this.title,
    required this.organizationName,
    required this.date,
    required this.session,
    required this.description,
  });

  // Convert Event object to a Map
  Map<String, dynamic> toMap() {
    return {
      'spotName': spotName,
      'title': title,
      'organizationName': organizationName,
      'date': date.toIso8601String(), // Store date as ISO string
      'session': session,
      'description': description,
    };
  }

  // Create Event object from a Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      spotName: map['spotName'] ?? '',
      title: map['title'] ?? '',
      organizationName: map['organizationName'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      session: map['session'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
