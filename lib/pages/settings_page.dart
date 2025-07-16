import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationExpanded = false;
  bool notificationAllowed = true;
  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  String? username;
  String? email;
  String? userImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadNotificationPreference();
    _loadProfile();
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _notificationsPlugin!.initialize(initSettings);
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationAllowed = prefs.getBool('notificationAllowed') ?? true;
    });
  }

  Future<void> _setNotificationPreference(bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationAllowed', allowed);
    setState(() {
      notificationAllowed = allowed;
    });
    if (!allowed && _notificationsPlugin != null) {
      await _notificationsPlugin!.cancelAll();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('All notifications muted.')));
    } else if (allowed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Notifications enabled.')));
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token found');
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['id'];
      final profile = await ProfileService.getProfile(userId);
      setState(() {
        username = profile['username'] ?? 'User';
        email = profile['email'] ?? '';
        userImage = profile['image'];
      });
    } catch (e) {
      setState(() {
        username = 'User';
        email = '';
        userImage = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out successfully')));
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all app data
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App reset! Restart the app to see the permission dialog again.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: CircleBorder(),
                                side: BorderSide(color: Colors.black),
                                padding: EdgeInsets.all(8),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        userImage != null && userImage!.isNotEmpty
                            ? CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.black,
                                backgroundImage: NetworkImage(userImage!),
                              )
                            : CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.black,
                                child: Icon(
                                  Icons.person,
                                  color: lightBlue,
                                  size: 64,
                                ),
                              ),
                        SizedBox(height: 8),
                        Text(
                          username ?? 'Your name',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          email ?? 'Yourname@Gmail.com',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/edit_profile');
                          },
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings List
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      children: [
                        // Notification
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    size: 32,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Notification',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      notificationExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.black,
                                    ),
                                    onPressed: () => setState(
                                      () => notificationExpanded =
                                          !notificationExpanded,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (notificationExpanded)
                                    ToggleButtons(
                                      borderColor: Colors.black,
                                      selectedBorderColor: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      fillColor: Colors.grey[300],
                                      selectedColor: Colors.black,
                                      color: Colors.black,
                                      constraints: BoxConstraints(
                                        minWidth: 64,
                                        minHeight: 36,
                                      ),
                                      isSelected: [
                                        notificationAllowed,
                                        !notificationAllowed,
                                      ],
                                      onPressed: (index) {
                                        _setNotificationPreference(index == 0);
                                      },
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text('Allow'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text('Mute'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.black, thickness: 1),
                        // Reset App (for testing)
                        GestureDetector(
                          onTap: _resetApp,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 32,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Reset App (Testing)',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Colors.black, thickness: 1),
                        // Log Out
                        GestureDetector(
                          onTap: _logout,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 32,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
