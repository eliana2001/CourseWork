import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'emergency_inspection_quiz_page.dart';

class EmergencySelectProblemPage extends StatefulWidget {
  final int plantId;
  final String plantName;

  const EmergencySelectProblemPage({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<EmergencySelectProblemPage> createState() =>
      _EmergencySelectProblemPageState();
}

class _EmergencySelectProblemPageState
    extends State<EmergencySelectProblemPage> {
  final ApiService _api = ApiService();
  List<dynamic> _problems = [];
  bool _isLoading = true;
  int? _selectedProblemId;

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  Future<void> _loadProblems() async {
    try {
      final res = await _api.getEmergencyProblems();
      setState(() {
        _problems = res;
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
          widget.plantName,
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
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Что беспокоит растение?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1A21),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _problems.length,
                      itemBuilder: (context, index) {
                        final problem = _problems[index];
                        final isSelected =
                            _selectedProblemId == problem['id_Problem'];

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedProblemId = problem['id_Problem'];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF4CAF50).withOpacity(0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF4CAF50)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Color(0xFF4CAF50)
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 16),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      problem['name'] ?? 'Проблема',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Color(0xFF092B03)
                                            : Color(0xFF2C1A21),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedProblemId == null
                          ? null
                          : () {
                              final problem = _problems.firstWhere(
                                (p) => p['id_Problem'] == _selectedProblemId,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmergencyInspectionQuizPage(
                                        plantId: widget.plantId,
                                        plantName: widget.plantName,
                                        problemId: problem['id_Problem'],
                                      ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 203, 250, 85),
                        foregroundColor: Color(0xFF3E2723),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Далее',
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
