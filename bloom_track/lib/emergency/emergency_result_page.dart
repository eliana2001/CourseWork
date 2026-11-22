import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmergencyResultPage extends StatefulWidget {
  final int plantId;
  final String plantName;
  final int problemId;
  final String solution;

  const EmergencyResultPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.problemId,
    required this.solution,
  });

  @override
  State<EmergencyResultPage> createState() => _EmergencyResultPageState();
}

class _EmergencyResultPageState extends State<EmergencyResultPage> {
  final ApiService _api = ApiService();
  bool _isSaving = false;

  Future<void> _saveDiagnosis() async {
    setState(() => _isSaving = true);
    try {
      await _api.submitEmergencyDiagnosis(widget.plantId, widget.problemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Диагностика сохранена!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения'),
            backgroundColor: Color(0xFFFB6868),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        elevation: 0,
        title: Text(
          'Результат',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFB6868).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFFB6868), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFFB6868).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: Color(0xFFFB6868),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Итоговый диагноз вашего растения',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.plantName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1A21),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Рекомендации по лечению:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.solution,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5D4037),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _isSaving
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _saveDiagnosis,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 203, 250, 85),
                        foregroundColor: Color(0xFF3E2723),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Сохранить в историю',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
