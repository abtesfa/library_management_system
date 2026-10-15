
import 'package:flutter/material.dart';
import 'screens/public/landing_page.dart';

void main() {
  runApp(const LibraryManagementApp());
}

class LibraryManagementApp extends StatelessWidget {
  const LibraryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library Management System',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0052CC),
        ),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const LandingPage(),
    );
  }
}
