import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final ApiService _api = ApiService();
  List<dynamic> _plants = [];
  bool _isLoading = true;
  String? _error;
  int _totalPlants = 0;
  int _needWatering = 0;
  int _needFertilizing = 0;
  int _overdueWatering = 0;
  int _overdueFertilizing = 0;
  int _needPhotoUpdate = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _api.getMyPlants();
      final plants = response.data as List<dynamic>;

      int watering = 0;
      int fertilizing = 0;
      int overdueWater = 0;
      int overdueFert = 0;
      int photoUpdate = 0;

      for (var plant in plants) {
        final lastWatering = plant['lastWateringDate'];
        if (lastWatering != null) {
          final lastDate = DateTime.parse(lastWatering);
          int interval = 7;
          final typePlant = plant['typePlant'];
          if (typePlant != null &&
              typePlant is Map &&
              typePlant['wateringIntervalDays'] != null) {
            interval = typePlant['wateringIntervalDays'] as int;
          }
          final nextWatering = lastDate.add(Duration(days: interval));
          final daysLeft = nextWatering.difference(DateTime.now()).inDays;

          if (daysLeft <= 0)
            overdueWater++;
          else if (daysLeft <= 2)
            watering++;
        } else {
          overdueWater++;
        }
        final lastFertilizing = plant['lastFertilizingDate'];
        if (lastFertilizing != null) {
          final lastDate = DateTime.parse(lastFertilizing);
          int interval = 14;
          final typePlant = plant['typePlant'];
          if (typePlant != null &&
              typePlant is Map &&
              typePlant['fertilizingIntervalDays'] != null) {
            interval = typePlant['fertilizingIntervalDays'] as int;
          }
          final nextFertilizing = lastDate.add(Duration(days: interval));
          final daysLeft = nextFertilizing.difference(DateTime.now()).inDays;

          if (daysLeft <= 0)
            overdueFert++;
          else if (daysLeft <= 3)
            fertilizing++;
        } else {
          overdueFert++;
        }
        final lastPhotoDate = plant['lastPhotoDate'];
        if (lastPhotoDate != null) {
          try {
            final lastPhoto = DateTime.parse(lastPhotoDate);
            final daysSincePhoto = DateTime.now().difference(lastPhoto).inDays;
            if (daysSincePhoto > 30) photoUpdate++;
          } catch (e) {
            photoUpdate++;
          }
        } else {
          photoUpdate++;
        }
      }

      setState(() {
        _plants = plants;
        _totalPlants = plants.length;
        _needWatering = watering;
        _needFertilizing = fertilizing;
        _overdueWatering = overdueWater;
        _overdueFertilizing = overdueFert;
        _needPhotoUpdate = photoUpdate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Отсутствует статистика. Необходимо сначала добавить растение';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Row(
                children: [
                  Image.asset(
                    'images/text_logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.eco, size: 32, color: Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.error_outline,
                          //   size: 64,
                          //   color: Colors.grey[400],
                          // ),
                          // SizedBox(height: 16),
                          // Text(
                          //   _error!,
                          //   style: TextStyle(color: Color(0xFF5D4037)),
                          // ),
                          // SizedBox(height: 16),
                          // ElevatedButton(
                          //   onPressed: _loadStatus,
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color(0xFF4CAF50),
                          //     foregroundColor: Colors.white,
                          //   ),
                          //   child: Text('Повторить'),
                          // ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStatus,
                      color: Color(0xFF4CAF50),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Статус вашего сада',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1A21),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Сводка на ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
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
                                      Text(
                                        'Умные рекомендации',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF092B03),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  if (_overdueWatering > 0)
                                    _buildRecommendation(
                                      'Срочно полейте $_overdueWatering растений!',
                                      'Просроченный полив может навредить корневой системе',
                                    ),
                                  if (_overdueFertilizing > 0)
                                    _buildRecommendation(
                                      'Внесите подкормку для $_overdueFertilizing растений',
                                      'Растения нуждаются в дополнительных питательных веществах',
                                    ),
                                  if (_needPhotoUpdate > 0)
                                    _buildRecommendation(
                                      'Обновите фото для $_needPhotoUpdate растений',
                                      'Это поможет визуально отслеживать динамику роста',
                                    ),
                                  if (_overdueWatering == 0 &&
                                      _overdueFertilizing == 0 &&
                                      _needPhotoUpdate == 0)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF4CAF50),
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Всё отлично! Ваши растения под надёжным контролем',
                                            style: TextStyle(
                                              color: Color(0xFF092B03),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24),
                            Text(
                              'Общая статистика',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C1A21),
                              ),
                            ),
                            SizedBox(height: 16),

                            _buildStatCard(
                              'Всего растений',
                              _totalPlants.toString(),
                              Icons.eco,
                              Color(0xFF4CAF50),
                              'Ваших зелёных питомцев',
                            ),
                            SizedBox(height: 16),

                            _buildStatCard(
                              'Требуют полива',
                              _overdueWatering > 0
                                  ? '$_overdueWatering'
                                  : '$_needWatering',
                              Icons.water_drop,
                              _overdueWatering > 0
                                  ? Color(0xFFFB6868)
                                  : Color(0xFFFFA726),
                              _overdueWatering > 0
                                  ? 'Полив просрочен!'
                                  : 'Нужно полить в ближайшие 2 дня',
                              subtitle: _overdueWatering > 0
                                  ? '$_overdueWatering растений ждут воду'
                                  : null,
                            ),
                            SizedBox(height: 16),

                            _buildStatCard(
                              'Требуют подкормки',
                              _overdueFertilizing > 0
                                  ? '$_overdueFertilizing'
                                  : '$_needFertilizing',
                              Icons.grass,
                              _overdueFertilizing > 0
                                  ? Color(0xFFFB6868)
                                  : Color(0xFFFFA726),
                              _overdueFertilizing > 0
                                  ? 'Подкормка просрочена!'
                                  : 'Нужно удобрить в ближайшие 3 дня',
                              subtitle: _overdueFertilizing > 0
                                  ? '$_overdueFertilizing растений нуждаются в питании'
                                  : null,
                            ),
                            SizedBox(height: 16),

                            _buildStatCard(
                              'Требуют обновления фото',
                              _needPhotoUpdate.toString(),
                              Icons.camera_alt,
                              Color(0xFF9C27B0),
                              'Пора сделать новые снимки',
                              subtitle: 'Для фото-дневника роста',
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String description, {
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF092B03),
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Divider(height: 24, color: Color(0xFF4CAF50), thickness: 1),
        ],
      ),
    );
  }
}
