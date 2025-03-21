class Lesson {
  final int lessonId;
  final String name;
  final int totalWeeks;
  final int sessionsPerWeek;
  final int maxAbsence;
  final String uniqueCode;
  final int studentCount;

  Lesson({
    required this.lessonId,
    required this.name,
    required this.totalWeeks,
    required this.sessionsPerWeek,
    required this.maxAbsence,
    required this.uniqueCode,
    required this.studentCount,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'],
      name: json['name'],
      totalWeeks: json['totalWeeks'],
      sessionsPerWeek: json['sessionsPerWeek'],
      maxAbsence: json['maxAbsence'],
      uniqueCode: json['uniqueCode'],
      studentCount: json['studentCount'],
    );
  }
}
