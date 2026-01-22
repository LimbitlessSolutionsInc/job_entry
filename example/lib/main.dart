import 'package:flutter/material.dart';
import 'package:job_entry/job_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CSS.pinkTheme,
      home: JobScreen(
        size: MediaQuery.sizeOf(context)
      ),
    );
  }
}
