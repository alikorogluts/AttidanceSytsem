import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:yoklama_mobil/Screen/Login/LoginScreen.dart';
import 'package:yoklama_mobil/Services/LoginServices/RegisterServices.dart';
import 'package:yoklama_mobil/Services/LoginServices/SendCodeServices.dart';

class VerifyCode extends StatefulWidget {
  final String email;
  final String username;
  final String surname;
  final String password;
  final String verfyCode;

  const VerifyCode({
    super.key,
    required this.email,
    required this.username,
    required this.surname,
    required this.password,
    required this.verfyCode,
  });

  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  late String currentCode;

  @override
  void initState() {
    super.initState();
    currentCode = widget.verfyCode; // Sayfa açıldığında gelen kodu al
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    // Kullanıcının girdiği kod ile mevcut kod eşleşiyor mu?
    if (_codeController.text != currentCode) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hatalı kod girdiniz!"),
          backgroundColor: Colors.red,
        ),
      );
      return; // İşlemi durdur
    }

    // Eğer kod doğruysa, kayıt işlemini başlat
    var value = await register(
      widget.email,
      widget.password,
      "${widget.username} ${widget.surname}",
    );

    setState(() {
      _isLoading = false;
    });

    if (value == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kod doğru, kayıt başarılı!"),
          backgroundColor: Colors.green,
        ),
      );

      // Kullanıcıyı giriş ekranına yönlendir
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Önceki sayfaları temizle
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt başarısız! Bağlantı hatası olabilir."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? newCode = await sendCode(widget.email); // Yeni kodu al
      setState(() {
        _isLoading = false;
        currentCode = newCode.toString(); // Gelen yeni kodu güncelle
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Yeni doğrulama kodu gönderildi!"),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kod gönderilemedi, tekrar deneyin!"),
          backgroundColor: Colors.red,
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
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
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
                          "Doğrulama Kodunu Girin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "E-postanıza gönderilen 6 haneli kodu girin",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white54,
                            selectedColor: Colors.blue,
                            activeFillColor: Colors.transparent,
                            inactiveFillColor: Colors.transparent,
                            selectedFillColor: Colors.transparent,
                          ),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          onCompleted: (v) => _verifyCode(),
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Container(
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
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: _verifyCode,
                                child: const Center(
                                  child: Text(
                                    "ONAYLA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _resendCode, // Tekrar gönderme fonksiyonu
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(text: "Kod gelmedi mi? "),
                                TextSpan(
                                  text: "Tekrar Gönder",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
