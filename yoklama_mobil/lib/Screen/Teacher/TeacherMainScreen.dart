import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/AttendanceScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/CreateLessonScreen/CreateLessonScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/EditAttendanceScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/MyLessonScreen/MyLessonScreen.dart';
import 'package:yoklama_mobil/Screen/Teacher/_partialScreen/ReportsScreen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğretmen Paneli',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.blue.shade800,
              );
            }
            return TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey.shade600,
            );
          }),
          indicatorColor: Colors.blue.shade100,
        ),
      ),
      home: TeacherMainScreen(),
    );
  }
}

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

  Future<String?> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name");
    });
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName ?? "Öğretmen Paneli",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 2,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.school_outlined, color: _getIconColor(0)),
          selectedIcon: Icon(Icons.school, color: _getSelectedColor()),
          label: 'Derslerim',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_outlined, color: _getIconColor(1)),
          selectedIcon: Icon(Icons.checklist, color: _getSelectedColor()),
          label: 'Yoklama',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline, color: _getIconColor(2)),
          selectedIcon: Icon(Icons.add_circle, color: _getSelectedColor()),
          label: 'Oluştur',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined, color: _getIconColor(3)),
          selectedIcon: Icon(Icons.edit_note, color: _getSelectedColor()),
          label: 'Düzenle',
        ),
        NavigationDestination(
          icon: Icon(Icons.insert_chart_outlined, color: _getIconColor(4)),
          selectedIcon: Icon(Icons.insert_chart, color: _getSelectedColor()),
          label: 'Raporlar',
        ),
      ],
    );
  }

  Color _getSelectedColor() => Theme.of(context).colorScheme.error;

  Color _getIconColor(int index) {
    return _selectedIndex == index
        ? _getSelectedColor()
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }
}
