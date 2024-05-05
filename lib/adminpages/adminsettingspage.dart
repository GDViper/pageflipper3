// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:pageflipper2/adminpages/adminhomepage.dart';
import 'package:pageflipper2/shared_preferences.dart';
import '../changepassword.dart';
import '../main.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            onTap: () {
              bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
              String newThemeMode = isDarkMode ? "light" : "dark";
              MyApp.themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
              SettingsManager.setThemeMode(newThemeMode);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePassword()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
            },
          ),
        ],
      ),
    );
  }
}
