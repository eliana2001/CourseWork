import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class ManagementPlant extends StatefulWidget {
  final dynamic plant;
  final bool isNewPlant;

  const ManagementPlant({
    super.key,
    required this.plant,
    this.isNewPlant = false,
  });

  @override
  State<ManagementPlant> createState() => _ManagementPlantState();
}

class _ManagementPlantState extends State<ManagementPlant> {
  final ApiService _api = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _diaryNoteController = TextEditingController();

  int? _selectedTypeId;
  DateTime _purchaseDate = DateTime.now();
  File? _photoFile;
  bool _isLoading = false;
  bool _isTypesLoading = true;

  List<Map<String, dynamic>> _plantTypes = [];

  @override
  void initState() {
    super.initState();
    _loadPlantTypes();
    if (!widget.isNewPlant) {
      _nameController.text = widget.plant['name_Plant'] ?? '';
      _selectedTypeId = widget.plant['id_TypePlant'];
      if (widget.plant['datePurchase'] != null) {
        _purchaseDate = DateTime.parse(widget.plant['datePurchase']);
      }
    }
  }

  Future<void> _loadPlantTypes() async {
    try {
      final response = await _api.getPlantTypes();
      final List<dynamic> data = response.data;

      setState(() {
        _plantTypes = data
            .map(
              (type) => {
                'id': type['id_TypePlant'],
                'name': type['name_TypePlant'],
              },
            )
            .toList();
        if (widget.isNewPlant &&
            _plantTypes.isNotEmpty &&
            _selectedTypeId == null) {
          _selectedTypeId = _plantTypes.first['id'];
        }

        _isTypesLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки справочника: $e');
      if (mounted) {
        setState(() => _isTypesLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _photoFile = File(image.path));
      }
    } catch (e) {}
  }

  Future<void> _savePlant() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Введите название растения', isError: true);
      return;
    }

    if (_selectedTypeId == null) {
      _showSnackBar('Выберите тип растения', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr = _purchaseDate.toIso8601String().split('T')[0];
      final name = _nameController.text.trim();

      if (widget.isNewPlant) {
        final createResponse = await _api.createPlant(
          namePlant: name,
          idTypePlant: _selectedTypeId!,
          datePurchase: dateStr,
          photoUrl: null,
        );
        final newPlantId = createResponse.data['id_Plant'];
        if (_photoFile != null && newPlantId != null) {
          await _api.uploadPlantPhoto(newPlantId, _photoFile!);
        }

        _showSnackBar('Растение добавлено!');
      } else {
        await _api.updatePlant(
          plantId: widget.plant['id_Plant'],
          namePlant: name,
          idTypePlant: _selectedTypeId!,
          datePurchase: dateStr,
          photoUrl: widget.plant['photoPlant'],
        );

        if (_photoFile != null) {
          await _api.uploadPlantPhoto(widget.plant['id_Plant'], _photoFile!);
        }

        if (_diaryNoteController.text.trim().isNotEmpty) {
          await _api.addDiaryEntry(
            plantId: widget.plant['id_Plant'],
            note: _diaryNoteController.text.trim(),
            photoUrl: null,
          );
        }

        _showSnackBar('Растение обновлено!');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Ошибка сохранения: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Color(0xFFFB6868) : Color(0xFF4CAF50),
      ),
    );
  }

  Future<void> _deletePlant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFFDFDE0),
        title: Text(
          'Удалить растение?',
          style: TextStyle(color: Color(0xFF2C1A21)),
        ),
        content: Text(
          'Это действие нельзя отменить. История ухода также будет удалена.',
          style: TextStyle(color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Удалить',
              style: TextStyle(
                color: Color(0xFFFB6868),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _api.deletePlant(widget.plant['id_Plant']);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) _showSnackBar('Ошибка при удалении', isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFDE0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFDFDE0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF2C1A21)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isNewPlant ? 'Новое растение' : 'Редактирование',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!widget.isNewPlant)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Color(0xFFFB6868)),
              onPressed: _deletePlant,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color.fromARGB(255, 203, 250, 85),
                      width: 2,
                    ),
                  ),
                  child: _photoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_photoFile!, fit: BoxFit.cover),
                        )
                      : widget.plant?['photoPlant'] != null &&
                            widget.plant['photoPlant'].toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.plant['photoPlant'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPhotoPlaceholder(),
                          ),
                        )
                      : _buildPhotoPlaceholder(),
                ),
              ),
            ),
            SizedBox(height: 32),
            if (!widget.isNewPlant) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE6FFAA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF4CAF50), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Фото-дневник роста',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF092B03),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Что изменилось с растением?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5D4037),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _diaryNoteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Например: "Появился новый лист!"',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
            _buildField(_nameController, 'Название растения', Icons.eco),
            SizedBox(height: 16),
            Text(
              'Тип растения',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 8),
            _isTypesLoading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedTypeId,
                        hint: Text(
                          'Выберите вид',
                          style: TextStyle(color: Colors.grey),
                        ),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                          color: Color(0xFF2C1A21),
                          fontSize: 16,
                        ),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                        items: _plantTypes
                            .map(
                              (type) => DropdownMenuItem<int>(
                                value: type['id'],
                                child: Text(type['name']),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedTypeId = val),
                      ),
                    ),
                  ),
            SizedBox(height: 16),
            Text(
              'Дата приобретения',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _purchaseDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF4CAF50),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _purchaseDate = picked);
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Text(
                      '${_purchaseDate.day}.${_purchaseDate.month}.${_purchaseDate.year}',
                      style: TextStyle(color: Color(0xFF2C1A21), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  )
                : ElevatedButton(
                    onPressed: _savePlant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 203, 250, 85),
                      foregroundColor: Color(0xFF3E2723),
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      widget.isNewPlant ? 'Создать' : 'Сохранить',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 50,
          color: Color.fromARGB(255, 203, 250, 85),
        ),
        SizedBox(height: 8),
        Text('Добавить фото', style: TextStyle(color: Color(0xFF3E2723))),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        cursorColor: Color(0xFF4CAF50),
        style: TextStyle(color: Color(0xFF2C1A21)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 203, 250, 85),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diaryNoteController.dispose();
    super.dispose();
  }
}
