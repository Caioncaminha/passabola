import 'package:flutter/material.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passa a Bola',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        
        primarySwatch: Colors.purple,
      ),
      home: const MainPage(),
    );
  }
}