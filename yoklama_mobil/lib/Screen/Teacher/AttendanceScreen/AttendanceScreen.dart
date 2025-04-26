// attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model ve servis importlarını unutmayın:
import 'package:yoklama_mobil/Models/GetAttendanceListModel.dart'
    as GetAttendaceList;
import 'package:yoklama_mobil/Screen/Teacher/AttendanceScreen/EditAttendanceScreen.dart';
import 'package:yoklama_mobil/Services/TeacherServices/AttendanceServices/GetAttendanceListServices.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? teacherEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // SharedPreferences'den user_email bilgisini çekiyoruz.
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("user_mail");
    if (email == null) {
      print("user_email bulunamadı!");
    }
    setState(() {
      teacherEmail = email;
    });
  }

  Future<List<GetAttendaceList.Lesson>> _fetchLessons() async {
    if (teacherEmail == null) {
      // Eğer henüz e-posta yüklenmediyse boş liste döndürüyoruz.
      return [];
    }
    return await getAttendaceList(teacherEmail!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Eğer teacherEmail null ise veri yükleniyor demektir.
    if (teacherEmail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Yoklama Listesi")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey,
          secondary: Colors.cyanAccent,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: Scaffold(
        body: FutureBuilder<List<GetAttendaceList.Lesson>>(
          future: _fetchLessons(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Hata: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final lessons = snapshot.data!;
              if (lessons.isEmpty) {
                return const Center(child: Text("Henüz veri yok."));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonCard(lesson, colors);
                },
              );
            } else {
              return const Center(child: Text("Henüz veri yok."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(GetAttendaceList.Lesson lesson, ColorScheme colors) {
    // Modelden gelen sessionları, aynı startTime ve endTime değerlerine göre gruplandırıyoruz.
    final sessions = _groupSessions(lesson.sessions);
    final sessionCount = sessions.length;
    final lessonName =
        lesson.lessonName.isNotEmpty ? lesson.lessonName : "İsimsiz Ders";

    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            lessonName.substring(0, 1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          lessonName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "$sessionCount Yoklama Kaydı",
          style: TextStyle(color: Colors.grey[400]),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children:
            sessionCount > 0
                ? sessions.map((session) => _buildSessionTile(session)).toList()
                : const [
                  ListTile(
                    title: Text("Henüz yoklama kaydı bulunmuyor"),
                    leading: Icon(Icons.info_outline),
                  ),
                ],
      ),
    );
  }

  /// Aynı startTime ve endTime değerine sahip Session'ları birleştirir.
  List<GetAttendaceList.Session> _groupSessions(
    List<GetAttendaceList.Session> sessions,
  ) {
    final Map<String, GetAttendaceList.Session> grouped = {};

    for (var session in sessions) {
      final key = "${session.startTime}-${session.endTime}";
      if (!grouped.containsKey(key)) {
        // Mevcut session'ın attendances listesini kopyalayarak ekliyoruz.
        grouped[key] = GetAttendaceList.Session(
          sessionDate: session.sessionDate,
          startTime: session.startTime,
          endTime: session.endTime,
          attendances: List.from(session.attendances),
        );
      } else {
        grouped[key]!.attendances.addAll(session.attendances);
      }
    }
    return grouped.values.toList();
  }

  Widget _buildSessionTile(GetAttendaceList.Session session) {
    final attendances = session.attendances;
    final startTime = formatTime(session.startTime);
    final endTime = formatTime(session.endTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule, size: 20),
        title: Text(
          "${_formatDate(session.sessionDate)} ($startTime - $endTime)",
        ),
        subtitle: Text(
          "${attendances.length} Kayıtlı öğrenci",
          style: TextStyle(color: Colors.grey[400]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children:
                  attendances.map((att) => _buildAttendanceTile(att)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTile(GetAttendaceList.Attendance att) {
    final statusColor = _getStatusColor(att.status);
    final explanation = att.explanation;
    final studentName =
        att.student.fullName.isNotEmpty
            ? att.student.fullName
            : "İsimsiz Öğrenci";

    return Slidable(
      key: Key(att.attendanceId.toString()),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editAttendance(att),
            backgroundColor: Colors.blue,
            icon: Icons.edit,
            label: 'Düzenle',
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getStatusIcon(att.status), color: statusColor),
        ),
        title: Text(
          studentName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle:
            explanation != null && explanation.isNotEmpty
                ? Text("Açıklama: $explanation")
                : null,
        trailing: Text(
          _translateStatus(att.status),
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Present':
        return 'Katılım';
      case 'Excused':
        return 'İzinli';
      case 'Absent':
        return 'Yok';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Excused':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle;
      case 'Excused':
        return Icons.warning;
      case 'Absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Mevcut _editAttendance fonksiyonunuz:
  void _editAttendance(GetAttendaceList.Attendance attendance) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendanceScreen(attendance: attendance),
      ),
    );

    if (result == true) {
      setState(() {
        // bu kısım ekrandaki verilerin yeniden çizilmesini sağlar
      });
    }
  }

  String formatTime(String time) {
    try {
      return time.substring(0, 5);
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String date) {
    try {
      final regex = RegExp(r'^(\d{4}-\d{2}-\d{2})T');
      final match = regex.firstMatch(date);

      if (match != null) {
        final datePart = match.group(1)!; // yyyy-MM-dd
        final parsed = DateFormat('yyyy-MM-dd').parse(datePart);
        return DateFormat(
          'dd-MM-yyyy',
        ).format(parsed); // istediğin format: 19-04-2025
      } else {
        return date;
      }
    } catch (e) {
      return date;
    }
  }
}
