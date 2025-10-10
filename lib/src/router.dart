import 'package:flutter/material.dart';
import 'package:job_entry/src/organization/organization.dart';
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
      currentUser = UsersProfile(
        uid: 'testUser',
        displayName: 'Test User',
        imageUrl: null,
        status: OrgStatus.admin,
      );

      final String jsonString = await rootBundle.loadString('lib/src/assets/test_data.json');
      final Map<String, dynamic> testData = json.decode(jsonString);

      final routerMap = testData['router'] as Map<String, dynamic>;
      final routerKey = routerMap.keys.first;
      final router = routerMap[routerKey];

      selectedRouter = routerKey;

      final processesMap = router['processes'] as Map<String, dynamic>;
      testProcessList = processesMap.entries.map((entry) {
        final details = entry.value['details'];
        return ProcessData(
          id: entry.key,
          title: details['title'],
          dateCreated: details['dateCreated'],
          createdBy: details['createdBy'],
          color: details['color'],
        );
      }).toList();
      selectedProcess = testProcessList.isNotEmpty ? testProcessList.first.id! : '';

      final jobsMap = router['jobs'] as Map<String, dynamic>;
      list = jobsMap.entries.map((entry) {
        final j = entry.value;
        return JobData(
          id: entry.key,
          title: j['title'],
          dateCreated: j['dateCreated'],
          createdBy: j['createdBy'],
          processId: j['processId'],
          dueDate: j['dueDate'],
          completeDate: j['completeDate'],
          workers: List<String>.from(j['workers']),
          approvers: List<String>.from(j['approvers']),
          status: JobStatus.values.firstWhere((e) => e.toString().split('.').last == j['status']),
          good: j['good'],
          bad: j['bad'],
          isApproved: j['isApproved'],
          isArchive: j['isArchive'],
          notes: (j['notes'] != null) ? Map<String, dynamic>.from(j['notes']) : null,
          prevJobs: (j['prevJobs'] != null) ? Map<String, dynamic>.from(j['prevJobs']) : null,
        );
      }).toList();

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