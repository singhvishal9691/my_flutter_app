import 'package:flutter/material.dart';
import 'new_loginpage.dart'; // Bhai, check karna file ka naam yahi hai na?

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vishal Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NewLoginPage(), // Ye wahi page hai jo humne abhi banaya
    );
  }
}