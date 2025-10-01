import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../spell_check/SpellChecker.dart';

import '../../../../../styles/globals.dart';
import '../../../../../styles/savedWidgets.dart';
import '../../../../../src/functions/lsi_functions.dart';

import '../../task_master.dart';
import '../example/taskCard.dart';
import '../example/taskWidgets.dart';

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
    ///this.allowEditing = true,
    this.screenOffset = const Offset(0,0),
    required this.users,
  }):super(key: key);

  /// Callback for process submission/creation
  final Function(String title)? onSubmit;

  /// Callback for process edit
  final Function(dynamic data, String id)? onEdit;

  /// Callback for process deletion
  final Function(String id, int index)? onProcessDelete;

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

  /// A dropdown of all the users to be used for assignment to tasks
  final List<DropDownItems> users;

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
  bool isNewCard = true;
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
    TextEditingController()
  ]; 
  List<int> boardJobs = [];
  List<DropdownMenuItem<dynamic>> workerDropDown = [];
  List<DropdownMenuItem<dynamic>> approverDropDown = [];
  List<ProcessData> processData = [];
  List<JobData> jobData = [];
  Map<String, List<String>>? jobNotes;

  String processBeingDragged = '';
  String processId = '';
  List<String> workers = [];
  List<String> newWorkers = [];
  List<String> approvers = [];
  String assignedDate = '';
  String processIdCardDragged = '';
  String processStartIdCardDragged = '';
  String jobBeingDragged = '';

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
    workerDropDown = LSIFunctions.setDropDownItems(widget.users);
    approverDropDown = LSIFunctions.setDropDownItems(widget.users);

    jobReset();
    processReset();
    sortByDueDate();
    setState(() {});
  }

  /// Reset Job Data to its defaults
  void jobReset() {

  }

  /// Gets card data from selected card [i] and populates their respective fields
  Future<void> jobSet() async {

  }

  /// Resets the board
  void processReset() {

  }

  /// Opens dialog that is used to edit process [id]'s title and notification status
  void processSet(int id) {
    processReset();
  }

  /// Prepares job data into JSON format to be sent to database
  void submitJobData() {

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

  }

  /// Exports the job and any archived assembilies
  void exportJob() {

  }

  /// Widget for draggable cards
  Widget dragCard(String id, int index, int jobToUse) {
    return SizedBox();
  }

  /// Opens dialog menu with editable card information of [jobToUse] if [jobToUse] is null, assuming creating a new card, edited by current user
  Widget jobName(int? jobToUse) {
    return SizedBox();
  }

  Widget info(bool drag, String id) {
    return SizedBox();
  }

  Widget title(String title, String subtitle, TextEditingController controller, Color color, bool dragged) {
    return SizedBox();
  }

  Widget process(int i, bool rotate) {
    return SizedBox();
  }

  Widget dragProcess(int i) {
    return SizedBox();
  }

  Widget processName() {
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}