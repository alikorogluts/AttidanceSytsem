class StudentLesson {
  final int studentLessonId;
  final String StudentName;
  final int studentId;
  final int absenceCount;

  StudentLesson({
    required this.studentLessonId,
    required this.StudentName,
    required this.studentId,
    required this.absenceCount,
  });

  factory StudentLesson.fromJson(Map<String, dynamic> json) {
    return StudentLesson(
      studentLessonId: json['id'],
      StudentName: json['fullName'],
      studentId: json['studentId'],
      absenceCount: json['absenceCount'],
    );
  }
}
