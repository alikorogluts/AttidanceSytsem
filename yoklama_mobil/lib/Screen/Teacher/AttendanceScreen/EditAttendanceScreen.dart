import 'package:flutter/material.dart';
import 'package:yoklama_mobil/Models/GetAttendanceListModel.dart'
    as GetAttendanceList;
import 'package:yoklama_mobil/Services/TeacherServices/AttendanceServices/UpdateAttendanceServices.dart';

class EditAttendanceScreen extends StatefulWidget {
  final GetAttendanceList.Attendance attendance;

  const EditAttendanceScreen({Key? key, required this.attendance})
    : super(key: key);

  @override
  _EditAttendanceScreenState createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedStatus;
  late TextEditingController _explanationController;

  String _statusToString(String status) {
    switch (status) {
      case "Present":
        return "Var";
      case "Absent":
        return "Yok";
      case "Excused":
        return "İzinli";
      default:
        return "Bilinmiyor";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green;
      case "Absent":
        return Colors.redAccent;
      case "Excused":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  int _statusStringToInt(String status) {
    switch (status) {
      case "Present":
        return 0;
      case "Absent":
        return 1;
      case "Excused":
        return 2;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = _statusStringToInt(widget.attendance.status);
    _explanationController = TextEditingController(
      text: widget.attendance.explanation ?? '',
    );
  }

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final data = await updateAttendance(
        widget.attendance.attendanceId,
        _selectedStatus,
        _explanationController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data?["message"] ?? "Bir hata oluştu"),
          backgroundColor: data?["success"] == true ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (data?["success"] == true) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Yoklama Düzenle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[850],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[800],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.attendance.student.fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "No: ${widget.attendance.student.studentId}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      widget.attendance.status,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Mevcut Durum: ${_statusToString(widget.attendance.status)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DropdownButtonFormField<int>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850],
                  labelText: 'Yeni Durum Seçiniz',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.grey[850],
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Var')),
                  DropdownMenuItem(value: 1, child: Text('Yok')),
                  DropdownMenuItem(value: 2, child: Text('İzinli')),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              if (_selectedStatus == 2) ...[
                const SizedBox(height: 24),
                TextFormField(
                  controller: _explanationController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[850],
                    labelText: 'İzin Açıklaması',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Değişiklikleri Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
