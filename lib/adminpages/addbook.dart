// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../permission_handler/permission_handler.dart';
import '../shared_preferences.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  File? file;
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorsController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorsController.dispose();
    _genreController.dispose();
    _languageController.dispose();
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
          const SnackBar(content: Text("No file selected or permission denied."))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission not granted."))
      );
    }
  }

  Future<void> uploadFile() async {
    if (file != null) {
      var uri = Uri.parse('http://$ip:3000/upload');
      var request = http.MultipartRequest('POST', uri)
        ..fields['bookName'] = _bookNameController.text
        ..fields['authors'] = _authorsController.text
        ..fields['genre'] = _genreController.text
        ..fields['language'] = _languageController.text
        ..fields['isbn'] = _isbnController.text
        ..files.add(await http.MultipartFile.fromPath('file', file!.path));


      try {
        var response = await request.send().timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully')));
        } else {
          var responseBody = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file: $responseBody')));
        }
      } on TimeoutException {
        print('The connection has timed out, please try again!');
      } catch (e) {
        print('An error occurred: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No file selected.")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(controller: _bookNameController, decoration: const InputDecoration(labelText: 'Book Name')),
            TextField(controller: _authorsController, decoration: const InputDecoration(labelText: 'Author(s)')),
            Row(
              children: <Widget>[
                Expanded(child: TextField(controller: _genreController, decoration: const InputDecoration(labelText: 'Genre'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _languageController, decoration: const InputDecoration(labelText: 'Language'))),
              ],
            ),
            TextField(controller: _isbnController, decoration: const InputDecoration(labelText: 'ISBN')),
            const SizedBox(height: 20),
            _buildButton(context, 'Pick PDF', pickFile),
            const SizedBox(height: 20),
            _buildButton(context, 'Upload PDF', file != null ? uploadFile : null),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback? onPressed) {
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