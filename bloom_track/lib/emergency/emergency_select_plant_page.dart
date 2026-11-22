import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'emergency_select_problem_page.dart';

class EmergencySelectPlantPage extends StatefulWidget {
  final String plantName;

  const EmergencySelectPlantPage({super.key, required this.plantName});

  @override
  State<EmergencySelectPlantPage> createState() =>
      _EmergencySelectPlantPageState();
}

class _EmergencySelectPlantPageState extends State<EmergencySelectPlantPage> {
  final ApiService _api = ApiService();
  List<dynamic> _plants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      final res = await _api.getMyPlants();
      setState(() {
        _plants = res.data;
        _isLoading = false;
      });
    } catch (e) {
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
          'Выберите растение',
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
          : _plants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'У вас пока нет растений',
                    style: TextStyle(fontSize: 18, color: Color(0xFF5D4037)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавьте растение в разделе "Растения"',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Какое растение беспокоит?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1A21),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _plants.length,
                      itemBuilder: (context, index) {
                        final plant = _plants[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.eco,
                                color: Color(0xFF4CAF50),
                                size: 30,
                              ),
                            ),
                            title: Text(
                              plant['name_Plant'] ?? 'Без названия',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1A21),
                              ),
                            ),
                            subtitle: Text(
                              plant['typePlant']?['name_TypePlant'] ??
                                  'Неизвестный вид',
                              style: TextStyle(color: Color(0xFF5D4037)),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmergencySelectProblemPage(
                                      plantId: plant['id_Plant'],
                                      plantName:
                                          plant['name_Plant'] ?? 'Растение',
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
