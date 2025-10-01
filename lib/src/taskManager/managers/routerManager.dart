import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../styles/savedWidgets.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../task_master.dart';
import '../example/taskWidgets.dart';
import '../../functions/lsi_functions.dart';
import '../../../../styles/globals.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../src/database/database.dart';

class RouterManager extends StatefulWidget {
  const RouterManager({
    Key? key,
    this.onSubmit,
    this.onComplete,
    this.onTitleChange,
    this.onFocusNode,
    required this.routerData,
    this.onRouterTap,
    this.onRouterDelete,
    this.onUpdate,
    this.width = 320,
    this.height = 360,
    this.cardWidth = 300,
    required this.allowEditing,
    required this.epic,
    this.startRouter,
  }):super(key: key);

  /// Callback for router creation/submit
  final Function(String title, String image, String date, int color)? onSubmit;

  /// Callback for router updates
  final Function(String title, String image, String date, int color, String selectedRouter)? onUpdate;

  /// Callback for router completion
  final Function(String selectedRouter)? onComplete;

  final Function? onFocusNode;

  /// Callback for router deletion
  final Function(String id)? onRouterDelete;

  /// Callback for router title changes
  final Function(String id, String title)? onTitleChange;

  final List<RouterData> routerData;

  /// Callback for tapping on router
  final Function(String routerName)? onRouterTap;

  final double? height;
  final double? width;

  /// Determine if current user is allowed to edit
  final bool allowEditing;

  /// Sets width of cards (in this case cards are processes)
  final double cardWidth;

  /// Epic that encompasses all the routers to be managed
  final String epic;

  /// Router that is selected by default
  final String? startRouter;

  @override
  _RouterManagerState createState() => _RouterManagerState();
}

class _RouterManagerState extends State<RouterManager> {
  String assignedDate = '';
  String selectedRouter = '';
  String editRouter = '';
  DateTime selectedDate = DateTime.now();

  TextEditingController routerNameController = TextEditingController();
  TextEditingController routerImageController = TextEditingController();
  List<TextEditingController> nameChangeController = [];
  bool error = false;
  bool isNewRouter = true;
  Color routerClickedColor = Colors.white;
  List<Color> hexColors = [
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.lightBlue,
    Colors.blue,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey
  ];
    List<IconData> cbIcon = [
    Icons.ac_unit,
    Icons.gavel,
    Icons.extension,
    Icons.settings_input_antenna,
    Icons.settings_input_component,
    Icons.polymer,
    Icons.code_off,
    Icons.insights,
    Icons.stream,
    Icons.gesture,
    Icons.grain,
    Icons.texture,
    Icons.dialpad,
    Icons.bubble_chart
  ];
  
  late String epic;

  @override
  void initState() {
    start();
    super.initState();
  }

  void start() {
    epic = widget.epic;
    selectedRouter = widget.startRouter ?? '';
    listenToFirebase();
  }

  void reset() {
    setState(() {});
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.dispose();
  }

  void listenToFirebase() {

  }

  void carryCardFunction(event) {

  }

  // Sets up data to be displayed in update dialog for a router
  void setUpdateData(int i) {

  }
  
  // Displays Created By, Creation date, and due date of routers
  Widget info(RouterData data, Color color) {
    return SizedBox();
  }

  /// Displays the router name
  Widget title(String title, String subtitle, Color color) {
    return SizedBox();
  }

  // Function that builds list of routerCard Widgets
  List<Widget> routerCards() {
    return [];
  }

  /// Creates Color Indicators to select colors for customization
  Widget createColorIndicators(void Function() callback) {
    return SizedBox();
  }

  // Widget for router creation/editing dialog
  Widget projectName() {
    return SizedBox();
  }

  Widget build(BuildContext context) {
    return SizedBox();
  }
}