// only needs org data
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../organization/organization.dart';
import '../../../../styles/globals.dart';
import 'package:intl/intl.dart';
import '../../../../src/database/database.dart';
import '../../task_master.dart';

class ProjectViewer extends StatefulWidget {
  const ProjectViewer({
    Key? key,
    this.callback,
    required this.width,
    required this.height,
    required this.fbLoc,
    required this.epic,
    this.startProject,
    this.onTap,
    this.onLabelAdded,
    this.labels
  }) : super(key: key);

  final HomeCallback? callback;
  final String epic;
  final String? startProject;
  final Function(String project)? onTap;
  final Function? onLabelAdded;
  final String fbLoc;
  final double width;
  final double height;
  final dynamic labels;

  @override
  _ProjectViewerState createState() => _ProjectViewerState();
}

class _ProjectViewerState extends State<ProjectViewer> {
  dynamic managemntData = {};
  dynamic timeLineDataComplete = {};
  String currentEpic = '';
  String fbLoc = '';
  String child = '';

  StreamSubscription<DatabaseEvent>? fbadded;
  StreamSubscription<DatabaseEvent>? completeAdded;

  @override
  void initState() {
    start();
    listenToFirebase();
    super.initState();
  }

  @override
  void dispose() {
    fbadded?.cancel();
    completeAdded?.cancel();
    super.dispose();
  }

  void start() {
    currentEpic = widget.epic;
    managemntData = {};
    fbLoc = widget.fbLoc;
    child = "managment/Epic/" + fbLoc + "/" + currentEpic;
  }

  void listenToFirebase() async{
    fbadded?.cancel();
    Database.once(
      "managment/complete/" + currentEpic, 
      'team'
    ).then((value) {
      setState(() {
        timeLineDataComplete = value ?? {};
      });
    });
    completeAdded = Database.onValue("managment/complete/" + currentEpic, 'team').listen((event) {
      setState(() {
        timeLineDataComplete = event.snapshot.value ?? {};
      });
    });
    Database.once(child, 'team').then((value){
      setState(() {
        managemntData = value ?? {};
      });
    });
    fbadded = Database.onValue(child, 'team').listen((event) {
      setState(() {
        managemntData = event.snapshot.value ?? {};
      });
    });
  }

  List<ProjectData> projectData() {
    List<ProjectData> data = [];
    if (managemntData != {}) {
      for (String key in managemntData.keys) {
        if (key != 'title') {
          if (managemntData[key]['complete'] == null) {
            data.add(ProjectData(
                color: managemntData[key]['color'],
                title: managemntData[key]['title'],
                id: key,
                createdBy: usersProfile[managemntData[key]['createdBy']]
                    ['displayName'],
                dateCreated: managemntData[key]['dateCreated'],
                department: managemntData[key]['department'],
                dueDate: managemntData[key]['dueDate']));
          }
        }
      }
    }
    return data;
  }

  bool allowEditing() {
    bool allowed = false;
    if (currentUser.status == OrgStatus.admin) {
      allowed = true;
    } else if (userData['orgData']['department'] == widget.epic) {
      allowed = true;
    } else if (fbLoc == 'Ind') {
      allowed = true;
    }
    return allowed;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.epic != currentEpic || fbLoc != widget.fbLoc) {
        setState(() {
          start();
          listenToFirebase();
        });
      }
    });

    return Container(
        height: widget.height,
        width: widget.width,
        decoration:
            BoxDecoration(color: Theme.of(context).canvasColor, boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(5, 3),
          ),
        ]),
        child: ProjectManager(
          labels: widget.labels,
          epic: widget.epic,
          startProject: widget.startProject,
          cardWidth: CSS.responsive(width: widget.width),
          width: widget.width,
          height: widget.height,
          allowEditing: allowEditing(),
          onProjectTap: (val) {
            if (widget.callback != null) {
              widget.callback!(
                call: LSICallbacks.ChangeTheme,
                info: {
                  'color':managemntData[val]['color'],
                  'data': managemntData,
                  'complete': timeLineDataComplete
                }
              );
            }
            if (widget.onTap != null) {
              widget.onTap!(val);
            }
          },
          onSubmit: (title, image, date, color) {
            DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
            String createdDate =
                dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
            Database.push('team', children: child + '/', data: {
              'department': widget.epic,
              'createdBy': currentUser.uid,
              'dateCreated': createdDate,
              'dueDate': (date != '') ? date : null,
              'title': title,
              'image': (image == '') ? 'temp' : image,
              'color': color,
            });
          },
          onUpdate: (title, image, date, color, project) {
            Database.update('team',
                children: child + '/',
                location: project,
                data: {
                  'department': widget.epic,
                  'createdBy': managemntData[project]
                      ['createdBy'], //currentUser['displayName'],
                  'dateCreated': managemntData[project]
                      ['dateCreated'], //createdDate,
                  'dueDate': (date != '') ? date : null,
                  'title': title,
                  'image': (image == '') ? 'temp' : image,
                  'color': color,
                });
          },
          onLabelsAdded: () {
            if (widget.onLabelAdded != null) {
              widget.onLabelAdded!();
            }
          },
          onComplete: (project) {
            DateFormat dayFormatter = DateFormat('y-MM-dd hh:mm:ss');
            String createdDate =
                dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
            Database.update('team',
                    children: child + '/' + project + '/',
                    location: 'complete',
                    data: {'markedBy': currentUser.uid, 'date': createdDate})
                .then((value) {
              Database.update('team',
                  children: 'managment/Cus/', location: project, data: null);
            });
          },
          onProjectDelete: (id) {
            Database.update('team', children: child, location: id, data: null);
          },
          onTitleChange: (id, title) {
            Database.update('team',
                children: child + '/' + id, location: 'title', data: title);
          },
          projectData: projectData(),
        ));
  }
}
