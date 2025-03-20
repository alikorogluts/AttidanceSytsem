import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/AttendanceScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/CreateLessonScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/EditAttendanceScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/MyLessonScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/ReportsScreen.dart';

class TeacherMainScreen extends StatefulWidget {
  @override
  _TeacherMainScreenState createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _selectedIndex = 0;
  String? userName;
  late Future<void> _prefsFuture;

  final List<Widget> _pages = [
    MyLessonsScreen(),
    AttendanceScreen(),
    CreateLessonScreen(),
    EditAttendanceScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _prefsFuture = _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name");
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName ?? "Öğretmen Paneli",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(backgroundImage: AssetImage('assets/logo.png')),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
          );
        },
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.school_outlined, Icons.school, 0),
            label: 'Derslerim',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              Icons.checklist_rtl_outlined,
              Icons.checklist_rtl,
              1,
            ),
            label: 'Yoklama',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.add_circle_outline, Icons.add_circle, 2),
            label: 'Oluştur',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.edit_note_outlined, Icons.edit_note, 3),
            label: 'Düzenle',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              Icons.insert_chart_outlined,
              Icons.insert_chart,
              4,
            ),
            label: 'Raporlar',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData outline, IconData filled, int index) {
    return Column(
      children: [
        Icon(_selectedIndex == index ? filled : outline, size: 28),
        SizedBox(height: 4),
        if (_selectedIndex == index)
          Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
