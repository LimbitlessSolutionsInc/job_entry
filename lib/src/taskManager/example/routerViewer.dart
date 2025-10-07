import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  bool testing = true;
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
    if (testing) {
      final String jsonString = await rootBundle.loadString('lib/src/assets/test_data.json');
      final Map<String, dynamic> testData = json.decode(jsonString);
      final router = testData['router'];

      usersProfile ??= {};
      usersProfile[router['createdBy']] = {
        'displayName': 'Test User',
        'imageUrl': null,
        'status': OrgStatus.admin,
        'canRemoteWork': true
      };
      
      managementData = {
        router['id']: {
          'color': router['color'],
          'title': router['title'],
          'id': router['id'],
          'createdBy': router['createdBy'],
          'dateCreated': router['dateCreated'],
        }
      };
      setState(() {});
    } else {

    }
  }

  List<RouterData> routerData() {
    List<RouterData> data = [];
    if (managementData != {}) {
      for (String key in managementData.keys) {
        if (key != 'title') {
            final createdById = managementData[key]['createdBy'];
            final createdByName = usersProfile['createdById']?['displayName'] ?? createdById;
            data.add(RouterData(
              color: managementData[key]['color'],
              title: managementData[key]['title'],
              id: key,
              createdBy: createdByName,
              dateCreated: managementData[key]['dateCreated'],
            ));
        }
      }
    }
    return data;
  }

  bool allowEditing() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.epic != currentEpic) {
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
        child: RouterManager(
          epic: widget.epic,
          cardWidth: CSS.responsive(width: widget.width),
          width: widget.width,
          height: widget.height,
          allowEditing: allowEditing(),
          onRouterTap: (val) {
            if (widget.callback != null) {
              widget.callback!(
                call: LSICallbacks.ChangeTheme,
                info: {
                  'color':managementData[val]['color'],
                  'data': managementData,
                  'complete': false
                }
              );
            }
            if (widget.onTap != null) {
              widget.onTap!(val);
            }
          },
          onSubmit: (title, image, date, color) {
            DateFormat dayFormatter = DateFormat('MM-dd-yy hh:mm:ss');
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
                  'createdBy': managementData[project]
                      ['createdBy'], //currentUser['displayName'],
                  'dateCreated': managementData[project]
                      ['dateCreated'], //createdDate,
                  'dueDate': (date != '') ? date : null,
                  'title': title,
                  'image': (image == '') ? 'temp' : image,
                  'color': color,
                });
          },
          onComplete: (project) {
            DateFormat dayFormatter = DateFormat('MM-dd-yy hh:mm:ss');
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
          onRouterDelete: (id) {
            Database.update('team', children: child, location: id, data: null);
          },
          onTitleChange: (id, title) {
            Database.update('team',
                children: child + '/' + id, location: 'title', data: title);
          },
          routerData: routerData(),
        ));
  }
}