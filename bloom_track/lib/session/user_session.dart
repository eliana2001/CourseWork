import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession instance = UserSession._();
  UserSession._();

  int? userId;
  String? fullName;
  String? login;
  String? email;
  String? token;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> save({
    required int userId,
    required String fullName,
    required String token,
    String? login,
    String? email,
  }) async {
    this.userId = userId;
    this.fullName = fullName;
    this.token = token;
    this.login = login;
    this.email = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('fullName', fullName);
    await prefs.setString('token', token);
    if (login != null) await prefs.setString('login', login);
    if (email != null) await prefs.setString('email', email);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    fullName = prefs.getString('fullName');
    token = prefs.getString('token');
    login = prefs.getString('login');
    email = prefs.getString('email');
  }

  Future<void> clear() async {
    userId = null;
    fullName = null;
    login = null;
    email = null;
    token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
