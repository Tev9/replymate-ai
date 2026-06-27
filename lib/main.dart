import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const ReplyMateApp());
}

class ReplyMateApp extends StatelessWidget {
  const ReplyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReplyMate AI',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

