import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class EmergencyHistoryPage extends StatefulWidget {
  const EmergencyHistoryPage({super.key});

  @override
  State<EmergencyHistoryPage> createState() => _EmergencyHistoryPageState();
}

class _EmergencyHistoryPageState extends State<EmergencyHistoryPage> {
  final ApiService _api = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _api.getDiagnosisHistory();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки истории: $e');
      setState(() => _isLoading = false);
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
          'История диагностики',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C1A21)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'История пуста',
                    style: TextStyle(fontSize: 18, color: Color(0xFF5D4037)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Пройдите диагностику,\nи записи появятся здесь',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: Color(0xFF4CAF50),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  final problemName =
                      item['problemName']?.toString() ?? 'Неизвестно';
                  final plantName =
                      item['plantName']?.toString() ?? 'Растение удалено';
                  final solution =
                      item['solution']?.toString() ?? 'Нет рекомендаций';

                  String formattedDate = 'Дата неизвестна';
                  try {
                    final dateStr = item['date_Diagnostic'];
                    if (dateStr != null) {
                      final date = DateTime.parse(dateStr.toString());
                      formattedDate = DateFormat(
                        'dd.MM.yyyy HH:mm',
                      ).format(date);
                    }
                  } catch (e) {
                    print('Ошибка парсинга даты: $e');
                  }

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Color(0xFFFB6868).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: Color(0xFFFB6868),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        problemName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1A21),
                        ),
                      ),
                      subtitle: Text(
                        '$plantName • $formattedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          color: Color(0xFFFB6868).withOpacity(0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Рекомендации:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF2C1A21),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                solution,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5D4037),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
