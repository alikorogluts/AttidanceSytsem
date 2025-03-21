import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yoklama_mobil/Models/GetLessonStudentList.dart';

class AttendanceScreen extends StatefulWidget {
  final List<StudentLesson> students;
  final int lessonId;

  const AttendanceScreen({
    super.key,
    required this.students,
    required this.lessonId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<StudentLesson> _students;
  final Map<int, String> _attendanceStatus = {};
  final Map<int, String?> _excuseNotes = {};

  @override
  void initState() {
    super.initState();
    // Animasyonları kaldırdık; direkt widget.students listesini atıyoruz.
    _students = widget.students;
  }

  Future<void> _showExcuseDialog(int studentId) async {
    String? excuse;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mazerat Giriniz'),
            icon: const Icon(Icons.edit_note_rounded),
            content: TextField(
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Mazerat sebebi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (value) => excuse = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Vazgeç'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  if (excuse?.trim().isNotEmpty ?? false) {
                    Navigator.pop(context);
                    _updateStatus(studentId, 'excused', excuse: excuse);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
    );
  }

  void _updateStatus(int studentId, String status, {String? excuse}) {
    setState(() {
      _attendanceStatus[studentId] = status;
      if (status == 'excused') {
        _excuseNotes[studentId] = excuse;
      } else {
        _excuseNotes.remove(studentId);
      }
    });
    Feedback.forTap(context);
  }

  Future<void> _confirmAttendance() async {
    if (_attendanceStatus.length != _students.length) {
      _showStatusSnackBar('Lütfen tüm öğrencileri işaretleyin', true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Yoklamayı Onayla'),
            icon: const Icon(Icons.task_alt_rounded),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _students.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final status = _attendanceStatus[student.studentLessonId];
                  return _buildSummaryItem(student, status);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Onayla'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      await _submitAttendance();
    }
  }

  Future<void> _submitAttendance() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final data =
          _students
              .map(
                (s) => {
                  'lessonId': widget.lessonId,
                  'studentId': s.studentId,
                  'status': _attendanceStatus[s.studentLessonId],
                  'excuse': _excuseNotes[s.studentLessonId],
                },
              )
              .toList();

      // API çağrısı simülasyonu
      await Future.delayed(const Duration(seconds: 1));

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Yoklama başarıyla kaydedildi'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      navigator.pop();
    } catch (e) {
      _showStatusSnackBar('Kayıt hatası: ${e.toString()}', false);
    }
  }

  void _showStatusSnackBar(String message, bool isWarning) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isWarning ? Icons.warning_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isWarning ? Colors.orange : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yoklama Al')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmAttendance,
        icon: const Icon(Icons.save_as_rounded),
        label: const Text('Kaydet'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body:
          _students.isEmpty
              ? const Center(child: Text('Öğrenci bulunamadı'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _students.length,
                itemBuilder:
                    (context, index) => _buildStudentItem(_students[index]),
              ),
    );
  }

  Widget _buildStudentItem(StudentLesson student) {
    final status = _attendanceStatus[student.studentLessonId];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey(student.studentLessonId),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed:
                  (_) => _updateStatus(student.studentLessonId, 'present'),
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green.shade900,
              icon: Icons.check_rounded,
              label: 'Katıldı',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed:
                  (_) => _updateStatus(student.studentLessonId, 'absent'),
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
              icon: Icons.close_rounded,
              label: 'Katılmadı',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => _showExcuseDialog(student.studentLessonId),
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.orange.shade900,
              icon: Icons.warning_rounded,
              label: 'İzinli',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: _buildStudentCard(student, status),
      ),
    );
  }

  Widget _buildStudentCard(StudentLesson student, String? status) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      // Arka plan rengi; status yoksa beyaz yaparak kontrastı arttırıyoruz.
      color: _getStatusColor(status),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.person_rounded,
            size: 36,
            color: _getTextColor(status),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.StudentName,
                style: TextStyle(
                  color: _getTextColor(status),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Öğrenci Numarası: ${student.studentId}',
                style: TextStyle(color: _getTextColor(status), fontSize: 12),
              ),
            ],
          ),
          subtitle:
              _excuseNotes[student.studentLessonId] != null
                  ? Text(
                    'Mazerat: ${_excuseNotes[student.studentLessonId]}',
                    style: TextStyle(
                      color: _getTextColor(status)?.withOpacity(0.8),
                    ),
                  )
                  : null,
          trailing: _buildStatusChip(status),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final color = _getStatusColor(status);
    final textColor = _getTextColor(status);

    return status != null
        ? Chip(
          label: Text(
            status == 'present'
                ? 'Katıldı'
                : status == 'absent'
                ? 'Katılmadı'
                : 'İzinli',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          backgroundColor: color,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        )
        : const SizedBox.shrink();
  }

  Widget _buildSummaryItem(StudentLesson student, String? status) {
    return ListTile(
      leading: Icon(_getStatusIcon(status), color: _getTextColor(status)),
      title: Text(
        student.StudentName,
        style: TextStyle(color: _getTextColor(status)),
      ),
      subtitle:
          _excuseNotes[student.studentLessonId] != null
              ? Text(
                'Mazerat: ${_excuseNotes[student.studentLessonId]}',
                style: TextStyle(color: _getTextColor(status)),
              )
              : null,
      trailing: Text(
        status == 'present'
            ? '✓'
            : status == 'absent'
            ? '✕'
            : '⚠',
        style: TextStyle(fontSize: 20, color: _getTextColor(status)),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'excused':
        return Icons.warning_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green.shade50;
      case 'absent':
        return Colors.red.shade50;
      case 'excused':
        return Colors.orange.shade50;
      default:
        return Colors.white; // Varsayılan beyaz arka plan
    }
  }

  Color _getTextColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green.shade900;
      case 'absent':
        return Colors.red.shade900;
      case 'excused':
        return Colors.orange.shade900;
      default:
        return Colors.black; // Varsayılan siyah metin
    }
  }
}
