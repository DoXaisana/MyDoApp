import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'todo_detail_page.dart';

class CalendarPage extends StatefulWidget {
  final List<Map<String, dynamic>> todos;
  const CalendarPage({Key? key, required this.todos}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);
  final Color transparentBg = const Color(
    0xCC222B45,
  ); // semi-transparent dark blue
  final Color cardBg = Colors.white.withValues(alpha: 0.85);
  final Color cardText = Colors.black87;
  final Color appBarText = Colors.black87;

  List<Map<String, dynamic>> _todosForDay(DateTime day) {
    final dateStr =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    return widget.todos.where((todo) => todo['date'] == dateStr).toList();
  }

  List<Map<String, dynamic>> get _todosForSelectedDay =>
      _todosForDay(_selectedDay ?? _focusedDay);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparentBg,
      appBar: AppBar(
        backgroundColor: lightBlue.withOpacity(0.95),
        elevation: 0,
        iconTheme: IconThemeData(color: appBarText),
        title: Text(
          'Calendar',
          style: TextStyle(color: appBarText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _todosForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: lightBlue.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
              defaultTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              outsideTextStyle: TextStyle(color: Colors.white54),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: TextStyle(
                color: mediumBlue,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _todosForSelectedDay.isEmpty
                ? Center(
                    child: Text(
                      'No todos for this date.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _todosForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final todo = _todosForSelectedDay[index];
                      return Card(
                        color: cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TodoDetailPage(todo: todo),
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              todo['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: cardText,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (todo['description'] != null &&
                                    todo['description'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      todo['description'],
                                      style: TextStyle(color: cardText),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: mediumBlue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      todo['time'],
                                      style: TextStyle(color: cardText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
