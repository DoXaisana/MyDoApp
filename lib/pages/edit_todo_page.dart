import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/todo_service.dart';
import '../services/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show DateInterpretation, AndroidScheduleMode;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';

class EditTodoPage extends StatefulWidget {
  final Map<String, dynamic> todo;
  const EditTodoPage({Key? key, required this.todo}) : super(key: key);

  @override
  _EditTodoPageState createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isSaving = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _reminderEnabled = false;
  String _reminderChoice = 'None';
  int? _customMinutes;
  final List<String> _reminderOptions = [
    'None',
    '5 min before',
    '10 min before',
    '15 min before',
    '30 min before',
    '1 hour before',
    '1 day before',
    'Custom...',
  ];
  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  final Color lightBlue = Color(0xFFD9ECFA);
  final Color mediumBlue = Color(0xFF5A7292);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo['title'] ?? '');
    _descController = TextEditingController(
      text: widget.todo['description'] ?? '',
    );
    // Parse date and time if present
    final dateStr = widget.todo['date'] ?? '';
    final timeStr = widget.todo['time'] ?? '';
    if (dateStr.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateStr);
      } catch (_) {}
    }
    if (timeStr.isNotEmpty) {
      try {
        final parts = timeStr.split(":");
        if (parts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }
    // --- Remind field initialization ---
    final remind = widget.todo['remind'];
    if (remind != null && remind.toString().isNotEmpty) {
      _reminderEnabled = true;
      if ([
        '5 min before',
        '10 min before',
        '15 min before',
        '30 min before',
        '1 hour before',
        '1 day before',
      ].contains(remind)) {
        _reminderChoice = remind;
        _customMinutes = null;
      } else {
        _reminderChoice = 'Custom...';
        _customMinutes = int.tryParse(remind.toString());
      }
    } else {
      _reminderEnabled = false;
      _reminderChoice = 'None';
      _customMinutes = null;
    }
    _initNotifications();
    tz.initializeTimeZones();
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = NotificationService.plugin;
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

  Future<void> _scheduleReminder(String title, DateTime dueDateTime) async {
    if (!_reminderEnabled || _reminderChoice == 'None') return;
    int minutesBefore = 0;
    switch (_reminderChoice) {
      case '5 min before':
        minutesBefore = 5;
        break;
      case '10 min before':
        minutesBefore = 10;
        break;
      case '15 min before':
        minutesBefore = 15;
        break;
      case '30 min before':
        minutesBefore = 30;
        break;
      case '1 hour before':
        minutesBefore = 60;
        break;
      case '1 day before':
        minutesBefore = 1440;
        break;
      case 'Custom...':
        minutesBefore = _customMinutes ?? 0;
        break;
      default:
        return;
    }
    final scheduledTime = dueDateTime.subtract(
      Duration(minutes: minutesBefore),
    );
    if (scheduledTime.isBefore(DateTime.now())) return;
    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    await _notificationsPlugin?.zonedSchedule(
      tzScheduled.millisecondsSinceEpoch ~/ 1000,
      'Todo Reminder',
      '"$title" is due soon!',
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminder',
          'Todo Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: mediumBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: mediumBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a due date and time.')),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token found');
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['id'];
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr =
          _selectedTime!.hour.toString().padLeft(2, '0') +
          ':' +
          _selectedTime!.minute.toString().padLeft(2, '0');
      print(
        'DEBUG: _reminderEnabled=$_reminderEnabled, _reminderChoice=$_reminderChoice, _customMinutes=$_customMinutes',
      );
      final todo = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'date': dateStr,
        'time': timeStr,
        'completed': widget.todo['completed'] ?? false,
        'userId': userId,
        'remind': (_reminderEnabled && _reminderChoice != 'None')
            ? (_reminderChoice == 'Custom...'
                  ? (_customMinutes?.toString() ?? '')
                  : _reminderChoice)
            : null,
      };
      print('Update Todo payload: $todo');
      await TodoService.updateTodo(widget.todo['id'], todo);
      // Schedule notification
      final dueDateTime = DateTime.parse(dateStr + ' ' + timeStr);
      await _scheduleReminder(_titleController.text.trim(), dueDateTime);
      setState(() {
        _isSaving = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Todo Updated'),
          content: Text(
            'Your todo has been updated!\n\nTitle: \'${_titleController.text}\'\nDate: $dateStr\nTime: $timeStr',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(
                  context,
                ).pop(true); // go back to detail/home, trigger refresh
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update todo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          'Edit Todo',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 600),
            margin: EdgeInsets.symmetric(vertical: 32, horizontal: 0),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today, color: mediumBlue),
                          label: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_selectedDate!),
                          ),
                          onPressed: _pickDate,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mediumBlue,
                            side: BorderSide(color: mediumBlue),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.access_time, color: mediumBlue),
                          label: Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : _selectedTime!.format(context),
                          ),
                          onPressed: _pickTime,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mediumBlue,
                            side: BorderSide(color: mediumBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: _reminderEnabled,
                        onChanged: (val) {
                          setState(() {
                            _reminderEnabled = val;
                            if (!val) _reminderChoice = 'None';
                            print(
                              'DEBUG: Switch changed, _reminderEnabled=$_reminderEnabled, _reminderChoice=$_reminderChoice',
                            );
                          });
                        },
                      ),
                      SizedBox(width: 8),
                      Text('Remind me'),
                      if (_reminderEnabled) ...[
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _reminderChoice,
                            items: _reminderOptions
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt,
                                    child: Text(opt),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) async {
                              if (val == null) return;
                              if (val == 'Custom...') {
                                final minutes = await showDialog<int>(
                                  context: context,
                                  builder: (context) {
                                    int custom = 1;
                                    return AlertDialog(
                                      title: Text('Custom Reminder'),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Minutes before',
                                              ),
                                              onChanged: (v) {
                                                custom = int.tryParse(v) ?? 1;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(custom),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (minutes != null && minutes > 0) {
                                  setState(() {
                                    _reminderChoice = 'Custom...';
                                    _customMinutes = minutes;
                                    print(
                                      'DEBUG: Dropdown changed, _reminderChoice=$_reminderChoice, _customMinutes=$_customMinutes',
                                    );
                                  });
                                }
                              } else {
                                setState(() {
                                  _reminderChoice = val;
                                  print(
                                    'DEBUG: Dropdown changed, _reminderChoice=$_reminderChoice',
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveTodo,
                      child: _isSaving
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 28),
                                SizedBox(width: 8),
                                Text('Save'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
