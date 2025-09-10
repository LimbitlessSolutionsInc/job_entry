import 'package:flutter/material.dart';
import 'package:job_entry/src/data/cardData.dart';
import 'package:job_entry/src/example/taskCard.dart';
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
          dateCreated: DateTime.now().toString(),
          createdBy: "User 1",
          dueDate: DateTime.now().toString(),
          points: 0,
        );
        list?.add(test1);
        CardData test2 = CardData(
          title: "Router 1",
          status: "In progress", 
          dateCreated: DateTime.now().toString(),
          dueDate: DateTime.now().toString(),
          isRouter: true,
          completedDate: "9/9/2025", 
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Card Testing", style: TextStyle(fontSize: 50),),
              Text("Task Card", style: TextStyle(fontSize: 25),),
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 10),
                width: 500,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColorDark, width: 1),
                  ),
                ),
                child: TaskCard(cardData: list!.first, height: 10, width: 70, context: context)
              ),
              Text("Router Card", style: TextStyle(fontSize: 25),),
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 10),
                width: 500,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColorDark, width: 1),
                  ),
                ),
                child: TaskCard(cardData: list!.last, height: 10, width: 70, context: context)
              )
            ],
          )]
      )
    );
  }
}