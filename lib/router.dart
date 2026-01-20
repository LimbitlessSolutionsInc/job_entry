import 'package:job_entry/router.dart';
import 'package:css/css.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../src/organization/organization.dart';
import 'src/router_master.dart';
import '../../../styles/globals.dart';
import '../../../src/database/database.dart';
import '../../../src/database/push.dart';
import '../../../src/functions/lsi_functions.dart';
import 'styles/savedWidgets.dart';

enum SelectedView { routers, archive }

class RouterScreen extends StatefulWidget {
  RouterScreen({
    super.key,
    required this.size
  });

  final Size size;

  @override
  State<RouterScreen> createState() => _RouterScreenState();
}

class _RouterScreenState extends State<RouterScreen> {
  bool testing = false;
  bool update = false;
  bool showRouterView = true;
  String selectedProcess = '';
  String selectedRouter = '';
  SelectedView selectedView = SelectedView.routers;
  List<ProcessData> processList = [];
  List<JobData> jobList = [];
  List<DropDownItems> dropDownWorkers = [];
  List<DropDownItems> dropDownApprovers = [];

  dynamic routers = {};

  StreamSubscription<DatabaseEvent>? fbadded;
  StreamSubscription<DatabaseEvent>? fbchanged;
  StreamSubscription<DatabaseEvent>? fbremoved;

  @override
  void initState() {
    deviceWidth = widget.size.width;
    deviceHeight = widget.size.height;
    
    dropDownWorkers = [DropDownItems(value: '', text: 'Pick Workers')];
    if(Org.statusAllowed(StatusAllowed.allAdmins, currentUser.status)){
      for(String uid in allUsersData.keys){
        if(uid != 'Play Store' && allUsersData[uid]['orgData'] != null && Org.statusAllowed(StatusAllowed.all, Org.getOrgStatusFromString(allUsersData[uid]['orgData']['status'])) && 
          allUsersData[uid]['orgData']['active'] != null && allUsersData[uid]['orgData']['active']){
            dropDownWorkers.add( DropDownItems(value: uid, text: usersProfile[uid]['displayName']) );
        }
      }
    }
    else{
      for(String uid in userSchedules.keys){
        dropDownWorkers.add( DropDownItems(value: uid, text: usersProfile[uid]['displayName']) );
      }
    }

    dropDownApprovers = [DropDownItems(value: '', text: 'Pick Approvers')] + Org.managers;

    start();
    listenToFirebase();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void start() async {
    try{
      await Database.once('router/routers', 'team').then((value) {
        setState(() {
          routers = value;
        });
      });
      if (routers != null) {
        selectedRouter = routers.keys.first;
      } else {
        selectedRouter = '';
      }
      updateRouters();
    }
    catch(e){
      print('start -> exception: $e');
    }
  }

  void listenToFirebase() {
    try {
      if (testing) {
        // final String jsonString =
        //     await rootBundle.loadString('json/test_data.json');
        // routers = json.decode(jsonString);

        setState(() {});
        updateRouters();
      } else {
        DatabaseReference ref = Database.reference('router/routers', 'team');

        fbadded = ref.onChildAdded.listen((event) {
          print('Firebase Child Added: ${event.snapshot.key}');
          carryFunction(event);
        });

        fbchanged = ref.onChildChanged.listen((event) {
          print('Firebase Child Changed: ${event.snapshot.key}');
          carryFunction(event);
        });

        fbremoved = ref.onChildRemoved.listen((event) {
          setState(() {
            routers[event.snapshot.key] = {};
            routers = LSIFunctions.removeNull(routers);
            updateRouters();
          });
        });
      }
    } catch (e) {
      print('router.dart -> listenToFirebase -> Exception: $e');
    }
  }

  void carryFunction(event) {
    dynamic temp = event.snapshot.value;
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        routers[event.snapshot.key] = temp;
        updateRouters();
      });
    });
  }

  void updateRouters() {
    try {
      if(processList.isNotEmpty){ processList.clear(); }
      if(jobList.isNotEmpty){ jobList.clear(); }
      // final routerMap = routers['router'];
      // final routerKey = routerMap.keys.first;

      if (selectedRouter.isNotEmpty) {
        print('updateRouters called for $selectedRouter');
        final router = routers[selectedRouter];

        final processesMap = router['processes'];
        int index = 0;
        if(processesMap != null){
          for (String processID in processesMap.keys) {
            processList.add(ProcessData(
              id: processID,
              title: processesMap[processID]['title'],
              dateCreated: processesMap[processID]['dateCreated'],
              createdBy: processesMap[processID]['createdBy'],
              routerId: processesMap[processID]['routerId'],
              notify: processesMap[processID]['notify'] ?? false,
              order: processesMap[processID]['order'] ?? index,
            ));
            index++;
          }
        }
        //selectedProcess = processList.isNotEmpty ? processList.first.id! : '';

        final jobsMap = router['jobs'];
        if(jobsMap != null){
          for(String jobID in jobsMap.keys) {
            final j = jobsMap[jobID];
            jobList.add(JobData(
              id: jobID,
              title: j['title'],
              description: j['description'],
              dateCreated: j['dateCreated'],
              createdBy: j['createdBy'],
              priority: j['priority'] ?? 0,
              processId: j['processId'], 
              dueDate: j['dueDate'],
              completeDate: j['completedDate'],
              startDate: j['startDate'],
              workers: List<String>.from(j['workers']),
              approvers: List<String>.from(j['approvers'] ?? []),
              numApprovals: List<String>.from(j['approvers'] ?? []).length,
              status: JobStatus.values.firstWhere((e) => e.toString().split('.').last == j['status']),
              good: j['good'],
              bad: j['bad'],
              isApproved: List<String>.from(j['isApproved'] ?? []),
              isArchive: j['isArchive'],
              notes: (j['notes'] != null)
                  ? Map<String, dynamic>.from(j['notes'])
                  : null,
              prevJobs: (j['prevJobs'] != null)
                  ? Map<String, dynamic>.from(j['prevJobs'])
                  : null,
            ));
          }
        }
      }
      setState(() {});
    } catch (e) {
      print('router.dart -> updateRouters -> Exception: $e');
    }
  }

  List<RouterData> routerData() {
    List<RouterData> data = [];
    if (routers != null && routers.isNotEmpty) {
      for (String key in routers.keys) {
        data.add(RouterData(
          color: routers[key]['details']['color'],
          title: routers[key]['details']['title'],
          id: key,
          createdBy: usersProfile[routers[key]['details']['createdBy']]
              ['displayName'],
          dateCreated: routers[key]['details']['dateCreated'],
        ));
      }
    }
    return data;
  }

  Widget routerView(){
    return Container(
      width: (deviceWidth - 320) > 320 ? 265 : deviceWidth - 1,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: (deviceWidth - 320) > 320 ? 1 : 0,
          ),
        ),
      ),
      child: RouterManager(
        width: (deviceWidth - 320) > 320 ? 265 : deviceWidth - 1,
        height: deviceHeight - 25,
        cardWidth: CSS.responsive(width: (deviceWidth - 320) > 320 ? 265 : deviceWidth),
        allowEditing: true,
        routerData: routerData(),
        startRouter: selectedRouter,
        canArchiveRouter: (id){
          try{
            int processCount = routers[id]['processes'].keys.length;
            dynamic allJobs = routers[id]['jobs'];
            bool allJobsApproved = true;
            if(allJobs != null){
              for(String jobId in allJobs.keys){
                List<String> approvedList = [];
                if(allJobs[jobId]['isApproved'] != null){
                  approvedList = List<String>.from(allJobs[jobId]['isApproved']);
                }
                if(approvedList.length < processCount){
                  allJobsApproved = false;
                  break;
                }
              }
            }
            else{
              allJobsApproved = false;
            }

            print('routerView -> canArchiveRouter -> allJobsApproved for $id: processCount $processCount $allJobsApproved');

            return allJobsApproved;
          }
          catch(e){
            print('routerView -> canArchiveRouter -> exception: $e');
            return false;
          }
        },
        onRouterTap: (id) {
          setState(() {
            selectedRouter = id;
          });
          print('selectedRouter: $selectedRouter');
          updateRouters();
          setState(() {
            update = true;
            if(showRouterView && (deviceWidth - 320) <= 320){
              showRouterView = false;
            }
          });
        },
        onSubmit: (title, image, date, color) {
          DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
          String createdDate =
              dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
          Database.push('team', children: 'router/routers/', data: {
            'details': {
              'createdBy': currentUser.uid,
              'dateCreated': createdDate,
              'title': title,
              'color': color,
            }
          });
        },
        onUpdate: (title, image, date, color, id) {
          DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
          String createdDate = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
          Database.update(
            'team',
            children: 'router/routers/$id',
            location: 'details',
            data: {
              'createdBy': currentUser.uid,
              'dateCreated': createdDate,
              'title': title,
              'color': color,
            }
          );
        },
        //don't think we need to declare routers as empty
        // onComplete: (id) {
        //   DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
        //   String createdDate = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
        //   Database.update(
        //     'team',
        //     children: 'router/routers/$id/details',
        //     location: 'complete',
        //     data: {'markedBy': currentUser.uid, 'date': createdDate}).then((value) {
        //       Database.update(
        //         'team',
        //         children: 'managment/Cus/',
        //         location: project,
        //         data: null
        //       );
        //     }
        //   );
        // },
        onRouterDelete: (id) {
          try {
            Database.update(
              'team',
              children: 'router/archive',
              location: id,
              data: routers[id]
            );

            Database.update(
              'team',
              children: 'router/archive/$id/details',
              location: 'dateArchived',
              data: DateFormat('MM-dd-yyyy hh:mm:ss')
                  .format(DateTime.now())
                  .replaceAll(' ', 'T'),
            );
 
            Database.update(
              'team',
              children: 'router/archive/$id/details',
              location: 'archivedBy',
              data: currentUser.uid
            );

            Database.update(
              'team',
              children: 'router/routers', 
              location: id, 
              data: null
            );
          } catch (e) {
            print('router.dart -> onRouterDelete -> Exception: $e');
          }
        },
        onTitleChange: (id, title) {
          Database.update(
            'team',
            children: 'router/routers/$id',
            location: 'title',
            data: title
          );
        },
      )
    );
  }

  Widget processView(){
    return ProcessManager(
      update: update,
      allowEditing: true,
      width: (deviceWidth - 320) > 320 ? deviceWidth - 265 : deviceWidth,
      height: deviceHeight - 25,
      routerId: selectedRouter,
      processData: processList,
      jobData: jobList,
      screenOffset: Offset(
        (!useSideNav)? 0: ((showList)? navSize.width + sideListSize + 265:navSize.width + 265),
        (!useSideNav) ? appBarHeight : 0
      ),
      callback: () {
        setState(() {
          update = false;
        });
      },
      workers: dropDownWorkers,
      approvers: dropDownApprovers,
      onSubmit: (title, notify) {
        DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
        String date = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
        
        Database.push(
          'team',
          children: 'router/routers/$selectedRouter/processes',
          data: {
            'createdBy': currentUser.uid,
            'routerId': selectedRouter,
            'dateCreated': date,
            'title': title,
            'notify': notify,
            'order': processList.length,
          }
        );
      },
      onEdit: (data, id) {
        Database.update('team',
            children: 'router/routers/$selectedRouter/processes',
            location: id,
            data: data);
      },
      onCreateJob: (data) {
        if (data['workers'] != null) {
          List<String> sendTo = [];
          for (int i = 0; i < data['workers'].length; i++) {
            if (data['workers'][i] != currentUser.uid) {
              sendTo.add(data['workers'][i]);
            }
          }
          if (sendTo.isNotEmpty) {
            print('sendTo: $sendTo');
            Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
                '${currentUser.displayName} assigned you to a new job!');
          }
        }
        if (data['approvers'] != null) {
          List<String> sendTo = [];
          for (int i = 0; i < data['approvers'].length; i++) {
            if (data['approvers'][i] != currentUser.uid) {
              sendTo.add(data['approvers'][i]);
            }
          }
          if (sendTo.isNotEmpty) {
            print('sendTo: $sendTo');
            Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
              '${currentUser.displayName} assigned you as an approver to a new job');
          }
        }
        print('onCreateJob data for $selectedRouter: $data');
        Database.push(
          'team',
          children: 'router/routers/$selectedRouter/jobs',
          data: data,
        ).then((value) {
          setState(() {
            update = true;
          });
        });
      },
      onEditJob: (data, loc, newWorkers) {
        List<String> uids = [];
        int currentCards = 0;

        // for (String i in currentJobData.keys) {
        //   if (currentJobData[i]!.id == loc) {
        //     currentCards = (currentJobData[i]!.notes == null)? 0:currentJobData[i]!.notes!.length;
        //   }
        // }
        if (data['workers'] != null && !data['workers'].toString().contains(currentUser.uid)) {
          for (int i = 0; i < data['workers'].length; i++) {
            uids.add(data['workers'][i]);
          }
        }
        if (data['notes'] != null) {
          if (currentCards != data['notes'].length) {
            for (String key in data['notes'].keys) {
              if (data['notes'][key]['createdBy'] !=
                  currentUser.uid) {
                uids.add(data['notes'][key]['createdBy']);
              }
            }
          }
        }
        if (data['workers'] != null && newWorkers.isNotEmpty) {
          List<String> sendTo = [];
          for (int i = 0; i < newWorkers.length; i++) {
            if (newWorkers[i] != currentUser.uid && data['workers'].contains(newWorkers[i])) {
              uids.add(newWorkers[i]);
            }
          }
          sendTo = uids.toSet().toList();

          if (sendTo.isNotEmpty) {
            Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
              '${currentUser.displayName} assigned you to a new job!');
          }
        }
        Database.update(
          'team',
          children: 'router/routers/$selectedRouter/jobs',
          location: loc,
          data: data
        ).then((value) {
          setState(() {
            update = true;
          });
        });
      },
      onProcessOrderChange: (val) { //continue -nlw
        String child = 'router/routers/$selectedRouter';
        Database.update(
          'team',
          children: child,
          location: 'processes',
          data: val
        );
      },
      onJobPriorityChange: (val, change) {
        try{
          JobData job = jobList.firstWhere((job) => job.id == change['job']);
          ProcessData newProcess = processList.firstWhere((proc) => proc.id == val[change['job']]['processId']);
          ProcessData oldProcess = processList.firstWhere((proc) => proc.id == change['process']);
          if (job.processId != change['process'] && oldProcess.notify) {
            List<String> allowSend = [];
            for(int i = 0; i < job.workers.length; i++){
              if(job.workers[i] != currentUser.uid) {
                allowSend.add(job.workers[i]);
              }
            }
            for(int i = 0; i < job.approvers.length; i++){
              if(job.approvers[i] != currentUser.uid && !allowSend.contains(job.approvers[i])) {
                allowSend.add(job.approvers[i]);
              }
            }
            if(allowSend.isNotEmpty){
              Messaging.sendPushMessage(
                allowSend,
                'LSI Router Manager', 
                '${job.title} has moved to ${newProcess.title}'
              );
            }
          }
          String child = 'router/routers/$selectedRouter';
          for (String key in val.keys) {
            Database.update(
              'team',
              children: '$child/jobs/$key',
              location: 'priority',
              data: val[key]['priority']
            );
            Database.update(
              'team',
              children: '$child/jobs/$key',
              location: 'processId',
              data: val[key]['processId']
            );
          }
        }
        catch(e){
          print('onJobPriorityChange -> exception: $e');
        }
      },
      onJobDelete: (id) {
        Database.update(
          'team',
          children: 'router/routers/archive/$selectedRouter/jobs',
          location: id,
          data: routers[selectedRouter]['jobs'][id],
        ).then((value) {
          Database.update(
            'team',
            children: 'router/routers/$selectedRouter/jobs',
            location: id,
            data: null,
          );
        });
      },
      onProcessDelete: (id) {
        Database.update(
          'team',
          children: 'router/routers/archive/$selectedRouter/processes',
          location: id,
          data: routers[selectedRouter]['processes'][id],
        ).then((value) {
          Database.update(
            'team',
            children: 'router/routers/$selectedRouter/processes',
            location: id,
            data: null,
          );
        });
      },
      onTitleChange: (id, title) {
        Database.update(
          'team',
          children: 'router/routers/$selectedRouter/processes/$id',
          location: 'title',
          data: title
        );
      },
    );
  }

  Widget archiveView(){
    return RouterArchiveManager(
      width: deviceWidth,
      height: deviceHeight - appBarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        setState(() {
          // widget.callback(
          //     call: LSICallbacks.gotoPage, place: AppScreens.main);
        });
      },
      child: Container(
        height: deviceHeight,
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10),
              width: deviceWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).primaryColorDark,
                      width: 1),
                ),
              ),
              child: Tabs(
                tabs: const ['Routers', 'Archive'],
                selectedTab: selectedView.index,
                height: 25,
                width: deviceWidth < 500 ? deviceWidth : 500,
                onTap: (val) {
                  setState(() {
                    selectedView = SelectedView.values.elementAt(val);
                  });
                },
              ),
            ),
            SizedBox(
              height: deviceHeight - 40,
              child: selectedView == SelectedView.routers
              ? ((deviceWidth - 320) > 320
                  ? Row(children: [routerView(), processView()])
                  : Stack(
                    children: [
                      showRouterView ? routerView() : processView(),
                      LSIFloatingActionButton(
                        alignment: Alignment.bottomLeft,
                        allowed: true, 
                        color: Theme.of(context).secondaryHeaderColor, 
                        icon: (showRouterView ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
                        onTap: (){
                          setState(() {
                            showRouterView = !showRouterView;
                          });
                        }
                      )
                    ]
                  )
                ) : archiveView()
            )
          ],
        ),
      ),
    );
  }
}
