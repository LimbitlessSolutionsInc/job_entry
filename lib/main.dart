// TODO Implement this library.

import 'package:flutter/material.dart';
import '../router.dart';
import '../archive.dart';
import '../jobPacket.dart';
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
      theme: css.CSS.lsiTheme,
      home: const TabBarWidget(),
    );
  }
}

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({super.key});

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Routers'),
            Tab(text: 'Job Packets'),
            Tab(text: 'Archive'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.9),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          const RouterPage(),
          const JobPacketPage(),
          const ArchivePage(),
        ],
      ),
    );
  }
}
