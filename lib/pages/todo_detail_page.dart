import 'package:flutter/material.dart';
import 'edit_todo_page.dart';
import 'package:intl/intl.dart';

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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTodoPage(todo: todo),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 28),
                      tooltip: 'Delete',
                      onPressed: () {
                        // TODO: Implement delete logic
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Deleted!')));
                        Navigator.of(context).pop();
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
                      onPressed: () {
                        // Here you would update the todo in your backend or state
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Marked as complete!')),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                if (todo['completed'] == true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Completed',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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
                      onPressed: null,
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
