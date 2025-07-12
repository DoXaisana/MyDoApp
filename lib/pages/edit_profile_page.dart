import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: 'Your name',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'Yourname@Gmail.com',
  );

  final Color lightBlue = const Color(0xFFD9ECFA);
  final Color mediumBlue = const Color(0xFF5A7292);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mediumBlue,
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: lightBlue, size: 64),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: lightBlue,
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('Save', style: TextStyle(fontSize: 20)),
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
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Profile updated!')),
                          );
                          Navigator.of(context).pop();
                        }
                      },
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
