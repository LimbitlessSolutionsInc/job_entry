import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../functions/saveFile/platform_saveFile.dart';
import '../example/jobCard.dart';
import '../spell_check/SpellChecker.dart';

import '../../../../../styles/globals.dart';
import '../../../../../styles/savedWidgets.dart';
import '../../../../../src/functions/lsi_functions.dart';

import '../example/taskWidgets.dart';
import '../data/jobData.dart';
import '../data/processData.dart';
// import 'package:lsicompapp/src/exporting/pdfGeneration.dart';

class ProcessManager extends StatefulWidget {
  const ProcessManager({
    Key? key,
    required this.update,
    this.onSubmit,
    this.onEdit,
    this.onTitleChange,
    this.onJobPriorityChange,
    this.onProcessOrderChange,
    this.onFocusNode,
    this.callback,
    this.onProcessDelete,
    this.onCreateJob,
    this.onEditJob,
    this.onJobDelete,
    required this.routerId,
    required this.processData,
    required this.jobData,
    this.width,
    this.height,
    this.processWidth = 240,
    this.allowEditing = true,
    this.screenOffset = const Offset(0, 0),
    required this.workers,
    required this.approvers,
    this.index,
    this.prevJobs,
  }) : super(key: key);

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
  
  final Function(Map<String, dynamic> pri, dynamic data)? onJobPriorityChange;

  final Function(Map<String, dynamic> pri)? onProcessOrderChange;

  /// Map of ProcessData
  final List<ProcessData>? processData;

  /// Map of JobData
  final List<JobData>? jobData;

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

  final int? index;

  final Map<String, dynamic>? prevJobs;

  @override
  _ProcessManagerState createState() => _ProcessManagerState();
}

class _ProcessManagerState extends State<ProcessManager> {
  double width = 100;
  double height = 100;
  double jobHeight = 126;
  double processWidth = 240;

  final ScrollController _scrollController = ScrollController();
  TextEditingController processNameController = TextEditingController();

  bool allowNotifying = false;
  bool error = false;
  bool needsUpdate = false;
  bool isNewJob = true;
  bool updateProcess = false;
  bool expandNotes = false;
  bool expandAssembilies = false;
  bool cardUpdateReady = false;

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
  List<DropDownItems> jobStatus = [
    DropDownItems(value: 'notStarted', text: 'Not Started'),
    DropDownItems(value: 'inProgress', text: 'In Progress'),
    DropDownItems(value: 'completed', text: 'Completed'),
  ];
  List<DropdownMenuItem<dynamic>> workerDropDown = [];
  List<DropdownMenuItem<dynamic>> approverDropDown = [];
  List<DropdownMenuItem<dynamic>> jobStatusDropDown = [];
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
  String requiredDate = '';
  String completeDate = '';
  JobStatus status = JobStatus.notStarted;
  List<String> isApproved = [];
  bool isArchive = false;

  String processIdCardDragged = '';
  String processStartIdCardDragged = '';
  String jobBeingDragged = '';
  List<String> processLoc = [];
  List<int> processJobs = [];
  int? draggedLoc;

  List<TextEditingController> numbersControllers = [
    TextEditingController(text: '0'),
    TextEditingController(text: '0')
  ];

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DateTime selectedRequiredDate = DateTime.now();

  int? selectedJob;
  int? jobDraggedLoc;
  int routerClickedColor = 7;
  int nextIndex = 0;
  int updateProcessId = 0;

  get prevJobs => null;

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

  // Initializes default state of processManager
  void start() {
    processWidth = widget.processWidth;
    jobData = widget.jobData ?? [];
    processData = widget.processData ?? [];
    print('Initializing Process Manager with ${widget.processData!.length} processes and ${widget.jobData!.length} jobs');
    workerDropDown = LSIFunctions.setDropDownItems(widget.workers);
    approverDropDown = LSIFunctions.setDropDownItems(widget.approvers);
    jobStatusDropDown = LSIFunctions.setDropDownItems(jobStatus);

    jobReset();
    processReset();
    sortByOrder();
    sortByJobPriority();
    setState(() {});
  }

  /// Reset Job Data to its defaults
  void jobReset() {
    jobNotes = null;
    selectedJob = null;
    isNewJob = true;
    //processId = '';
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
    requiredDate = '';
    numbersControllers = [
      TextEditingController(text: '0'),
      TextEditingController(text: '0')
    ];
    status = JobStatus.notStarted;
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    selectedRequiredDate = DateTime.now();
    isApproved = [];
    isArchive = false;
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
      if (jobData[i].description != null) {
        cardNameControllers[1].text = jobData[i].description!;
      }
      if (jobData[i].workers.isNotEmpty) {
        for (var element in jobData[i].workers) {
          workers.add(element);
        }
      } else if (jobData[i].workers.isEmpty) {
        String? createdBy =
            (isNewJob) ? currentUser.uid : jobData[selectedJob!].createdBy;
        if (createdBy != null) {
          workers.add(createdBy);
        }
      }
      if (jobData[i].approvers.isNotEmpty) {
        for (var element in jobData[i].approvers) {
          approvers.add(element);
        }
      }

      DateFormat inputFormat = DateFormat('MM-dd-yyyy');

      if (jobData[i].startDate != null) {
        assignedDate = jobData[i].startDate!;
        selectedStartDate = inputFormat.parse(assignedDate);
      }
      if (jobData[i].dueDate != null) {
        requiredDate = jobData[i].dueDate!;
        selectedRequiredDate = inputFormat.parse(requiredDate);
      }
      if (jobData[i].completeDate != null) {
        if (jobData[i].completeDate == 'N/A' || jobData[i].completeDate == '') {
          completeDate = 'N/A';
        } else {
          completeDate = jobData[i].completeDate!;
          selectedEndDate = inputFormat.parse(completeDate);
        }
      }
      if (jobData[i].status != null) {
        status = jobData[i].status!;
      }
      if (jobData[i].good != null) {
        numbersControllers[0].text = jobData[i].good!.toString();
      }
      if (jobData[i].bad != null) {
        numbersControllers[1].text = jobData[i].bad!.toString();
      }
      for (var element in jobData[i].isApproved) {
        isApproved.add(element);
      }
      isApproved = jobData[i].isApproved;
      isArchive = jobData[i].isArchive;

      print('Loading notes for job ${jobData[i].id}, found notes: ${jobData[i].notes != null ? jobData[i].notes!.length : 0}');
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
  }

  /// Opens dialog that is used to edit process [id]'s title and notification status
  void processSet(int id) {
    processReset();
    processNameController.text = processData[id].title!;
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
    String startDate = '';
    String endDate = '';
    String dueDate = '';
    if (assignedDate != '') {
      startDate = DateFormat('MM-dd-yyyy').format(selectedStartDate).replaceAll(' ', 'T'); 
    }
    if (completeDate != '') {
      endDate = DateFormat('MM-dd-yyyy').format(selectedEndDate).replaceAll(' ', 'T'); 
    }
    if (requiredDate != '') {
      dueDate = DateFormat('MM-dd-yyyy').format(selectedRequiredDate).replaceAll(' ', 'T'); 
    }
    dynamic activities;
    String createdDate =
        DateFormat('MM-dd-yyyy').format(DateTime.now()).replaceAll(' ', 'T');
    if (activityControllers.isNotEmpty) {
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
    String? createdBy =
        (isNewJob) ? currentUser.uid : jobData[selectedJob!].createdBy;

    
    Map<String, dynamic> data = {
      'title': (cardNameControllers[0].text == '') ? 'Temp Title' : cardNameControllers[0].text,
      'description': (cardNameControllers[1].text == '') ? null : cardNameControllers[1].text,
      'workers': (workers.isEmpty) ? null : workers,
      'approvers': (approvers.isEmpty) ? null : approvers,
      'createdBy': createdBy,
      'dueDate': (dueDate == '') ? null : dueDate,
      'createdDate': (isNewJob) ? createdDate : jobData[selectedJob!].dateCreated,
      'startDate': (startDate == '') ? null : startDate,
      'completedDate': (endDate == '') ? null : endDate,
      'notes': activities,
      'status': status.toString().split('.').last,
      'good': int.parse(numbersControllers[0].text),
      'bad': int.parse(numbersControllers[1].text),
      'isApproved': (isApproved.isEmpty) ? null : isApproved,
      'isArchive': isArchive,
      'prevJobs': prevJobs,
      'processId': processId,
      'routerId': widget.routerId,
    };

    if (widget.onCreateJob != null && isNewJob) {
      widget.onCreateJob!(data);
    } else if (widget.onEditJob != null) {
      widget.onEditJob!(data, jobData[selectedJob!].id!, newWorkers);
    }
  }

  /// Will format card due date change data and send to database using [onEditJob] callback function
  void priorityJobChange() {
    Map<String, dynamic> pri = {};
    for (int i = 0; i < jobData.length; i++) {
      pri[jobData[i].id!] = {
        'priority': jobData[i].priority,
        'processId': jobData[i].processId,
      };
    }

    dynamic data = {'job': jobBeingDragged, 'process': processStartIdCardDragged};
    if (widget.onJobPriorityChange != null) {
      widget.onJobPriorityChange!(pri, data);
    }
  }

  void priorityChange() {
    Map<String, dynamic> pri = {};
    for (int i = 0; i < processData.length; i++) {
      pri[processData[i].id!] = {
        'createdBy': processData[i].createdBy!,
        'dateCreated': processData[i].dateCreated!,
        'title': processData[i].title!,
        'notify': processData[i].notify,
        'order': processData[i].order!
      };
    }

    if (widget.onProcessOrderChange != null) {
      print('Sending process order change: $pri');
      widget.onProcessOrderChange!(pri);
    }
  }

  void updateProcessOrder(Offset details){
    double startPosX = (details.dx - widget.screenOffset.dx) + _scrollController.offset;
    if (startPosX > 0) {
      int newDragLoc = (startPosX / processWidth).floor();
      if (newDragLoc > processData.length - 1) {
        newDragLoc = processData.length - 1;
      } else if (newDragLoc < 0) {
        newDragLoc = 0;
      }
      if (draggedLoc != newDragLoc) {
        reorder(draggedLoc!, newDragLoc);
        setOrder(newDragLoc);
        sortByOrder();
        draggedLoc = newDragLoc;
      }
    }
  }

  void setOrder(int newDragLoc) {
    for (int i = 0; i < processData.length; i++) {
      if (processData[i].id == processBeingDragged) {
        processData[i].order = newDragLoc;
        break;
      }
    }
  }

  void sortByOrder() {
    processLoc = [];
    setState(() {
      processData.sort((a, b) => a.order!.compareTo(b.order!));
    });
    //print('Process order for processes ${processData.map((e) => e.id).toList()} sorted: ${processData.map((e) => e.order).toList()}');

    for (int i = 0; i < processData.length; i++) {
      processLoc.add(processData[i].id!);
    }
  }

  void sortByJobPriority() {
    processLoc = [];
    processJobs = [];

    if (jobData.isNotEmpty) {
      List<JobData> tempData = [];
      for (int i = 0; i < processData.length; i++) {
        processLoc.add(processData[i].id!);
        processJobs.add(0);
      }

      for (int i = 0; i < processLoc.length; i++) {
        List<JobData> sortLocData = [];

        for (int j = 0; j < jobData.length; j++) {
          if (jobData[j].processId == processLoc[i]) {
            sortLocData.add(jobData[j]);
            processJobs[i]++;
          }
        }
        sortLocData.sort((a, b) => a.priority!.compareTo(b.priority!));
        tempData += sortLocData;
      }
      setState(() {
        jobData = tempData;
      });
    }
  }
  
  void updateJobPriority(Offset details){
    double startPosX = (details.dx - widget.screenOffset.dx) + _scrollController.offset;
    double startPosY = details.dy - widget.screenOffset.dy;
    
    if (startPosY > 0) {
      int newYLoc = (startPosY / jobHeight).floor();
      int newXLoc = (startPosX / processWidth).floor();

      if (newXLoc > processData.length - 1) {
        newXLoc = processData.length - 1;
      } else if (newXLoc < 0) {
        newXLoc = 0;
      }

      String newProcess = processLoc[newXLoc];
      
      if (newYLoc > processJobs[newXLoc] - 1) {
        newYLoc = processJobs[newXLoc] - 1;
      } else if (newYLoc < 0) {
        newYLoc = 0; 
      }

      if (jobDraggedLoc != newYLoc || processIdCardDragged != newProcess) {
        reorderJobs(newYLoc, newProcess);
        sortByJobPriority();
        jobDraggedLoc = newYLoc;
        processIdCardDragged = newProcess;
      }
    }
  }

  void reorderJobs(int newLoc, String processId) {
    //set cards new priority and loc
    for (int i = 0; i < jobData.length; i++) {
      int newindex = processData.indexWhere((x) => x.id == processId);
      if (jobData[i].id == jobBeingDragged) {
        int oldIndex = processData.indexWhere((x) => x.id == jobData[i].processId);
        print('old order: ${processData[oldIndex].order!} new order: ${processData[newindex].order!}');
        jobData[i].priority = newLoc;
        jobData[i].processId = processData[newindex].order! > processData[oldIndex].order!?processId:jobData[i].processId;
        break;
      }
    }
    //change priorities
    int j = 0;
    String tempID = processLoc[0];
    for (int i = 0; i < jobData.length; i++) {
      if (jobData[i].id != jobBeingDragged) {
        if (tempID != jobData[i].processId) {
          if (newLoc == 0 && jobData[i].processId == processId) {
            j = 1;
          } else {
            j = 0;
          }
          tempID = jobData[i].processId!;
        } else if (newLoc == j && jobData[i].processId == processId) {
          j++;
        }
        jobData[i].priority = j;
        j++;
      }
    }
  }

  /// Reorders processData based on oldLoc and newLoc
  void reorder(int oldLoc, int newLoc) {
    for (int i = 0; i < processData.length; i++) {
      if (processData[i].order == newLoc) {
        processData[i].order = oldLoc;
        break;
      }
    }
  }

  // TODO: See if we need a different format like csv
  // Saves the job and any archived assembilies to PDF format
  // filename: name of the file, data: data to be saved (the current job plus the prev assembilies hopefully combined?)
  void exportJob(String filename, List<JobData> data, int order) async {
    try{
      if (data.isNotEmpty) {

        String csvFile = 'Job Title, Description, Status, Creation Date, Start Date, Completed Date, Due Date, Good Parts, Bad Parts, Approved?, Approval Date, Approver\n';
        for (int i = 0; i < data.length; i++) {
          String approved = 'No';
          if (data[i].isApproved.length < order) {
            approved = 'Yes';
          }
          csvFile +=
              '"${data[i].title}", "${data[i].description}", "${describeEnum(data[i].status!)}", "${data[i].dateCreated}", "${data[i].startDate}", "${data[i].completeDate}", "${data[i].dueDate}", "${data[i].good}", "${data[i].bad}", "$approved", "${approved=='No'?'-':data[i].isApproved[order - 1]}", "${approved=='No'?'-':data[i].approvers[0]}"\n';
        }

        Uint8List bytes = Uint8List.fromList(csvFile.codeUnits);

        SaveFile.saveBytes(
          printName: filename,
          fileType: 'csv',
          bytes: bytes
        );
      }
    }
    catch(e){
      print('processManager.dart -> jobName() -> Exception: $e');
    }
  }

  /// Widget for draggable cards
  Widget dragCard(String id, int index, int jobToUse) {
    int procIndex = processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!;
    if (procIndex >= 0 && procIndex < jobData[jobToUse].isApproved.length) {
      return Stack(
        children: [
          (jobBeingDragged != jobData[jobToUse].id) ? JobCard(
            context: context,
            jobData: jobData[jobToUse],
            height: jobHeight,
            width: processWidth - 40.0,
            processIndex: processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!,
          ) : Container(),
          Draggable( //does not move over to the new location until released -nlw
            data: 1,
            feedback: JobCard(
              context: context,
              jobData: jobData[jobToUse],
              height: jobHeight,
              rotate: true,
              width: processWidth - 40.0,
              processIndex: processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                child: Icon(
                  Icons.drag_indicator,
                  color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white60 : Colors.black45,
                  size: 20,
                ),
              ),
            ),
            onDragStarted: () {
              setState(() {
                processStartIdCardDragged = jobData[jobToUse].processId!;
                processIdCardDragged = jobData[jobToUse].processId!;
                jobBeingDragged = jobData[jobToUse].id!;
              });
            },
            onDragEnd: (val) {
              setState(() {
                priorityJobChange();
                jobBeingDragged = '';
                processIdCardDragged = '';
              });
            },
            onDragCompleted: () {
              setState(() {
                priorityJobChange();
                jobBeingDragged = '';
                processIdCardDragged = '';
              });
            },
            onDraggableCanceled: (vel, off) {
              setState(() {
                priorityJobChange();
                jobBeingDragged = '';
                processIdCardDragged = '';
              });
            },
          ),
        ],
      );
    } else {
      return JobCard(
        context: context,
        jobData: jobData[jobToUse],
        height: jobHeight,
        width: processWidth - 40.0,
        processIndex: processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!,
      );
    }
  }

  /// Opens dialog menu with editable card information of [jobToUse] if [jobToUse] is null, assuming creating a new card, edited by current user
  Widget jobName(int? jobToUse) {
    try{
    if (jobToUse == null) {
      workers.add(currentUser.uid);
    }
    String tempWorker = '';
    String tempApprover = '';
    cardUpdateReady = false;

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
        try{
          if (isNewJob) return true;
          if (workers.isNotEmpty) {
            for (int i = 0; i < workers.length; i++) {
              if (workers[i] == currentUser.uid) {
                return true;
              }
            }
          }
        }
        catch(e){
          print('processManager.dart -> jobName() -> isWorker() -> Error: $e');
        }
        return false;
      }

      bool isApprover(int? index) {
        return index == null ? approvers.isNotEmpty && approvers.contains(currentUser.uid) : (jobToUse != null && approvers.isNotEmpty && approvers.length > index && approvers[index] == currentUser.uid);
      }

      Widget textField(String name, int width, String label, dynamic controller) {
        try{
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              EnterTextFormField(
                width: 260,
                color: Theme.of(context).canvasColor,
                maxLines: 1,
                label: label,
                controller: controller,
                onEditingComplete: () {},
                onSubmitted: (val) {},
                onTap: widget.onFocusNode
              ),
            ],
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> textField() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget descriptionField() {
        try{
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  'Description:',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              EnterTextFormField(
                width: 260,
                color: Theme.of(context).canvasColor,
                maxLines: 4,
                label: 'Enter Description',
                controller: cardNameControllers[1],
                onEditingComplete: () {},
                onSubmitted: (val) {},
                onTap: widget.onFocusNode,
                textStyle: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  fontFamily: 'NotoSans',
                  package: 'css',
                  fontSize: 14,
                  decoration: TextDecoration.none,
                )
              ),
            ]
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> descriptionField() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget approveCheckbox() {
        try{
          print('Building approveCheckbox for jobToUse: $jobToUse with numApprovals: ${jobToUse != null ? jobData[jobToUse].isApproved.length : 'N/A'}');
          int? processIndex;
          int numofApprovals = 0;
          if(jobToUse != null){
            processIndex = processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!;
            numofApprovals = processIndex + 1;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  "Approvals:",
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              (jobToUse != null) ? Row(
                children: [
                  Container(
                    width: 200,
                    height: 20,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: numofApprovals,
                      itemBuilder: (context, index) {
                        return Checkbox(
                          activeColor: Theme.of(context).secondaryHeaderColor,
                          value: (index < jobData[jobToUse].isApproved.length) ? true : false,
                          onChanged: (val) {
                            setState(() {
                              if (isApprover(null)) {
                                if (jobData[jobToUse].isApproved.length <= index) {
                                  var formatter = DateFormat('MM-dd-yyyy');
                                  String approvalDate = formatter.format(DateTime.now());
                                  jobData[jobToUse].isApproved.add(approvalDate);
                                } 
                              }
                            });
                          },
                        );
                      }
                    )
                  )
                ]
              ): const SizedBox()
            ]
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> approveCheckbox() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget statusField() {
        try{
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  'Status:',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              FocusedDropDown(
                itemVal: jobStatusDropDown,
                value: status.name,
                radius: 5,
                width: 150,
                color: Theme.of(context).canvasColor,
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                onchange: (val) {
                  if (widget.allowEditing || isNewJob) {
                    setState(() {
                      status = JobStatus.values.byName(val);
                    });
                  }
                },
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  fontSize: 12
                ),
              ),
            ],
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> statusField() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget fieldList() {
        return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          textField('Job Title:', 300, 'Enter Job Title', cardNameControllers[0]),
          const SizedBox(height: 10),
          descriptionField(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  'Required Date:',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                //width: 120,
                child: FocusedInkWell(
                  onTap: () async{
                    if (widget.allowEditing || isNewJob) {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedRequiredDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (picked != null && picked != selectedRequiredDate) {
                        setState(() {
                          var formatter = DateFormat('MM-dd-yyyy');
                          requiredDate = formatter.format(picked);
                          selectedRequiredDate = picked;
                        });
                      }
                    }
                  },
                  child: TaskWidgets.iconNote(
                    Icons.insert_invitation_outlined,
                    (requiredDate == '') ? DateFormat('MM-dd-yyyy').format(DateTime.now()) : requiredDate,
                    TextStyle(
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      fontFamily: 'NotoSans',
                      package: 'css',
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                    20
                  ),
                ),
              )
            ]
          ),
          if(status == JobStatus.inProgress || status == JobStatus.completed)Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  'Start Date:',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                //width: 120,
                child: FocusedInkWell(
                  onTap: () async{
                    if (widget.allowEditing || isNewJob) {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (picked != null && picked != selectedStartDate) {
                        setState(() {
                          var formatter = DateFormat('MM-dd-yyyy');
                          assignedDate = formatter.format(picked);
                          selectedStartDate = picked;
                        });
                      }
                    }
                  },
                  child: TaskWidgets.iconNote(
                    Icons.insert_invitation_outlined,
                    (assignedDate == '') ? DateFormat('MM-dd-yyyy').format(DateTime.now()) : assignedDate,
                    TextStyle(
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      fontFamily: 'NotoSans',
                      package: 'css',
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                    20
                  ),
                ),
              )
            ]
          ),
          if(status == JobStatus.completed)Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  'End Date:',
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontSize: 18,
                    fontFamily: 'NotoSans Bold',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                //width: 120,
                child: FocusedInkWell(
                  onTap: () async{
                    if (widget.allowEditing || isNewJob) {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (picked != null && picked != selectedEndDate) {
                        setState(() {
                          var formatter = DateFormat('MM-dd-yyyy');
                          completeDate = formatter.format(picked);
                          selectedEndDate = picked;
                        });
                      }
                    }
                  },
                  child: TaskWidgets.iconNote(
                    Icons.insert_invitation_outlined,
                    (completeDate == '') ? DateFormat('MM-dd-yyyy').format(DateTime.now()) : completeDate,
                    TextStyle(
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      fontFamily: 'NotoSans',
                      package: 'css',
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                    20
                  ),
                ),
              )
            ]
          ),
          if(status == JobStatus.inProgress || status == JobStatus.completed)const SizedBox(height: 10),
          if(status == JobStatus.inProgress || status == JobStatus.completed)textField('Good:', 180, 'number', numbersControllers[0]),
          if(status == JobStatus.inProgress || status == JobStatus.completed)const SizedBox(height: 10),
          if(status == JobStatus.inProgress || status == JobStatus.completed)textField('Bad:', 180, 'number', numbersControllers[1]),
          const SizedBox(height: 10),
          statusField(),
          const SizedBox(height: 10),
          approveCheckbox(),
        ]);
      }

      Widget workerDropDownWidget() {
        try{
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    TaskWidgets.iconNote(
                      Icons.assignment,
                      "Workers:",
                      TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .color,
                          fontFamily: 'NotoSans',
                          package: 'css',
                          decoration: TextDecoration.none),
                      20
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FocusedDropDown(
                          itemVal: workerDropDown,
                          value: tempWorker,
                          radius: 5,
                          width: 150,
                          color: Theme.of(context).canvasColor,
                          onchange: (val) {
                            setState(() {
                              tempWorker = val;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                            fontSize: 12
                          ),
                        ),
                        FocusedInkWell(
                          onTap: () {
                            if (isWorker()) {
                              bool allowedAdded = true;
                              if (workers.isNotEmpty && tempWorker != '') {
                                for (int i = 0; i < workers.length; i++) {
                                  if (tempWorker == workers[i]) {
                                    allowedAdded = false;
                                    break;
                                  }
                                }
                              }
                              setState(() {
                                if (allowedAdded && tempWorker != '') {
                                  workers.add(tempWorker);
                                  if (!isNewJob) {
                                    newWorkers.add(tempWorker);
                                  }
                                }
                              });
                            }
                          },
                          child: Icon(
                            Icons.add_box,
                            size: 30,
                            color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                          )
                        )
                      ],
                    )
                  ],
                ),
              ),
              workers.isNotEmpty ? Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_ind,
                      size: 35,
                    ),
                    LSIUserIcon(
                      remove: (loc) {
                        setState(() {
                          workers.removeAt(loc);
                        });
                      },
                      viewidth: 150,
                      uids: workers,
                      colors: [Colors.teal[200]!, Colors.teal[600]!],
                    )
                  ],
                )
              ):const SizedBox()
            ]
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> workerDropDownWidget() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget approverDropDownWidget() {
        try{
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              approvers.isEmpty ? SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    TaskWidgets.iconNote(
                      Icons.assignment,
                      "Approvers:",
                      TextStyle(
                        color: Theme.of(context)
                          .primaryTextTheme
                          .bodyMedium!
                          .color,
                        fontFamily: 'NotoSans',
                        package: 'css',
                        decoration: TextDecoration.none
                      ),
                      20
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FocusedDropDown(
                          itemVal: approverDropDown,
                          value: tempApprover,
                          radius: 5,
                          width: 150,
                          color: Theme.of(context).canvasColor,
                          onchange: (val) {
                            setState(() {
                              tempApprover = val;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                            fontSize: 12
                          ),
                        ),
                        FocusedInkWell(
                          onTap: () {
                            //if (isApprover()) {
                              bool allowedAdded = true;
                              // if (approvers.isNotEmpty && tempApprover != '') {
                              //   for (int i = 0; i < approvers.length; i++) {
                              //     if (tempApprover == approvers[i]) {
                              //       allowedAdded = false;
                              //       break;
                              //     }
                              //   }
                              // }
                              setState(() {
                                if (allowedAdded && tempApprover != '') {
                                  approvers.add(tempApprover);
                                  // if (!isNewJob) {
                                  //   approvers.add(tempApprover);
                                  // } // edit
                                }
                              });
                            //}
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
                  ],
                ),
              ) : Container(
                alignment: Alignment.centerLeft,
                width: 200,
                margin: const EdgeInsets.only(top: 30),
                child: TaskWidgets.iconNote(
                  Icons.assignment,
                  "Approvers:",
                  TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                      .primaryTextTheme
                      .bodyMedium!
                      .color,
                    fontFamily: 'NotoSans',
                    package: 'css',
                    decoration: TextDecoration.none
                  ),
                  20
                ),
              ),
              approvers.isNotEmpty ? Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_ind,
                      size: 35,
                    ),
                    LSIUserIcon(
                      remove: (loc) {
                        setState(() {
                          approvers.removeAt(loc);
                        });
                      },
                      viewidth: 150,
                      uids: approvers,
                      colors: [Colors.teal[200]!, Colors.teal[600]!],
                    )
                  ],
                )
              ):const SizedBox(),
            ]
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> approverDropDownWidget() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget assemblyList() { //will have to rework how this is done -nlw
        try{
          Widget createAssemblyCards() {
            List<Widget> assemblyCards = [];
            for (String key in jobData[jobToUse!].prevJobs!.keys) {
              (key == jobData[jobToUse].prevJobs!.keys.last) ? assemblyCards.add(
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: JobCard(
                    context: context,
                    jobData: JobData(
                      title: jobData[jobToUse].prevJobs![key]['title'],
                      createdBy: jobData[jobToUse].prevJobs![key]
                          ['createdBy'],
                      dateCreated: jobData[jobToUse].prevJobs![key]
                          ['dateCreated'],
                      dueDate: jobData[jobToUse].prevJobs![key]
                          ['dueDate'],
                      completeDate: jobData[jobToUse].prevJobs![key]
                          ['completeDate'],
                      workers: List<String>.from(
                          jobData[jobToUse].prevJobs![key]['workers'] ??
                              []),
                      approvers: List<String>.from(jobData[jobToUse]
                              .prevJobs![key]['approvers'] ??
                          []),
                      status: JobStatus.values.byName(
                          jobData[jobToUse].prevJobs![key]['status']),
                      isApproved: jobData[jobToUse].prevJobs![key]
                          ['isApproved'],
                      good: jobData[jobToUse].prevJobs![key]['good'],
                      bad: jobData[jobToUse].prevJobs![key]['bad'],
                    ),
                    height: 120,
                    width: 200,
                    processIndex: processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!,
                  )
                ),
              ) : assemblyCards.add(
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: JobCard(
                        context: context,
                        jobData: JobData(
                          title: jobData[jobToUse].prevJobs![key]['title'],
                          createdBy: jobData[jobToUse].prevJobs![key]
                              ['createdBy'],
                          dateCreated: jobData[jobToUse].prevJobs![key]
                              ['dateCreated'],
                          dueDate: jobData[jobToUse].prevJobs![key]
                              ['dueDate'],
                          completeDate: jobData[jobToUse].prevJobs![key]
                              ['completeDate'],
                          workers: List<String>.from(
                              jobData[jobToUse].prevJobs![key]['workers'] ??
                                  []),
                          approvers: List<String>.from(jobData[jobToUse]
                                  .prevJobs![key]['approvers'] ??
                              []),
                          status: JobStatus.values.byName(
                              jobData[jobToUse].prevJobs![key]['status']),
                          isApproved: jobData[jobToUse].prevJobs![key]
                              ['isApproved'],
                          good: jobData[jobToUse].prevJobs![key]['good'],
                          bad: jobData[jobToUse].prevJobs![key]['bad'],
                        ),
                        height: 120,
                        width: 200,
                        processIndex: processData.firstWhere((x) => x.id == jobData[jobToUse].processId).order!,
                      )
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_forward,
                        color: Theme.of(context).secondaryHeaderColor,
                        size: 30),
                    const SizedBox(width: 10),
                  ]
                )
              );
            }
            return Row(children: assemblyCards);
          }

          return (jobToUse == null || jobData[jobToUse].prevJobs == null || jobData[jobToUse].prevJobs!.isEmpty) ? const SizedBox() : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FocusedInkWell(
                        onTap: () {
                          setState(() {
                            expandAssembilies = !expandAssembilies;
                          });
                        },
                        child: Icon(
                          (!expandAssembilies)
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
                          "Assembilies",
                          TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyMedium!
                                  .color,
                              fontFamily: 'NotoSans',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none),
                          20),
                    ],
                  ),
                  LSIWidgets.squareButton(
                    text: 'View all',
                    fontSize: 12,
                    textColor: Theme.of(context).secondaryHeaderColor,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.only(
                                left: 1, right: 1),
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              height: 220,
                              width: jobData[jobToUse].prevJobs!.length * 250,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: const BorderRadius.all( Radius.circular(20) ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 5,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Assembly Timeline:",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyMedium!
                                            .color,
                                        fontFamily: 'NotoSans Bold',
                                        package: 'css',
                                        fontSize: 20,
                                        decoration:
                                            TextDecoration.none
                                    )
                                  ),
                                  const SizedBox(height: 10),
                                  Row( children: [createAssemblyCards()] )
                                ]
                              )
                            )
                          );
                        }
                      );
                    },
                    buttonColor: Colors.transparent,
                    borderColor: Theme.of(context)
                        .primaryTextTheme
                        .bodyMedium!
                        .color,
                    height: 30,
                    radius: 30 / 2,
                  ),
                ],
              ),
              SizedBox(height: 10),
              expandAssembilies ? SizedBox(
                height: 140.0,
                width: 480.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(0),
                      child: createAssemblyCards()
                    );
                  }
                )
              ) : const SizedBox()
            ],
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> assemblyList() -> Exception: $e');
          return const SizedBox();
        }
      }

      Widget notes() {
        try{
          print('Rendering Notes Section; Number of Controllers: ${activityControllers.length}');
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FocusedInkWell(
                    onTap: () {
                      setState(() {
                        expandNotes = !expandNotes;
                      });
                    },
                    child: Icon(
                      (!expandNotes) ? Icons.expand : Icons.clear_outlined,
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TaskWidgets.iconNote(
                    Icons.list_rounded,
                    "Notes",
                    TextStyle(
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      fontFamily: 'NotoSans',
                      package: 'css',
                      fontSize: 20,
                      decoration: TextDecoration.none
                    ),
                    20
                  ),
                  const SizedBox(width: 35),
                  FocusedInkWell(
                      onTap: () {
                        if (isWorker() || isApprover(null)) {
                          setState(() {
                            expandNotes = true;
                            activityControllers.add(SpellCheckController());
                            if (jobNotes == null) {
                              jobNotes = {
                                'names': [currentUser.uid],
                                'dates': [
                                  DateFormat('MM-dd-yyyy').format(DateTime.now())
                                ],
                              };
                            } else {
                              jobNotes!['names']!.add(currentUser.uid);
                              jobNotes!['dates']!.add(DateFormat('MM-dd-yyyy')
                                  .format(DateTime.now()));
                            }
                          });
                        }
                      },
                      child: Icon(
                        Icons.add_box,
                        size: 30,
                        color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      ))
                ],
              ),
              const SizedBox(height: 10),
              expandNotes ? Container(
                height: 100.0 * activityControllers.length,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Theme.of(context).primaryTextTheme.bodyMedium!.color!,
                    width: 2
                  )
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: activityControllers.length,
                  itemBuilder: (context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              Text(
                                usersProfile[jobNotes!['names']![i]]['displayName'],
                                style: TextStyle(
                                  color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                                  fontSize: 14,
                                  fontFamily: 'NotoSans Bold',
                                  package: 'css',
                                  decoration: TextDecoration.none
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                jobNotes!['dates']![i].replaceAll('T', ' '),
                                style: TextStyle(
                                  color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                                  fontSize: 12,
                                  fontFamily: 'OpenSans',
                                  decoration: TextDecoration.none
                                )
                              ),
                            ]
                          )
                        ),
                        EnterTextFormField(
                          width: width,
                          color: Theme.of(context).canvasColor,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          label: 'Write a Note',
                          controller: activityControllers[i],
                          onEditingComplete: () {},
                          onSubmitted: (val) {},
                          onTap: widget.onFocusNode
                        ),
                      ]
                    );
                  }
                )
              ): const SizedBox()
            ],
          );
        }
        catch(e){
          print('processManager.dart -> jobName() -> descriptionField() -> Exception: $e');
          return const SizedBox();
        }
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.only(left: 1, right: 1),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 650,
          width: 500,
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
            ],
          ),
          child: Stack(
            children: [ 
              Container(
                padding: const EdgeInsets.all(25),
                height: 625,
                width: 475,
                child: ListView(
                  padding: const EdgeInsets.all(0), 
                  children: [
                    cardUpdateReady ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        fieldList(),
                        workerDropDownWidget(),
                        approverDropDownWidget(),
                        const SizedBox(height: 10),
                        assemblyList(),
                        const SizedBox(height: 10),
                        notes(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // (!isNewJob && (isWorker() || isApprover(null))) ? LSIWidgets.squareButton(
                            //   text: 'delete',
                            //   textColor: Colors.red,
                            //   onTap: () {
                            //     setState(() {
                            //       if (widget.onJobDelete != null) {
                            //         widget.onJobDelete!(jobData[selectedJob!].id!);
                            //         jobReset();
                            //       }
                            //     });
                            //     Navigator.of(context).pop();
                            //   },
                            //   buttonColor: Colors.transparent,
                            //   borderColor: Colors.red,
                            //   height: 45,
                            //   radius: 45 / 2,
                            //   width: 425 / 2,
                            // ): Container(),
                            (isWorker() || isApprover(null)) ? LSIWidgets.squareButton(
                              text: 'save',
                              textColor: Theme.of(context).secondaryHeaderColor,
                              onTap: () {
                                setState(() {
                                  submitJobData();
                                  jobReset();
                                });
                                error = false;
                                Navigator.of(context).pop();
                              },
                              buttonColor: Colors.transparent,
                              borderColor:
                                  Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              height: 45,
                              radius: 45 / 2,
                              width: 425 / 2,
                            ) : Container(),
                          ]
                        )
                      ]
                    ) : LSILoadingWheel()
                  ]
                )
              ),
              Align(
                alignment: Alignment.topRight,
                child: FocusedInkWell(
                  onTap: () {
                    setState(() {
                      error = false;
                      jobReset();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close_outlined,
                    color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                    size: 30,
                  ),
                )
              )
            ]
          )
        )
      );
    });
    } catch (e) {
      print('processManager.dart -> jobName() -> Error: $e');
      return const SizedBox();
    }
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
                  Text("Do you want to duplicate this job?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .color,
                          fontFamily: 'NotoSans',
                          package: 'css',
                          fontSize: 20,
                          decoration: TextDecoration.none)),
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
                          width: 320 / 2 - 10),
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
              )));
    });
  }

  Widget info(String id) {
    int processIndex = processData.indexWhere((element) => element.id == id);

    return Stack(
      alignment: AlignmentDirectional.bottomEnd, 
      children: [
        infoContainer(id),
        LSIFloatingActionButton(
          message: 'Add New Job',
          allowed: processData[processIndex].order == 0,
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
            });
          },
        ),
        LSIFloatingActionButton(
          message: 'Export Jobs',
          alignment: Alignment.bottomLeft,
          allowed: true, 
          color: Theme.of(context).secondaryHeaderColor, 
          icon: Icons.download,
          size: 40,
          onTap:() {
            exportJob('${processData[processIndex].title!.replaceAll(' ', '_')}.csv', jobData.where((x) => x.processId == id).toList(), processData[processIndex].order!);
          },
        )
      ]
    );
  }

  /// Widget that displays all the cards in the board [id]
  Widget infoContainer(String id) {
    List<Widget> jobs = [];
    if (jobData.isNotEmpty) {
      for (int index = 0; index < jobData.length; index++) {
        int jobToUse;

        if (jobData[index].processId == id) {
          jobToUse = index;
        
          if (jobBeingDragged != jobData[jobToUse].id) {
            jobs.add(
              FocusedInkWell(
                onLongPress: () {
                  setState(() {
                    processId = id;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return duplicateCard();
                  });
                },
                onDoubleTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      processId = id;
                      return jobName(jobToUse);
                    }
                  );
                },
                child: dragCard(id, index, jobToUse)
              )
            );
          } else {
            jobs.add(SizedBox(
              height: 70,
              width: processWidth - 20.0,
            ));
          }
        }
      }
    } else {
      jobs.add(Container());
    }
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, right: 10),
      height: height - 110,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).canvasColor
      ),
      child: ListView(padding: const EdgeInsets.all(0), children: jobs)
    );
  }

  /// Displays title of the process
  Widget title(String title, String subtitle, TextEditingController controller, Color color) {
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
                child: Text(
                  '', //title.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontFamily: 'OpenSans',
                    package: 'css',
                    decoration: TextDecoration.none
                  )
                )
              ),
            Container(
                width: width,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10),
                color: Theme.of(context).splashColor,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .color,
                          fontFamily: 'NotoSans',
                          package: 'css',
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      // FocusedInkWell(
                      //   onLongPress: () {
                      //     if (widget.allowEditing &&
                      //         widget.onProcessDelete != null) {
                      //       widget.onProcessDelete!(title);
                      //     }
                      //   },
                      //   child: Icon(
                      //     Icons.delete_forever,
                      //     size: 20,
                      //     color: Theme.of(context)
                      //         .primaryTextTheme
                      //         .bodyMedium!
                      //         .color,
                      //   ),
                      // )
                    ]))
          ]),
    );
  }

  /// Widget that replaces board [i] with container while it is being dragged, also determines behavior of board when dragged
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
              priorityChange();
            });
          },
          onDragCompleted: () {
            setState(() {
              processBeingDragged = '';
              priorityChange();
            });
          },
          onDraggableCanceled: (vel, off) {
            setState(() {
              processBeingDragged = '';
              priorityChange();
            });
          },
          child: const Padding(
              padding: EdgeInsets.only(top: 10, left: 10),
              child: Icon(Icons.drag_indicator)),
        ),
      ],
    );
  }
  /// Widget that displays process when dragging to new position, rotation of process determined by [rotate] and process being used is processData[i]
  Widget process(int i, bool rotate) {
    return Transform.rotate(
      angle: (rotate) ? 0.174533 : 0,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: processWidth + 4,
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
          ]
        ),
        child: Column(
          children: [
            title(
              processData[i].id!,
              processData[i].title!,
              nameChangeController[i],
              Theme.of(context).primaryColor,
              //Color(processData[i].color!),
            ),
            info(processData[i].id!)
          ],
        ),
      )
    );
  }

  /// Displays the list of boards
  List<Widget> processList() {
    List<Widget> routers = [];
    nextIndex = 0;
    for (int i = 0; i < processData.length; i++) {
      nameChangeController.add(TextEditingController());
      if (processBeingDragged != processData[i].id) {
        routers.add(
          FocusedInkWell(
            mouseCursor: MouseCursor.defer,
            onDoubleTap: () {
              processSet(i);
            },
            child: process(i, false)
          )
        );
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
                  color: Theme.of(context)
                      .primaryTextTheme
                      .bodyMedium!
                      .color,
                  fontFamily: 'NotoSans',
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
                onTap: widget.onFocusNode ?? () {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Allow Process Notifications!",
                    style: TextStyle(
                      color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      fontFamily: 'NotoSans',
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
              (error) ? const Text(
                "Field is missing data!",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'NotoSans',
                  package: 'css',
                  fontSize: 20
                ),
              ) : Container(),
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
                      width: 320 / 2 - 10),
                  LSIWidgets.squareButton(
                    text: (!updateProcess) ? 'submit' : 'update',
                    onTap: () {
                      if (processNameController.text != '') {
                        if (!updateProcess) {
                          if (widget.onSubmit != null) {
                            widget.onSubmit!(
                                processNameController.text, allowNotifying);
                          }
                        } else {
                          dynamic data = {
                            'title': processNameController.text,
                            'createdBy':
                                processData[updateProcessId].createdBy,
                            'dateCreated':
                                processData[updateProcessId].dateCreated,
                            'routerId': processData[updateProcessId].routerId,
                            'notify': allowNotifying,
                            'order': processData[updateProcessId].order
                          };
                          if (widget.onEdit != null) {
                            widget.onEdit!(
                                data, processData[updateProcessId].id!);
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
    height = (widget.height == null)
        ? MediaQuery.of(context).size.height
        : widget.height!;
    width = (widget.width == null)
        ? MediaQuery.of(context).size.width
        : widget.width!;

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
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd, 
        children: [
          (processData.isNotEmpty) ? DragTarget<int>(
            onMove: (details) {
              if (details.offset.dx > deviceWidth - 140) {
                _scrollController.jumpTo(_scrollController.offset + 5);
              } else if (details.offset.dx < widget.screenOffset.dx + 5 && _scrollController.offset > 0) {
                _scrollController.jumpTo(_scrollController.offset - 5);
              }

              if (processBeingDragged != '') {
                updateProcessOrder(details.offset);
              }
              if (jobBeingDragged != '') {
                updateJobPriority(details.offset);
              }
            }, builder: (context, List<int?> candidateData, rejectedData) {
              return Container(
                height: height,
                width: width,
                color: Theme.of(context).cardColor,
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
                    children: processList()
                  )
                )
              );
            }
          ) : Container(
            height: height,
            width: width,
            color: Theme.of(context).cardColor,
          ),
          LSIFloatingActionButton(
            allowed: widget.routerId.isNotEmpty,
            color: Theme.of(context).secondaryHeaderColor,
            icon: Icons.add,
            message: 'Create New Process',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return processName();
                }
              );
            }
          ),
        ]
      )
    );
  }
}
