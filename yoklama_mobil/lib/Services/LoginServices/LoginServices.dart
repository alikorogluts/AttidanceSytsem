import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:yoklama_mobil/Screen/Teacher/TeacherMainScreen.dart';
import 'package:yoklama_mobil/Screen/Student/StudentMainScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveSession(String email, String role, String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("user_mail", email);
  await prefs.setString("user_role", role);
  await prefs.setString("user_name", username);
}

Future<bool> login(BuildContext context, String email, String password) async {
  final HttpClient client = HttpClient();
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  final ioClient = IOClient(client);
  final url = Uri.parse('https://10.0.2.2:7170/api/Acount/Login');

  try {
    final response = await ioClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey("role")) {
        print("Hata: Eksik yanıt formatı.");
        return false;
      }

      String sessionEmail = email;
      String userRole = data["role"];
      String userName = data["username"];

      await _saveSession(sessionEmail, userRole, userName);

      if (userRole == "Teacher") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TeacherMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentMainScreen()),
        );
      }

      return true; // Başarılı giriş
    } else if (response.statusCode == 401) {
      print('Kimlik bilgileri hatalı!');
      return false; // Hatalı giriş
    } else {
      print('Hata: ${response.statusCode}, ${response.body}');
      return false;
    }
  } catch (e) {
    print('İstek başarısız: $e');
    return false;
  }
}
