import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:yoklama_mobil/Models/GetLessonStudentList.dart'
    as GetLessonStudentList; // Alias for LessonModel

Future<List<GetLessonStudentList.StudentLesson>> getLessonStudentList(
  int lessonId,
) async {
  // Using the alias for LessonModel
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final ioClient = IOClient(client);

  final url = Uri.parse(
    'https://10.0.2.2:7170/api/Teacher/GetLessonStudentList?LessonId=$lessonId',
  );

  try {
    final response = await ioClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((lesson) => GetLessonStudentList.StudentLesson.fromJson(lesson))
          .toList(); // Use the alias here
    } else {
      print('Hata: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load lessons');
    }
  } catch (e) {
    print('İstek başarısız: $e');
    throw Exception('Network error');
  }
}
