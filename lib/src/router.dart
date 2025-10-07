import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_entry/src/taskManager/data/jobData.dart';
import 'package:job_entry/src/taskManager/data/processData.dart';
import 'package:job_entry/src/taskManager/example/jobCard.dart';
import 'package:job_entry/src/taskManager/example/processViewer.dart';
import 'package:job_entry/src/task_master.dart';
import 'package:job_entry/styles/globals.dart';

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
  List<JobData>? list;

  String selectedRouter = '';
  
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

  void listenToFirebase() async{
    list = <JobData> [];
    try{
      if(testing){

      } else {

      }
    }
    catch(e){
      print('Exception (listentoFirebase): $e');
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
        child: Column(
          children: [
            //align the board viewer of routes/jobs and assemblies in the center right
            //project viewer of the processes on the left
            JobCard(jobData: list!.first, height: 150, width: 550, context: context),
            JobCard(jobData: list!.last, height: 150, width: 550, context: context),
            ProcessViewer(router: "test", width: 250, height: 500, color: 1)
          ]
        )
      )
    );
  }
}