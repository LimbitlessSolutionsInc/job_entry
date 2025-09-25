import 'package:flutter/material.dart';
import 'package:job_entry/src/taskManager/data/cardData.dart';
import 'package:job_entry/src/taskManager/example/taskCard.dart';
import 'package:job_entry/src/taskManager/example/boardViewer.dart';
import 'package:job_entry/styles/globals.dart';

// TODO: Test with testing user, make router and task project
// TODO: make the library only need the current user as input?

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
  List<CardData>? list;
  
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
    list = <CardData> [];
    try{
      if(testing){
        CardData test1 = CardData(
          title: "Task 1",
          dateCreated: "09/09",
          createdBy: "User 1",
          points: 0,
        );
        list?.add(test1);
        CardData test2 = CardData(
          title: "Router 1",
          status: "In progress", 
          dateCreated: "09/09",
          dueDate: "09/11",
          isRouter: true,
          completedDate: "09/10", 
          points: 0,
          good: 140, 
          bad: 10, 
          isApproved: false,
        );        
        list?.add(test2);
      }
      else {

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
        child: Stack(
          children: [
            //align the board viewer of routes/jobs and assemblies in the center right
            //project viewer of the processes on the left
          ]
        )
      )
    );
  }
}