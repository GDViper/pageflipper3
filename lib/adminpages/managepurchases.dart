// ignore_for_file: avoid_print, unused_import, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pageflipper3/adminpages/addbook.dart';
import 'package:pageflipper3/adminpages/adminhomepage.dart';
import 'package:pageflipper3/adminpages/adminmanagepreview.dart';
import 'package:pageflipper3/adminpages/adminstorepage.dart';
import 'package:pageflipper3/adminpages/adminstorepreview.dart';
import 'package:pageflipper3/adminpages/managestore.dart';
import 'package:pageflipper3/shared_preferences.dart';

class ManagePurchasePage extends StatefulWidget {
  const ManagePurchasePage({super.key});

  @override
  State<ManagePurchasePage> createState() => _ManagePurchasePageState();
}

class _ManagePurchasePageState extends State<ManagePurchasePage> {
  List<dynamic> files = [];
  String? isbn;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('purchases').get();
    files = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/text.png', width: 300),
        centerTitle: true,
        actions: <Widget>[
          Container(),
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
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: files.isEmpty
              ? const Center(child: Text('No files available.'))
              : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  Timestamp timestamp = files[index]['datetime'];
                  DateTime dateTime = timestamp.toDate();
                  String formattedDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);

                  return Card(
                    color: Colors.purple,
                    child: ListTile(
                      title: Text(files[index]['email']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ISBN: ${files[index]['isbn']}'),
                          Text('Datetime: $formattedDateTime'),
                        ],
                      ),
                    ),
                  );
                },
              )
          ),
        ],
      )
    );
  }
}