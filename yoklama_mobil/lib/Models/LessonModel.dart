class Lesson {
  final int id;
  final String name;
  final String uniqueCode;
  final int sessionsPerWeek;
  final int totalWeeks;
  final int maxAbsence;
  final int studentLessons;

  static bool isEmpty = false;

  static var length;

  Lesson({
    required this.id,
    required this.name,
    required this.uniqueCode,
    required this.sessionsPerWeek,
    required this.totalWeeks,
    required this.maxAbsence,
    required this.studentLessons,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      name: json['name'],
      uniqueCode: json['uniqueCode'],
      sessionsPerWeek: json['sessionsPerWeek'],
      totalWeeks: json['totalWeeks'],
      maxAbsence: json['maxAbsence'],
      studentLessons: json['studentLessons'],
    );
  }
}
