import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

Future<Map<String, dynamic>?> deleteLessonStudent(int id) async {
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final ioClient = IOClient(client);
  final url = Uri.parse(
    'https://10.0.2.2:7170/api/Teacher/DeleteLessonStudent?studentLessonId=$id',
  ); // Parametreyi URL'ye ekledik

  try {
    final response = await ioClient.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      print('Hata: ${response.statusCode}, ${response.body}');
      return null;
    }
  } catch (e) {
    print('İstek başarısız: $e');
    return null;
  }
}
