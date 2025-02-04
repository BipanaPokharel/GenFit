// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/features/presentation/password/password.dart';
import 'package:fyp/features/presentation/signup/signup.dart';
import 'package:fyp/features/workout/presentation/equipment_listing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key, this.email});

  final String? email;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailField =
      TextEditingController(text: widget.email);
  final TextEditingController _passwordField = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  Future<void> _login() async {
    final url = Uri.parse('http://localhost:3000/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailField.text,
        'password': _passwordField.text,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful login
      json.decode(response.body);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      // Navigate to MealPlanner screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                DailyWorkoutsPage(username: _emailField.text)),
      );
    } else {
      // Handle login failure
      final errorData = json.decode(response.body);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${errorData['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      // final authController = ref.read(authProvider.notifier);
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 122, 185, 108),
        appBar: AppBar(
          title: const Text("Workout Buddy"),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Workout Buddy! Your fitness journey starts here.",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailField,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email for workout tracking',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordField,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Secure your workout data',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    helperText:
                        'Must contain at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character.',
                    helperMaxLines: 3,
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 53, 195, 193),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      await _login();

                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Start Workout',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: const Text(
                    'Create a Workout Account',
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
