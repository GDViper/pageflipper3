import 'package:flutter/material.dart';
import 'package:pageflipper3/adminpages/adminsettingspage.dart';
import 'package:pageflipper3/adminpages/adminstorepage.dart';
import 'package:pageflipper3/adminpages/fileuploader.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/text.png'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AdminSettingsPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              child: Image.asset('assets/logo.png'),
            ),
            Image.asset('assets/text.png'),

            ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: Transform.scale(
                  scale: 2,
                  child: const Icon(Icons.store),
                ),
              ),
              title: Transform.scale(
                scale: 1.2,
                alignment: Alignment.centerLeft,
                child: const Text('Store page'),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AdminStorePage()),
                );
              },
            ),
            ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: Transform.scale(
                  scale: 2,
                  child: const Icon(Icons.note_add),
                ),
              ),
              title: Transform.scale(
                scale: 1.2,
                alignment: Alignment.centerLeft,
                child: const Text('Add book to store'),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FileUploader()),
                );
              },
            ),
            ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: Transform.scale(
                  scale: 2,
                  child: const Icon(Icons.view_timeline),
                ),
              ),
              title: Transform.scale(
                scale: 1.2,
                alignment: Alignment.centerLeft,
                child: const Text('Manage store collection'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: Transform.scale(
                  scale: 2,
                  child: const Icon(Icons.manage_search),
                ),
              ),
              title: Transform.scale(
                scale: 1.2,
                alignment: Alignment.centerLeft,
                child: const Text('Purchase management'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                
              },
              child: const Text('Action 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('Action 2'),
            ),
          ],
        ),
      ),
    );
  }
}