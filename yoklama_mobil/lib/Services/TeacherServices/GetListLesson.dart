import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import 'package:yoklama_mobil/Models/LessonModel.dart'
    as LessonModel; // Alias for LessonModel

Future<List<LessonModel.Lesson>> getLessons(String email) async {
  // Using the alias for LessonModel
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final ioClient = IOClient(client);

  final url = Uri.parse(
    'https://10.0.2.2:7170/api/Teacher/GetLesson?email=$email',
  );

  try {
    final response = await ioClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((lesson) => LessonModel.Lesson.fromJson(lesson))
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
