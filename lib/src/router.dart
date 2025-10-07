import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_entry/src/organization/organization.dart';
import 'package:job_entry/src/taskManager/data/jobData.dart';
import 'package:job_entry/src/taskManager/data/processData.dart';
import 'package:job_entry/src/taskManager/example/jobCard.dart';
import 'package:job_entry/src/taskManager/example/processViewer.dart';
import 'package:job_entry/src/taskManager/example/routerViewer.dart';
import 'package:job_entry/src/task_master.dart';
import 'package:job_entry/styles/globals.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RouterScreen extends StatefulWidget {
  RouterScreen({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<RouterScreen> createState() => _RouterScreenState();
}

class _RouterScreenState extends State<RouterScreen> {
  Size currentSize = Size(0, 0);
  bool testing = true;
  String selectedProcess = '';
  String selectedRouter = '';
  List<ProcessData> testProcessList = [];
  List<JobData>? list;
  
  @override
  void initState() {
    currentSize = widget.size;
    deviceWidth = currentSize.width;
    deviceHeight = currentSize.height;
    listenToFirebase();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenToFirebase() async {
    list = <JobData>[];
    if (testing) {
        final String jsonString = await rootBundle.loadString('lib/src/assets/test_data.json');
        final Map<String, dynamic> testData = json.decode(jsonString);

        // Set up router
        final router = testData['router'];
        final testRouterId = router['id'];
        selectedRouter = testRouterId;

        // Set up processes
        final processes = testData['processes'] as List;
        testProcessList = processes.map((p) => ProcessData(
          id: p['id'],
          title: p['title'],
          dateCreated: p['dateCreated'],
          createdBy: p['createdBy'],
          color: p['color'],
        )).toList();
        selectedProcess = testProcessList.first.id!;

        // Set up jobs
        final jobs = testData['jobs'] as List;
        list = jobs.map((j) => JobData(
          id: j['id'],
          title: j['title'],
          dateCreated: j['dateCreated'],
          createdBy: j['createdBy'],
          processId: j['processId'],
          dueDate: j['dueDate'],
          workers: List<String>.from(j['workers']),
          approvers: List<String>.from(j['approvers']),
          status: JobStatus.values.firstWhere((e) => e.toString().split('.').last == j['status']),
          good: j['good'],
          bad: j['bad'],
          isApproved: j['isApproved'],
          isArchive: j['isArchive'],
          notes: j['notes'] as Map<String, dynamic>?,
        )).toList();

        setState(() {});
      } else {

      }
  }

  @override
  Widget build(BuildContext context) {
    currentSize = MediaQuery.sizeOf(context);
    deviceHeight = currentSize.height;
    deviceWidth = currentSize.width;

    return Scaffold(
      body: SizedBox(
        height: deviceHeight,
        width: deviceWidth,
        child: Row(
          children: [
            SizedBox(
              width: deviceWidth * 0.20,
              height: deviceHeight,
              child: RouterViewer(
                epic: selectedRouter,
                width: deviceWidth * 0.20,
                height: deviceHeight,
              ),
            ),
            SizedBox(
              width: deviceWidth * 0.80,
              height: deviceHeight,
              child: ProcessViewer(
                router: selectedRouter,
                width: deviceWidth * 0.80,
                height: deviceHeight,
                color: 1,
              ),
            )
          ]
        )
      )
    );
  }
}