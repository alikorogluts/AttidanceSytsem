// getAttendanceListServices.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:yoklama_mobil/Models/GetAttendanceListModel.dart'
    as GetAttendaceList;

Future<List<GetAttendaceList.Lesson>> getAttendaceList(
  String teacherEmail,
) async {
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final ioClient = IOClient(client);

  final url = Uri.parse(
    'https://10.0.2.2:7170/api/Teacher/GetAttendancesByTeacher/$teacherEmail',
  );

  try {
    final response = await ioClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((lesson) => GetAttendaceList.Lesson.fromJson(lesson))
          .toList();
    } else if (response.statusCode == 404) {
      final errorMessage = response.body;
      print('Hata: $errorMessage');
      throw errorMessage; // sadece mesajı fırlat
    } else {
      print('Beklenmeyen hata: ${response.statusCode}, ${response.body}');
      throw 'Beklenmeyen bir hata oluştu';
    }
  } catch (e) {
    print('İstek başarısız: $e');
    throw e; // sadece e'yi fırlat
  }
}
