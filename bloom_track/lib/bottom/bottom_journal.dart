import 'package:flutter/material.dart';
import '../services/api_service.dart';

class JournalPage extends StatefulWidget {
  final int plantId;
  final String plantName;

  const JournalPage({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ApiService _api = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _api.getPlantHistory(widget.plantId);
      setState(() {
        _history = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить историю';
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCareType(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('полив') || lowerName.contains('water'))
      return Icons.water_drop;
    if (lowerName.contains('подкормк') || lowerName.contains('fertiliz'))
      return Icons.grass;
    if (lowerName.contains('дневник') ||
        lowerName.contains('diary') ||
        lowerName.contains('запис'))
      return Icons.camera_alt;
    return Icons.history;
  }

  Color _getColorForCareType(String typeName) {
    final lowerName = typeName.toLowerCase();
    if (lowerName.contains('полив') || lowerName.contains('water'))
      return Color(0xFF4CAF50);
    if (lowerName.contains('подкормк') || lowerName.contains('fertiliz'))
      return Color(0xFFFFA726);
    if (lowerName.contains('дневник') ||
        lowerName.contains('diary') ||
        lowerName.contains('запис'))
      return Color(0xFF9C27B0);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFDE0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDFDE0),
        elevation: 0,
        title: Text(
          'Журнал: ${widget.plantName}',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C1A21)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Color(0xFF5D4037))),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Повторить'),
                  ),
                ],
              ),
            )
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'История ухода пуста',
                    style: TextStyle(fontSize: 18, color: Color(0xFF5D4037)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Начните поливать или удобрять растение,\nи записи появятся здесь',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
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
                  final typeName = item['typeName'] ?? 'Неизвестно';
                  final careDate = item['careDate'] ?? '';
                  final notes = item['notes'];

                  final icon = _getIconForCareType(typeName);
                  final color = _getColorForCareType(typeName);

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 24),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  typeName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C1A21),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  careDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (notes != null &&
                                    notes.toString().isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      notes,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5D4037),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
