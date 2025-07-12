import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/todo_service.dart';
import '../services/auth_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      final timeStr = _selectedTime!.format(context);
      final todo = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'date': dateStr,
        'time': timeStr,
        'completed': widget.todo['completed'] ?? false,
        'userId': userId,
      };
      await TodoService.updateTodo(widget.todo['id'], todo);
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
