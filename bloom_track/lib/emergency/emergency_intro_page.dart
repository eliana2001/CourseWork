import 'package:flutter/material.dart';
import 'emergency_select_plant_page.dart';
import 'emergency_history_page.dart';

class EmergencyIntroPage extends StatelessWidget {
  const EmergencyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        elevation: 0,
        title: Text(
          'Скорая помощь',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF2C1A21)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFFFB6868).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xFFFB6868),
                  size: 64,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Модуль "Скорая помощь"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Этот модуль поможет вам самостоятельно диагностировать проблемы с вашим растением и получить рекомендации по лечению.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5D4037),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Как это работает?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 16),
            _buildStep(1, 'Выберите растение', 'Из вашей коллекции'),
            SizedBox(height: 16),
            _buildStep(2, 'Опишите симптомы', 'Что беспокоит растение?'),
            SizedBox(height: 16),
            _buildStep(3, 'Пройдите тест', 'Ответьте на вопросы об осмотре'),
            SizedBox(height: 16),
            _buildStep(4, 'Получите диагноз', 'Рекомендации по лечению'),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EmergencySelectPlantPage(plantName: ''),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 203, 250, 85),
                  foregroundColor: Color(0xFF3E2723),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Начать диагностику',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyHistoryPage(),
                    ),
                  );
                },
                icon: Icon(Icons.history, color: Color(0xFF5D4037)),
                label: Text(
                  'История диагностики',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF5D4037), width: 2),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 203, 250, 85),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1A21),
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
