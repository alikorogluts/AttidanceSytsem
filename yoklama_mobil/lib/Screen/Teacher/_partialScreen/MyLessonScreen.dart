import 'package:yoklama_mobil/Models/LessonModel.dart';
import 'package:yoklama_mobil/Services/TeacherServices/GetListLesson.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyLessonsScreen(),
    );
  }
}

class MyLessonsScreen extends StatefulWidget {
  const MyLessonsScreen({super.key});

  @override
  State<MyLessonsScreen> createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen> {
  late List<Lesson> lessons = [];
  late String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_mail");
    });
    await _getLessons(userName.toString());
  }

  Future<void> _getLessons(String userName) async {
    // Assuming getLessons returns a List<Lesson> or something similar
    final fetchedLessons = await getLessons(
      userName,
    ); // Modify this call based on your actual method for fetching lessons
    setState(() {
      lessons = fetchedLessons;
    });
  }

  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Derslerim',
                style: TextStyle(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              background: ColoredBox(color: colors.surface),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder:
                  (context, index) => _buildLessonCard(lessons[index], colors),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson, ColorScheme colors) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    lesson.name.substring(0, 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    lesson.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.code_rounded,
              'Kod: ${lesson.uniqueCode}',
              colors,
            ),
            _buildInfoRow(
              Icons.schedule_rounded,
              'Haftalık Ders: ${lesson.sessionsPerWeek}',
              colors,
            ),
            _buildInfoRow(
              Icons.calendar_month_rounded,
              'Toplam Hafta: ${lesson.totalWeeks}',
              colors,
            ),
            _buildInfoRow(
              Icons.warning_rounded,
              'Maks. Devamsızlık: ${lesson.maxAbsence}',
              colors,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.people_alt_rounded,
                    label: 'Öğrenciler (${lesson.studentCount})',
                    onPressed: () => _showStudents(lesson.lessonId),
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Yoklama Al',
                    onPressed: () => _takeAttendance(lesson.lessonId),
                    colors: colors,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colors,
  }) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudents(int id) {
    // Öğrenci listesi göster
  }

  void _takeAttendance(int id) {
    // Yoklama alma işlemi
  }
}
