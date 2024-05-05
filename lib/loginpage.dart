// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pageflipper3/shared_preferences.dart';
import 'signuppage.dart';
import 'userhomepage.dart';
import 'adminpages/adminhomepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });
  try {
    final response = await http.post(
      Uri.parse('http://$ip:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': _usernameController.text,  // Assuming you use the same controller for email
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['isAdmin']) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
      }
    } else {
      final message = jsonDecode(response.body)['message'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to login: $message')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error connecting to server: $e')));
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_text.png'),
                const SizedBox(height: 20),
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
                const SizedBox(height: 20),
                _isLoading ? const CircularProgressIndicator() : _buildButton(context, 'Login', _login),
                const SizedBox(height: 20),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('OR'),
                ),
                const SizedBox(height: 20),
                _buildButton(context, 'Sign Up', () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpPage()));}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}