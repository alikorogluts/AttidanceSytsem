import 'package:flutter/material.dart';

class StudentMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Öğrenci Paneli")),
      body: Center(child: Text("Hoş geldiniz, Öğrenci!")),
    );
  }
}
