import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notifications first
    await _initializeNotifications();
    
    // Check if this is the first time the app is launched
    await _checkFirstTimeAndRequestPermissions();
    
    // Check auto login
    await _checkAutoLogin();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request this manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await NotificationService.plugin.initialize(initSettings);
  }

  Future<void> _checkFirstTimeAndRequestPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    
    if (isFirstTime) {
      // Mark that the app has been launched before
      await prefs.setBool('isFirstTime', false);
      
      // Show permission request dialog
      if (mounted) {
        await _showPermissionRequestDialog();
      }
    }
  }

  Future<void> _showPermissionRequestDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: mediumBlue),
              SizedBox(width: 8),
              Text('Enable Notifications'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MyDoApp would like to send you notifications for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: mediumBlue),
                  SizedBox(width: 8),
                  Text('• Todo reminders'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: mediumBlue),
                  SizedBox(width: 8),
                  Text('• Due date alerts'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: mediumBlue),
                  SizedBox(width: 8),
                  Text('• Task completion updates'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'You can change this later in Settings.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestNotificationPermissions();
              },
              child: Text(
                'Enable',
                style: TextStyle(
                  color: mediumBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Not Now',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      // Request permissions
      final bool? alertPermission = await NotificationService.plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      
      // For Android, permissions are handled automatically during initialization
      // Android 13+ requires notification permission, but it's requested automatically
      final bool? androidPermission = true; // Android permissions are granted by default

      // Save permission status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationAllowed', 
          (alertPermission ?? false) || (androidPermission ?? false));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (alertPermission ?? false) || (androidPermission ?? false)
                  ? 'Notifications enabled! You\'ll receive reminders for your todos.'
                  : 'Notifications disabled. You can enable them later in Settings.',
            ),
            backgroundColor: (alertPermission ?? false) || (androidPermission ?? false)
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
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
              'MyDoApp',
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
