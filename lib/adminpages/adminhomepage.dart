import 'package:flutter/material.dart';
import 'package:pageflipper3/adminpages/addbook.dart';
import 'package:pageflipper3/adminpages/adminsettingspage.dart';
import 'package:pageflipper3/adminpages/adminstorepage.dart';
import 'package:pageflipper3/adminpages/managepurchases.dart';
import 'package:pageflipper3/adminpages/managestore.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.ac_unit, color: Colors.transparent),onPressed: () {},
            ),
            Image.asset('assets/text.png', width: 250),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminSettingsPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: <Widget>[
            _buildButton(context, 'Preview User Store Page', () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminStorePage()));}),
            const SizedBox(height: 15),
            _buildButton(context, 'Add a Book', () {Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage()));}),
            const SizedBox(height: 15),
            _buildButton(context, 'Manage Store Collection', () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManageStorePage()));}),
            const SizedBox(height: 15),
            _buildButton(context, 'Purchase Management', () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManagePurchasePage()));}),
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
          minimumSize: const Size.fromHeight(100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}