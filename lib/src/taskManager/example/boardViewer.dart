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

// TODO: should have router card + fill in task card
// TODO: have timeline modal (complete timeline of assemblies)

class BoardViewer extends StatefulWidget {
  const BoardViewer({
    Key? key,
    this.callback,
    required this.project,
    required this.department,
    required this.width,
    required this.height,
    this.fbLoc = 'Dep',
    this.labels,
    this.showChart = false,
    this.isMobile = false,
    required this.color,
    this.completeData,
    this.points,
  }): super(key: key);

  final HomeCallback? callback;
  final String project;
  final String department;
  final String fbLoc;
  final double width;
  final double height;
  final bool showChart;
  final dynamic labels;
  final bool isMobile;
  final int color;
  final dynamic completeData;
  final dynamic points;

  @override
  _BoardViewerState createState() => _BoardViewerState();
}

class _BoardViewerState extends State<BoardViewer> {
  bool testing = true;
  dynamic labelsData;
  String selectedProject = '';
  String currentDep = '';
  String child = '';
  String fbLoc = '';
  bool update = false;
  bool hasStarted = false;
  List<DropDownItems> dropDownNames = [];

  double startingWidth = deviceWidth;

  StreamSubscription<DatabaseEvent>? boardAdded;
  StreamSubscription<DatabaseEvent>? cardAdded;

  Map<String,BoardData> currentBoardData = {};
  Map<String,CardData> currentCardData = {};
  int color = lightBlue.value;
  dynamic completedTasks;
  dynamic points;
  bool showChart = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      start();
    });
    
    super.initState();
  }

  @override
  void dispose() {
    boardAdded?.cancel();
    cardAdded?.cancel();
    super.dispose();
  }

  void callback() {
    setState(() {
      update = false;
    });
  }

  void firebaseReset() {
    currentBoardData = {};
    currentCardData = {};
    hasStarted = false;
    labelsData = null;

    completedTasks = null;
    points = null;
    update = true;

    boardAdded?.cancel();
    cardAdded?.cancel();
  }

  void start() async {
    firebaseReset();
    completedTasks = widget.completeData;
    color = widget.color;
    labelsData = widget.labels;
    startingWidth = widget.width;
    selectedProject = widget.project;
    currentDep = widget.department;
    showChart = widget.showChart;
    fbLoc = widget.fbLoc;
    if (fbLoc == 'Ind') {
      currentDep = currentUser.displayName;
    }

    child = "managment/$fbLoc/$currentDep/$selectedProject";

    dropDownNames = [DropDownItems(value: '', text: 'Pick a Person')];
    if (Org.statusAllowed(StatusAllowed.studentOnly, currentUser.status)) {
      dropDownNames.add(
        DropDownItems(value: currentUser.uid, text: currentUser.displayName)
      );
      for(String uid in schedules[sem][Org.getDEP(widget.department)].keys){
        if(uid != currentUser.uid){
          dropDownNames.add(
            DropDownItems(value: uid, text: usersProfile[uid]['displayName'])
          );
        }
      }
    }
    else {
      for (String key in allUsersData.keys) {
        if(Org.checkInDepartment(allUsersData[key],widget.department)) {
          if(usersProfile?[key]?['displayName'] != null){
            dropDownNames.add(
              DropDownItems(value: key, text: usersProfile[key]['displayName'])
            );
          }
        }
      }
    }

    points = widget.points ?? {};

    listenToFirebase();
    setState(() {

    });
  }

  void listenToFirebase() {
    if (testing) {
      
    } else {
      boardAdded = Database.onValue('$child/boards', 'team').listen((event) {
      setState(() {
        currentBoardData = boardData(event.snapshot.value);
        update = true;
      });
    });
    cardAdded = Database.onValue('$child/cards', 'team').listen((event) {
      setState(() {
        currentCardData = cardData(event.snapshot.value);
        update = true;
        if(!hasStarted){ hasStarted = true; }
      });
      
    });
    }
  }

  bool allowEditing() {
    bool allowed = false;
    if (currentUser.status == OrgStatus.admin) {
      allowed = true;
    } else if (userData['orgData']['department'] == currentDep) {
      allowed = true;
    } else if (fbLoc == 'Ind') {
      allowed = true;
    }
    return allowed;
  }

  // mainly for quality team view only permissions
  bool allowView() {
    bool allowed = false;
    // double check this is the right string
    if (userData['orgData']['department'] == 'Quality') {
      currentBoardData.forEach((key, value) {
        // assumes that every board is an assembly board if the first one is
        if (value.isAssembly && fbLoc != 'Ind') {
          allowed = true;
        }
      });
      return allowed;
    }
    return allowed;
  }

  Map<String,BoardData> boardData(dynamic projectBoardData) {
    Map<String,BoardData> data = {};
    if (projectBoardData != null) {
      for (String key in projectBoardData.keys) {
        data[key] = BoardData(
          id: key,
          title: projectBoardData[key]['title'],
          createdBy: projectBoardData[key]['createdBy'],
          dateCreated: projectBoardData[key]['dateCreated'],
          isAssembly: projectBoardData[key]['isAssembly'],
          isArchive: (projectBoardData[key]['isArchive'] == null)
              ? false
              : projectBoardData[key]['isArchive'],
          priority: projectBoardData[key]['priority'],
          color: color,
          notify: (projectBoardData[key]['notify'] == null)
              ? false
              : projectBoardData[key]['notify'],
        );
      }
    }
    return data;
  }

  // edit this to include the new vars added
  Map<String,CardData> cardData(dynamic projectCardData) {
    Map<String,CardData> data = {};
    if (projectCardData != null) {
      for (String key in projectCardData.keys) {
        Map<String, dynamic>? labels;
        if (labelsData != null && projectCardData[key]['data']['labels'] != null) {
          for (int i = 0;i < projectCardData[key]['data']['labels'].length;i++) {
            if (labelsData[projectCardData[key]['data']['labels'][i]] != null) {
              if (labels == null) {
                labels = {
                  projectCardData[key]['data']['labels'][i]:
                      labelsData[projectCardData[key]['data']['labels'][i]]
                };
              } else {
                labels[projectCardData[key]['data']['labels'][i]] =
                    labelsData[projectCardData[key]['data']['labels'][i]];
              }
            }
          }
        }

        List<String> assigned = [];
        if(projectCardData[key]['data']['assign'] != null){
          assigned.add(projectCardData[key]['data']['assign']);
        }
        if(projectCardData[key]['data']['assigned'] != null){
          for(int i = 0; i < projectCardData[key]['data']['assigned'].length;i++){
            assigned.add(projectCardData[key]['data']['assigned'][i]);
          }
        }

        List<String> editors = [];
        if(projectCardData[key]['data']['editors'] != null){
          for(int i = 0; i < projectCardData[key]['data']['editors'].length;i++){
            editors.add(projectCardData[key]['data']['editors'][i]);
          }
        }

        List<String> approvers = [];
        if(projectCardData[key]['data']['approvers'] != null){
          for(int i = 0; i < projectCardData[key]['data']['approvers'].length;i++){
            approvers.add(projectCardData[key]['data']['approvers'][i]);
          }
        }

        List<CardData> routers = [];
        if(projectCardData[key]['data']['routers'] != null){
          for(int i = 0; i < projectCardData[key]['data']['routers'].length;i++){
            routers.add(projectCardData[key]['data']['routers'][i]);
          }
        }

        data[key] = CardData(
          id: key,
          title: projectCardData[key]['data']['title'],
          createdBy: projectCardData[key]['data']['createdBy'],
          dateCreated: projectCardData[key]['data']['createdDate'],
          priority: projectCardData[key]['priority'],
          description: (projectCardData[key]['data']['description'] == null)? '':projectCardData[key]['data']['description'],
          dueDate: projectCardData[key]['data']['dueDate'],
          points: projectCardData[key]['data']?['points'] ?? 0,
          assigned: assigned,
          editors: editors,
          approvers: approvers,
          checkList: LSIFunctions.getFromData(projectCardData[key]['data']['subTasks'], 'st_'),
          comments: LSIFunctions.getFromData(projectCardData[key]['data']['comments'], 'act_'),
          boardId: projectCardData[key]['board'],
          level: projectCardData[key]['data']['priority'],
          labels: labels,
          isRouter: projectCardData[key]['data']['isRouter'], 
          routers: routers,         
        );
      }
    }
    return data;
  }

  Widget boardInfo() {
    return BoardManager(
      labels: labelsData,
      update: update,
      callback: callback,
      users: dropDownNames,
      height: widget.height,
      width: (!useSideNav || !showChart) ? widget.width : widget.width - 180,
      screenOffset: Offset(
        (!useSideNav)? 0: ((showList)? navSize.width + sideListSize + 265:navSize.width + 265),
        (!useSideNav) ? appBarHeight : 0
      ),
      allowEditing: allowEditing(),
      projectId: selectedProject,
      onSubmit: (title, priority, notify) {
        DateFormat dayFormatter = DateFormat('MM-dd-yy hh:mm:ss');
        String date = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
        Database.push(
          'team', 
          children: '$child/boards', 
          data: {
            'createdBy': currentUser.uid,
            'dateCreated': date,
            'title': title,
            'priority': priority,
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
      onCreateCard: (data) {
        if (data['data']['assigned'] != null) {
          List<String> sendTo = [];
          for(int i = 0; i < data['data']['assigned'].length; i++){
            if(data['data']['assigned'][i] != currentUser.uid){
              sendTo.add(data['data']['assigned'][i]);
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
      onEditCard: (data, loc, newAssigned) {
        List<String> uids = [];
        int currentCards = 0;

        for (String i in currentCardData.keys) {
          if (currentCardData[i]!.id == loc) {
            currentCards = (currentCardData[i]!.comments == null)? 0:currentCardData[i]!.comments!.length;
          }
        }
        if (data['assigned'] != null && !data['assigned'].toString().contains(currentUser.uid)) {
          for(int i = 0; i < data['assigned'].length; i++){
            uids.add(data['assigned'][i]);
          }
        }
        if (data['comments'] != null) {
          if (currentCards != data['comments'].length) {
            for (String key in data['comments'].keys) {
              if(data['comments'][key]['createdBy'] != currentUser.uid){
                uids.add(data['comments'][key]['createdBy']);
              }
            }
          }
        }
        if (data['assigned'] != null && newAssigned.isNotEmpty) {
          List<String> sendTo = [];
          for(int i = 0; i < data['assigned'].length; i++){
            if(data['assigned'][i] != currentUser.uid && newAssigned.contains(data['assigned'][i])){
              uids.add(data['assigned'][i]);
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
      onPriorityBoardChange: (pri) {
        for (String key in pri.keys) {
          Database.update(
            'team',
            children: '$child/boards/$key',
            location: 'priority',
            data: pri[key]
          );
        }
      },
      onCardPriorityChange: (val, change) {
        for (String j in currentCardData.keys) {
          if (currentCardData[j]!.id == change['card'] && currentCardData[j]!.assigned!.isNotEmpty) {

          }
          if (currentCardData[j]!.id == change['card'] && currentCardData[j]!.boardId != change['board'] && currentCardData[j]!.assigned!.isNotEmpty) {
            String name = usersProfile[currentCardData[j]!.assigned?[0]]['displayName'];
            List<String> allowSend = [];
            for(int i = 0; i < currentCardData[j]!.assigned!.length; i++){
              if(currentCardData[j]!.assigned![i] == currentUser.uid) {
                allowSend.add(currentCardData[j]!.assigned![i]);
              }
            }
            if(allowSend.isNotEmpty){
              Messaging.sendPushMessage(
                allowSend,
                'LSI Task Manager', 'A card assigned to you has been moved!'
              );
            }
            for (String l in currentBoardData.keys) {
              if (currentBoardData[l]!.notify! && currentBoardData[l]!.id == currentCardData[j]!.boardId && currentUser.uid != currentBoardData[l]!.createdBy) {
                Messaging.sendPushMessage(
                  [userData['orgData']['manager']],
                  'LSI Task Manager',
                  "$name's task has moved to ${currentBoardData[l]!.title}!"
                );
                break;
              }
            }
            break;
          }
        }
        for (String key in val.keys) {
          Database.update('team',
            children: '$child/cards/$key',
            location: 'priority',
            data: val[key]['priority']
          );
          Database.update(
            'team',
            children: '$child/cards/$key',
            location: 'board',
            data: val[key]['boardId']
          );
        }
      },
      onCardDelete: (id) {
        Database.update(
          'team',
          children: '$child/cards/', 
          location: id
        );
      },
      // this only applicable to task cards, not router cards
      assignPoints: (name, points, id) {
        List<String> pushTo = [];
        DateFormat dayFormatter = DateFormat('MM-dd-yy hh:mm:ss');
        String createdDate = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');

        dynamic archiveData = {
          'createdBy': currentCardData[id]!.createdBy,
          'createdDate': currentCardData[id]!.dateCreated,
          'dueDate': currentCardData[id]!.dueDate,
          'title': currentCardData[id]!.title,
          'completedDate': createdDate,
          'completedBy': (name != null)?name.join(','):currentUser.uid
        };

        if (name != null && points != null) {
          dynamic pointData = {
            'assignedBy': currentUser.uid,
            'dateAssigned': createdDate,
            'points': points
          };
          for(int i = 0; i < name.length; i++){
            if(allUsersData[name[i]] != null){
              pushTo.add(name[i]);
            }
            Database.update(
              'team',
              children: '/managment/points/$currentDep/${name[i]}/${widget.project}',
              location: id,
              data: pointData
            );
          }
          Database.update(
            'team',
            children: '/managment/complete/$currentDep/${widget.project}',
            location: id,
            data: archiveData
          ).then((value) {
            Database.update(
              'team',
              children: '$child/cards/', 
              location: id
            );
          });
          if(pushTo.isNotEmpty){
            Messaging.sendPushMessage(
              pushTo,
              'LSI Task Manager',
              '${currentUser.displayName} you just earned some points!'
            );
          }
        } 
        else {
          Database.update(
            'team',
            children: '/managment/complete/$currentDep/${widget.project}',
            location: id,
            data: archiveData
          ).then((value) {
            Database.update(
              'team',
              children: '$child/cards/', 
              location: id
            );
          });
        }

        setState(() {
          start();
          Database.once('/managment/complete/$currentDep/${widget.project}', 'team').then((value) => 
            completedTasks = value
          ,);
        });
      },
      onBoardDelete: (id) {
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
      boardData: currentBoardData,
      cards: currentCardData,
    );
  }

  // would not be used for routers, make new func for archive
  Widget showCompletedTasks([String? uid]){
    List<Widget> completedTaskCards = [];

    if(uid != null && points[uid] != null){
      for(String story in points[uid].keys){
        for(String task in points[uid][story].keys){
          String date =completedTasks[task] != null
            ? '${DateTime.parse(completedTasks[task]['completedDate']).month}-${DateTime.parse(completedTasks[task]['completedDate']).day}-${DateTime.parse(completedTasks[task]['completedDate']).year}'
            : '';
          completedTaskCards.add(
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 15),
              //height: 100,
              width: CSS.responsive() - 60.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        completedTasks[task]?['title'] ?? 'n/a',
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          decoration: TextDecoration.none),
                      ),
                      Text(
                        points[uid][story][task]['points'].toString(),
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 20,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          decoration: TextDecoration.none),
                      )
                    ],
                  ),
                  Text(
                    'Completed On: $date',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 15,
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        decoration: TextDecoration.none),
                  ),
                  Row(
                    children: [
                      Text(
                        'Created By: ',
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontSize: 15,
                            fontFamily: 'Klavika Bold',
                            package: 'css',
                            decoration: TextDecoration.none),
                      ),
                      LSIUserIcon(
                        uids: completedTasks[task]!=null?[completedTasks[task]['createdBy']]:[],
                        colors: [Colors.teal[200]!, Colors.teal[600]!],
                        iconSize: 25,
                        viewidth: CSS.responsive() - 160,
                        //usersProfile: users,
                      ),
                    ],
                  ),
                ],
              )
            )
          );
        }
      }
    }
    else{
      if(completedTasks != null){
        for(String id in completedTasks.keys){
          String date = completedTasks[id]['completedDate']==null?'n/a'
                        :'${DateTime.parse(completedTasks[id]['completedDate']).month}-${DateTime.parse(completedTasks[id]['completedDate']).day}-${DateTime.parse(completedTasks[id]['completedDate']).year}';
          completedTaskCards.add( Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 15),
            //height: 120,
            width: CSS.responsive() - 60.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completedTasks[id]['title'] ?? 'n/a',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20,
                      fontFamily: 'Klavika Bold',
                      package: 'css',
                      decoration: TextDecoration.none),
                ),
                Text(
                  'Completed On: $date',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 15,
                      fontFamily: 'Klavika Bold',
                      package: 'css',
                      decoration: TextDecoration.none),
                ),
                if(completedTasks[id]['createdBy'] != null)
                Row(
                  children: [
                    Text(
                      'Created By: ',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 15,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          decoration: TextDecoration.none),
                    ),
                    LSIUserIcon(
                      uids: [completedTasks[id]['createdBy']],
                      colors: [Colors.teal[200]!, Colors.teal[600]!],
                      iconSize: 25,
                      viewidth: CSS.responsive() - 160,
                      //usersProfile: users,
                    ),
                  ],
                ),
                if(completedTasks[id]['completedBy'] != null)Row(
                  children: [
                    Text(
                      'Completed By: ',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 15,
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        decoration: TextDecoration.none
                      ),
                    ),
                    LSIUserIcon(
                      uids: completedTasks[id]['completedBy'].toString().split(','),
                      colors: [Colors.teal[200]!, Colors.teal[600]!],
                      iconSize: 25,
                      viewidth: CSS.responsive() - 180,
                      //usersProfile: users,
                    ),
                  ],
                ),
              ],
            )
          ));
        }
      }
    }

    return StatefulBuilder(builder: (context1, setState){
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.only(left: 1, right: 1),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: widget.height-66-30,
            width: CSS.responsive(),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: FocusedInkWell(
                    debugLabel: 'Close Button',
                    onTap: (){
                      Navigator.pop(context1);
                    },
                    child: Icon(
                      Icons.close, 
                      size: 20, 
                      color: Theme.of(context).secondaryHeaderColor
                    ),
                  )
                ),
                Text(
                  'Completed Tasks',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 32,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: widget.height-210,
                  width: CSS.responsive(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).splashColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: ListView(
                    children: completedTaskCards
                  )
                )
              ],
            )
          )
        );
      }
    );  
  }

  // maybe make a different one for the router?
  Widget chartInfo() {
    List<String> names = ['Complete', 'Overdue', 'Planned', 'No Due Date'];
    List<Color> colors = [Colors.blue, Colors.red, Colors.orange, Colors.grey];
    List<int> amount = [0, 0, 0, 0];

    Widget indicator(String text, Color color, int amount, int total) {
      try{
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                      //color: color,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(width: 2.5, color: color)),
                ),
                Text(
                  ' $text',
                  style: TextStyle(
                      fontFamily: 'MuseoSans',
                      package: 'css',
                      fontSize: 10,
                      color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                      decoration: TextDecoration.none),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  amount.toString(),
                  style: TextStyle(
                      fontFamily: 'MuseoSans',
                      package: 'css',
                      fontSize: 10,
                      color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                      decoration: TextDecoration.none),
                ),
                Text(
                  ' (${(total == 0 || amount == 0)? 0:(amount / total * 100).floor()}%',
                  style: TextStyle(
                      fontFamily: 'MuseoSans',
                      package: 'css',
                      fontSize: 10,
                      color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                      decoration: TextDecoration.none),
                ),
              ],
            )
          ],
        );
      }
      catch(e){
        print('boardViewer.dart -> chartInfo -> indicator -> Exception: $e');
        return const SizedBox();
      }
    }

    int total = 0;
    if (currentCardData.isNotEmpty) {
      total = currentCardData.length;
    }

    List<Widget> info = [];
    List<Widget> circles = [];

    if (completedTasks != null) {
      total += completedTasks.length as int;
      amount[0] = completedTasks.length;
    }

    List<String> emp = [];
    int maxVal = 0;
    // complete, overdue, planned, pts
    List<List<int>> work = [];
    int i = 0;
    if (points != null) {
      for (String key in points.keys) {
        emp.add(key);
        work.add([0, 0, 0, 0]);
        if (points[key][selectedProject] != null) {
          for (String cKey in points[key][selectedProject].keys) {
            work[i][0]++;
            work[i][3] += points[key][selectedProject][cKey]['points'] as int;
          }
        }
        i++;
      }
    }

    void checkEmp(String? per, int loc) {
      try{
        if (per != null) {
          bool hasPer = false;
          for (int i = 0; i < emp.length; i++) {
            if (per == emp[i]) {
              hasPer = true;
              work[i][loc]++;
              break;
            }
          }
          if (!hasPer) {
            emp.add(per);
            if (loc == 1) {
              work.add([0, 1, 0, 0]);
            } else {
              work.add([0, 0, 1, 0]);
            }
          }
        }
      }
      catch(e){
        print('boardViewer.dart -> chartInfo -> checkEmp -> Exception: $e');
      }
    }

    void getMax() {
      try{
        for (int i = 0; i < emp.length; i++) {
          int temp = work[i][0] + work[i][1] + work[i][2];
          if (temp > maxVal) {
            maxVal = temp;
          }
        }
      }
      catch(e){
        print('boardViewer.dart -> chartInfo -> getMax -> Exception: $e');
      }
    }

    try{
      if (currentCardData.isNotEmpty) {
        for (String i in currentCardData.keys) {
          if (currentCardData[i]!.dueDate != null) {
            DateTime now = DateTime.now();
            DateTime due = DateTime.parse(currentCardData[i]!.dueDate!.replaceAll('T', ' '));
            if(currentCardData[i]!.assigned!.isNotEmpty){
              for(int j = 0; j < currentCardData[i]!.assigned!.length;j++){
                if (now.isAfter(due)) {
                  amount[1]++;
                  checkEmp(currentCardData[i]!.assigned![j], 1);
                } 
                else {
                  amount[2]++;
                  checkEmp(currentCardData[i]!.assigned![j], 2);
                }
              }
            }
          } 
          else {
            amount[3]++;
          }
        }
      }
      getMax();

      List<Widget> barChart = [];
      if (completedTasks != null) {
        for (int i = 0; i < emp.length; i++) {
          //print(maxVal);
          barChart.add(SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LSISingleUserIcon(
                      uid: emp[i], 
                      color: Colors.teal, 
                      loc: 0,
                      iconSize: 35,
                    ),
                    const SizedBox(width: 5,),
                    FocusedInkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return showCompletedTasks(emp[i]);
                          }
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        height: 20,
                        width: maxVal == 0?0:110 * work[i][0] / maxVal,
                        color: Colors.blue,
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      height: 20,
                      width:  maxVal == 0?0:110 * work[i][1] / maxVal,
                      color: Colors.red,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      height: 20,
                      width:  maxVal == 0?0:110 * work[i][2] / maxVal,
                      color: Colors.orange,
                    ),
                  ],
                ),
                RichText(
                    text: TextSpan(
                  text: "Pts: ", //+work[i][3].toString(),
                  children: [
                    TextSpan(
                      text: work[i][3].toString(),
                      style: TextStyle(
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          fontSize: 10,
                          color:
                              Theme.of(context).primaryTextTheme.titleMedium!.color,
                          decoration: TextDecoration.none),
                    )
                  ],
                  style: TextStyle(
                      fontFamily: 'MuseoSans',
                      package: 'css',
                      fontSize: 10,
                      color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                      decoration: TextDecoration.none),
                )),
                const SizedBox(height: 10,),
              ],
            ),
          ));
        }
      } else {
        barChart.add(Container());
      }

      double start = 0;
      double finish = 0;
      for (int i = 0; i < 4; i++) {
        info.add(indicator(names[i], colors[i], amount[i], total));
        if (total != 0) {
          start += finish.ceil();
          finish = 360 * (amount[i] / total);

          circles.add(TimeTracking.timeCircles(
              offset: const Offset(0, 0),
              alignment: Alignment.center,
              color: colors[i],
              width: 150 / 1.9,
              percentage: 0.99,
              spacing: 0.15,
              deg: 360 - start,
              sweep: finish,
              size: 120));
        }
      }
      circles.add(Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                total.toString(),
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 36,
                    color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                    decoration: TextDecoration.none),
              ),
              Text(
                'Total Tasks',
                style: TextStyle(
                    fontFamily: 'MuseoSans',
                    package: 'css',
                    fontSize: 10,
                    color: Theme.of(context).primaryTextTheme.titleMedium!.color,
                    decoration: TextDecoration.none),
              ),
            ],
          )));

      return Container(
        height: widget.height,
        decoration:
            BoxDecoration(color: Theme.of(context).splashColor, boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(-5, 3),
          ),
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FocusedInkWell(
              bgColor: Theme.of(context).splashColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return showCompletedTasks();
                  }
                );
              },
              child: SizedBox(
                width: 176,
                height: 176,
                //padding: EdgeInsets.all(10),
                child: Stack(children: circles),
              ),
            ),
            Container(
              width: 180,
              height: 80,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: info
              ),
            ),
            Container(
              width: 180,
              height: widget.height - 180 - 80,
              padding: const EdgeInsets.all(10),
              child: ListView(
                padding: const EdgeInsets.all(0),
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: barChart
              ),
            ),
          ],
        )
      );
    }
    catch(e){
      print('boardViewer.dart -> chartInfo -> Exception: $e');
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasStarted?!widget.isMobile?SizedBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [boardInfo(), (showChart) ? chartInfo() : Container()],
        )
      ):SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            boardInfo(),
            Align(
              alignment: Alignment.centerRight,
              child: (showChart)?chartInfo():Container()
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
  void didUpdateWidget(BoardViewer oldBoardViewer){
    if (widget.project != oldBoardViewer.project || oldBoardViewer.width != widget.width ||
        widget.showChart != oldBoardViewer.showChart || oldBoardViewer.labels != widget.labels ||
        widget.color != oldBoardViewer.color || widget.department != oldBoardViewer.department ||
        widget.fbLoc != oldBoardViewer.fbLoc || widget.completeData != oldBoardViewer.completeData) {
      start();
    } 
    else if (update) {
      setState(() {});
    } 
    super.didUpdateWidget(oldBoardViewer);
  }
}

