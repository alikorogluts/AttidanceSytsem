class Lesson {
  final int lessonId;
  final String lessonName;
  final List<Session> sessions;

  Lesson({
    required this.lessonId,
    required this.lessonName,
    required this.sessions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'],
      lessonName: json['lessonName'],
      sessions:
          (json['sessions'] as List<dynamic>)
              .map((session) => Session.fromJson(session))
              .toList(),
    );
  }
}

class Session {
  final String sessionDate;
  final String startTime;
  final String endTime;
  final List<Attendance> attendances;

  Session({
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.attendances,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionDate: json['sessionDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      attendances:
          (json['attendances'] as List<dynamic>)
              .map((attendance) => Attendance.fromJson(attendance))
              .toList(),
    );
  }
}

class Attendance {
  final int attendanceId;
  final Student student;
  late String status;
  final String startTime;
  final String endTime;
  late String? explanation;

  Attendance({
    required this.attendanceId,
    required this.student,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.explanation,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      student: Student.fromJson(json['student']),
      status: json['status'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      explanation: json['explanation'],
    );
  }
}

class Student {
  final int studentId;
  final String fullName;

  Student({required this.studentId, required this.fullName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(studentId: json['studentId'], fullName: json['fullName']);
  }
}
