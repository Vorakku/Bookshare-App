import 'package:bookshare/tests/screens/Authentication/login.dart';
import 'package:bookshare/tests/screens/user_controller.dart';
import 'package:flutter/material.dart';

class MyHomePageTest extends StatelessWidget {
  const MyHomePageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserController().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: const Text("Welcome to the Home Page"),
      ),
    );
  }
}
