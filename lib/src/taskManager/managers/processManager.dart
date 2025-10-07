import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_entry/src/functions/saveFile/platform_saveFile.dart';
import 'package:job_entry/src/taskManager/example/jobCard.dart';
import '../spell_check/SpellChecker.dart';

import '../../../../../styles/globals.dart';
import '../../../../../styles/savedWidgets.dart';
import '../../../../../src/functions/lsi_functions.dart';

import '../example/taskWidgets.dart';
import 'package:job_entry/src/taskManager/data/jobData.dart';
import 'package:job_entry/src/taskManager/data/processData.dart';

// TODO: have timeline modal (complete timeline of assemblies)

class ProcessManager extends StatefulWidget {
  const ProcessManager({
    Key? key,
    required this.update,
    this.onSubmit,
    this.onEdit,
    //this.onEditIndex, // might need this
    this.onTitleChange,
    this.onFocusNode,
    this.callback,
    this.onProcessDelete,
    this.onCreateJob,
    this.onEditJob,
    this.onJobDelete,
    required this.routerId,
    required this.processData,
    required this.jobs,
    this.width,
    this.height,
    this.processWidth = 240,
    this.allowEditing = true,
    this.screenOffset = const Offset(0,0),
    required this.workers,
    required this.approvers,
  }):super(key: key);

  /// Callback for process submission/creation
  final Function(String title, bool notify)? onSubmit;

  /// Callback for process edit
  final Function(dynamic data, String id)? onEdit;

  /// Callback for process deletion
  final Function(String id)? onProcessDelete;

  /// Callback for job deletion
  final Function(String id)? onJobDelete;

  /// ID of router that contains the processes
  final String routerId;

  final Function()? onFocusNode;

  /// Callback for job creation
  final Function(Map<String, dynamic> data)? onCreateJob;

  /// Callback for job editing
  final Function(Map<String, dynamic> data, String id, List<String> newWorkers)? onEditJob;

  /// Callback for title change
  final Function(String id, String title)? onTitleChange;

  /// Map of ProcessData
  final Map<String, ProcessData?> processData;

  /// Map of JobData 
  final Map<String, JobData?> jobs;

  /// Width of the manager
  final double? width;

  /// Height of the manager
  final double? height;

  /// Width of each process
  final double processWidth;

  final bool allowEditing;

  /// A dropdown of all the workers to be used for assignment to tasks
  final List<DropDownItems> workers;

  /// A dropdown of all the approvers to be used for this assignment to tasks
  final List<DropDownItems> approvers;

  final void Function()? callback;

  final Offset screenOffset;

  /// Value to indicate if there has been an update
  final bool update;

  @override
  _ProcessManagerState createState() => _ProcessManagerState();
}

class _ProcessManagerState extends State<ProcessManager> {
  double width = 100;
  double height = 100;
  double jobHeight = 61;
  double processWidth = 100;

  final ScrollController _scrollController = ScrollController();
  TextEditingController processNameController = TextEditingController();

  bool error = false;
  bool needsUpdate = false;
  bool isNewJob = true;
  bool allowNotifying = false;
  bool updateProcess = false;
  bool expandNotes = false;
  bool expandAssembilies = false;

  List<TextEditingController> nameChangeController = [];
  List<int> hexColors = [
    0xffff0000,
    0xff00ff00,
    0xff0000ff,
    0xff009688,
    0xffff9800,
    0xff3f51b5,
    0xff
  ];
  List cardNameControllers = [
    SpellCheckController(),
    SpellCheckController(),
  ]; 
  List<int> boardJobs = [];
  List<DropdownMenuItem<dynamic>> workerDropDown = [];
  List<DropdownMenuItem<dynamic>> approverDropDown = [];
  List<ProcessData> processData = [];
  List<JobData> jobData = [];
  Map<String, List<String>>? jobNotes;
  List<TextEditingController> activityControllers = [];

  String processBeingDragged = '';
  String processId = '';
  List<String> workers = [];
  List<String> newWorkers = [];
  List<String> approvers = [];
  String assignedDate = '';
  String completeDate = '';
  JobStatus status = JobStatus.notStarted;
  String processIdCardDragged = '';
  String processStartIdCardDragged = '';
  String jobBeingDragged = '';
  List<String> processLoc = [];
  int? draggedLoc;

  int good = 0;
  int bad = 0;

  DateTime selectedDate = DateTime.now();

  int? selectedJob;
  int routerClickedColor = 7;
  int nextIndex = 0;
  int updateProcessId = 0;

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  // Initializes default state of boardManager
  void start() {
    height = (widget.height == null)
      ? MediaQuery.of(context).size.height
      : widget.height!;
    width = (widget.width == null)
      ? MediaQuery.of(context).size.width
      : widget.width!;
    processWidth = widget.processWidth; 
    jobData = widget.jobs.entries.map((e)=>e.value).whereType<JobData>().toList();
    processData = widget.processData.entries.map((e) => e.value).whereType<ProcessData>().toList();
    workerDropDown = LSIFunctions.setDropDownItems(widget.workers);
    approverDropDown = LSIFunctions.setDropDownItems(widget.approvers);

    jobReset();
    processReset();
    sortByDueDate();
    setState(() {});
  }

  /// Reset Job Data to its defaults
  void jobReset() {
    jobNotes = null;
    selectedJob = null;
    isNewJob = true;
    processId = '';
    cardNameControllers = [
      SpellCheckController(),
      SpellCheckController(),
      TextEditingController(),
    ];
    activityControllers = [];
    workers = [];
    newWorkers = [];
    approvers = [];
    assignedDate = '';
    completeDate = '';
    good = 0;
    bad = 0;
    status = JobStatus.notStarted;
    selectedDate = DateTime.now();
  }

  /// Gets card data from selected card [i] and populates their respective fields
  Future<void> jobSet(int i) async {
    await Future.delayed(const Duration(milliseconds: 250), (() {
      jobReset();
      selectedJob = i;
      isNewJob = false;
      error = false;
      if (jobData[i].title != null) {
        cardNameControllers[0].text = jobData[i].title!;
      }
      if (jobData[i].workers.isNotEmpty) {
        for (var element in jobData[i].workers) {
          workers.add(element);
        }
      } else if (jobData[i].workers.isEmpty) {
        String? createdBy = (isNewJob)
          ? currentUser.uid
          : jobData[selectedJob!].createdBy;
        if (createdBy != null) {
          workers.add(createdBy);
        }
      }
      if (jobData[i].approvers.isNotEmpty) {
        for (var element in jobData[i].approvers) {
          approvers.add(element);
        }
      }
      if (jobData[i].dueDate != null) {
        assignedDate = jobData[i].dueDate!.split('T')[0];
        selectedDate = DateTime.parse(jobData[i].dueDate!.replaceAll('T', ' '));
      }
      if (jobData[i].completeDate != null) {
        completeDate = jobData[i].completeDate!.split('T')[0];
      }
      if (jobData[i].status != null) {
        status = jobData[i].status!;
      } else if (jobData[i].status == null) {
        status = JobStatus.notStarted;
      }
      if (jobData[i].good != null) {
        good = jobData[i].good!;
      } else if (jobData[i].good == null) {
        good = 0;
      }
      if (jobData[i].bad != null) {
        bad = jobData[i].bad!;
      } else if (jobData[i].bad == null) {
        bad = 0;
      }
      if (jobData[i].notes != null) {
        List<String> names = [];
        List<String> dates = [];
        for (int j = 0; j < jobData[i].notes!.length; j++) {
          String ac = 'note_$j';
          activityControllers.add(SpellCheckController());
          activityControllers[j].text = jobData[i].notes![ac]['comment'];
          names.add(jobData[i].notes![ac]['createdBy']);
          dates.add(jobData[i].notes![ac]['dateCreated']);
        }
        jobNotes = {
          'names': names,
          'dates': dates,
        };
      }
    }));
  }

  /// Resets the board
  void processReset() {
    error = false;
    updateProcess = false;
    processNameController.text = '';
    allowNotifying = false;
  }

  /// Opens dialog that is used to edit process [id]'s title and notification status
  void processSet(int id) {
    processReset();
    processNameController.text = processData[id].title!;
    allowNotifying = processData[id].notify;
    updateProcess = true;
    updateProcessId = id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return processName();
      }
    );
  }

  /// Prepares job data into JSON format to be sent to database
  void submitJobData() {
    DateFormat dayFormatter = DateFormat('MM-dd-yy hh:mm:ss');
    String dueDate = '';
    if (assignedDate != '') {
      dueDate = dayFormatter.format(selectedDate).replaceAll(' ', 'T');
    }
    dynamic activities;
    String createdDate = dayFormatter.format(DateTime.now()).replaceAll(' ','T');
    if(activityControllers.isNotEmpty) {
      for (int i = 0; i < activityControllers.length; i++) {
        String st = 'note_$i';
        if (activityControllers[i].text != '') {
          if (activities == null) {
            activities = {
              st: {
                'comment': activityControllers[i].text,
                'dateCreated': jobNotes!['dates']![i],
                'createdBy': jobNotes!['names']![i],
              }
            };
          } else {
            activities[st] = {
              'comment': activityControllers[i].text,
              'dateCreated': jobNotes!['dates']![i],
              'createdBy': jobNotes!['names']![i],
            };
          }
        }
      }
    }
    String? createdBy = (isNewJob)
      ? currentUser.uid
      : jobData[selectedJob!].createdBy;

    Map<String, dynamic> data = {
      'title': (cardNameControllers[0].text == '')
        ? 'Temp Title'
        : cardNameControllers[0].text,
      'description': (cardNameControllers[1].text == '')
        ? null
        : cardNameControllers[1].text,
      'workers': (workers.isEmpty) ? null : workers,
      'approvers': (approvers.isEmpty) ? null : approvers,
      'createdBy': createdBy,
      'dueDate': (dueDate == '') ? null : dueDate,
      'createdDate': (isNewJob) ? createdDate : jobData[selectedJob!].dateCreated,
      'notes': activities,
      'status': status,
      'good': good,
      'bad': bad,
      //'isApproved':
      //'isArchive':
      //'prevJobs':
    };

    Map<String, dynamic> toSend = {
      'data': data,
      'process': processId,
      'router': widget.routerId,
    };
    if (widget.onCreateJob != null && isNewJob) {
      widget.onCreateJob!(toSend);
    } else if (widget.onEditJob != null) {
      widget.onEditJob!(data, jobData[selectedJob!].id!, newWorkers);
    }
  }

  /// Will update the due date and reorder cards are drag
  void updateJobDueDate() {

  }

  /// Will format card due date change data and send to database using [onEditJob] callback function
  void dueDateJobChange() {

  }

  /// Default sorting of jobData, adds them to [boardLoc]
  void sortByDueDate() {

  }

  /// Updates priorities of process based on calculated [newDragLoc]
  void updateDueDate() {

  }

  /// Reorders processData based on oldLoc and newLoc
  void reorder() {

  }

  /// Builds date picker and updates [assignedDate] and [selectedDate] accordingly
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        var formatter = DateFormat('MM-dd-yy');
        assignedDate = formatter.format(picked);
        selectedDate = picked;
      });
    }

  }

  // Future<Uint8List> generatePdf() async {
  //   final pdf = pw.Document();
    
  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) {
  //         return [
  //           pw.Column(
  //             children: [ 
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text("${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}"),
  //                 ]
  //               )
  //             ]
  //           ),
  //           pw.SizedBox(height: 40),
  //           pw.Container(
  //             child: pw.Row(
  //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //               children: [
  //                 pw.Expanded(child: pw.Container(child: 
  //                   pw.Column(
  //                     crossAxisAlignment: pw.CrossAxisAlignment.start, 
  //                     children: [
  //                       pw.Text("Job name: "),
  //                       pw.Text("Workers: "),
  //                     ]
  //                   ))),
  //                 pw.Container(height: 40),
  //                 pw.Expanded(child: pw.Container(child: 
  //                   pw.Column( 
  //                     crossAxisAlignment: pw.CrossAxisAlignment.end,
  //                     children: [
  //                       pw.Text("Start Date: __/__/____"),
  //                       pw.Text("Finish Date: __/__/____"),
  //                       pw.Text("Required By: __/__/____"),
  //                     ]
  //                   )
  //                 )),
  //               ]
  //             )
  //           ),
  //           pw.SizedBox(height: 40),
  //         ];
  //       },
  //     ),
  //   );

  //   return await pdf.save();
  // }

  /// Exports the job and any archived assembilies
  // void exportJob() {
  //   if (selectedJob != null || !isNewJob) {
  //     final bytes = await generatePdf();

  //     SaveFile.saveBytes(
  //       printName: filename, 
  //       fileType: 'pdf', 
  //       bytes: bytes
  //     );
  // }

  /// Widget for draggable cards
  Widget dragCard(String id, int index, int jobToUse) {
    return Stack(
      children: [
        (jobBeingDragged != jobData[jobToUse].id)
          ? JobCard(
            context: context,
            jobData: jobData[jobToUse],
            height: jobHeight,
            width: processWidth - 40.0)
          : Container(),
        Draggable(
          data: 1,
          feedback: JobCard(
            context: context,
            jobData: jobData[jobToUse],
            height: jobHeight,
            rotate: true,
            width: processWidth - 40.0),
          child: const Padding(
            padding: EdgeInsets.only(top: 2, left: 2),
            child: Icon(Icons.drag_indicator)),
          onDragStarted: () {
            setState(() {
              processStartIdCardDragged = jobData[jobToUse].processId!;
              processIdCardDragged = jobData[jobToUse].processId!;
              jobBeingDragged = jobData[jobToUse].id!;
            });
          },
          onDragEnd: (val) {
            setState(() {
              dueDateJobChange();
              jobBeingDragged = '';
              processIdCardDragged = '';
            });
          },
          onDragCompleted: () {
            setState(() {
              dueDateJobChange();
              jobBeingDragged = '';
              processIdCardDragged = '';
            });
          },
          onDraggableCanceled: (vel, off) {
            setState(() {
              dueDateJobChange();
              jobBeingDragged = '';
              processIdCardDragged = '';
            });
          },
        )
      ],
    );
  }

  /// Opens dialog menu with editable card information of [jobToUse] if [jobToUse] is null, assuming creating a new card, edited by current user
  Widget jobName(int? jobToUse) {
    if (jobToUse == null) {
      workers.add(currentUser.uid);
    }
    String tempWorker = '';
    String tempApprover = '';
    bool cardUpdateReady = false;

    return StatefulBuilder(builder: (context, setState) {
      if (!cardUpdateReady) {
        if (jobToUse != null) {
          jobSet(jobToUse).then((value) {
            setState(() {
              cardUpdateReady = true;
            });
          });
        } else {
          cardUpdateReady = true;
        }
      }
      bool isWorker() {
        if (isNewJob) return true;
        if (workers.isNotEmpty) {
          for (int i = 0; i < workers.length; i++) {
            if (workers[i] == currentUser.uid) {
              return true;
            }
          }
        }
        return false;
      }
      // TODO: Fix this so that only admins can approve
      bool isApprover() {
        return true;
      }
      Widget createActivityList() {
        Widget section(int i){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(children: [
                  Text(
                    usersProfile[jobNotes!['names']![i]]
                        ['displayName'],
                    style: TextStyle(
                      color: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .color,
                      fontSize: 14,
                      fontFamily: 'Klavika Bold',
                      package: 'css',
                      decoration: TextDecoration.none
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    jobNotes!['dates']![i],
                    style: TextStyle(
                      color: Theme.of(context)
                          .primaryTextTheme
                          .labelSmall!
                          .color,
                      fontSize: 12,
                      fontFamily: 'MuseoSans',
                      decoration: TextDecoration.none
                    )
                  ),
                ])
              ),
              EnterTextFormField(
                width: CSS.responsive() - 50,
                color: Theme.of(context).canvasColor,
                maxLines: null,
                label: 'Write a Note',
                controller: activityControllers[i],
                onEditingComplete: () {},
                onSubmitted: (val) {},
                onTap: widget.onFocusNode
              ),
            ],
          );
        }

        if (activityControllers.isNotEmpty) {
          List<Widget> rows = [];
          for (int i = 0; i < activityControllers.length; i++) {
            rows.add(section(i));
            rows.add(const SizedBox(height: 5));
          }
          return SizedBox(
            height: (activityControllers.length < 3 || expandNotes)
              ? activityControllers.length * 57.0
              : 57.0 * 3,
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: rows,
            )
          );
        } else  {
          return const SizedBox();
        }
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.only(left: 1, right: 1),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: height,
          width: CSS.responsive(),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                offset: const Offset(2,2),
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              cardUpdateReady
                ? Column (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: height - 65 - 40,
                        child: ListView(
                          padding: const EdgeInsets.all(0),
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.title_rounded,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: CSS.responsive() - 60,
                                      child: EnterTextFormField(
                                        margin: const EdgeInsets.only(left: 5),
                                        height: 35,
                                        color: Theme.of(context).canvasColor,
                                        maxLines: 1,
                                        label: 'Title',
                                        controller: cardNameControllers[0],
                                        onTap: widget.onFocusNode,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  width: 120,
                                  child: FocusedInkWell(
                                    onTap: () {
                                      if(widget.allowEditing || isNewJob) {
                                        _selectDate(context);
                                      }
                                    },
                                    child: TaskWidgets.iconNote(
                                      Icons.insert_invitation_outlined,
                                      (assignedDate == '')
                                        ? DateFormat('MM-dd-y').format(DateTime.now())
                                        : assignedDate,
                                      TextStyle(
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .color,
                                        fontFamily: 'Klavika',
                                        package: 'css',
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                      ),
                                    20),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.assignment_late_outlined,
                                        size: 20,
                                      ),
                                      LSIUserIcon(
                                        remove: (loc) {
                                          setState(() {
                                            workers.removeAt(loc);
                                          });
                                        },
                                        viewidth: CSS.responsive() - 60,
                                        uids: workers, 
                                        colors: [
                                          Colors.teal[200]!,
                                          Colors.teal[600]!
                                        ], 
                                      )
                                    ],
                                  )
                                ),
                                workers.isNotEmpty
                                  ? Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.assignment_ind,
                                          size: 20,
                                        ),
                                        LSIUserIcon(
                                          remove: (loc) {
                                            setState(() {
                                              workers.removeAt(loc);
                                            });
                                          },
                                          viewidth: CSS.responsive() - 60,
                                          uids: workers,
                                          colors: [
                                            Colors.teal[200]!,
                                            Colors.teal[600]!
                                          ],
                                        )
                                      ],
                                    )
                                  )
                                : Container()
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TaskWidgets.iconNote(
                                      Icons.assignment,
                                      "Assign",
                                      TextStyle(
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .color,
                                        fontFamily: 'Klavika',
                                        package: 'css',
                                        decoration: TextDecoration.none
                                      ),
                                    20),
                                    SizedBox(
                                      width: 150,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          FocusedDropDown(
                                            itemVal: workerDropDown,
                                            value: tempWorker,
                                            radius: 5, 
                                            width: 115,
                                            color: Theme.of(context)
                                                .canvasColor,
                                            onchange: (val) {
                                              setState(() {
                                                tempWorker = val;
                                              });
                                            },
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyMedium!
                                                  .color,
                                              fontSize: 12
                                            ),
                                          ),
                                          FocusedInkWell(
                                            onTap: () {
                                              if(isWorker()) {
                                                bool allowedAdded = true;
                                                if(workers.isNotEmpty && tempWorker != '') {
                                                  for (int i = 0; i < workers.length; i++) {
                                                    if (tempWorker == workers[i]) {
                                                      allowedAdded = false;
                                                    }
                                                    break;
                                                  }
                                                }
                                                setState(() {
                                                  if (allowedAdded && tempWorker != '') {
                                                    workers.add(tempWorker);
                                                    if(!isNewJob) { newWorkers.add(tempWorker); }
                                                  }
                                                });
                                              }
                                            },
                                            child: Icon(
                                              Icons.add_box,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyMedium!
                                                  .color,
                                            )
                                          )
                                        ],
                                      )
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TaskWidgets.iconNote(
                                      Icons.edit_note_rounded,
                                      "Approver",
                                      TextStyle(
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .color,
                                        fontFamily: 'Klavika',
                                        package: 'css',
                                        fontSize: 20,
                                        decoration: TextDecoration.none,
                                      ),
                                    20),
                                    SizedBox(
                                      width: 150,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          FocusedDropDown(
                                            itemVal: approverDropDown,
                                            value: tempApprover,
                                            radius: 5,
                                            width: 114, 
                                            color: Theme.of(context).canvasColor,
                                            onchange: (val) {
                                              setState(() {
                                                tempApprover = val;
                                              });
                                            },
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyMedium!
                                                  .color,
                                              fontSize: 12,
                                            ),
                                          ),
                                          FocusedInkWell(
                                            onTap: () {
                                              if (isApprover()) {
                                                bool allowedEdit = true;
                                                if (approvers.isNotEmpty && tempApprover != '') {
                                                  for (int i = 0; i < approvers.length; i++) {
                                                    if (tempApprover == approvers[i]) {
                                                      allowedEdit = false;
                                                      break;
                                                    }
                                                  }
                                                }
                                                setState(() {
                                                  if (allowedEdit && tempApprover != '') {
                                                    approvers.add(tempApprover);
                                                  }
                                                });
                                              }
                                            },
                                            child: Icon(
                                              Icons.add_box,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .bodyMedium!
                                                  .color,
                                            ),
                                          )
                                        ],
                                      )
                                    )
                                  ],
                                )
                              ],
                            ),
                           const SizedBox(height: 20),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  FocusedInkWell(
                                    onTap: () {
                                      setState(() {
                                        expandNotes = !expandNotes;
                                      });
                                    },
                                    child: Icon(
                                      (!expandNotes)
                                        ? Icons.expand
                                        : Icons.clear_outlined,
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyMedium!
                                          .color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  TaskWidgets.iconNote(
                                    Icons.list_rounded,
                                    "Notes",
                                    TextStyle(
                                      color: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyMedium!
                                          .color,
                                      fontFamily: 'Klavika',
                                      package: 'css',
                                      fontSize: 20,
                                      decoration: TextDecoration.none
                                    ),
                                  20),
                                ],
                              ),
                              FocusedInkWell(
                                onTap: () {
                                  setState(() {
                                    activityControllers.add(SpellCheckController());
                                    DateFormat dayFormatter = DateFormat('MM-dd-y');
                                    String createdDate = dayFormatter.format(DateTime.now());
                                    if (jobNotes == null) {
                                      jobNotes = {
                                        'names': [currentUser.uid],
                                        'dates': [createdDate],
                                      };
                                    } else {
                                      jobNotes!['names']!.add(currentUser.uid);
                                      jobNotes!['dates']!.add(createdDate);
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.add_box,
                                  size: 30,
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              )
                            ],
                           ),
                            Container(
                              color: CSS.lighten(Theme.of(context).canvasColor, 0.2),
                              child: createActivityList(),
                            ),
                          ],
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          (!isNewJob && (isWorker() || isApprover()))
                            ? LSIWidgets.squareButton(
                              text: 'delete',
                              onTap: () {
                                setState(() {
                                  if(widget.onJobDelete != null) {
                                    widget.onJobDelete!(jobData[selectedJob!].id!);
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                              buttonColor: Colors.transparent,
                              borderColor: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyMedium!
                                  .color,
                              height: 45,
                              radius: 45 / 2,
                              width: CSS.responsive() / 3 - 15,
                            )
                          : Container(),
                        ],
                      )
                    ],
                  )
                  : LSILoadingWheel(),
            ],
          )
        )
      );
    });
  }

  /// Opens dialog menu for duplicating cards
  Widget duplicateCard() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: 150,
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Do you want to duplicate this job?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .primaryTextTheme
                      .bodyMedium!
                      .color,
                  fontFamily: 'Klavika',
                  package: 'css',
                  fontSize: 20,
                  decoration: TextDecoration.none
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LSIWidgets.squareButton(
                    text: 'cancel',
                    onTap: () {
                      setState(() {
                        processNameController.text = '';
                      });
                      error = false;
                      Navigator.of(context).pop();
                    },
                    buttonColor: Colors.transparent,
                    borderColor: Theme.of(context)
                        .primaryTextTheme
                        .bodyMedium!
                        .color,
                    height: 45,
                    radius: 45 / 2,
                    width: 320 / 2 - 10
                  ),
                  LSIWidgets.squareButton(
                    text: 'duplicate',
                    onTap: () {
                      isNewJob = true;
                      submitJobData();
                      setState(() {
                        error = false;
                        jobReset();
                      });
                      Navigator.of(context).pop();
                    },
                    textColor: Theme.of(context).indicatorColor,
                    buttonColor: Theme.of(context)
                        .primaryTextTheme
                        .bodyMedium!
                        .color!,
                    height: 45,
                    radius: 45 / 2,
                    width: 320 / 2 - 10,
                  ),
                ],
              )
            ],
          )
        )
      );
    });
  }

  Widget info(bool drag, String id) {
    return (!drag)
      ? Stack(alignment: AlignmentDirectional.bottomEnd,
      children: [
        infoContainer(id),
        LSIFloatingActionButton(
          allowed: true,
          color: Theme.of(context).secondaryHeaderColor,
          icon: Icons.add,
          size: 40,
          onTap: () {
            setState(() {
              jobReset();
              processId = id;
              showDialog(
                context: context,
                builder: (context) {
                  return jobName(null);
                }
              );
            },);
          },
        ),
      ])
      : infoContainer(id);
  }

  /// Widget that displays all the cards in the board [id]
  Widget infoContainer(String id) {
    List<Widget> jobs = [];
    if (jobData.isNotEmpty) {
      for (int index = nextIndex; index < jobData.length; index++) {
        int jobToUse;
        if (jobData[index].processId == id) {
          jobToUse = index;
          nextIndex = index + 1;
        } else {
          break;
        }
        if (jobBeingDragged != jobData[jobToUse].id) {
          jobs.add(FocusedInkWell(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  processId = id;
                  return duplicateCard();
                }
              );
            },
            onDoubleTap: () {
              showDialog(
                context: context, 
                builder: (BuildContext context) {
                  processId = id;
                  return jobName(jobToUse);
                });
            },
            child: dragCard(id, index, jobToUse)
          ));
        } else {
          jobs.add(SizedBox(
            height: 70,
            width: processWidth - 20.0,
          ));
        }
      }
    } else {
      jobs.add(Container());
    }
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, right: 10),
      height: height - 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).canvasColor
      ),
      child: ListView(padding: const EdgeInsets.all(0), children: jobs)
    );
  }

  /// Displays title of the process
  Widget title(String title, String subtitle, TextEditingController controller, Color color, bool dragged) {
        controller.text = subtitle;
    return Container(
      width: processWidth,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10),
                child: Text('', //title.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontFamily: 'MuseoSans',
                        package: 'css',
                        decoration: TextDecoration.none))),
            Container(
              width: width,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 10),
              color: Theme.of(context).splashColor,
              child: (!dragged)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          EnterTextFormField(
                            height: 25,
                            width: processWidth - 65.0,
                            maxLines: 1,
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 10.0),
                            textStyle: TextStyle(
                                color: color,
                                fontFamily: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .fontFamily,
                                decoration: TextDecoration.none),
                            controller: controller,
                            onEditingComplete: () {
                              if (widget.onTitleChange != null) {
                                widget.onTitleChange!(title, controller.text);
                              }
                            },
                            onSubmitted: (val) {
                              if (widget.onTitleChange != null) {
                                widget.onTitleChange!(title, controller.text);
                              }
                            },
                            onTap: widget.onFocusNode,
                          ),
                          FocusedInkWell(
                            onLongPress: () {
                              if (widget.allowEditing && widget.onProcessDelete != null){
                                widget.onProcessDelete!(title);
                              }
                            },
                            child: Icon(
                              Icons.delete_forever,
                              size: 20,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyMedium!
                                  .color,
                            ),
                          )
                        ])
                  : Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      height: 45,
                      width: width - 20,
                      child: Text(
                        subtitle,
                        style: Theme.of(context).primaryTextTheme.bodyMedium,
                      ),
                    ),
            )
          ]),
    );
  }

  /// Widget that displays process when dragging to new position, rotation of process determined by [rotate] and process being used is processData[i]
  Widget process(int i, bool rotate) {
        return Transform.rotate(
        angle: (rotate) ? 0.174533 : 0,
        child: Container(
          margin: const EdgeInsets.all(10),
          width: processWidth+4,
          height: height - 20,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]),
          child: Column(
            children: [
              title(
                processData[i].id!,
                processData[i].title!,
                nameChangeController[i],
                Theme.of(context).primaryColor,
                //Color(processData[i].color!),
                rotate
              ),
              info(rotate, processData[i].id!)
            ],
          ),
        ));
  }

  /// Widget that replaces process [i] with container while it is being dragged, also determines behavior of process when dragged
  Widget dragProcess(int i) {
    return Stack(
      children: [
        (processBeingDragged != processData[i].id) ? process(i, false) : Container(),
        Draggable(
          data: 0,
          feedback: process(i, true),
          onDragStarted: () {
            setState(() {
              draggedLoc = i;
              processBeingDragged = processData[i].id!;
            });
          },
          onDragEnd: (val) {
            setState(() {
              processBeingDragged = '';
              dueDateJobChange();
            });
          },
          onDragCompleted: () {
            setState(() {
              processBeingDragged = '';
              dueDateJobChange();
            });
          },
          onDraggableCanceled: (vel, off) {
            setState(() {
              processBeingDragged = '';
              dueDateJobChange();
            });
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Icon(Icons.drag_indicator)
          ),
        )
      ],
    );
  }

  /// Displays the list of boards
  List<Widget> processList() {
    List<Widget> routers = [];
    nextIndex = 0;
    for (int i = 0; i < processData.length; i++) {
      nameChangeController.add(TextEditingController());
      if (processBeingDragged != processData[i].id) {
        routers.add(FocusedInkWell(
          mouseCursor: MouseCursor.defer,
          onDoubleTap: () {
            processSet(i);
          },
          child: dragProcess(i)
        ));
      } else {
        routers.add(Container(width: processWidth));
      }
    }
    return routers;
  }

  // Widget that displays dialog to create/update a board
  Widget processName() {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: 320 * 3 / 4,
          width: 320, 
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5, 
                offset: Offset(2, 2)
              )
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Please enter the name of this step of the process!",
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  fontFamily: 'Klavika',
                  package: 'css',
                  fontSize: 20,
                  decoration: TextDecoration.none,
                )
              ),
              EnterTextFormField(
                width: 320 - 40.0,
                height: 35,
                color: Theme.of(context).canvasColor,
                maxLines: 1,
                label: 'Process Name',
                controller: processNameController,
                onEditingComplete: () {},
                onSubmitted: (val) {},
                onTap: widget.onFocusNode ?? (){},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Allow Process Notifications!",
                    style: TextStyle(
                      color: Theme.of(context)
                          .primaryTextTheme
                          .bodyMedium!
                          .color,
                      fontFamily: 'Klavika',
                      package: 'css',
                      fontSize: 20,
                      decoration: TextDecoration.none
                    ),
                  ),
                  Checkbox(
                    activeColor: Theme.of(context).secondaryHeaderColor,
                    value: allowNotifying,
                    onChanged: (val) {
                      setState(() {
                        allowNotifying = val!;
                      });
                    },
                  )
                ],
              ),
              (error)
                ? const Text(
                  "Field is missing data!",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Klavika',
                    package: 'css',
                    fontSize: 20
                  ),
                )
                : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    LSIWidgets.squareButton(
                      text: 'cancel',
                      onTap: () {
                        processReset();
                        Navigator.of(context).pop();
                      },
                      buttonColor: Colors.transparent,
                      borderColor: Theme.of(context)
                          .primaryTextTheme
                          .bodyMedium!
                          .color,
                      height: 45,
                      radius: 45 / 2,
                      width: 320 / 2 -10
                    ),
                    LSIWidgets.squareButton(
                      text: (!updateProcess) ? 'submit' : 'update',
                      onTap: () {
                        if (processNameController.text != '') {
                          if (!updateProcess) {
                            if (widget.onSubmit != null) {
                              //widget.onSubmit!(processNameController.text, processData.length, allowNotifying);
                            }
                          } else {
                            dynamic data = {
                              'title': processNameController.text,
                              'createdBy': processData[updateProcessId].createdBy,
                              'dateCreated': processData[updateProcessId].dateCreated,
                              'notify': allowNotifying
                            };
                            if (widget.onEdit != null) {
                              widget.onEdit!(data, processData[updateProcessId].id!);
                            }
                          }
                          processReset();
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            error = true;
                          });
                        }
                      },
                      textColor: Theme.of(context).indicatorColor,
                      buttonColor: Theme.of(context)
                          .primaryTextTheme
                          .bodyMedium!
                          .color!,
                      height: 45,
                      radius: 45 / 2,
                      width: 320 / 2 - 10,
                    )
                  ],
                )
            ],
          )
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.update) {
        setState(() {
          if (widget.callback != null) {
            widget.callback!();
          }
          start();
        });
      }
    });

    return InkWell(
        mouseCursor: MouseCursor.defer,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          (processData.isNotEmpty)
              ? DragTarget<int>(onMove: (details) {
                  if (details.offset.dx > deviceWidth - 140) {
                    _scrollController.jumpTo(_scrollController.offset + 5);
                  } else if (details.offset.dx < widget.screenOffset.dx + 5 &&
                      _scrollController.offset > 0) {
                    _scrollController.jumpTo(_scrollController.offset - 5);
                  }

                  if (processBeingDragged != '') {
                    // change the sorting for processes
                  }
                  if (jobBeingDragged != '') {
                    // change the sorting for jobs
                  }
                }, builder: (context, List<int?> candidateData, rejectedData) {
                  return Container(
                      height: height,
                      width: width,
                      color: Theme.of(context).canvasColor,
                      child: GestureDetector(
                          onHorizontalDragUpdate: (dragUpdateDetails) {
                            double pos = _scrollController.offset -
                                dragUpdateDetails.delta.dx;
                            _scrollController.jumpTo(pos);
                          },
                          child: ListView(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              scrollDirection: Axis.horizontal,
                              children: processList())));
                })
              : Container(
                  height: height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                ),
          LSIFloatingActionButton(
              allowed: widget.allowEditing,
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icons.add,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return processName();
                    });
              }),
        ]));
  }
}