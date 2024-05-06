// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    String hashedEmail = hashInput(_emailController.text);
    String hashedPassword = hashInput(_passwordController.text);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: hashedEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userData = querySnapshot.docs.first.data();
      bool passwordsMatch = userData != null && (userData as Map<String, dynamic>)['password'] == hashedPassword;
      if (passwordsMatch) {
        bool isAdmin = (userData)['admin'];
        await SettingsManager.setEmail(hashedEmail);
        if (isAdmin) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserHomePage()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

String hashInput(String input) {
  return sha256.convert(utf8.encode(input)).toString();
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