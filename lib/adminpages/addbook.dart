// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pageflipper3/permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  File? file;
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _bookSubtitleController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  String _selectedGenre = 'None';
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  @override
  void dispose() {
    _bookTitleController.dispose();
    _bookSubtitleController.dispose();
    _authorsController.dispose();
    _priceController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

    Future<void> pickFile() async {
      if (await requestStoragePermission(Permission.storage)) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          file = File(result.files.single.path!);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected or permission denied.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission not granted.")),
      );
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      String fileName = _isbnController.text;
      Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName.pdf');

      bool fileExists = false;
      await ref.parent!.listAll().then((res) {
        for (var element in res.items) {
          if (element.name == '$fileName.pdf') {
            fileExists = true;
          }
        }
      });

      if (fileExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("A file with the same ISBN already exists.")),
        );
        return;
      }

      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();

      if (!isValidISBN(_isbnController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid ISBN. Please enter a valid ISBN.")),
        );
        return;
      }

      List<String> authors = _authorsController.text.split(',');

      FirebaseFirestore.instance.collection('books').doc(_isbnController.text).set({
        'title': _bookTitleController.text,
        'subtitle': _bookSubtitleController.text,
        'authors': authors,
        'genre': _selectedGenre,
        'price': _priceController.text,
        'isbn': _isbnController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded! Download URL: $downloadURL')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }


  bool isValidISBN(String isbn) {
    if (isbn.length != 10 && isbn.length != 13) {
      return false;
    }
    int total = 0;
    for (int i = 0; i < isbn.length - 1; i++) {
      int digit = int.parse(isbn[i]);
      total += (i % 2 == 0) ? digit * 1 : digit * 3;
    }
    int checksum = int.parse(isbn[isbn.length - 1]);
    int requiredTotal = (isbn.length == 10) ? 11 : 10;
    return (total + checksum) % requiredTotal == 0;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(controller: _bookTitleController, decoration: const InputDecoration(labelText: 'Book Title')),
            TextField(controller: _bookSubtitleController, decoration: const InputDecoration(labelText: 'Book Subtitle')),
            TextField(controller: _authorsController, decoration: const InputDecoration(labelText: 'Author(s)')),
            TextField(controller: _isbnController, decoration: const InputDecoration(labelText: 'ISBN')),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedGenre,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGenre = value!;
                      });
                    },
                    items: <String>[
                      'None',
                      'Literary Fiction',
                      'Science Fiction (Sci-Fi)',
                      'Fantasy',
                      'Nonfiction',
                      'Thriller',
                      'Horror',
                      'Romance',
                      'Historical Fiction',
                      'Adventure',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Genre'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildButton(context, 'Pick PDF', pickFile),
            const SizedBox(height: 20),
            _buildButton(context, 'Upload PDF', () {
              if (_bookTitleController.text.isEmpty ||
                  _authorsController.text.isEmpty ||
                  _isbnController.text.isEmpty ||
                  _selectedGenre == 'None' ||
                  _priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields.")),
                );
                return;
              }

              if (file != null) {
                uploadFile(file!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a file to upload.")),
                );
              }
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onPressed: onPressed as void Function()?,
        child: Text(text),
      ),
    );
  }
}