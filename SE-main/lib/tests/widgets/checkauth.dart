import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/homepagetest.dart';
import 'package:bookshare/tests/screens/Authentication/login.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    User? user = await getUser();
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
