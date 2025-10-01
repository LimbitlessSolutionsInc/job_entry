import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../organization/organization.dart';
import '../../../../styles/globals.dart';
import 'package:intl/intl.dart';
import '../../../../src/database/database.dart';
import '../../task_master.dart';

class RouterViewer extends StatefulWidget {
  const RouterViewer({
    Key? key,
    this.callback,
    required this.epic,
    required this.width,
    required this.height,
    this.startProject,
    this.onTap,
  }):super(key: key);

  final HomeCallback? callback;
  final String epic;
  final String? startProject;
  final Function(String project)? onTap;
  final double width;
  final double height;

  @override
  _RouterViewerState createState() => _RouterViewerState();
}

class _RouterViewerState extends State<RouterViewer> {
  dynamic managementData = {};
  String currentEpic = '';
  String child = '';
  StreamSubscription<DatabaseEvent>? completeAdded;

  @override
  void initState() {
    start();
    listenToFirebase();
    super.initState();
  }

  @override
  void dispose() {
    completeAdded?.cancel();
    super.dispose();
  }

  void start() {
    currentEpic = widget.epic;
    child = "managment/Epic/" + currentEpic;
  }

  void listenToFirebase() async {

  }

  List<RouterData> routerData() {
    return [];
  }

  bool allowEdition() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}