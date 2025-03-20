import 'package:flutter/material.dart';

class MyLessonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Derslerim Sayfası", style: TextStyle(fontSize: 24)),
          // Ders kartları ve diğer içerik
        ],
      ),
    );
  }
}
