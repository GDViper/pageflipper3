// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pageflipper3/adminpages/addbook.dart';
import 'package:pageflipper3/shared_preferences.dart';

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});

  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  List<dynamic> files = [];
  String balance = "Fetching...";

  @override
  void initState() {
    super.initState();
    fetchFiles();
    fetchBalance();
  }

  Future<void> fetchFiles() async {
    try {
      final response = await http.get(Uri.parse('http://$ip:3000/files'));
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          files = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load files with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  Future<void> fetchBalance() async {
    try {
      // Assuming 'username' is stored locally or passed in some way
      String username = "exampleUser";
      final response = await http.get(Uri.parse('http://$ip:3000/balance/$username'));
      if (response.statusCode == 200) {
        setState(() {
          balance = json.decode(response.body)['balance'].toString();
        });
      } else {
        throw Exception('Failed to fetch balance');
      }
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        balance = "Error fetching balance";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/text.png'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: Text("Balance: $balance")),
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
                  MaterialPageRoute(builder: (context) => const AddBookPage()),
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
      body: files.isEmpty
          ? const Center(child: Text('No files available.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(files[index]['filename']),
                    subtitle: Text('Uploaded on: ${files[index]['uploadDate']}'),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
        ],
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.purple,
      ),
    );
  }
}