import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  dynamic router;
  bool testing = true;
  String selectedRouter = '';
  String child = '';
  bool update = false;
  bool hasStarted = false;
  List<DropDownItems> dropDownWorkers = [];
  List<DropDownItems> dropDownApprovers = [];
  int index = 0;

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

    //completedJobs = null;
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

    dropDownWorkers = [DropDownItems(value: '', text: 'Pick Workers')];
    // populate the drop down items based on who can edit this router (students)

    dropDownApprovers = [DropDownItems(value: '', text: 'Pick Approvers')];
    // populate the drop down items based on who can approve this router


    listenToFirebase();
    setState(() {

    });
  }

  void listenToFirebase() async {
    if (testing) {
      currentUser = UsersProfile(
        uid: 'testUser',
        displayName: 'Test User',
        imageUrl: null,
        status: OrgStatus.admin,
      );

      final String jsonString = await rootBundle.loadString('lib/src/assets/test_data.json');
      dynamic testData = json.decode(jsonString);

      usersProfile = {};

      void addUser(String uid, {String? displayName, String? imageUrl, OrgStatus? status, bool? canRemoteWork}) {
        if (!usersProfile.containsKey(uid)) {
          usersProfile[uid] = {
            'displayName': displayName ?? uid,
            'imageUrl': imageUrl ?? 'https://example.com/image.png',
            'status': status ?? OrgStatus.admin,
            'canRemoteWork': canRemoteWork ?? false,
          };
        }
      }

      router = testData['router'][selectedRouter];
      addUser(
        router['details']['createdBy'],
        displayName: 'Test User',
        imageUrl: 'https://example.com/image.png',
        status: OrgStatus.admin,
        canRemoteWork: false
      );

      for (var process_id in router['processes'].keys) {
        var creator = router['processes'][process_id]['details']['createdBy'];
        addUser(creator);
      }

      for (var job_id in router['jobs'].keys) {
        var j = router['jobs'][job_id];
        addUser(j['createdBy']);
        for (var w in j['workers']) {
          addUser(w);
        }
        for (var a in j['approvers']) {
          addUser(a, status: OrgStatus.admin, canRemoteWork: true);
        }
        if (j['notes'] != null) {
          (j['notes'] as Map<String, dynamic>).forEach((_, note) {
            addUser(note['createdBy']);
          });
        }
      }

      currentProcessData = {};
      final processes = router['processes'];
      for (var process_id in processes.keys) {
        final details = processes[process_id]['details'];
        currentProcessData[process_id] = ProcessData(
          id: process_id,
          title: details['title'],
          dateCreated: details['dateCreated'],
          createdBy: details['createdBy'],
          color: details['color'],
        );
      }

      currentJobData = {};
      final jobs = router['jobs'];
      for (var job_id in jobs.keys) {
        var j = jobs[job_id];
        currentJobData[job_id] = JobData(
          id: job_id,
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
          notes: j['notes'] as Map<String, dynamic>?,
        );
      }

      hasStarted = true;
      setState(() {});
    } else {
      //call firebase to get the router data
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
          index: (routerProcessData[key]['index'] == null)
            ? index++
            : routerProcessData[key]['index'],
        );
      }
    }
    index = 0;
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
          prevJobs: routerJobData[key]['data']['prevJob'],
        );
      }
    }
    return data;
  }

  Widget processInfo() {
    return ProcessManager(
      update: update,
      callback: callback,
      workers: dropDownWorkers,
      approvers: dropDownApprovers,
      height: widget.height,
      width: widget.width,
      screenOffset: Offset(0, appBarHeight),
      allowEditing: allowEditing(),
      routerId: selectedRouter,
      onSubmit: (title, notify) {
        DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
        String date = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
        Database.push(
          'team', 
          children: '$child/boards', 
          data: {
            'createdBy': currentUser.uid,
            'dateCreated': date,
            'title': title,
            'notify': notify
          }
        );
      },
      onEdit: (data, id) {
        Database.update(
          'team',
          children: '$child/boards/',
          location: id,
          data: data
        );
      },
      onCreateJob: (data) {
        if (data['data']['workers'] != null) {
          List<String> sendTo = [];
          for(int i = 0; i < data['data']['workers'].length; i++){
            if(data['data']['workers'][i] != currentUser.uid){
              sendTo.add(data['data']['workers'][i]);
            }
          }
          if(sendTo.isNotEmpty){
            Messaging.sendPushMessage(
              sendTo,
              'LSI Task Manager',
              '${currentUser.displayName} assigned you to a new task!'
            );
          }
        }
        Database.push('team', children: '$child/cards', data: data);
      },
      onEditJob: (data, loc, newWorkers) {
        List<String> uids = [];
        int currentCards = 0;

        for (String i in currentJobData.keys) {
          if (currentJobData[i]!.id == loc) {
            currentCards = (currentJobData[i]!.notes == null)? 0:currentJobData[i]!.notes!.length;
          }
        }
        if (data['workers'] != null && !data['workers'].toString().contains(currentUser.uid)) {
          for(int i = 0; i < data['workers'].length; i++){
            uids.add(data['workers'][i]);
          }
        }
        if (data['notes'] != null) {
          if (currentCards != data['notes'].length) {
            for (String key in data['notes'].keys) {
              if(data['notes'][key]['createdBy'] != currentUser.uid){
                uids.add(data['notes'][key]['createdBy']);
              }
            }
          }
        }
        if (data['workers'] != null && newWorkers.isNotEmpty) {
          List<String> sendTo = [];
          for(int i = 0; i < data['workers'].length; i++){
            if(data['workers'][i] != currentUser.uid && newWorkers.contains(data['workers'][i])){
              uids.add(data['workers'][i]);
            }
          }
          sendTo = uids.toSet().toList();

          if(sendTo.isNotEmpty){
            Messaging.sendPushMessage(
              sendTo,
              'LSI Task Manager',
              '${currentUser.displayName} assigned you to a new task!'
            );
          }
        }
        Database.update(
          'team',
          children:  '$child/cards/$loc', 
          location: 'data', 
          data: data
        );
      },
      // onEditProcess -> change of index
      // onDateChange -> change priority
      onJobDelete: (id) {
        Database.update(
          'team',
          children: '$child/cards/', 
          location: id
        );
      },
      onProcessDelete: (id) {
        Database.update(
          'team',
          children: '$child/boards/', 
          location: id, 
        );
      },
      onTitleChange: (id, title) {
        Database.update(
          'team',
          children: '$child/boards/$id', 
          location: 'title', 
          data: title
        );
      },
      processData: currentProcessData,
      jobs: currentJobData,
      index: currentProcessData['data']?.index ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
      return hasStarted?(
        !widget.isMobile?SizedBox(
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
            ]
          )
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