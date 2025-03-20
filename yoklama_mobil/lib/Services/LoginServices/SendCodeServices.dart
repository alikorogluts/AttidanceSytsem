import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';

Future<String?> sendCode(String email) async {
  final HttpClient client = HttpClient();

  // Sertifika doğrulamasını atlatmak için
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  final ioClient = IOClient(client);

  final url = Uri.parse('https://10.0.2.2:7170/api/Acount/SendCode');

  try {
    final response = await ioClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Giriş başarılı: $data');
      return data['code'].toString(); // Gelen kodu döndür
    } else {
      print('Hata: ${response.statusCode}, ${response.body}');
      return "1"; // Hata olursa null döndür
    }
  } catch (e) {
    print('İstek başarısız: $e');
    return null; // Ağ hatası olursa null döndür
  }
}
