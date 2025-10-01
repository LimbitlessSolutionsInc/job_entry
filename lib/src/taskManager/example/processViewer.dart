import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../styles/savedWidgets.dart';

import '../../task_master.dart';
import '../../organization/organization.dart';
import '../../functions/lsi_functions.dart';

import '../../../styles/circles.dart';
import '../../../styles/globals.dart';

import '../../database/push.dart';
import '../../database/database.dart';

class ProcessViewer extends StatefulWidget {
  const ProcessViewer({
    Key? key,
    this.callback,
    required this.router,
    required this.width,
    required this.height,
    this.isMobile = false,
    required this.color,
    this.completeData,
  }):super(key: key);

  final HomeCallback? callback;
  final String router;
  final double width;
  final double height;
  final bool isMobile;
  final int color;
  final dynamic completeData;

  @override
  _ProcessViewerState createState() => _ProcessViewerState();
}

class _ProcessViewerState extends State<ProcessViewer> {
  bool testing = true;
  String selectedRouter = '';
  String child = '';
  bool update = false;
  bool hasStarted = false;
  List<DropDownItems> dropDownNames = [];

  double startingWidth = deviceWidth;

  StreamSubscription<DatabaseEvent>? processAdded;
  StreamSubscription<DatabaseEvent>? jobAdded;

  Map<String, ProcessData> currentProcessData = {};
  Map<String, JobData> currentJobData = {};
  int color = lightBlue.value;
  dynamic completedJobs;
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      start();
    });
    
    super.initState();
  }

  @override
  void dispose() {
    processAdded?.cancel();
    jobAdded?.cancel();
    super.dispose();
  }

  void callback() {
    setState(() {
      update = false;
    });
  }

  void firebaseReset() {
    currentProcessData = {};
    currentJobData = {};
    hasStarted = false;

    completedJobs = null;
    update = true;

    processAdded?.cancel();
    jobAdded?.cancel();
  }

  void start() async {
    firebaseReset();
    completedJobs = widget.completeData;
    color = widget.color;
    startingWidth = widget.width;
    selectedRouter = widget.router;

    // fill this with the correct route to the selected project
    child = "management/$selectedRouter";

    dropDownNames = [DropDownItems(value: '', text: 'Pick a Person')];
    // populate the drop down items based on who can edit this router

    listenToFirebase();
    setState(() {

    });
  }

  void listenToFirebase() {
    if (testing) {

    } else {

    }
  }

  // TODO: add editing and viewing perms
  bool allowEditing() {
    return true;
  }

  bool allowView() {
    return true;
  }

  Map<String, ProcessData> processData(dynamic routerProcessData) {
    Map<String, ProcessData> data = {};
    if (routerProcessData != null) {
      for (String key in routerProcessData.keys) {
        data[key] = ProcessData(
          id: key,
          title: routerProcessData[key]['title'],
          createdBy: routerProcessData[key]['createdBy'],
          dateCreated: routerProcessData[key]['dateCreated'],
          isArchive: (routerProcessData[key]['isArchive'] == null)
            ? false
            : routerProcessData[key]['isArchive'],
          index: routerProcessData[key]['index'],
        );
      }
    }
    return data;
  }

  Map<String, JobData> jobData(dynamic routerJobData) {
    Map<String, JobData> data = {};
    if (routerJobData != null) {
      for (String key in routerJobData.keys) {
        List<String> workers = [];
        if(routerJobData[key]['data']['workers'] != null) {
          for(int i = 0; i < routerJobData[key]['data']['workers'].length;i++) {
            workers.add(routerJobData[key]['data']['workers'][i]);
          }
        }

        List<String> approvers = [];
        if(routerJobData[key]['data']['approvers'] != null){
          for(int i = 0; i < routerJobData[key]['data']['approvers'].length;i++){
            approvers.add(routerJobData[key]['data']['approvers'][i]);
          }
        }

        List<String> jobs = [];
        if(routerJobData[key]['data']['jobs'] != null){
          for(int i = 0; i < routerJobData[key]['data']['jobs'].length;i++){
            jobs.add(routerJobData[key]['data']['jobs'][i]);
          }
        }

        data[key] = JobData(
          id: key,
          title: routerJobData[key]['data']['title'],
          createdBy: routerJobData[key]['data']['createdBy'],
          dateCreated: routerJobData[key]['data']['dateCreated'],
          dueDate: routerJobData[key]['data']['dueDate'],
          workers: workers,
          approvers: approvers,
          notes: LSIFunctions.getFromData(routerJobData[key]['data']['subTasks'], 'st_'),
          processId: routerJobData[key]['process'],
          completeDate: routerJobData[key]['data']['completeDate'],
          status: routerJobData[key]['data']['status'],
          good: routerJobData[key]['data']['good'],
          bad: routerJobData[key]['data']['bad'],
          isApproved: routerJobData[key]['data']['isApproved'],
          // should be false unless this board is an archive board
          isArchive: routerJobData[key]['data']['isArchive'],
          jobs: jobs,
        );
      }
    }
    return data;
  }

  Widget processInfo() {
    return ProcessManager()
  }

  @override
  Widget build(BuildContext context) {
        return hasStarted?!widget.isMobile?SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [processInfo(), Container()],
        )
      ):SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            processInfo(),
            Align(
              alignment: Alignment.centerRight,
              child: Container()
            )
          ],
        )
      ):SizedBox(
        width: widget.width,
        height: widget.height,
        child:LSILoadingWheel()
      );
  }

  @override
  void didUpdateWidget(ProcessViewer oldBoardViewer){
    if (widget.router != oldBoardViewer.router || oldBoardViewer.width != widget.width ||
        widget.color != oldBoardViewer.color || widget.completeData != oldBoardViewer.completeData) {
      start();
    } 
    else if (update) {
      setState(() {});
    } 
    super.didUpdateWidget(oldBoardViewer);
  }
}