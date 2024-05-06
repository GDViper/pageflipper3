// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unnecessary_string_interpolations

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pageflipper3/book.dart';
import 'package:pageflipper3/pdfviewpage.dart';
import 'package:pageflipper3/adminpages/adminsettingspage.dart';
import 'package:pageflipper3/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminStorePreview extends StatefulWidget {
  final String isbn ;

  const AdminStorePreview({super.key, required this.isbn});

  @override
  _AdminStorePreviewState createState() => _AdminStorePreviewState();
}

class _AdminStorePreviewState extends State<AdminStorePreview> {
  late Future<Book> futureBook;
  String? isbn = SettingsManager.getIsbn();
  bool loading = false;
    
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

  Future<Uint8List> fetchPdf(isbn) async {
    try {
      final ref = FirebaseStorage.instance.ref('uploads/${widget.isbn}.pdf');
      final downloadUrl = await ref.getDownloadURL();
      print('Download URL: $downloadUrl');
      var response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        print('PDF downloaded successfully');
        return response.bodyBytes;
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
    throw Exception('Failed to download PDF');
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${snapshot.data!.title}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${snapshot.data!.authors.join(', ')}', style: const TextStyle(fontSize: 20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Genre: ${snapshot.data!.genre}', style: const TextStyle(fontSize: 20)),
                      Text('Price: ${snapshot.data!.price.toString()}', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: loading ? const CircularProgressIndicator() : _buildButton(context, 'Preview', () async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          final pdfBytes = await fetchPdf(widget.isbn);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PdfViewPage(pdfBytes: pdfBytes)),
                          );
                        } catch (e) {
                          print('An error occurred while trying to fetch the PDF: $e');
                        } finally {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
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
      )
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
        child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(text),
      ),
    );
  }
}