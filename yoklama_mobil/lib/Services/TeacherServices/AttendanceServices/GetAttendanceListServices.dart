// getAttendanceListServices.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:yoklama_mobil/Models/GetAttendanceListModel.dart'
    as GetAttendaceList;

Future<List<GetAttendaceList.Lesson>> getAttendaceList(
  String teacherEmail,
) async {
  // Güvenlik sertifikası uyarılarını devre dışı bırakmak için HttpClient
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final ioClient = IOClient(client);

  // URL oluşturma: Artık teacherEmail parametresi doğru şekilde ekleniyor
  final url = Uri.parse(
    'https://10.0.2.2:7170/api/Teacher/GetAttendancesByTeacher/$teacherEmail',
  );

  try {
    // API çağrısı
    final response = await ioClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Gelen JSON verisini çözümleme
      final List<dynamic> data = jsonDecode(response.body);

      // Lesson modeline dönüştürme
      return data
          .map((lesson) => GetAttendaceList.Lesson.fromJson(lesson))
          .toList();
    } else {
      // Hata durumunu yazdırma
      print('Hata: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load lessons');
    }
  } catch (e) {
    // Ağ hatası durumunu ele alma
    print('İstek başarısız: $e');
    throw Exception('Network error');
  }
}
