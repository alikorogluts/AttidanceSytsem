import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:yoklama_mobil/Screen/Login/VerifyCode.dart';
import 'package:yoklama_mobil/Services/LoginServices/SendCodeServices.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _usernameError = '';
  String _surnameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';
  String _errorMessage = '';
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'@(ogrenci\.)?artvin\.edu\.tr$').hasMatch(email);
  }

  void _validateFields() async {
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
              : (_passwordController.text.length < 6
                  ? 'Şifre en az 6 karakter olmalı'
                  : '');
      _confirmPasswordError =
          _confirmPasswordController.text.isEmpty
              ? 'Şifre tekrar boş olamaz'
              : (_confirmPasswordController.text != _passwordController.text
                  ? 'Şifreler uyuşmuyor'
                  : '');
      _errorMessage = '';
    });

    if (_usernameError.isEmpty &&
        _surnameError.isEmpty &&
        _emailError.isEmpty &&
        _passwordError.isEmpty &&
        _confirmPasswordError.isEmpty) {
      setState(() {
        _isLoading = true; // Yükleme animasyonunu başlat
      });

      String? code = await sendCode(_emailController.text);

      if (code == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Kod gönderilemedi. Lütfen tekrar deneyin.";
        });

        return;
      }

      if (code == "1") {
        setState(() {
          _isLoading = false;
          _errorMessage = "Zaten kayıtlı bir hesabınız bulunmaktadır";
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => VerifyCode(
                verfyCode: code,
                username: _usernameController.text,
                surname: _surnameController.text,
                email: _emailController.text,
                password: _passwordController.text,
              ),
        ),
      );
    }
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
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField(
                                _usernameController,
                                'Adınız',
                                Icons.person,
                                _usernameError,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                _surnameController,
                                'Soyadınız',
                                Icons.person_outline,
                                _surnameError,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                _emailController,
                                'E-posta',
                                Icons.email,
                                _emailError,
                                isEmail: true,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                _passwordController,
                                'Şifre',
                                Icons.lock,
                                _passwordError,
                                isPassword: true,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                _confirmPasswordController,
                                'Şifre Tekrar',
                                Icons.lock,
                                _confirmPasswordError,
                                isPassword: true,
                              ),
                              const SizedBox(height: 30),

                              // Hata mesajı ekranda gösterme
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              // Yükleme animasyonu
                              if (_isLoading) const CircularProgressIndicator(),

                              const SizedBox(height: 15),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _validateFields,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'KAYIT OL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    String errorText, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        errorText: errorText.isNotEmpty ? errorText : null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
