// import 'package:job_entry/router.dart';
// import 'package:css/css.dart';

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/services.dart' show rootBundle;

// import '../../../src/organization/organization.dart';
// import 'src/router_master.dart';
// import '../../../styles/globals.dart';
// import '../../../src/database/database.dart';
// import '../../../src/database/push.dart';
// import '../../../src/functions/lsi_functions.dart';
// import 'styles/savedWidgets.dart';

// enum SelectedView { routers, archive }

// class RouterScreen extends StatefulWidget {
//   RouterScreen({super.key, required this.size});

//   final Size size;

//   @override
//   State<RouterScreen> createState() => _RouterScreenState();
// }

// class _RouterScreenState extends State<RouterScreen> {
//   bool testing = true;
//   bool update = false;
//   bool showRouterView = true;
//   String selectedProcess = '';
//   String selectedRouter = '';
//   SelectedView selectedView = SelectedView.routers;
//   List<ProcessData> processList = [];
//   List<JobData> jobList = [];
//   List<DropDownItems> dropDownWorkers = [];
//   List<DropDownItems> dropDownApprovers = [];

//   dynamic routers = {};

//   StreamSubscription<DatabaseEvent>? fbadded;
//   StreamSubscription<DatabaseEvent>? fbchanged;
//   StreamSubscription<DatabaseEvent>? fbremoved;

//   @override
//   void initState() {
//     currentUser = UsersProfile(
//         uid: 'testUser',
//         displayName: 'Test User',
//         status: OrgStatus.admin,
//         imageUrl: null,
//         canRemoteWork: true);

//     deviceWidth = widget.size.width;
//     deviceHeight = widget.size.height;

//     dropDownWorkers = [DropDownItems(value: '', text: 'Pick Workers')];
//     if (Org.statusAllowed(StatusAllowed.allAdmins, currentUser.status)) {
//       if (allUsersData != null && allUsersData.isNotEmpty) {
//         for (String uid in allUsersData.keys) {
//           if (uid != 'Play Store' &&
//               allUsersData[uid]['orgData'] != null &&
//               Org.statusAllowed(
//                   StatusAllowed.all,
//                   Org.getOrgStatusFromString(
//                       allUsersData[uid]['orgData']['status'])) &&
//               allUsersData[uid]['orgData']['active'] != null &&
//               allUsersData[uid]['orgData']['active']) {
//             if (usersProfile != null && usersProfile.containsKey(uid)) {
//               dropDownWorkers.add(DropDownItems(
//                   value: uid, text: usersProfile[uid]['displayName']));
//             }
//           }
//         }
//       }
//     } else {
//       if (userSchedules != null && userSchedules.isNotEmpty) {
//         for (String uid in userSchedules.keys) {
//           if (usersProfile != null && usersProfile.containsKey(uid)) {
//             dropDownWorkers.add(DropDownItems(
//                 value: uid, text: usersProfile[uid]['displayName']));
//           }
//         }
//       }
//     }

//     dropDownApprovers = [DropDownItems(value: '', text: 'Pick Approvers')];
//     if (Org.managers != null && Org.managers.isNotEmpty) {
//       dropDownApprovers.addAll(Org.managers);
//     }

//     start();
//     listenToFirebase();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void start() async {
//     try {
//       if (testing) {
//         try {
//           final String jsonString =
//               await rootBundle.loadString('lib/src/assets/test_data.json');
//           final testData = json.decode(jsonString);
//           print(
//               'Test data loaded successfully: ${testData['router']?.keys.toList()}');
//           if (mounted) {
//             setState(() {
//               routers = testData['router'] ?? {};
//             });
//           }
//         } catch (loadError) {
//           print('ERROR loading test_data.json: $loadError');
//           rethrow;
//         }
//       } else {
//         try {
//           final value = await Database.once('router/routers', 'team');
//           if (mounted) {
//             setState(() {
//               routers = (value is Map) ? value : {};
//             });
//           }
//         } catch (dbError) {
//           print('Database error in start: $dbError');
//           if (mounted) {
//             setState(() {
//               routers = {};
//             });
//           }
//         }
//       }

//       if (routers is Map && routers.isNotEmpty) {
//         String firstKey = routers.keys.first;
//         if (mounted) {
//           setState(() {
//             selectedRouter = firstKey;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             selectedRouter = '';
//           });
//         }
//       }
//       updateRouters();
//     } catch (e) {
//       print('start -> exception: $e');
//       if (mounted) {
//         setState(() {
//           routers = {};
//           selectedRouter = '';
//         });
//       }
//     }
//   }

//   Future<void> listenToFirebase() async {
//     try {
//       if (testing) {
//         final String jsonString =
//             await rootBundle.loadString('lib/src/assets/test_data.json');
//         final testData = json.decode(jsonString);
//         setState(() {
//           routers = testData['router'] ?? {};
//         });
//         updateRouters();
//       } else {
//         DatabaseReference ref = Database.reference('router/routers', 'team');

//         fbadded = ref.onChildAdded.listen((event) {
//           print('Firebase Child Added: ${event.snapshot.key}');
//           carryFunction(event);
//         });

//         fbchanged = ref.onChildChanged.listen((event) {
//           print('Firebase Child Changed: ${event.snapshot.key}');
//           carryFunction(event);
//         });

//         fbremoved = ref.onChildRemoved.listen((event) {
//           setState(() {
//             routers[event.snapshot.key] = {};
//             routers = LSIFunctions.removeNull(routers);
//             updateRouters();
//           });
//         });
//       }
//     } catch (e) {
//       print('router.dart -> listenToFirebase -> Exception: $e');
//     }
//   }

//   void carryFunction(event) {
//     dynamic temp = event.snapshot.value;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         routers[event.snapshot.key] = temp;
//         updateRouters();
//       });
//     });
//   }

//   int _parsePriority(dynamic priority) {
//     print('Parsing priority: $priority');
//     if (priority is int) return priority;
//     if (priority is String) {
//       switch (priority.toLowerCase()) {
//         case 'high':
//           return 0;
//         case 'medium':
//           return 1;
//         case 'low':
//           return 2;
//         default:
//           return 0;
//       }
//     }
//     return 0;
//   }

//   JobStatus _parseJobStatus(dynamic status) {
//     print('Parsing job status: $status');
//     if (status is String) {
//       switch (status.toLowerCase()) {
//         case 'not_started':
//           return JobStatus.notStarted;
//         case 'in_progress':
//           return JobStatus.inProgress;
//         case 'completed':
//           return JobStatus.completed;
//         default:
//           return JobStatus.notStarted;
//       }
//     }
//     return JobStatus.notStarted;
//   }

//   void updateRouters() {
//     try {
//       if (processList.isNotEmpty) {
//         processList.clear();
//       }
//       if (jobList.isNotEmpty) {
//         jobList.clear();
//       }

//       if (selectedRouter.isNotEmpty) {
//         print('updateRouters called for $selectedRouter');
//         final router = routers[selectedRouter];

//         // Load processes
//         final processesMap = router['processes'];
//         int index = 0;
//         final Set<String> addedJobIds = {}; // avoid duplicates
//         if (processesMap != null) {
//           for (String processID in processesMap.keys) {
//             final proc = processesMap[processID];
//             processList.add(ProcessData(
//               id: processID,
//               title: proc['title'],
//               dateCreated: proc['dateCreated'],
//               createdBy: proc['createdBy'],
//               routerId: proc['routerId'] ?? selectedRouter,
//               notify: proc['notify'] ?? false,
//               order: proc['order'] ?? index,
//             ));

//             // If jobs are nested under the process, load them here
//             final processJobs = proc['jobs'];
//             if (processJobs != null) {
//               for (String jobID in processJobs.keys) {
//                 try {
//                   final j = processJobs[jobID];
//                   jobList.add(JobData(
//                     id: jobID,
//                     title: j['title'],
//                     description: j['description'],
//                     dateCreated: j['dateCreated'],
//                     createdBy: j['createdBy'],
//                     priority: _parsePriority(j['priority']),
//                     processId: processID,
//                     dueDate: j['dueDate'],
//                     completeDate: j['completeDate'] ?? j['endDate'],
//                     startDate: j['startDate'],
//                     workers: (j['workers'] != null)
//                         ? List<String>.from(j['workers'])
//                         : <String>[],
//                     approvers: (j['approvers'] != null)
//                         ? List<String>.from(j['approvers'])
//                         : <String>[],
//                     numApprovals: (j['approvers'] != null)
//                         ? List<String>.from(j['approvers']).length
//                         : 0,
//                     good: j['good'],
//                     bad: j['bad'],
//                     isApproved: (j['isApproved'] != null)
//                         ? List<String>.from(j['isApproved'])
//                         : <String>[],
//                     isArchive: j['isArchive'],
//                     notes: (j['notes'] != null)
//                         ? Map<String, dynamic>.from(j['notes'])
//                         : null,
//                     prevJobs: (j['prevJobs'] != null)
//                         ? Map<String, dynamic>.from(j['prevJobs'])
//                         : null,
//                   ));
//                   addedJobIds.add(jobID);
//                 } catch (jobError) {
//                   print('Error loading nested job $jobID: $jobError');
//                 }
//               }
//             }

//             index++;
//           }
//         }

//         // Load jobs from router level
//         final jobsMap = router['jobs'];
//         if (jobsMap != null) {
//           for (String jobID in jobsMap.keys) {
//             if (addedJobIds.contains(jobID)) continue;
//             try {
//               final j = jobsMap[jobID];
//               jobList.add(JobData(
//                 id: jobID,
//                 title: j['title'],
//                 description: j['description'],
//                 dateCreated: j['dateCreated'],
//                 createdBy: j['createdBy'],
//                 priority: _parsePriority(j['priority']),
//                 processId: j['processId'],
//                 dueDate: j['dueDate'],
//                 completeDate: j['completeDate'],
//                 startDate: j['startDate'],
//                 workers: (j['workers'] != null)
//                     ? List<String>.from(j['workers'])
//                     : <String>[],
//                 approvers: (j['approvers'] != null)
//                     ? List<String>.from(j['approvers'])
//                     : <String>[],
//                 numApprovals: (j['approvers'] != null)
//                     ? List<String>.from(j['approvers']).length
//                     : 0,
//                 status: _parseJobStatus(j['status']),
//                 good: j['good'],
//                 bad: j['bad'],
//                 isApproved: (j['isApproved'] != null)
//                     ? List<String>.from(j['isApproved'])
//                     : <String>[],
//                 isArchive: j['isArchive'],
//                 notes: (j['notes'] != null)
//                     ? Map<String, dynamic>.from(j['notes'])
//                     : null,
//                 prevJobs: (j['prevJobs'] != null)
//                     ? Map<String, dynamic>.from(j['prevJobs'])
//                     : null,
//               ));
//             } catch (jobError) {
//               print('Error loading job $jobID: $jobError');
//             }
//           }
//         }
//       }

//       print('Loaded processes: ${processList.length}');
//       print('Loaded jobs: ${jobList.length}');
//       if (jobList.isNotEmpty) {
//         print(
//             'First job: ${jobList.first.id} -> processId=${jobList.first.processId}');
//       }

//       setState(() {});
//     } catch (e) {
//       print('router.dart -> updateRouters -> Exception: $e');
//     }
//   }

//   List<RouterData> routerData() {
//     List<RouterData> data = [];
//     if (routers != null && routers.isNotEmpty) {
//       for (String key in routers.keys) {
//         try {
//           final createdByUid = routers[key]['details']['createdBy'];
//           String displayName = 'Unknown';
//           if (usersProfile != null && usersProfile.containsKey(createdByUid)) {
//             displayName =
//                 usersProfile[createdByUid]['displayName'] ?? 'Unknown';
//           }

//           // Parse color from string or use as-is if int
//           dynamic colorValue = routers[key]['details']['color'];
//           int colorInt;
//           if (colorValue is String) {
//             // Remove '0x' or '0X' prefix if present
//             String colorStr = colorValue.replaceFirst(RegExp(r'^0[xX]'), '');
//             colorInt = int.parse(colorStr, radix: 16);
//           } else if (colorValue is int) {
//             colorInt = colorValue;
//           } else {
//             colorInt = 0xFF42A5F5; // Default blue
//           }

//           data.add(RouterData(
//             color: colorInt,
//             title: routers[key]['details']['title'],
//             id: key,
//             createdBy: displayName,
//             dateCreated: routers[key]['details']['dateCreated'],
//           ));
//         } catch (e) {
//           print('routerData error for key $key: $e');
//         }
//       }
//     }
//     return data;
//   }

//   Widget routerView() {
//     return Container(
//         width: (deviceWidth - 320) > 320 ? 265 : deviceWidth - 1,
//         decoration: BoxDecoration(
//           border: Border(
//             right: BorderSide(
//               color: Theme.of(context).primaryColorDark,
//               width: (deviceWidth - 320) > 320 ? 1 : 0,
//             ),
//           ),
//         ),
//         child: RouterManager(
//           width: (deviceWidth - 320) > 320 ? 265 : deviceWidth - 1,
//           height: deviceHeight - 25,
//           cardWidth: CSS.responsive(
//               width: (deviceWidth - 320) > 320 ? 265 : deviceWidth),
//           allowEditing: true,
//           routerData: routerData(),
//           startRouter: selectedRouter,
//           canArchiveRouter: (id) {
//             try {
//               // determine number of processes
//               final procMap = routers[id]?['processes'];
//               int processCount = (procMap != null) ? procMap.keys.length : 0;

//               // aggregate jobs: prefer jobs nested under processes, otherwise fallback to router-level jobs
//               Map<String, dynamic> aggregatedJobs = {};
//               if (procMap != null) {
//                 for (String pId in procMap.keys) {
//                   final pJobs = procMap[pId]?['jobs'];
//                   if (pJobs != null && pJobs is Map) {
//                     aggregatedJobs.addAll(Map<String, dynamic>.from(pJobs));
//                   }
//                 }
//               }
//               if (aggregatedJobs.isEmpty && routers[id]?['jobs'] != null) {
//                 aggregatedJobs = Map<String, dynamic>.from(routers[id]['jobs']);
//               }

//               bool allJobsApproved = true;
//               if (aggregatedJobs.isNotEmpty && processCount > 0) {
//                 for (String jobId in aggregatedJobs.keys) {
//                   List<String> approvedList = [];
//                   final jobObj = aggregatedJobs[jobId];
//                   if (jobObj != null && jobObj['isApproved'] != null) {
//                     try {
//                       approvedList = List<String>.from(jobObj['isApproved']);
//                     } catch (_) {
//                       approvedList = [];
//                     }
//                   }
//                   if (approvedList.length < processCount) {
//                     allJobsApproved = false;
//                     break;
//                   }
//                 }
//               } else {
//                 allJobsApproved = false;
//               }

//               print(
//                   'routerView -> canArchiveRouter -> allJobsApproved for $id: processCount $processCount $allJobsApproved');

//               return allJobsApproved;
//             } catch (e) {
//               print('routerView -> canArchiveRouter -> exception: $e');
//               return false;
//             }
//           },
//           onRouterTap: (id) {
//             setState(() {
//               selectedRouter = id;
//             });
//             print('selectedRouter: $selectedRouter');
//             updateRouters();
//             setState(() {
//               update = true;
//               if (showRouterView && (deviceWidth - 320) <= 320) {
//                 showRouterView = false;
//               }
//             });
//           },
//           onSubmit: (title, image, date, color) {
//             DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
//             String createdDate =
//                 dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
//             Database.push('team', children: 'router/routers/', data: {
//               'details': {
//                 'createdBy': currentUser.uid,
//                 'dateCreated': createdDate,
//                 'title': title,
//                 'color': color,
//               }
//             });
//           },
//           onUpdate: (title, image, date, color, id) {
//             DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
//             String createdDate =
//                 dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
//             Database.update('team',
//                 children: 'router/routers/$id',
//                 location: 'details',
//                 data: {
//                   'createdBy': currentUser.uid,
//                   'dateCreated': createdDate,
//                   'title': title,
//                   'color': color,
//                 });
//           },
//           //don't think we need to declare routers as empty
//           // onComplete: (id) {
//           //   DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
//           //   String createdDate = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');
//           //   Database.update(
//           //     'team',
//           //     children: 'router/routers/$id/details',
//           //     location: 'complete',
//           //     data: {'markedBy': currentUser.uid, 'date': createdDate}).then((value) {
//           //       Database.update(
//           //         'team',
//           //         children: 'managment/Cus/',
//           //         location: project,
//           //         data: null
//           //       );
//           //     }
//           //   );
//           // },
//           onRouterDelete: (id) {
//             try {
//               Database.update('team',
//                   children: 'router/archive', location: id, data: routers[id]);

//               Database.update(
//                 'team',
//                 children: 'router/archive/$id/details',
//                 location: 'dateArchived',
//                 data: DateFormat('MM-dd-yyyy hh:mm:ss')
//                     .format(DateTime.now())
//                     .replaceAll(' ', 'T'),
//               );

//               Database.update('team',
//                   children: 'router/archive/$id/details',
//                   location: 'archivedBy',
//                   data: currentUser.uid);

//               Database.update('team',
//                   children: 'router/routers', location: id, data: null);
//             } catch (e) {
//               print('router.dart -> onRouterDelete -> Exception: $e');
//             }
//           },
//           onTitleChange: (id, title) {
//             Database.update('team',
//                 children: 'router/routers/$id', location: 'title', data: title);
//           },
//         ));
//   }

//   Widget processView() {
//     return ProcessManager(
//       update: update,
//       allowEditing: true,
//       width: (deviceWidth - 320) > 320 ? deviceWidth - 265 : deviceWidth,
//       height: deviceHeight - 25,
//       routerId: selectedRouter,
//       processData: processList,
//       jobData: jobList,
//       screenOffset: Offset(
//           (!useSideNav)
//               ? 0
//               : ((showList)
//                   ? navSize.width + sideListSize + 265
//                   : navSize.width + 265),
//           (!useSideNav) ? appBarHeight : 0),
//       callback: () {
//         setState(() {
//           update = false;
//         });
//       },
//       workers: dropDownWorkers,
//       approvers: dropDownApprovers,
//       onSubmit: (title, notify) {
//         DateFormat dayFormatter = DateFormat('MM-dd-yyyy hh:mm:ss');
//         String date = dayFormatter.format(DateTime.now()).replaceAll(' ', 'T');

//         Database.push('team',
//             children: 'router/routers/$selectedRouter/processes',
//             data: {
//               'createdBy': currentUser.uid,
//               'routerId': selectedRouter,
//               'dateCreated': date,
//               'title': title,
//               'notify': notify,
//               'order': processList.length,
//             });
//       },
//       onEdit: (data, id) {
//         Database.update('team',
//             children: 'router/routers/$selectedRouter/processes',
//             location: id,
//             data: data);
//       },
//       onCreateJob: (data) {
//         if (data['workers'] != null) {
//           List<String> sendTo = [];
//           for (int i = 0; i < data['workers'].length; i++) {
//             if (data['workers'][i] != currentUser.uid) {
//               sendTo.add(data['workers'][i]);
//             }
//           }
//           if (sendTo.isNotEmpty) {
//             print('sendTo: $sendTo');
//             Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
//                 '${currentUser.displayName} assigned you to a new job!');
//           }
//         }
//         if (data['approvers'] != null) {
//           List<String> sendTo = [];
//           for (int i = 0; i < data['approvers'].length; i++) {
//             if (data['approvers'][i] != currentUser.uid) {
//               sendTo.add(data['approvers'][i]);
//             }
//           }
//           if (sendTo.isNotEmpty) {
//             print('sendTo: $sendTo');
//             Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
//                 '${currentUser.displayName} assigned you as an approver to a new job');
//           }
//         }
//         print('onCreateJob data for $selectedRouter: $data');
//         Database.push(
//           'team',
//           children: 'router/routers/$selectedRouter/jobs',
//           data: data,
//         ).then((value) {
//           setState(() {
//             update = true;
//           });
//         });
//       },
//       onEditJob: (data, loc, newWorkers) {
//         List<String> uids = [];
//         int currentCards = 0;

//         // for (String i in currentJobData.keys) {
//         //   if (currentJobData[i]!.id == loc) {
//         //     currentCards = (currentJobData[i]!.notes == null)? 0:currentJobData[i]!.notes!.length;
//         //   }
//         // }
//         if (data['workers'] != null &&
//             !data['workers'].toString().contains(currentUser.uid)) {
//           for (int i = 0; i < data['workers'].length; i++) {
//             uids.add(data['workers'][i]);
//           }
//         }
//         if (data['notes'] != null) {
//           if (currentCards != data['notes'].length) {
//             for (String key in data['notes'].keys) {
//               if (data['notes'][key]['createdBy'] != currentUser.uid) {
//                 uids.add(data['notes'][key]['createdBy']);
//               }
//             }
//           }
//         }
//         if (data['workers'] != null && newWorkers.isNotEmpty) {
//           List<String> sendTo = [];
//           for (int i = 0; i < newWorkers.length; i++) {
//             if (newWorkers[i] != currentUser.uid &&
//                 data['workers'].contains(newWorkers[i])) {
//               uids.add(newWorkers[i]);
//             }
//           }
//           sendTo = uids.toSet().toList();

//           if (sendTo.isNotEmpty) {
//             Messaging.sendPushMessage(sendTo, 'LSI Router Manager',
//                 '${currentUser.displayName} assigned you to a new job!');
//           }
//         }
//         Database.update('team',
//                 children: 'router/routers/$selectedRouter/jobs',
//                 location: loc,
//                 data: data)
//             .then((value) {
//           setState(() {
//             update = true;
//           });
//         });
//       },
//       onProcessOrderChange: (val) {
//         //continue -nlw
//         String child = 'router/routers/$selectedRouter';
//         Database.update('team',
//             children: child, location: 'processes', data: val);
//       },
//       onJobPriorityChange: (val, change) {
//         try {
//           JobData job = jobList.firstWhere((job) => job.id == change['job']);
//           ProcessData newProcess = processList
//               .firstWhere((proc) => proc.id == val[change['job']]['processId']);
//           ProcessData oldProcess =
//               processList.firstWhere((proc) => proc.id == change['process']);
//           if (job.processId != change['process'] && oldProcess.notify) {
//             List<String> allowSend = [];
//             for (int i = 0; i < job.workers.length; i++) {
//               if (job.workers[i] != currentUser.uid) {
//                 allowSend.add(job.workers[i]);
//               }
//             }
//             for (int i = 0; i < job.approvers.length; i++) {
//               if (job.approvers[i] != currentUser.uid &&
//                   !allowSend.contains(job.approvers[i])) {
//                 allowSend.add(job.approvers[i]);
//               }
//             }
//             if (allowSend.isNotEmpty) {
//               Messaging.sendPushMessage(allowSend, 'LSI Router Manager',
//                   '${job.title} has moved to ${newProcess.title}');
//             }
//           }
//           String child = 'router/routers/$selectedRouter';
//           for (String key in val.keys) {
//             Database.update('team',
//                 children: '$child/jobs/$key',
//                 location: 'priority',
//                 data: val[key]['priority']);
//             Database.update('team',
//                 children: '$child/jobs/$key',
//                 location: 'processId',
//                 data: val[key]['processId']);
//           }
//         } catch (e) {
//           print('onJobPriorityChange -> exception: $e');
//         }
//       },
//       onJobDelete: (id) {
//         Database.update(
//           'team',
//           children: 'router/routers/archive/$selectedRouter/jobs',
//           location: id,
//           data: routers[selectedRouter]['jobs'][id],
//         ).then((value) {
//           Database.update(
//             'team',
//             children: 'router/routers/$selectedRouter/jobs',
//             location: id,
//             data: null,
//           );
//         });
//       },
//       onProcessDelete: (id) {
//         Database.update(
//           'team',
//           children: 'router/routers/archive/$selectedRouter/processes',
//           location: id,
//           data: routers[selectedRouter]['processes'][id],
//         ).then((value) {
//           Database.update(
//             'team',
//             children: 'router/routers/$selectedRouter/processes',
//             location: id,
//             data: null,
//           );
//         });
//       },
//       onTitleChange: (id, title) {
//         Database.update('team',
//             children: 'router/routers/$selectedRouter/processes/$id',
//             location: 'title',
//             data: title);
//       },
//     );
//   }

//   Widget archiveView() {
//     return RouterArchiveManager(
//       width: deviceWidth,
//       height: deviceHeight - appBarHeight,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) {
//           return;
//         }
//         setState(() {
//           // widget.callback(
//           //     call: LSICallbacks.gotoPage, place: AppScreens.main);
//         });
//       },
//       child: Container(
//         height: deviceHeight,
//         color: Theme.of(context).cardColor,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.only(top: 10),
//               width: deviceWidth,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 border: Border(
//                   bottom: BorderSide(
//                       color: Theme.of(context).primaryColorDark, width: 1),
//                 ),
//               ),
//               child: Tabs(
//                 tabs: const ['Routers', 'Archive'],
//                 selectedTab: selectedView.index,
//                 height: 25,
//                 width: deviceWidth < 500 ? deviceWidth : 500,
//                 onTap: (val) {
//                   setState(() {
//                     selectedView = SelectedView.values.elementAt(val);
//                   });
//                 },
//               ),
//             ),
//             SizedBox(
//                 height: deviceHeight - 40,
//                 child: selectedView == SelectedView.routers
//                     ? ((deviceWidth - 320) > 320
//                         ? Row(children: [routerView(), processView()])
//                         : Stack(children: [
//                             showRouterView ? routerView() : processView(),
//                             LSIFloatingActionButton(
//                                 alignment: Alignment.bottomLeft,
//                                 allowed: true,
//                                 color: Theme.of(context).secondaryHeaderColor,
//                                 icon: (showRouterView
//                                     ? Icons.arrow_forward_ios
//                                     : Icons.arrow_back_ios),
//                                 onTap: () {
//                                   setState(() {
//                                     showRouterView = !showRouterView;
//                                   });
//                                 })
//                           ]))
//                     : archiveView())
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../src/organization/organization.dart';
import '../src/managers/routerManager.dart';
import '../src/data/routerData.dart';
import '../styles/globals.dart';
import 'package:css/css.dart' as css;

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  // final Size size;

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  bool showRouterList = true;
  String? selectedRouterId;
  RouterData? selectedRouter;

  final List<RouterData> routers = [
    // Sample data can be added here for demo
  ];

  @override
  void initState() {
    super.initState();
    selectedRouterId = routers.isNotEmpty ? routers[0].id : null;

    currentUser = UsersProfile(
      uid: 'testUser',
      displayName: 'Test User',
      status: OrgStatus.admin,
      imageUrl: null,
      canRemoteWork: true,
    );

    // deviceWidth = widget.size.width;
    // deviceHeight = widget.size.height;
  }

  void _togglePane() {
    setState(() => showRouterList = !showRouterList);
  }

  void _onRouterSelected(String routerId, List<RouterData> routersList) {
    setState(() {
      selectedRouterId = routerId;
      selectedRouter = routersList.firstWhere(
        (r) => r.id == routerId,
        orElse: () => routersList.first,
      );
    });
  }

  // void selectRouter(String routerId) {
  //   setState(() {
  //     selectedRouterId = routerId;
  //     showRouterList = false;
  //   });
  // }

  // void addRouter(RouterData router) {
  //   setState(() {
  //     routers.add(router);
  //     selectedRouterId = router.id;
  //     showRouterList = false;
  //   });
  // }

  // void editRouter(RouterData updatedRouter) {
  //   setState(() {
  //     final index = routers.indexWhere((r) => r.id == updatedRouter.id);
  //     if (index != -1) {
  //       routers[index] = updatedRouter;
  //     }
  //   });
  // }

  // void deleteRouter(String routerId) {
  //   setState(() {
  //     routers.removeWhere((r) => r.id == routerId);
  //     if (selectedRouterId == routerId) {
  //       selectedRouterId = routers.isNotEmpty ? routers[0].id : null;
  //       showRouterList = true;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isWide = width >= 900;

        final leftPane = RouterManager(
          onRouterSelected: _onRouterSelected,
        );
        final rightPane = RouterWorkspace(selectedRouter: selectedRouter);

        const SizedBox(width: 12);
        Alignment.centerLeft;
        Text(
          'Current User: ${currentUser.displayName}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: css.darkBlue,
          ),
        );

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Card(
              child: Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: RouterSidebarFrame(
                      child: RouterManager(
                        onRouterSelected: _onRouterSelected,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: RouterProcessFrame(
                      child: RouterWorkspace(selectedRouter: selectedRouter),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // show one pane at a time, with a toggle
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Card(
                child: showRouterList
                    ? RouterSidebarFrame(
                        child: RouterManager(
                          onRouterSelected: _onRouterSelected,
                        ),
                      )
                    : RouterProcessFrame(
                        child: RouterWorkspace(selectedRouter: selectedRouter),
                      ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: FloatingActionButton(
                onPressed: _togglePane,
                child: Icon(
                  showRouterList
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A thin wrapper for sidebar
class RouterSidebarFrame extends StatelessWidget {
  const RouterSidebarFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

/// A thin wrapper for process timeline
class RouterProcessFrame extends StatelessWidget {
  const RouterProcessFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

/// Process timeline area
class RouterWorkspace extends StatelessWidget {
  const RouterWorkspace({super.key, this.selectedRouter});

  final RouterData? selectedRouter;

  @override
  Widget build(BuildContext context) {
    if (selectedRouter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'No router selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a router from the list to view details',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: ViewDetailsWidget(routerData: selectedRouter!),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Job extends StatelessWidget {
  const _Job();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Text('Process and jobs', textAlign: TextAlign.center),
      ),
    );
  }
}

