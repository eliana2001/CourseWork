import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'management_plants.dart';
import 'bottom_journal.dart';
import '../services/notification_service.dart';

class PlantsPage extends StatefulWidget {
  const PlantsPage({super.key});

  @override
  State<PlantsPage> createState() => _PlantsPageState();
}

class _PlantsPageState extends State<PlantsPage> {
  final ApiService _api = ApiService();
  List<dynamic> _plants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _api.getMyPlants();
      setState(() {
        _plants = response.data;
        _isLoading = false;
      });
      await _checkAndShowNotifications();
    } catch (e) {
      print('Ошибка загрузки растений: $e');
      setState(() {
        _error = 'Добавьте нового друга прямо сейчас!';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndShowNotifications() async {
    await NotificationService.cancelAllNotifications();

    int notificationId = 1;

    for (var plant in _plants) {
      final plantName = plant['name_Plant'] ?? 'Растение';
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

        if (daysLeft <= 0) {
          await NotificationService.showNotification(
            id: notificationId++,
            title: 'Срочный полив!',
            body: '$plantName нуждается в поливе прямо сейчас',
          );
        } else if (daysLeft <= 2) {
          await NotificationService.showNotification(
            id: notificationId++,
            title: 'Скоро полив',
            body: '$plantName нужно полить через $daysLeft дн.',
          );
        }
      } else {
        await NotificationService.showNotification(
          id: notificationId++,
          title: 'Полив не проводился',
          body: '$plantName ещё ни разу не поливали',
        );
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

        if (daysLeft <= 0) {
          await NotificationService.showNotification(
            id: notificationId++,
            title: 'Срочная подкормка!',
            body: '$plantName нуждается в удобрении',
          );
        } else if (daysLeft <= 3) {
          await NotificationService.showNotification(
            id: notificationId++,
            title: 'Скоро подкормка',
            body: '$plantName нужно удобрить через $daysLeft дн.',
          );
        }
      } else {
        await NotificationService.showNotification(
          id: notificationId++,
          title: 'Подкормка не проводилась',
          body: '$plantName ещё ни разу не удобряли',
        );
      }
      final lastPhotoDate = plant['lastPhotoDate'];
      if (lastPhotoDate != null) {
        try {
          final lastPhoto = DateTime.parse(lastPhotoDate);
          final daysSincePhoto = DateTime.now().difference(lastPhoto).inDays;
          if (daysSincePhoto > 30) {
            await NotificationService.showNotification(
              id: notificationId++,
              title: 'Обновите фото',
              body: 'Пора сделать новое фото $plantName для дневника роста',
            );
          }
        } catch (e) {}
      } else {
        await NotificationService.showNotification(
          id: notificationId++,
          title: 'Добавьте фото',
          body: 'Загрузите первое фото $plantName',
        );
      }
    }
  }

  int _calculateDaysUntilWatering(dynamic plant) {
    final lastWateringDateStr = plant['lastWateringDate'];
    if (lastWateringDateStr == null) return 0;

    int interval = 7;
    final typePlant = plant['typePlant'];
    if (typePlant != null &&
        typePlant is Map &&
        typePlant['wateringIntervalDays'] != null) {
      interval = typePlant['wateringIntervalDays'] as int;
    }

    try {
      final lastDate = DateTime.parse(lastWateringDateStr);
      final nextWatering = lastDate.add(Duration(days: interval));
      return nextWatering.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  int _calculateDaysUntilFertilizing(dynamic plant) {
    final lastFertilizingDateStr = plant['lastFertilizingDate'];
    if (lastFertilizingDateStr == null) return 0;

    int interval = 14;
    final typePlant = plant['typePlant'];
    if (typePlant != null &&
        typePlant is Map &&
        typePlant['fertilizingIntervalDays'] != null) {
      interval = typePlant['fertilizingIntervalDays'] as int;
    }

    try {
      final lastDate = DateTime.parse(lastFertilizingDateStr);
      final nextFertilizing = lastDate.add(Duration(days: interval));
      return nextFertilizing.difference(DateTime.now()).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _getPlantTypeName(dynamic plant) {
    final typePlant = plant['typePlant'];
    if (typePlant != null && typePlant is Map) {
      return typePlant['name_TypePlant'] ?? 'Неизвестный вид';
    }
    return 'Неизвестный вид';
  }

  Color _getStatusColor(int days) => days < 0
      ? Color(0xFFFB6868)
      : (days <= 2 ? Color(0xFFFFA726) : Color(0xFF4CAF50));

  Color _getFertilizeColor(int days) => days < 0
      ? Color(0xFFFB6868)
      : (days <= 3 ? Color(0xFFFFA726) : Color(0xFF4CAF50));

  String _getStatusText(int days, bool hasHistory) {
    if (!hasHistory) return 'Полив не проводился';
    if (days < 0) return 'Просрочено на ${-days} дн.';
    if (days == 0) return 'Полив сегодня';
    if (days == 1) return 'Полив завтра';
    return 'Полив через $days дн.';
  }

  String _getFertilizeText(int days, bool hasHistory) {
    if (!hasHistory) return 'Подкормка не проводилась';
    if (days < 0) return 'Подкормка просрочена на ${-days} дн.';
    if (days < 0) return 'Подкормка просрочена на ${-days} дн.';
    if (days == 1) return 'Подкормка завтра';
    return 'Подкормка через $days дн.';
  }

  Widget _buildPlantImage(dynamic photoUrl, Color statusColor) {
    if (photoUrl == null || photoUrl.toString().isEmpty) {
      return Icon(Icons.eco, color: Color(0xFF4CAF50), size: 25);
    }

    String imageUrl = photoUrl.toString();
    if (imageUrl.startsWith('/')) {
      imageUrl = '${ApiService.baseUrl.replaceAll('/api', '')}$imageUrl';
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.eco, color: statusColor, size: 32),
    );
  }

  Widget _buildStatusChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(dynamic plant) {
    final daysUntilWatering = _calculateDaysUntilWatering(plant);
    final daysUntilFertilizing = _calculateDaysUntilFertilizing(plant);
    final statusColor = _getStatusColor(daysUntilWatering);
    final fertilizeColor = _getFertilizeColor(daysUntilFertilizing);
    final typeName = _getPlantTypeName(plant);
    final photoUrl = plant['photoPlant'];
    final hasWateringHistory = plant['lastWateringDate'] != null;
    final hasFertilizingHistory = plant['lastFertilizingDate'] != null;
    bool needsPhotoUpdate = false;
    if (plant['lastPhotoDate'] != null) {
      try {
        final lastPhoto = DateTime.parse(plant['lastPhotoDate']);
        final daysSincePhoto = DateTime.now().difference(lastPhoto).inDays;
        needsPhotoUpdate = daysSincePhoto > 30;
      } catch (e) {
        needsPhotoUpdate = true;
      }
    } else {
      needsPhotoUpdate = true;
    }

    return GestureDetector(
      onTap: () => _showEditPlant(plant),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, statusColor.withOpacity(0.25)],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPlantImage(photoUrl, statusColor),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['name_Plant'] ?? 'Без названия',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1A21),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      typeName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),

                    _buildStatusChip(
                      Icons.water_drop,
                      _getStatusText(daysUntilWatering, hasWateringHistory),
                      statusColor,
                    ),
                    SizedBox(height: 4),
                    _buildStatusChip(
                      Icons.grass,
                      _getFertilizeText(
                        daysUntilFertilizing,
                        hasFertilizingHistory,
                      ),
                      fertilizeColor,
                    ),
                    if (needsPhotoUpdate) ...[
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF9C27B0).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Color(0xFF9C27B0),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Обновить фото',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9C27B0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showWaterDialog(plant),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.water_drop,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showFertilizeDialog(plant),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.grass, color: fertilizeColor, size: 24),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JournalPage(
                            plantId: plant['id_Plant'],
                            plantName: plant['name_Plant'] ?? 'Растение',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.history,
                        color: Color(0xFF5D4037),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      body: SafeArea(
        bottom: false,
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
                         
                          SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(color: Color(0xFF5D4037)),
                          ),
                          SizedBox(height: 16),
                         
                        ],
                      ),
                    )
                  : _plants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'У вас пока нет растений',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Добавьте первое растение!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlants,
                      color: Color(0xFF4CAF50),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _plants.length,
                        itemBuilder: (context, index) =>
                            _buildPlantCard(_plants[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlantDialog,
        backgroundColor: Color.fromARGB(255, 203, 250, 85),
        child: Icon(Icons.add, color: Color(0xFF3E2723)),
      ),
    );
  }

  void _showWaterDialog(dynamic plant) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Color(0xFFFDFDE0),
        title: Text(
          'Полить "${plant['name_Plant']}"?',
          style: TextStyle(color: Color(0xFF2C1A21)),
        ),
        content: Text(
          'Это действие будет записано в журнал ухода.',
          style: TextStyle(color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _api.updateCare(
                  plantId: plant['id_Plant'],
                  lastWateringDate: DateTime.now().toIso8601String().split(
                    'T',
                  )[0],
                  notes: 'Полив через приложение',
                );
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Растение полито! '),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
                _loadPlants();
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при поливе'),
                      backgroundColor: Color(0xFFFB6868),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 203, 250, 85),
              foregroundColor: Color(0xFF3E2723),
            ),
            child: Text('Полить'),
          ),
        ],
      ),
    );
  }

  void _showFertilizeDialog(dynamic plant) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Color(0xFFFDFDE0),
        title: Text(
          'Внести подкормку для "${plant['name_Plant']}"?',
          style: TextStyle(color: Color(0xFF2C1A21)),
        ),
        content: Text(
          'Это действие будет записано в журнал ухода.',
          style: TextStyle(color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _api.updateCare(
                  plantId: plant['id_Plant'],
                  lastFertilizingDate: DateTime.now().toIso8601String().split(
                    'T',
                  )[0],
                  notes: 'Подкормка через приложение',
                );
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Подкормка внесена!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
                _loadPlants();
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при внесении подкормки'),
                      backgroundColor: Color(0xFFFB6868),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 203, 250, 85),
              foregroundColor: Color(0xFF3E2723),
            ),
            child: Text('Внести'),
          ),
        ],
      ),
    );
  }

  void _showEditPlant(dynamic plant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagementPlant(plant: plant, isNewPlant: false),
      ),
    ).then((result) {
      if (result == true) _loadPlants();
    });
  }

  void _showAddPlantDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagementPlant(plant: null, isNewPlant: true),
      ),
    ).then((result) {
      if (result == true) _loadPlants();
    });
  }
}
