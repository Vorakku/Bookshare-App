import 'package:bookshare/tests/screens/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureTextPassword = true;

  void _toggle() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  bool _obscureTextConfirm = true;

  void _toggleConfirm() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Register API Function
  Future<void> registerUser(String username, String password) async {
    final url = Uri.parse("${dotenv.env['API_URL']}/register");
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'password_confirmation': password,
      }),
    );

    try {
      if (response.statusCode == 201) {
        // Registration successful
        print('User registered successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // Registration failed
        print('Failed to register user');
        print(response.body);
      }
    } catch (e, stackTrace) {
      print('An error occurred: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 1) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        _register();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // Register Function
  void _register() async {
    if (_formKey.currentState!.validate()) {
      await registerUser(_usernameController.text, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Username',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a unique username.',
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
          validator: _validateUsername,
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Password',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a long and strong password that no one can guess!',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
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
          obscureText: _obscureTextPassword,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                  color: Colors.white,
                  _obscureTextPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: _toggle,
            ),
            fillColor: const Color(0xFF33333D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        const Text(
          'Confirm Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            suffixIcon: IconButton(
              icon: Icon(
                  color: Colors.white,
                  _obscureTextConfirm ? Icons.visibility : Icons.visibility_off),
              onPressed: _toggleConfirm,
            ),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF33333D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          obscureText: _obscureTextConfirm,
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) _buildUsernameStep(),
                    if (_currentStep == 1) _buildPasswordStep(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _nextStep,
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
                        child: Text(
                          _currentStep < 1 ? 'Next' : 'Register',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Home Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
