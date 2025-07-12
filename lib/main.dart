import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/add_todo_page.dart';
import 'pages/edit_todo_page.dart';
import 'pages/completed_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/pomodoro_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      initialRoute: '/splash',
      debugShowCheckedModeBanner: true,
      routes: {
        '/splash': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/add_todo': (context) => AddTodoPage(),
        '/edit_todo': (context) => const EditTodoPage(todo: {}),
        '/completed': (context) => CompletedPage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/pomodoro': (context) => PomodoroPage(),
      },
    );
  }
}
