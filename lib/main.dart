import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pageflipper2/themeprovider.dart';
import 'package:provider/provider.dart';
import 'loginpage.dart';
import 'signuppage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(initialTheme: ThemeMode.system,),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialTheme});
  final ThemeMode initialTheme;

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
            brightness: Brightness.light,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.white,
                shadowColor: Colors.grey,
                elevation: 10,
                shape: const RoundedRectangleBorder(
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.purple,
            brightness: Brightness.dark,
          ),
          themeMode: currentMode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _imageYOffset = 0.0;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1000), _startAnimation);
  }

  void _startAnimation() {
    setState(() {
      _imageYOffset = -44.0;
    });
    Timer(const Duration(milliseconds: 1500), () {
      _navigateToMainScreen(context);
    });
  }

  void _navigateToMainScreen(BuildContext context) {
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 1500),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _imageYOffset, 0),
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              MyApp.themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Image.asset("assets/logo_text.png"),
                ),
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 15),
                _buildButton(context, 'Login', () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                }),
                const SizedBox(height: 20),
                _buildButton(context, 'Sign Up', () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                }),
                Container(height: 20),
              ],
            ),
          ],
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