import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:view/Login/VerifyCode.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _usernameError = '';
  String _surnameError = '';
  String _emailError = '';
  String _passwordError = '';

  bool _isValidEmail(String email) {
    return RegExp(r'@(ogrenci\.)?artvin\.edu\.tr$').hasMatch(email);
  }

  void _validateFields() {
    setState(() {
      _usernameError =
          _usernameController.text.isEmpty ? 'Ad alanı boş olamaz' : '';

      _surnameError =
          _surnameController.text.isEmpty ? 'Soyad alanı boş olamaz' : '';

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

    if (_usernameError.isEmpty &&
        _surnameError.isEmpty &&
        _emailError.isEmpty &&
        _passwordError.isEmpty) {
      _performRegistration();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyCode()),
    );
  }

  void _performRegistration() {
    // API kayıt işlemleri burada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt Başarılı!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.all(25),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Yeni Hesap Oluştur',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Ad Input
                              TextField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  hintText: 'Adınız',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorText:
                                      _usernameError.isNotEmpty
                                          ? _usernameError
                                          : null,
                                  errorStyle: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Soyad Input
                              TextField(
                                controller: _surnameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  hintText: 'Soyadınız',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorText:
                                      _surnameError.isNotEmpty
                                          ? _surnameError
                                          : null,
                                  errorStyle: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // E-posta Input
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
                                  errorText:
                                      _emailError.isNotEmpty
                                          ? _emailError
                                          : null,
                                  errorStyle: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 15),

                              // Şifre Input
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
                                      _passwordError.isNotEmpty
                                          ? _passwordError
                                          : null,
                                  errorStyle: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Kayıt Butonu
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade800,
                                      Colors.blue.shade600,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _validateFields,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
                                    foregroundColor: Colors.blue[800],
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'KAYIT OL',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
