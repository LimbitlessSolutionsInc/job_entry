// TODO Implement this library.

import 'package:flutter/material.dart';
import '../router.dart';
import '../archive.dart';
import 'package:css/css.dart' as css;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: css.CSS.darkTheme,
      home: const TabBarWidget(),
    );
  }
}

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Routers'),
              Tab(text: 'Archive'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            RouterPage(),
            ArchivePage(),
          ],
        ),
      ),
    );
  }
}
