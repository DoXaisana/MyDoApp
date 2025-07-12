import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDark = false;
  bool notificationExpanded = false;
  bool notificationAllowed = true;

  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out successfully')));
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      body: SafeArea(
        child: Column(
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
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: lightBlue, size: 64),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your name',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Yourname@Gmail.com',
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
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Theme
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.brightness_2, size: 32, color: Colors.black),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Theme',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.black),
                        SizedBox(width: 8),
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
                          isSelected: [!isDark, isDark],
                          onPressed: (index) {
                            setState(() {
                              isDark = index == 1;
                            });
                          },
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Light'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Dark'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.black, thickness: 1),
                  // Notification
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                                  setState(() {
                                    notificationAllowed = index == 0;
                                  });
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
                  // Log Out
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 32, color: Colors.black),
                          SizedBox(width: 16),
                          Text(
                            'Log Out',
                            style: TextStyle(fontSize: 22, color: Colors.black),
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
