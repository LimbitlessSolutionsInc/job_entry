import 'package:flutter/material.dart';
import 'package:job_entry/router.dart';
import 'package:css/css.dart';

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
      home: RouterScreen(
        size: MediaQuery.sizeOf(context)
      ),
    );
  }
}
