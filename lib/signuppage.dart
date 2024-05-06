// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, depend_on_referenced_packages

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'loginpage.dart';
import 'userhomepage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

Future<void> _signUp() async {
  if (!_validateEmail(_emailController.text) ||
      !_validateUsername(_usernameController.text) ||
      !_validatePassword(_passwordController.text)) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get();

    QuerySnapshot usernameSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _usernameController.text)
        .get();

    if (emailSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already exists')));
      return;
    }

    if (usernameSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
      return;
    }

    // Hash the email, username, and password
    String hashedEmail = hashInput(_emailController.text);
    String hashedUsername = hashInput(_usernameController.text);
    String hashedPassword = hashInput(_passwordController.text);

    final response = await http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDOjlQtsQq9B-uklHyAnHZtQ36Xyx-EkRs'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'returnSecureToken': true,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final userId = responseData['localId'];

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': hashedEmail,
        'username': hashedUsername,
        'password': hashedPassword,
        'admin': false,
        'balance': 50,
      });
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
    } else {
      final errorMessage = jsonDecode(response.body)['error']['message'] ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create account: $errorMessage')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error connecting to server: $e')));
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

String hashInput(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}

bool _validateEmail(String email) {
  if (!email.contains('.')) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email must be valid')));
    return false;
  }
  return true;
}

bool _validateUsername(String username) {
  if (username.length < 8) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username must be at least 8 characters')));
    return false;
  }
  return true;
}

bool _validatePassword(String password) {
  if (password.length < 8 || !password.contains(RegExp(r'\d'))) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 8 characters and contain a number')));
    return false;
  }
  return true;
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
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
              _isLoading ? const CircularProgressIndicator() : _buildButton(context, 'Sign Up', _signUp),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('OR'),
              ),
              const SizedBox(height: 20),
              _buildButton(context, 'Login', () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }),
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