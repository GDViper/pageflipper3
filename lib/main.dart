// ignore_for_file: avoid_print, depend_on_referenced_packages, unused_import

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pageflipper3/firebase_options.dart';
import 'package:pageflipper3/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'loginpage.dart';
import 'signuppage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SettingsManager.initialize();
  String themeModeString = SettingsManager.getThemeMode() ?? 'system';

  ThemeMode initialTheme;
  switch (themeModeString) {
    case 'dark':
      initialTheme = ThemeMode.dark;
      break;
    case 'light':
      initialTheme = ThemeMode.light;
      break;
    default:
      initialTheme = ThemeMode.system;
      break;
  }
  runApp(MyApp(initialTheme: initialTheme));
}

class PermissionsDeniedApp extends StatelessWidget {
  const PermissionsDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Storage permission is required to use this app."),
              ElevatedButton(
                onPressed: () {
                  openAppSettings(); // Open app settings to let the user grant permission
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> requestPermissions() async {
  print("Requesting Storage Permission");
  var status = await Permission.storage.status;
  print("Current Storage Permission Status: ${status.isGranted}");

  if (!status.isGranted) {
    status = await Permission.storage.request();
    print("Storage Permission Status After Request: ${status.isGranted}");
  }
  
  return status.isGranted;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialTheme});
  final ThemeMode initialTheme;

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    themeNotifier.value = initialTheme; // Set the initial theme mode
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
            brightness: Brightness.light,
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
              String newThemeMode = isDarkMode ? "light" : "dark";
              MyApp.themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
              SettingsManager.setThemeMode(newThemeMode);
            },
          )
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