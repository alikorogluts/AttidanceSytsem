import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoklama_mobil/Models/GetLessonStudentListModel.dart';
import 'package:yoklama_mobil/Services/TeacherServices/MyLessonServices/_SaveAttendanceServices.dart';

class AttendanceScreen extends StatefulWidget {
  final List<StudentLesson> students;
  final int lessonId;
  final String lessonName;

  const AttendanceScreen({
    super.key,
    required this.students,
    required this.lessonId,
    required this.lessonName,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<StudentLesson> _students;
  final Map<int, String> _attendanceStatus = {};
  final Map<int, String?> _excuseNotes = {};
  int? _selectedLessonDuration;

  // Süre ve zaman kontrolü için değişkenler
  DateTime? _lastAttendanceTime;
  int _remainingTime = 0;
  bool _isAttendanceDisabled = false;
  late Timer _timer;
  static const _lockDuration = Duration(seconds: 120);
  static const _attendanceTimeKey = 'lastAttendanceTime';

  final List<Map<String, dynamic>> _lessonDurations = [
    {'value': 1, 'text': '1 Ders (45 dakika)'},
    {'value': 2, 'text': '2 Ders (90 dakika)'},
    {'value': 3, 'text': '3 Ders (135 dakika)'},
    {'value': 4, 'text': '4 Ders (180 dakika)'},
  ];

  @override
  void initState() {
    super.initState();
    _students = widget.students;
    _loadLastAttendanceTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// SharedPreferences’den son yoklama zamanını yüklüyoruz.
  Future<void> _loadLastAttendanceTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMillis = prefs.getInt(_attendanceTimeKey);
    if (lastMillis != null) {
      _lastAttendanceTime = DateTime.fromMillisecondsSinceEpoch(lastMillis);
      final diff = DateTime.now().difference(_lastAttendanceTime!);
      if (diff < _lockDuration) {
        setState(() {
          _isAttendanceDisabled = true;
          _remainingTime = _lockDuration.inSeconds - diff.inSeconds;
        });
      }
    }
  }

  /// Yoklama alındığında zamanı kaydediyoruz.
  Future<void> _saveAttendanceTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attendanceTimeKey, time.millisecondsSinceEpoch);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        if (_isAttendanceDisabled) {
          setState(() => _isAttendanceDisabled = false);
        }
      }
    });
  }

  Widget _buildLessonDurationSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ders Süresi Seçin',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: _selectedLessonDuration,
            items:
                _lessonDurations
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e['value'],
                        child: Text(
                          e['text'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
            onChanged:
                (value) => setState(() => _selectedLessonDuration = value),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          _isAttendanceDisabled
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sonraki yoklama: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildStudentList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                _students.isEmpty
                    ? Center(
                      child: Text(
                        'Öğrenci bulunamadı',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _students.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder:
                          (context, index) =>
                              _buildStudentItem(_students[index]),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentItem(StudentLesson student) {
    final status = _attendanceStatus[student.studentLessonId];

    return Slidable(
      key: ValueKey(student.studentLessonId),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _updateStatus(student.studentLessonId, 'present'),
            backgroundColor: Colors.green.shade300,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Var',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => _updateStatus(student.studentLessonId, 'absent'),
            backgroundColor: Colors.red.shade300,
            foregroundColor: Colors.white,
            icon: Icons.close,
            label: 'Yok',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => _showExcuseDialog(student.studentLessonId),
            backgroundColor: Colors.amber.shade400,
            foregroundColor: Colors.white,
            icon: Icons.info_outline,
            label: 'İzinli',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: _buildStudentCard(student, status),
    );
  }

  Widget _buildStudentCard(StudentLesson student, String? status) {
    // Varsayılan kart rengi koyu, eğer yoklama seçilmemişse.
    final cardColor =
        status != null ? _getStatusColor(status) : Colors.grey.shade900;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.person, size: 32, color: Colors.white),
        title: Text(
          student.StudentName,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'No: ${student.studentId}',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
        ),
        trailing:
            status == 'excused'
                ? Tooltip(
                  message: _excuseNotes[student.studentLessonId] ?? '',
                  child: const Icon(Icons.info_outline, color: Colors.white),
                )
                : null,
      ),
    );
  }

  Color _getStatusColor(String status) {
    // Duruma göre arka plan renkleri (var: yeşil, yok: kırmızı, izinli: sarı)
    if (status == 'present') return Colors.green.shade600;
    if (status == 'absent') return Colors.red.shade600;
    if (status == 'excused') return Colors.amber.shade700;
    return Colors.grey.shade900;
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
  }

  Future<void> _showExcuseDialog(int studentId) async {
    String? excuse;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('İzin Sebebi'),
            content: TextField(
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Mazerat açıklaması...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => excuse = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
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

  Future<void> _confirmAttendance() async {
    if (_selectedLessonDuration == null) {
      _showErrorSnackBar('Lütfen ders süresini seçin');
      return;
    }
    if (_attendanceStatus.length != _students.length) {
      _showErrorSnackBar('Lütfen tüm öğrencileri işaretleyin');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Yoklamayı Onayla'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ders: ${widget.lessonName}'),
                  Text(
                    'Süre: ${_lessonDurations.firstWhere((e) => e['value'] == _selectedLessonDuration)['text']}',
                  ),
                  const SizedBox(height: 16),
                  // Özet ekranında, her öğrenci için adının yanına durum ikonları gösteriliyor.
                  ..._students.map((student) {
                    final status =
                        _attendanceStatus[student.studentLessonId] ?? '?';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _getStatusIcon(status),
                        color: Colors.white,
                      ),
                      title: Text(
                        student.StudentName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      subtitle:
                          status == 'excused'
                              ? Text(
                                'Gerekçe: ${_excuseNotes[student.studentLessonId] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              )
                              : null,
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Onayla'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) await _submitAttendance();
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'excused':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _submitAttendance() async {
    try {
      final attendanceList =
          _students.map((student) {
            final status = _attendanceStatus[student.studentLessonId];
            // Eğer izinli ise açıklama boş olmamalı; aksi halde boş string gönderiyoruz.
            final explanation =
                status == 'excused'
                    ? (_excuseNotes[student.studentLessonId]?.trim() ?? "")
                    : "";
            return {
              'studentId': student.studentId,
              'studentLessonId': student.studentLessonId,
              'status': status,
              'Explanation': explanation,
            };
          }).toList();

      final attendanceData = {
        'lessonId': widget.lessonId,
        'lessonPeriod': _selectedLessonDuration, // Ders süresi bilgisi
        'startTime': DateFormat("HH:mm").format(DateTime.now()), // Şu anki saat
        'Attendances': attendanceList,
      };

      final result = await submitAttendance(attendanceData);

      if (result != null && result['success'] == true) {
        setState(() {
          _isAttendanceDisabled = true;
          _remainingTime = _lockDuration.inSeconds;
          _lastAttendanceTime = DateTime.now();
        });
        await _saveAttendanceTime(_lastAttendanceTime!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Yoklama başarıyla kaydedildi'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        _showErrorSnackBar(
          'API hatası: ${result?['message'] ?? 'Bilinmeyen hata'}',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Hata: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _isAttendanceDisabled ? null : _confirmAttendance,
      icon: const Icon(Icons.save),
      label: const Text('Yoklamayı Kaydet'),
      backgroundColor: _isAttendanceDisabled ? Colors.grey : Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Yardım'),
            content: const Text(
              '• Öğrenci kartını sağa veya sola kaydırarak yoklama durumunu seçin.\n'
              '• "İzinli" seçildiğinde açıklama girilmesi zorunludur.\n'
              '• Yoklama alındıktan sonra 2 dakikaya kadar tekrar yoklama alınamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.lessonName),
            if (_lastAttendanceTime != null)
              Text(
                'Son yoklama: ${DateFormat('HH:mm').format(_lastAttendanceTime!)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLessonDurationSelector(),
          _buildTimeIndicator(),
          _buildStudentList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
