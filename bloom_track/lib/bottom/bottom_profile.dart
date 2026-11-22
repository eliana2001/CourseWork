import 'dart:io';
import 'package:bloom_track/emergency/emergency_intro_page.dart';
import 'package:bloom_track/emergency/emergency_select_plant_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../session/user_session.dart';
import '../auth/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _api = ApiService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isProfileLoading = true;

  File? _avatarFile;
  String? _currentAvatarUrl;
  String? _initialName;
  String? _initialEmail;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = UserSession.instance;

    try {
      final response = await _api.getMyInfo();
      final data = response.data as Map<String, dynamic>;

      final fullName = data['fullName_User'] ?? user.fullName ?? '';
      final email = data['email'] ?? user.email ?? '';
      final login = data['login'] ?? user.login ?? '';

      await user.save(
        userId: data['id_User'] ?? user.userId!,
        fullName: fullName,
        login: login,
        token: user.token!,
        email: email,
      );

      String? avatarUrl;
      final avatarPath = data['avatarUser'];

      if (avatarPath != null && avatarPath.toString().isNotEmpty) {
        String path = avatarPath.toString();
        if (!path.startsWith('http')) {
          String serverRoot = ApiService.baseUrl.replaceAll('/api', '');
          String cleanPath = path.startsWith('/') ? path.substring(1) : path;
          avatarUrl = '$serverRoot/$cleanPath';
        } else {
          avatarUrl = path;
        }
      }

      if (mounted) {
        setState(() {
          _nameController.text = fullName;
          _emailController.text = email;
          _initialName = fullName;
          _initialEmail = email;
          _currentAvatarUrl = avatarUrl;
          _isProfileLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProfileLoading = false);
      }
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _avatarFile = File(image.path));
      }
    } catch (e) {}
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Введите имя', isError: true);
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('Введите email', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _api.updateProfile(
        fullName: name,
        email: email,
        avatar: _avatarFile,
      );

      final data = response.data as Map<String, dynamic>;

      await UserSession.instance.save(
        userId: data['id_User'],
        fullName: data['fullName_User'],
        login: data['login'] ?? UserSession.instance.login ?? '',
        token: UserSession.instance.token ?? '',
        email: data['email'],
      );

      final avatarPath = data['avatarUser'];
      String? newAvatarUrl;
      if (avatarPath != null) {
        final cleanPath = avatarPath.toString().startsWith('/')
            ? avatarPath.substring(1)
            : avatarPath.toString();
        newAvatarUrl =
            '${ApiService.baseUrl.replaceAll('/api', '')}/$cleanPath';
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _avatarFile = null;
          _initialName = name;
          _initialEmail = email;
          _currentAvatarUrl = newAvatarUrl;
        });
        _showSnackBar('Профиль обновлён!');
      }
    } catch (e) {
      String errorMsg = 'Ошибка сохранения';
      if (e.toString().contains('500')) {
        errorMsg = 'Ошибка сервера. Попробуйте позже.';
      } else if (e.toString().contains('Email')) {
        errorMsg = 'Этот email уже используется';
      }
      if (mounted) _showSnackBar(errorMsg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _avatarFile = null;
      _nameController.text = _initialName ?? '';
      _emailController.text = _initialEmail ?? '';
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFFFFDD0),
        title: Text(
          'Выйти из аккаунта?',
          style: TextStyle(color: Color(0xFF2C1A21)),
        ),
        content: Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: Color(0xFF5D4037)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UserSession.instance.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFB6868),
              foregroundColor: Colors.white,
            ),
            child: Text('Выйти'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    if (_isProfileLoading) {
      return Scaffold(
        backgroundColor:Color(0xFFFFFDD0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    final user = UserSession.instance;
    final fullName = user.fullName ?? "Садовод";
    final initials = fullName
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(
        backgroundColor:Color(0xFFFFFDD0),
        elevation: 0,
        title: Text(
          _isEditing ? 'Редактирование профиля' : 'Профиль',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(
                Icons.medical_services,
                color: Color(0xFFFB6868),
                size: 26,
              ),
              tooltip: 'Скорая помощь',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyIntroPage()),
                );
              },
            ),
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF4CAF50)),
              onPressed: () => setState(() => _isEditing = true),
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
                onTap: _isEditing ? _pickAvatar : null,
                child: Stack(
                  children: [
                    Container(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _avatarFile != null
                            ? Image.file(_avatarFile!, fit: BoxFit.cover)
                            : _currentAvatarUrl != null
                            ? Image.network(
                                _currentAvatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(initials),
                              )
                            : _buildAvatarPlaceholder(initials),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF4CAF50),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isEditing) ...[
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Нажмите, чтобы изменить фото',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
            SizedBox(height: 32),
            if (_isEditing)
              _buildField(_nameController, 'Имя', Icons.person)
            else
              _buildInfoBlock(
                icon: Icons.person,
                label: 'Имя',
                value: fullName,
              ),
            SizedBox(height: 16),
            if (_isEditing)
              _buildField(
                _emailController,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              )
            else
              _buildInfoBlock(
                icon: Icons.email,
                label: 'Email',
                value: user.email ?? 'Не указан',
              ),
            SizedBox(height: 16),
            _buildInfoBlock(
              icon: Icons.lock_outline,
              label: 'Логин',
              value: user.login ?? 'Не указан',
              isReadOnly: true,
            ),
            SizedBox(height: 8),
            Text(
              'Логин нельзя изменить',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 32),

            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEditing,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4CAF50),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                255,
                                203,
                                250,
                                85,
                              ),
                              foregroundColor: Color(0xFF3E2723),
                              minimumSize: Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Сохранить',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ] else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: Icon(Icons.logout, color: Color(0xFF3E2723)),
                  label: Text(
                    'Выйти из аккаунта',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 203, 250, 85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String initials) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, size: 50, color: Color.fromARGB(255, 203, 250, 85)),
        SizedBox(height: 8),
        Text(
          initials,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String label,
    required String value,
    bool isReadOnly = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReadOnly ? Colors.grey.shade300 : Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isReadOnly ? Colors.grey : Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isReadOnly ? Colors.grey : Color(0xFF2C1A21),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
    _emailController.dispose();
    super.dispose();
  }
}
