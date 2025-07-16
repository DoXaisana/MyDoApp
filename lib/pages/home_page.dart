import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';
import 'calendar_page.dart';
import 'todo_detail_page.dart';
import 'edit_profile_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> todos = [];
  bool isLoading = true;
  String? errorMessage;
  String? username;
  String? userImage;

  // Dropdown filter
  final List<String> _filters = [
    'Today',
    'Yesterday',
    'Tomorrow',
    'Last 7 Days',
    'Next 7 Days',
    'All',
  ];
  String _selectedFilter = 'Today';

  List<Map<String, dynamic>> get _filteredTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return todos.where((todo) {
      final dateStr = todo['date'] ?? '';
      if (dateStr.isEmpty) return false;
      DateTime? todoDate;
      try {
        todoDate = DateTime.parse(dateStr);
      } catch (_) {
        return false;
      }
      final diff = todoDate.difference(today).inDays;
      switch (_selectedFilter) {
        case 'Today':
          return diff == 0;
        case 'Yesterday':
          return diff == -1;
        case 'Tomorrow':
          return diff == 1;
        case 'Last 7 Days':
          return diff >= -6 && diff <= 0;
        case 'Next 7 Days':
          return diff >= 0 && diff <= 6;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTodos();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['id'];
      final profile = await ProfileService.getProfile(userId);
      setState(() {
        username = profile['username'] ?? 'User';
        userImage = profile['image'];
      });
    } catch (e) {
      setState(() {
        username = 'User';
        userImage = null;
      });
    }
  }

  Future<void> _loadTodos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // TODO: Replace with actual userId from auth/profile
      final userId = await _getUserId();
      final fetched = await TodoService.fetchTodos(userId);
      setState(() {
        todos = fetched;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading todos: $e');
      setState(() {
        errorMessage = 'Failed to load todos';
        isLoading = false;
      });
    }
  }

  Future<String> _getUserId() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    print('Decoded token: ' + decodedToken.toString()); // Debug print
    // Update the key below if your user ID is under a different field
    final userId = decodedToken['id'];
    if (userId == null)
      throw Exception(
        'User ID not found in token. Check your backend JWT payload.',
      );
    return userId;
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out successfully')));
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  bool _isOverdue(Map<String, dynamic> todo) {
    if (todo['completed'] == true) return false;
    final dateStr = todo['date'] ?? '';
    final timeStr = todo['time'] ?? '';
    if (dateStr.isEmpty || timeStr.isEmpty) return false;
    try {
      final dueDateTime = DateTime.parse('$dateStr $timeStr');
      return dueDateTime.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: mediumBlue,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: lightBlue,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 32),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/edit_profile');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child: Icon(Icons.person, color: Colors.black, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: lightBlue,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        children: [
                          userImage != null && userImage!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 28,
                                  backgroundImage: NetworkImage(userImage!),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 28,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 36,
                                  ),
                                ),
                          SizedBox(width: 16),
                          Text(
                            username ?? 'Your name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: Colors.black38,
                  indent: 0,
                  endIndent: 0,
                ),
                SizedBox(height: 24),
                _DrawerItem(
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Divider(
                  thickness: 1,
                  color: Colors.black38,
                  indent: 16,
                  endIndent: 16,
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  label: 'Setting',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
                Divider(
                  thickness: 1,
                  color: Colors.black38,
                  indent: 16,
                  endIndent: 16,
                ),
                Expanded(child: Container()),
                Divider(
                  thickness: 1,
                  color: Colors.black38,
                  indent: 16,
                  endIndent: 16,
                ),
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(Duration(milliseconds: 250));
                    _logout(context);
                  },
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          // Call your function to fetch profile data here
          _loadProfile();
        }
      },
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Filter:',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(width: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            items: _filters
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      f,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFilter = val;
                                });
                              }
                            },
                            style: TextStyle(color: Colors.black),
                            dropdownColor: lightBlue,
                            icon: Padding(
                              padding: const EdgeInsets.only(
                                left: 2,
                                right: 0,
                                bottom: 1,
                              ),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTodos,
                    child: _filteredTodos.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    'No todos for this filter! Add your first task.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 24, 16, 100),
                            itemCount: _filteredTodos.length,
                            itemBuilder: (context, index) {
                              final todo = _filteredTodos[index];
                              return Card(
                                color: todo['completed'] == true
                                    ? Colors.grey[300]!.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.95),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  leading: GestureDetector(
                                    onTap: () async {
                                      try {
                                        await TodoService.updateTodo(
                                          todo['id'],
                                          {
                                            ...todo,
                                            'completed':
                                                !(todo['completed'] == true),
                                          },
                                        );
                                        setState(() {
                                          todos[index]['completed'] =
                                              !(todo['completed'] == true);
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              todos[index]['completed']
                                                  ? 'Marked as complete!'
                                                  : 'Marked as incomplete!',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to update: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: todo['completed'] == true
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.teal,
                                            size: 28,
                                          )
                                        : Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey,
                                            size: 28,
                                          ),
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                  onTap: () async {
                                    final result = await Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TodoDetailPage(todo: todo),
                                          ),
                                        );
                                    if (result == true) {
                                      _loadTodos();
                                    }
                                  },
                                  title: Text(
                                    todo['title'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: mediumBlue,
                                      decoration: todo['completed'] == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (todo['description'] != null &&
                                          todo['description']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                            bottom: 8.0,
                                          ),
                                          child: Text(
                                            todo['description'],
                                            style: TextStyle(
                                              color: Colors.black87,
                                              decoration:
                                                  todo['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: (todo['completed'] == true)
                                                ? mediumBlue
                                                : _isOverdue(todo)
                                                ? Colors.red
                                                : mediumBlue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            todo['date'] ?? '',
                                            style: TextStyle(
                                              color: (todo['completed'] == true)
                                                  ? mediumBlue
                                                  : _isOverdue(todo)
                                                  ? Colors.red
                                                  : mediumBlue,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 18,
                                            color: (todo['completed'] == true)
                                                ? mediumBlue
                                                : _isOverdue(todo)
                                                ? Colors.red
                                                : mediumBlue,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            todo['time'] ?? '',
                                            style: TextStyle(
                                              color: (todo['completed'] == true)
                                                  ? mediumBlue
                                                  : _isOverdue(todo)
                                                  ? Colors.red
                                                  : mediumBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: lightBlue,
        foregroundColor: Colors.black,
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddTodoPage()));
          if (result == true) {
            _loadTodos();
          }
        },
        child: Icon(Icons.add, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: lightBlue,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: true,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CalendarPage(todos: todos),
                      ),
                    );
                  },
                  child: _BottomNavItem(
                    icon: Icons.calendar_today,
                    label: 'Calendar',
                    selected: false,
                  ),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.access_time,
                  label: 'Focus',
                  selected: false,
                  onTap: () {
                    Navigator.of(context).pushNamed('/pomodoro');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black, size: 32),
      title: Text(
        label,
        style: TextStyle(fontSize: 18, color: textColor ?? Colors.black),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      horizontalTitleGap: 16,
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? Colors.black : Colors.grey[700],
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.grey[700],
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
