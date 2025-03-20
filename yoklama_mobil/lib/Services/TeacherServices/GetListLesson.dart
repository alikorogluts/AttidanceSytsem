import 'package:http/http.dart' as http;
import 'package:yoklama_mobil/Models/LessonModel.dart';
import 'dart:convert';

class LessonService {
  Future<List<Lesson>> fetchLessons() async {
    final response = await http.get(
      Uri.parse('https://api.example.com/lessons'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Lesson.fromJson(json)).toList();
    } else {
      throw Exception('Dersler yüklenemedi');
    }
  }
}
