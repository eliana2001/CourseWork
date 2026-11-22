import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verify_code_page.dart';

class RequestResetPage extends StatefulWidget {
  const RequestResetPage({super.key});
  @override
  State<RequestResetPage> createState() => _RequestResetPageState();
}

class _RequestResetPageState extends State<RequestResetPage> {
  final ApiService _api = ApiService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requestCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите корректный email'),
          backgroundColor: Color(0xFFFB6868),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _api.requestPasswordResetCode(email);
      final demoCode = response['code'] ?? 'Неизвестно';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Код подтверждения: $demoCode'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 15),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyCodePage(email: email)),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Color(0xFFFB6868),
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDD0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        title: Text(
          'Восстановление пароля',
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
            Text(
              'Введите email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Мы отправим код подтверждения для смены пароля',
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Color(0xFF8B6F47),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF8B6F47), width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestCode,
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
                        'Отправить код',
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
