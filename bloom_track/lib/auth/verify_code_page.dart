import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'new_password_page.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});
  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final ApiService _api = ApiService();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Код должен содержать 6 цифр'),
          backgroundColor: Color(0xFFFB6868),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _api.verifyResetCode(widget.email, code);
      if (mounted)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NewPasswordPage(email: widget.email, code: code),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неверный код'),
            backgroundColor: Color(0xFFFB6868),
          ),
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
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDD0),
        title: Text(
          'Подтверждение кода',
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
            Center(child: Icon(Icons.sms, size: 80, color: Color(0xFF8B6F47))),
            SizedBox(height: 32),
            Text(
              'Введите код',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1A21),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Мы отправили 6-значный код на ${widget.email}',
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              cursorColor: Color(0xFF8B6F47),
              style: TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: 'Код',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Color(0xFF8B6F47)),
                counterText: '',
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
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
                        'Подтвердить',
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
