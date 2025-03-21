import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoklama_mobil/Services/TeacherServices/CreateLessonServices/CreateLessonServices.dart';

class CreateLessonScreen extends StatefulWidget {
  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  String? userMail;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalWeeksController = TextEditingController();
  final TextEditingController _sessionsController = TextEditingController();
  final TextEditingController _maxAbsenceController = TextEditingController();

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userMail = prefs.getString("user_mail");
    });
    if (userMail != null) {
      final result = await _createLessons(userMail!);
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dersler oluşturulamadı, lütfen tekrar deneyin.'),
          ),
        );
      } else {
        _nameController.text = "";
        _totalWeeksController.text = "";
        _sessionsController.text = "";
        _maxAbsenceController.text = "";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İşlem başarılı')));
      }
    }
  }

  Future<Map<String, dynamic>?> _createLessons(String email) async {
    return createLesson(
      userMail ?? "",
      _nameController.text,
      int.tryParse(_totalWeeksController.text) ?? 0,
      int.tryParse(_sessionsController.text) ?? 0,
      int.tryParse(_maxAbsenceController.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Ders Oluştur'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                SizedBox(height: 24),
                _buildNameField(),
                SizedBox(height: 20),
                _buildNumberInputs(),
                SizedBox(height: 24),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue, width: 4)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.book,
            Colors.blue,
            'Ders Adı: Bu ad, dersin tanımlanması için kullanılır ve kayıt sonrası bu ekrandaki değerler değiştirilemez. Seçiminizi dikkatli yapın.',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            Colors.green,
            'Toplam Hafta: Dersin toplam süresini belirler.',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.school,
            Colors.purple,
            'Haftalık Ders: Her hafta yapılacak ders saati sayısını belirler.',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            Colors.red,
            'Maksimum Devamsızlık: Öğrencinin belirlenen ders saati sınırını aşması durumunda başarısız sayılacağı kriter.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: const Color.fromARGB(255, 246, 243, 243),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Ders Adı',
        prefixIcon: Icon(Icons.book, color: Colors.blue),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen ders adını giriniz';
        }
        return null;
      },
    );
  }

  Widget _buildNumberInputs() {
    return Column(
      children: [
        _buildNumberField(
          controller: _totalWeeksController,
          label: 'Toplam Hafta',
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        _buildNumberField(
          controller: _sessionsController,
          label: 'Haftalık Ders',
          icon: Icons.school,
          color: Colors.purple,
        ),
        SizedBox(height: 16),
        _buildNumberField(
          controller: _maxAbsenceController,
          label: 'Maks. Devamsızlık',
          icon: Icons.access_time,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bu alanı doldurunuz';
        }
        if (int.tryParse(value) == null || int.parse(value) < 1) {
          return 'Geçersiz değer';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.save),
        label: Text('Ders Oluştur', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ders oluşturuluyor...')));
            _loadUserData();
          }
        },
      ),
    );
  }
}
