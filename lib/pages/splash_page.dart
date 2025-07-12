import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final token = await AuthService.getToken();
    await Future.delayed(Duration(milliseconds: 800)); // for splash effect
    if (token != null && !JwtDecoder.isExpired(token)) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: lightBlue, size: 80),
            SizedBox(height: 24),
            Text(
              'Todo App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: lightBlue),
          ],
        ),
      ),
    );
  }
}
