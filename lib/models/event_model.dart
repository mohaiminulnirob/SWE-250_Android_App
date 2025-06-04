class Event {
  String? id;
  final String uid;
  final String spotName;
  final String title;
  final String organizationName;
  final DateTime date;
  final String session;
  final String description;
  final String applicationImageUrl;

  Event({
    this.id,
    required this.uid,
    required this.spotName,
    required this.title,
    required this.organizationName,
    required this.date,
    required this.session,
    required this.description,
    required this.applicationImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'spotName': spotName,
      'title': title,
      'organizationName': organizationName,
      'date': date.toIso8601String(),
      'session': session,
      'description': description,
      'applicationImageUrl': applicationImageUrl,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, {String? id}) {
    return Event(
      id: id,
      uid: map['uid'] ?? '',
      spotName: map['spotName'] ?? '',
      title: map['title'] ?? '',
      organizationName: map['organizationName'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      session: map['session'] ?? '',
      description: map['description'] ?? '',
      applicationImageUrl: map['applicationImageUrl'] ?? '',
    );
  }
}
