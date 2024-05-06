// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unnecessary_string_interpolations

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pageflipper3/book.dart';
import 'package:pageflipper3/adminpages/adminsettingspage.dart';
import 'package:pageflipper3/shared_preferences.dart';

class AdminManagePreview extends StatefulWidget {
  final String isbn ;

  const AdminManagePreview({super.key, required this.isbn});

  @override
  _AdminManagePreviewState createState() => _AdminManagePreviewState();
}

class _AdminManagePreviewState extends State<AdminManagePreview> {
  late Future<Book> futureBook;
  String? isbn = SettingsManager.getIsbn();
  bool loading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController authorsController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController priceController = TextEditingController();

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

    
  @override
  void initState() {
    super.initState();
    String? isbn = SettingsManager.getIsbn();
    if (isbn != null) {
      futureBook = fetchBook(isbn);
    }
  }

  Future<Book> fetchBook(String isbn) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('books').doc(isbn).get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      if (data != null && data.containsKey('title') && data.containsKey('authors') && data.containsKey('genre') && data.containsKey('price')) {
        return Book.fromJson(data);
      }
    }

    throw Exception('Book not found or missing required fields');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
      body: FutureBuilder<Book>(
        future: futureBook,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            titleController.text = snapshot.data!.title;
            authorsController.text = snapshot.data!.authors.join(', ');
            genreController.text = snapshot.data!.genre;
            priceController.text = snapshot.data!.price.toString();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  TextField(
                    controller: authorsController,
                    decoration: const InputDecoration(
                      labelText: 'Authors',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: genreController.text.isEmpty ? null : genreController.text,
                    items: genres.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        genreController.text = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                  const Spacer(),
                  _buildButton(context, 'Edit',
                    () async {
                      await FirebaseFirestore.instance.collection('books').doc(isbn).update({
                        'title': titleController.text,
                        'authors': authorsController.text.split(', ').toList(),
                        'genre': genreController.text,
                        'price': double.parse(priceController.text),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Book updated successfully!')),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    context,
                    'Delete',
                    () async {
                      await FirebaseFirestore.instance.collection('books').doc(isbn).delete();

                      var firebaseStorageRef = FirebaseStorage.instance.ref('uploads/$isbn');
                      await firebaseStorageRef.delete();

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
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