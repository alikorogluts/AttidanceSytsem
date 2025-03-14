import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:view/Login/RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _emailError = '';
  String _passwordError = '';

  bool _isValidEmail(String email) {
    return RegExp(r'@(ogrenci\.)?artvin\.edu\.tr$').hasMatch(email);
  }

  void _validateFields() {
    setState(() {
      _emailError =
          _emailController.text.isEmpty
              ? 'E-posta boş olamaz'
              : (!_isValidEmail(_emailController.text)
                  ? 'Geçersiz e-posta formatı'
                  : '');

      _passwordError =
          _passwordController.text.isEmpty
              ? 'Şifre boş olamaz'
              : (_passwordController.text.length < 6)
              ? 'Şifre en az 6 karakter olmalı'
              : '';
    });

    if (_emailError.isEmpty && _passwordError.isEmpty) {
      _performLogin();
    }
  }

  void _performLogin() {
    // API işlemleri burada
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Giriş Başarılı!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi ve blur efekti
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // Ana içerik
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // E-posta Alanı
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: 'E-posta',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _emailError.isNotEmpty ? _emailError : null,
                        errorStyle: const TextStyle(color: Colors.amber),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Şifre Alanı
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: 'Şifre',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        errorText:
                            _passwordError.isNotEmpty ? _passwordError : null,
                        errorStyle: const TextStyle(color: Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Giriş Butonu
                    ElevatedButton(
                      onPressed: _validateFields,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.blue[800],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'GİRİŞ YAP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Kayıt Ol Butonu
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          ),

                      child: Text(
                        'Hesabınız yok mu? KAYIT OL',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
