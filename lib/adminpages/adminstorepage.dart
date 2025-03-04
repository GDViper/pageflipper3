// ignore_for_file: avoid_print, unused_import, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pageflipper3/adminpages/addbook.dart';
import 'package:pageflipper3/adminpages/adminhomepage.dart';
import 'package:pageflipper3/adminpages/adminstorepreview.dart';
import 'package:pageflipper3/adminpages/managepurchases.dart';
import 'package:pageflipper3/adminpages/managestore.dart';
import 'package:pageflipper3/shared_preferences.dart';

class AdminStorePage extends StatefulWidget {
  const AdminStorePage({super.key});

  @override
  State<AdminStorePage> createState() => _AdminStorePageState();
}

class _AdminStorePageState extends State<AdminStorePage> {
  List<dynamic> files = [];
  List<String> selectedGenres = [];
  List<String> genres = [
    'Literary Fiction',
    'Science Fiction (Sci-Fi)',
    'Fantasy',
    'Nonfiction',
    'Thriller',
    'Horror',
    'Romance',
    'Historical Fiction',
    'Adventure',
  ];
  bool showGenres = false;
  String? isbn;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    try {
      CollectionReference filesRef = FirebaseFirestore.instance.collection('books');
      QuerySnapshot querySnapshot = await filesRef.get();
      List<DocumentSnapshot> allFiles = querySnapshot.docs;

      List<DocumentSnapshot> filteredFiles = allFiles.where((file) {
        Map<String, dynamic>? data = file.data() as Map<String, dynamic>?;
        if (data == null) return false;

        bool genreMatch = selectedGenres.isEmpty || selectedGenres.contains(data['genre']);

        return genreMatch;
      }).toList();

      setState(() {
        files = filteredFiles;
      });
    } catch (e) {
      print('Error fetching files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/text.png', width: 300),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                showGenres = !showGenres;
              });
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminHomePage()),
                  );
                },
                child: Image.asset('assets/logo.png'),
              ),
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
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const ManageStorePage()),
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
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ManagePurchasePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
  children: [
    if (showGenres)
      Row(
        children: [
          DropdownButton<String>(
            items: genres.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                if (selectedGenres.contains(newValue)) {
                  selectedGenres.remove(newValue);
                } else {
                  selectedGenres.add(newValue!);
                }
                fetchFiles();
              });
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedGenres.clear();
                fetchFiles();
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      Expanded(
        child: files.isEmpty
          ? const Center(child: Text('No files available.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.purple,
                  child: TextButton(
                    onPressed: () async {
                      String? isbn = files[index]['isbn'];
                      if (isbn != null) {
                        await SettingsManager.setIsbn(isbn);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminStorePreview(isbn: isbn)));
                      }
                    },
                    child: ListTile(
                      title: Text(files[index]['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${files[index]['authors']}'),
                          Text('ISBN: ${files[index]['isbn']}'),
                          Text('Genre: ${files[index]['genre']}'),
                          Text('Price: ${files[index]['price'].toString()}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ]
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
      )
    );
  }
}