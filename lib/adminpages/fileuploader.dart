// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pageflipper2/shared_preferences.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MaterialApp(home: FileUploader()));
}

class FileUploader extends StatefulWidget {
  const FileUploader({super.key});

  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  File? file;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  void _uploadFile() async {
    if (file == null) return;
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$ip:3000/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file!.path,
        contentType: MediaType('application', 'pdf'),
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        print('File uploaded!');
      } else {
        print('Failed to upload file.');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Uploader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick PDF'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: const Text('Upload PDF'),
            ),
            const SizedBox(height: 20),
            file != null ? Text('Selected File: ${basename(file!.path)}') : Container(),
          ],
        ),
      ),
    );
  }
}