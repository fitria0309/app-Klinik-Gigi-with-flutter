import 'package:flutter/material.dart';
import 'package:my_project_pui/loginpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CimmyBeauty Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const LoginPage(), // Ganti dengan login jika perlu
    );
  }
}

