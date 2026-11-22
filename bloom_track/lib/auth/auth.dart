import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../session/user_session.dart';
import '../home.dart';

import 'request_reset_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final ApiService _api = ApiService();

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color(0xFFFB6868)),
    );
  }

  void _handleLogin() async {
    final login = _loginController.text.trim();
    final password = _passController.text;

    if (login.isEmpty || password.isEmpty) {
      _showError('Введите логин и пароль');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _api.login(login, password);
      final token = response['token'];
      final user = response['user'];

      if (token == null || user == null) {
        throw Exception('Некорректный ответ сервера');
      }

      await UserSession.instance.save(
        userId: user['id_User'],
        fullName: user['fullName_User'] ?? "Садовод",
        login: user['login'],
        email: user['email'],
        token: token,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      final isNetworkError =
          e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException');
      _showError(
        isNetworkError
            ? 'Нет соединения с сервером'
            : 'Неверный логин или пароль',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRegister() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final login = _loginController.text.trim();
    final password = _passController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        login.isEmpty ||
        password.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    if (!email.contains('@')) {
      _showError('Введите корректный Email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _api.register(
        fullNameUser: fullName,
        login: login,
        password: password,
        email: email,
      );

      final data = response.data.containsKey('data')
          ? response.data['data']
          : response.data;
      final user = data['user'] ?? data;

      await UserSession.instance.save(
        userId: user['id_User'],
        fullName: user['fullName_User'] ?? fullName,
        token: data['token'],
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      final isConflict =
          e.toString().contains('400') || e.toString().contains('409');
      _showError(
        isConflict ? 'Этот логин или Email уже заняты' : 'Ошибка регистрации',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF8B6F47), width: 2),
    );

    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF5D4037), width: 4),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/logo2.png',
                    width: 132,
                    height: 132,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.eco, size: 60, color: Color(0xFF092B03)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Image.asset('images/text_logo.png', height: 45),
              SizedBox(height: 5),
              Text(
                "Гармония ухода за вашими растениями",
                style: TextStyle(color: Color(0xFF6D5A4A), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = true;
                      _nameController.clear();
                      _emailController.clear();
                    }),
                    child: Column(
                      children: [
                        Text(
                          "Вход",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isLogin ? Color(0xFF5D4037) : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 40,
                          color: _isLogin
                              ? Color.fromARGB(255, 203, 250, 85)
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isLogin = false;
                      _loginController.clear();
                      _passController.clear();
                    }),
                    child: Column(
                      children: [
                        Text(
                          "Регистрация",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: !_isLogin ? Color(0xFF5D4037) : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 40,
                          color: !_isLogin
                              ? Color.fromARGB(255, 203, 250, 85)
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: Color(0xFF2C1A21)),
                  cursorColor: Color(0xFF4CAF50),
                  decoration: InputDecoration(
                    labelText: 'Ваше имя',
                    floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),
                    border: inputBorder,
                    focusedBorder: focusedBorder,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Color(0xFF2C1A21)),
                  cursorColor: Color(0xFF4CAF50),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    border: inputBorder,
                    focusedBorder: focusedBorder,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
              ],

              TextField(
                controller: _loginController,
                style: TextStyle(color: Color(0xFF2C1A21)),
                cursorColor: Color(0xFF8B6F47),
                decoration: InputDecoration(
                  labelText: 'Логин',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                style: TextStyle(color: Color(0xFF2C1A21)),
                cursorColor: Color(0xFF8B6F47),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  border: inputBorder,
                  focusedBorder: focusedBorder,
                  enabledBorder: inputBorder,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestResetPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator(color: Color(0xFF4CAF50))
                  : ElevatedButton(
                      onPressed: _isLogin ? _handleLogin : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 203, 250, 85),
                        foregroundColor: Color(0xFF3E2723),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLogin ? "Войти" : "Зарегистрироваться",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
