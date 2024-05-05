// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(Permission permission) async {
  if (Platform.isAndroid && int.parse(Platform.operatingSystemVersion.split(" ")[1]) >= 30) {
    var result = await Permission.manageExternalStorage.request();
    if (result.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class PermissionHandlerUtil extends StatelessWidget {
  const PermissionHandlerUtil({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage Permission'),),
      body: Center(child: ElevatedButton(onPressed: () async {
        if (await requestStoragePermission(Permission.storage) == true) {
          print('Permission Granted');
        } else {
          print('Permission Denied');
        }
      },
      child: Text('Request Permission'))),
    );
  }

  static Future<bool> checkPermission(Permission permission) async {
    var status = await permission.status;
    return status.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}