import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';
import 'calendar_page.dart';
import 'todo_detail_page.dart';
import 'edit_profile_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  List<Map<String, dynamic>> todos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          CircleAvatar(
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
                            'Your name',
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
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Log Out',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(Duration(milliseconds: 250));
                    _logout(context);
                  },
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTodos,
              child: todos.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Text(
                              'No todos yet! Add your first task.',
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
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Card(
                          color: Colors.white.withOpacity(0.95),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TodoDetailPage(todo: todo),
                                ),
                              );
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
                                      style: TextStyle(
                                        color: Colors.black87,
                                        decoration: todo['completed'] == true
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
                                      color: mediumBlue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      todo['date'] ?? '',
                                      style: TextStyle(color: mediumBlue),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: mediumBlue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      todo['time'] ?? '',
                                      style: TextStyle(color: mediumBlue),
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
              _BottomNavItem(icon: Icons.home, label: 'Home', selected: true),
              // Replace Calendar button with GestureDetector to navigate
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
              _BottomNavItem(
                icon: Icons.access_time,
                label: 'Focus',
                selected: false,
                onTap: () {
                  Navigator.of(context).pushNamed('/pomodoro');
                },
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
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 32),
      title: Text(label, style: TextStyle(fontSize: 18, color: Colors.black)),
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
    return Expanded(
      child: InkWell(
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
      ),
    );
  }
}
