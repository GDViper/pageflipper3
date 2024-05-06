import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class fetchBalance extends StatefulWidget {
  const fetchBalance({super.key});

  @override
  State<fetchBalance> createState() => _fetchBalanceState();
}

class _fetchBalanceState extends State<fetchBalance> {
  List<dynamic> files = [];
  String balance = "Fetching...";

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

Future<void> fetchBalance() async {
    try {
      String? email = "62346245ee91fdb61d9d00f1f655cfdf125746e4ed0eaf22e3c6e0f1619a76bb";
      print('Email: $email');
      var querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs.first;
        setState(() {
          balance = documentSnapshot.data()['balance'].toString();
        });
      } else {
        print('User document not found');
      }
        } catch (e) {
      print('Error fetching balance: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}