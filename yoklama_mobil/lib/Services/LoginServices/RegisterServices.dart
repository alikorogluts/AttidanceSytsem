import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

Future<int> register(String email, String password, String fullName) async {
  final HttpClient client = HttpClient();

  // Sertifika doğrulamasını atlatmak için
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  final ioClient = IOClient(client);

  // Android emülatörü için localhost yerine 10.0.2.2 kullanılmalı
  final url = Uri.parse('https://10.0.2.2:7170/api/Acount/Register');

  try {
    final response = await ioClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Giriş başarılı: $data');
    } else {
      print('Hata: ${response.statusCode}, ${response.body}');
    }
    return response.statusCode;
  } catch (e) {
    print('İstek başarısız: $e');
    return -1;
  }
}
