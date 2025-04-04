class BookedDate {
  final String spotName;
  final DateTime date;
  final String session;

  BookedDate({
    required this.spotName,
    required this.date,
    required this.session,
  });

  Map<String, dynamic> toMap() {
    return {
      'spotName': spotName,
      'date': date.toIso8601String(),
      'session': session,
    };
  }

  factory BookedDate.fromMap(Map<String, dynamic> map) {
    return BookedDate(
      spotName: map['spotName'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      session: map['session'] ?? '',
    );
  }
}
