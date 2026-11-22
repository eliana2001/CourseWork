import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'emergency_result_page.dart';

class EmergencyInspectionQuizPage extends StatefulWidget {
  final int plantId;
  final String plantName;
  final int problemId;

  const EmergencyInspectionQuizPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.problemId,
  });

  @override
  State<EmergencyInspectionQuizPage> createState() =>
      _EmergencyInspectionQuizPageState();
}

class _EmergencyInspectionQuizPageState
    extends State<EmergencyInspectionQuizPage> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _showQuiz = false;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _api.getEmergencyProblemDetails(widget.problemId);
      setState(() {
        _details = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onAnswerSelected(dynamic answer) {
    if (answer['id_Problem'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmergencyResultPage(
            plantId: widget.plantId,
            plantName: widget.plantName,
            problemId: answer['id_Problem'],
            solution: _details?['solution'] ?? 'Рекомендации отсутствуют',
          ),
        ),
      );
    } else {
      setState(() => _currentQuestionIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFFFFDD0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }
    if (_details == null) {
      return Scaffold(
        backgroundColor: Color(0xFFFFFDD0),
        body: Center(
          child: Text(
            'Ошибка загрузки',
            style: TextStyle(color: Color(0xFF5D4037)),
          ),
        ),
      );
    }

    final stages = _details!['inspectionStages'] as List<dynamic>;
    final questions = _details!['questions'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        elevation: 0,
        title: Text(
          _showQuiz ? 'Тест' : 'Осмотр',
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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: !_showQuiz
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Этапы осмотра',
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
                        color: Color(0xFFE6FFAA).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF4CAF50),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Проверьте растение:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF092B03),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ...stages
                              .map<Widget>(
                                (stage) => Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4CAF50),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '•',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          stage['text_Stage'],
                                          style: TextStyle(
                                            color: Color(0xFF092B03),
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _showQuiz = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  203,
                                  250,
                                  85,
                                ),
                                foregroundColor: Color(0xFF3E2723),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Я осмотрел(а), начать тест',
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
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentQuestionIndex < questions.length) ...[
                    Text(
                      'Вопрос ${_currentQuestionIndex + 1} из ${questions.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      questions[_currentQuestionIndex]['text_Question'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1A21),
                      ),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: ListView.separated(
                        itemCount:
                            questions[_currentQuestionIndex]['answers'].length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final ans =
                              questions[_currentQuestionIndex]['answers'][idx];
                          return InkWell(
                            onTap: () => _onAnswerSelected(ans),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Color(0xFF4CAF50),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ans['text_Answer'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2C1A21),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else
                    Center(
                      child: Text(
                        'Диагностика завершена',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF2C1A21),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
