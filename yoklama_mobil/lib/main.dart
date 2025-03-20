import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoklama_mobil/Screen/Login/LoginScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/TeacherMainScreen.dart';
import 'package:yoklama_mobil/Services/LoginServices/SessionServices.dart';
import 'package:yoklama_mobil/Screen/Student/StudentMainScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Session kontrolü yap
    String? email = prefs.getString("user_email");
    String? role = prefs.getString("user_role");

    if (email == null || role == null) {
      // Eğer oturum bilgileri yoksa, giriş ekranına yönlendir
      _setLoginScreen();
      return;
    }

    // Eğer session doluysa API'ye gidip oturumu doğrula
    Map<String, dynamic>? response = await sessionCheck(email);

    if (response != null && response['message'] == "True") {
      String fetchedRole = response['role'] ?? "Student";

      setState(() {
        _defaultScreen =
            fetchedRole == "Teacher"
                ? TeacherMainScreen()
                : StudentMainScreen();
      });

      // Rolü güncelle (değişmiş olabilir)
      prefs.setString("user_role", fetchedRole);
    } else {
      _setLoginScreen();
    }
  }

  void _setLoginScreen() {
    setState(() {
      _defaultScreen = const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: _defaultScreen,
    );
  }
}
