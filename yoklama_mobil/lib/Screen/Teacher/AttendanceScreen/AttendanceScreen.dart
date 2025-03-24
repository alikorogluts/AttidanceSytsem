import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatelessWidget {
  final List<Map<String, dynamic>> lessons = [
    {
      "lessonId": 1,
      "lessonName": "Matematik 101",
      "sessions": [
        {
          "sessionDate": "2025-03-24T04:07:04.5202296",
          "startTime": "04:06:00",
          "endTime": "05:36:00",
          "attendances": [
            {
              "attendanceId": 6,
              "student": {"studentId": 220506, "fullName": "Koroglu Ali"},
              "status": "Present",
              "startTime": "04:06:00",
              "endTime": "05:36:00",
              "explanation": null,
            },
            {
              "attendanceId": 5,
              "student": {"studentId": 220502, "fullName": "Ali Koroglu"},
              "status": "Excused",
              "startTime": "04:06:00",
              "endTime": "05:36:00",
              "explanation": "Hastalık",
            },
          ],
        },
      ],
    },
    {"lessonId": 2, "lessonName": "Boş Ders", "sessions": []},
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return _buildLessonCard(lesson, colors);
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, ColorScheme colors) {
    final sessions = _groupSessions(lesson["sessions"] as List);
    final sessionCount = sessions.length;
    final lessonName = lesson["lessonName"]?.toString() ?? "İsimsiz Ders";

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
            lessonName.isNotEmpty ? lessonName.substring(0, 1) : "?",
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
                ? sessions
                    .map<Widget>((session) => _buildSessionTile(session))
                    .toList()
                : [
                  const ListTile(
                    title: Text("Henüz yoklama kaydı bulunmuyor"),
                    leading: Icon(Icons.info_outline),
                  ),
                ],
      ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session) {
    final attendances = session["attendances"] as List;
    final startTime = formatTime(session["startTime"]!.toString());
    final endTime = formatTime(session["endTime"]!.toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule, size: 20),
        title: Text("$startTime - $endTime"),
        subtitle: Text(
          "${attendances.length} Kayıtlı öğrenci",
          style: TextStyle(color: Colors.grey[400]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children:
                  attendances
                      .map<Widget>((att) => _buildAttendanceTile(att))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTile(Map<String, dynamic> att) {
    final statusColor = _getStatusColor(att["status"]);
    final explanation = att["explanation"]?.toString();
    final studentName =
        att["student"]?["fullName"]?.toString() ?? "İsimsiz Öğrenci";

    return Slidable(
      key: Key(att["attendanceId"].toString()),
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
          child: Icon(_getStatusIcon(att["status"]), color: statusColor),
        ),
        title: Text(
          studentName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle:
            explanation?.isNotEmpty == true
                ? Text("Açıklama: $explanation")
                : null,
        trailing: Text(
          _translateStatus(att["status"]),
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Yeni eklenen yardımcı fonksiyonlar
  List<Map<String, dynamic>> _groupSessions(List sessions) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var session in sessions) {
      final key = "${session["startTime"]}-${session["endTime"]}";
      if (!grouped.containsKey(key)) {
        grouped[key] = {
          "sessionDate": session["sessionDate"],
          "startTime": session["startTime"],
          "endTime": session["endTime"],
          "attendances": [],
        };
      }
      grouped[key]!['attendances'].addAll(session["attendances"] as List);
    }

    return grouped.values.toList();
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

  void _editAttendance(Map<String, dynamic> attendance) {
    // Düzenleme işlemleri
  }

  String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  String formatTime(String time) {
    try {
      return time.substring(0, 5);
    } catch (e) {
      return time;
    }
  }
}
