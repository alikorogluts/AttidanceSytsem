import 'package:flutter/material.dart';
import 'package:yoklama_mobil/Models/GetLessonStudentListModel.dart';
import 'package:yoklama_mobil/Services/TeacherServices/MyLessonServices/_DeleteLessonStudentServices.dart';

class StudentListScreen extends StatefulWidget {
  final List<StudentLesson> students;

  const StudentListScreen({super.key, required this.students});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late List<StudentLesson> _students;
  late int lessonId;

  @override
  void initState() {
    super.initState();
    _students = widget.students;
  }

  Future<void> _deleteStudent(int studentLessonId) async {
    final message = await deleteLessonStudent(studentLessonId);

    if (message != null) {
      setState(() {
        _students.removeWhere(
          (student) => student.studentLessonId == studentLessonId,
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silme işlemi başarılı')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silme işlemi sırasında hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body:
          _students.isEmpty
              ? const Center(child: Text('Öğrenci bulunamadı'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _students.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Dismissible(
                    key: Key(student.studentLessonId.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Silme Onayı'),
                              content: const Text(
                                'Bu öğrenciyi silmek istediğinize emin misiniz?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sil'),
                                ),
                              ],
                            ),
                      );
                      if (result ?? false) {
                        _deleteStudent(student.studentLessonId);
                        return true;
                      }
                      return false;
                    },
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, size: 32),
                        title: Text(
                          student.StudentName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Devamsızlık: ${student.absenceCount}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Silme Onayı'),
                                    content: const Text(
                                      'Bu öğrenciyi silmek istediğinize emin misiniz?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('İptal'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Sil'),
                                      ),
                                    ],
                                  ),
                            );
                            if (result ?? false) {
                              _deleteStudent(student.studentLessonId);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
