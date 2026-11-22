import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordPage({super.key, required this.email, required this.code});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final ApiService _api = ApiService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пароль должен содержать минимум 6 символов'),
          backgroundColor: Color(0xFFFB6868),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пароли не совпадают'),
          backgroundColor: Color(0xFFFB6868),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _api.resetPassword(widget.email, widget.code, password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пароль успешно изменён!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Color(0xFFFB6868),
          ),
        );
      }
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
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        title: Text(
          'Новый пароль',
          style: TextStyle(
            color: Color(0xFF2C1A21),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            Center(
              child: Icon(Icons.password, size: 80, color: Color(0xFF8B6F47)),
            ),
            SizedBox(height: 32),
            Text(
              'Придумайте новый пароль',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              cursorColor: Color(0xFF8B6F47),
              style: TextStyle(color: Color(0xFF2C1A21)),
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              cursorColor: Color(0xFF8B6F47),
              style: TextStyle(color: Color(0xFF2C1A21)),
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 203, 250, 85),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Color(0xFF3E2723))
                    : Text(
                        'Сменить пароль',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
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
