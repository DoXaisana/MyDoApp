import 'package:flutter/material.dart';
import 'edit_todo_page.dart';
import 'package:intl/intl.dart';
import '../services/todo_service.dart';

class TodoDetailPage extends StatelessWidget {
  final Map<String, dynamic> todo;
  const TodoDetailPage({Key? key, required this.todo}) : super(key: key);

  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  @override
  Widget build(BuildContext context) {
    final dateStr = todo['date'] ?? '';
    final timeStr = todo['time'] ?? '';
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(dateStr);
        formattedDate = DateFormat('EEEE, MMM d').format(date);
      } catch (_) {
        formattedDate = dateStr;
      }
    }
    String display = formattedDate.isNotEmpty && timeStr.isNotEmpty
        ? '$formattedDate | $timeStr'
        : formattedDate.isNotEmpty
        ? formattedDate
        : timeStr;
    return Scaffold(
      backgroundColor: mediumBlue,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: lightBlue,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    todo['title'] ?? 'Todo Detail',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.black),
                      tooltip: 'Edit',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTodoPage(todo: todo),
                          ),
                        );
                        if (result == true) {
                          Navigator.of(context).pop(true); // trigger refresh
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 28),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Todo'),
                            content: Text(
                              'Are you sure you want to delete this todo?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await TodoService.deleteTodo(todo['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Todo deleted!')),
                            );
                            Navigator.of(
                              context,
                            ).pop(true); // pop detail page, trigger refresh
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete todo: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          toolbarHeight: 70,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: mediumBlue,
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 600),
            margin: EdgeInsets.symmetric(vertical: 32, horizontal: 0),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  todo['title'] ?? '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mediumBlue,
                    decoration: todo['completed'] == true
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  display,
                  style: TextStyle(
                    fontSize: 18,
                    color: mediumBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (todo['remind'] != null &&
                    todo['remind'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Colors.teal,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Reminder: ${todo['remind']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.teal[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 24),
                Text(
                  'Detail:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mediumBlue,
                    fontSize: 16,
                  ),
                ),
                Divider(thickness: 1, color: Colors.grey[300]),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 24),
                  child: Text(
                    (todo['description'] ?? '').isNotEmpty
                        ? todo['description']
                        : 'No details',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87,
                      decoration: todo['completed'] == true
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Spacer(),
                if (todo['completed'] != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check_circle, size: 28),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Mark Complete',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await TodoService.updateTodo(todo['id'], {
                            ...todo,
                            'completed': true,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Marked as complete!')),
                          );
                          Navigator.of(context).pop(true); // trigger refresh
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to mark complete: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if (todo['completed'] == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.undo, color: Colors.white, size: 28),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Unmark Complete',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await TodoService.updateTodo(todo['id'], {
                            ...todo,
                            'completed': false,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Marked as incomplete!')),
                          );
                          Navigator.of(context).pop(true); // trigger refresh
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to unmark complete: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
