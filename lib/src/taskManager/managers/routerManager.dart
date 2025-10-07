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
    routerClickedColor = Colors.white;
    setState(() {
      isNewRouter = false;
      routerNameController.text = widget.routerData[i].title;
      selectedDate = DateTime.now();
      assignedDate = '';
      routerClickedColor = Color(widget.routerData[i].color);
    });
  }
  
  // Displays Created By, Creation date, and due date of routers
  Widget info(RouterData data, Color color) {
      return Container(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(
          children: [
            Row(children: [
              Text(
                'Created By: ',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    fontSize: 14),
              ),
              Text(
                data.createdBy,
                style: TextStyle(
                    color: color,
                    fontFamily: 'Klavika',
                    package: 'css',
                    fontSize: 14),
              )
            ]),
            Row(children: [
              Text(
                'Date Created: ',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.labelSmall!.color,
                    fontFamily: 'Klavika Bold',
                    package: 'css',
                    fontSize: 14),
              ),
              Text(
                data.dateCreated.split('T')[0],
                style: TextStyle(
                    color: color,
                    fontFamily: 'Klavika',
                    package: 'css',
                    fontSize: 14),
              )
            ]),
            Container(height: 16),
          ],
        )
      ]),
    );
  }

  /// Displays the router name
  Widget title(String title, String subtitle, Color color) {
      return Container(
      width: widget.cardWidth,
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
                width: widget.cardWidth,
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10, top: 15),
                padding: const EdgeInsets.only(left: 10),
                color: Theme.of(context).splashColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: widget.cardWidth - 40,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: color,
                          fontFamily: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .fontFamily,
                          decoration: TextDecoration.none
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FocusedInkWell(
                      onTap: () {
                        if (widget.onRouterDelete != null &&
                            widget.allowEditing) {
                          widget.onRouterDelete!(title);
                        }
                      },
                      child: Icon(
                        Icons.delete_forever,
                        size: 20,
                        color:
                            Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      ),
                    )
                  ],
                )),
          ]),
    );
  }

  // Function that builds list of routerCard Widgets
  List<Widget> routerCards() {
    List<Widget> projects = [];
    int numOfPro = widget.routerData.length;
    for (int i = 0; i < numOfPro; i++) {
      projects.add(FocusedInkWell(
        onLongPress: () {
          editRouter = widget.routerData[i].id;
          setUpdateData(i);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return projectName();
              });
        },
        onDoubleTap: () {
          editRouter = widget.routerData[i].id;
          setUpdateData(i);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return projectName();
              });
        },
        onTap: () {
          if (widget.onRouterTap != null) {
            widget.onRouterTap!(widget.routerData[i].id);
          }
          setState(() {
            selectedRouter = widget.routerData[i].id;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(top: 20, right: 5, left: 5),
          width: widget.cardWidth,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Theme.of(context).cardColor,
              border: Border.all(
                width: 2,
                color: (selectedRouter == widget.routerData[i].id)
                    ? Theme.of(context).secondaryHeaderColor
                    : Theme.of(context).cardColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]),
          child: Column(
            children: [
              title(widget.routerData[i].id, widget.routerData[i].title,
                  Color(widget.routerData[i].color)),
              info(widget.routerData[i], Color(widget.routerData[i].color))
            ],
          ),
        ),
      ));
    }
    if (numOfPro > 0) {
      int allowed = (widget.width! / (widget.cardWidth)).floor();
      int leftOver = numOfPro - (numOfPro ~/ allowed) * allowed + 1;
      for (int i = 0; i < leftOver; i++) {
        projects.add(SizedBox(
          width: widget.cardWidth,
          height: 265 / 2,
        ));
      }
    }

    return projects;
  }

  /// Creates Color Indicators to select colors for customization
  Widget createColorIndicators(void Function() callback) {
    List<Widget> colorsWidget = [];
    for (int i = 0; i < hexColors.length - 1; i++) {
      colorsWidget.add(FocusedInkWell(
        onTap: () {
          routerClickedColor = hexColors[i];
          callback();
        },
        child: Container(
          height: 320 / hexColors.length,
          width: 320 / hexColors.length,
          decoration: BoxDecoration(
              color: hexColors[i],
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: (routerClickedColor.value == hexColors[i].value)
              ? Icon(Icons.check,
                  size: 320 / hexColors.length, color: Colors.white)
              : Container(),
        ),
      ));
    }
    colorsWidget.add(FocusedInkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Pick a color!'),
                content: SizedBox(
                  width: 250,
                  height: 260,
                  child: ColorPicker(
                    pickerColor: routerClickedColor,
                    onColorChanged: (color) {
                      setState(() {
                        routerClickedColor = color;
                      });
                    },
                    colorPickerWidth: 250,
                    pickerAreaHeightPercent: 0.7,
                    portraitOnly: true,
                    enableAlpha: false,
                    labelTypes: [],
                    pickerAreaBorderRadius: BorderRadius.circular(10),
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Got it'),
                    onPressed: () {
                      callback();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }).then((value) {
          callback();
        });
        callback();
      },
      child: Container(
        height: 320 / hexColors.length,
        width: 320 / hexColors.length,
        decoration: BoxDecoration(
            color: routerClickedColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Icon(Icons.color_lens,
            size: 320 / hexColors.length,
            color: CSS.responsiveColor(routerClickedColor, 0.5)),
      ),
    ));
    return Wrap(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: colorsWidget);
  }

  // Widget for router creation/editing dialog
  Widget projectName() {
        return StatefulBuilder(builder: (context, setState) {
      // Creates handles the date picker for the project due date
      void _selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.isBefore(DateTime.now())
              ? DateTime.now()
              : selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            var formatter = DateFormat('MM-dd-y');
            assignedDate = formatter.format(picked);
            selectedDate = picked;
          });
        }
      }

      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 380,
            width: CSS.responsive(),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Please Enter the name of the router!",
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyMedium!.color,
                        fontFamily: 'Klavika',
                        package: 'css',
                        fontSize: 20),
                  ),
                  Wrap(
                    children: [
                      Text(
                        "Name: ",
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium!
                                .color,
                            fontFamily: 'Klavika',
                            package: 'css',
                            fontSize: 20),
                      ),
                      EnterTextFormField(
                        width: CSS.responsive() - 120,
                        height: 35,
                        color: Theme.of(context).canvasColor,
                        maxLines: 1,
                        label: 'Router Name',
                        controller: routerNameController,
                        onTap: () {
                          if (widget.onFocusNode != null) {
                            widget.onFocusNode!();
                          }
                        },
                      )
                    ],
                  ),
                  createColorIndicators(() {
                    setState(() {});
                  }),
                  Row(
                    children: [
                      TaskWidgets.iconNote(
                          Icons.insert_invitation_outlined,
                          "Due Date: ",
                          TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyMedium!
                                  .color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none),
                          20),
                      FocusedInkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: SizedBox(
                            child: Text(
                              (assignedDate == '')
                                  ? DateFormat('MM-dd-y').format(DateTime.now())
                                  : assignedDate,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .color,
                                  fontFamily: 'Klavika',
                                  package: 'css',
                                  fontSize: 20,
                                  decoration: TextDecoration.none),
                            ),
                          ))
                    ],
                  ),
                  (error)
                      ? const Text(
                          "Field is missing Data!",
                          style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20),
                        )
                      : Container(),
                  Wrap(
                      runSpacing: 20,
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        LSIWidgets.squareButton(
                          text: 'cancel',
                          onTap: () {
                            setState(() {
                              routerNameController.text = '';
                            });
                            routerClickedColor = Colors.white;
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
                          width: 320 / 3 - 10,
                        ),
                        (!isNewRouter)
                            ? LSIWidgets.squareButton(
                                text: 'complete',
                                onTap: () {
                                  if (widget.onComplete != null) {
                                    widget.onComplete!(editRouter);
                                  }
                                  setState(() {
                                    error = false;
                                    routerNameController.text = '';
                                  });
                                  routerClickedColor = Colors.white;
                                  Navigator.of(context).pop();
                                },
                                textColor: Theme.of(context).indicatorColor,
                                buttonColor: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .color!,
                                height: 45,
                                radius: 45 / 2,
                                width: 320 / 3 - 10,
                              )
                            : Container(),
                        LSIWidgets.squareButton(
                          text: (isNewRouter) ? 'submit' : 'update',
                          onTap: () {
                            if (routerNameController.text != '') {
                              if (isNewRouter) {
                                if (widget.onSubmit != null) {
                                  widget.onSubmit!(
                                      routerNameController.text,
                                      routerImageController.text,
                                      (assignedDate != '')
                                          ? selectedDate
                                              .toString()
                                              .replaceAll(' ', 'T')
                                          : '',
                                      routerClickedColor.value);
                                }
                              } else {
                                if (widget.onUpdate != null) {
                                  widget.onUpdate!(
                                      routerNameController.text,
                                      routerImageController.text,
                                      (assignedDate != '')
                                          ? selectedDate
                                              .toString()
                                              .replaceAll(' ', 'T')
                                          : '',
                                      routerClickedColor.value,
                                      editRouter);
                                }
                              }
                              setState(() {
                                error = false;
                                routerNameController.text = '';
                              });
                              routerClickedColor = Colors.white;
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
                          width: 320 / 3 - 10,
                        )
                      ])
                ]),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.epic != epic) {
        setState(() {
          start();
        });
      }
    });
    double width = (widget.width == null)
        ? MediaQuery.of(context).size.width
        : widget.width!;
    return InkWell(
        mouseCursor: MouseCursor.defer,
        onTap: () {
          setState(() {
            FocusManager.instance.primaryFocus?.unfocus();
          });
        },
        child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          (widget.routerData.isNotEmpty)
              ? Container(
                  height: (widget.height == null)
                      ? MediaQuery.of(context).size.height
                      : widget.height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                  child: ListView(padding: const EdgeInsets.all(0), children: [
                    Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: routerCards())
                  ]))
              : Container(
                  height: (widget.height == null)
                      ? MediaQuery.of(context).size.height
                      : widget.height,
                  width: width,
                  color: Theme.of(context).canvasColor,
                ),
          LSIFloatingActionButton(
              allowed: widget.allowEditing,
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icons.add,
              onTap: () {
                setState(() {
                  isNewRouter = true;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return projectName();
                    });
              }),
        ]));
  }
}