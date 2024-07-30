// ignore_for_file: prefer_const_constructors

import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/homepagetest.dart';
import 'package:bookshare/tests/screens/Authentication/register.dart';
import 'package:bookshare/tests/screens/userprofile.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';

class ChangeUsernameScreen extends StatefulWidget {
  @override
  _ChangeUsernameScreenState createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _changeUsername() async {
    setState(() {
      _isLoading = true;
    });

    User? user = await getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _apiService.changeUsername(_usernameController.text);
      user.updateUsername(_usernameController.text);
      await saveUser(user, user.token!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePageTest(initialIndex: 3)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update username')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF23232C),
      appBar: AppBar(title: Text('Change Username', style: TextStyle(color: Colors.white),),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF23232C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Enter Your New Username', labelStyle: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _changeUsername,
                    child: Text('Change Username'),
                  ),
          ],
        ),
      ),
    );
  }
}
