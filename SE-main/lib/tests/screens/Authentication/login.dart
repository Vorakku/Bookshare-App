import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/homepagetest.dart';
import 'package:bookshare/tests/screens/Authentication/register.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    dotenv.load();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['API_URL']}/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var userJson = data['user'];
        String token = data['token'];
        User user = User.fromJson(userJson);
        await saveUser(user, token);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePageTest()),
        );
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong Username or Password'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('An error occurred: $e');
      print('Stack trace: $stackTrace');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent, // Transparent to show the gradient behind
              elevation: 0, // Remove the shadow
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login to BookShare',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your Username and Password to login',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          validator: _validateUsername,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF33333D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            hintText: '********',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            suffixIcon: IconButton(
                              color: Colors.white,
                              onPressed: _toggle,
                              icon: Icon(_obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            fillColor: const Color(0xFF33333D),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              await loginUser(
                                  _usernameController.text, _passwordController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Text('Login', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Or', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Text('Register', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
