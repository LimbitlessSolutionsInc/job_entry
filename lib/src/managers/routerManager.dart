// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../styles/savedWidgets.dart';
// import '../router_master.dart';
// import '../../../../styles/globals.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// class RouterManager extends StatefulWidget {
//   const RouterManager({
//     Key? key,
//     this.onSubmit,
//     this.onComplete,
//     this.onTitleChange,
//     this.onFocusNode,
//     required this.routerData,
//     this.onRouterTap,
//     this.onRouterDelete,
//     this.canArchiveRouter,
//     this.onUpdate,
//     this.width = 320,
//     this.height = 360,
//     this.cardWidth = 300,
//     required this.allowEditing,
//     this.startRouter,
//   }) : super(key: key);

//   /// Callback for router creation/submit
//   final Function(String title, String image, String date, int color)? onSubmit;

//   /// Callback for router updates
//   final Function(String title, String image, String date, int color,
//       String selectedRouter)? onUpdate;

//   /// Callback for router completion
//   final Function(String selectedRouter)? onComplete;

//   final Function? onFocusNode;

//   /// Callback for router deletion
//   final Function(String id)? onRouterDelete;

//   /// Callback for router title changes
//   final Function(String id, String title)? onTitleChange;

//   final List<RouterData> routerData;

//   /// Callback for tapping on router
//   final Function(String routerName)? onRouterTap;

//   final Function(String id)? canArchiveRouter;

//   final double? height;
//   final double? width;

//   /// Determine if current user is allowed to edit
//   final bool allowEditing;

//   /// Sets width of cards (in this case cards are processes)
//   final double cardWidth;

//   /// Router that is selected by default
//   final String? startRouter;

//   @override
//   _RouterManagerState createState() => _RouterManagerState();
// }

// class _RouterManagerState extends State<RouterManager> {
//   String assignedDate = '';
//   String selectedRouter = '';
//   String editRouter = '';
//   DateTime selectedDate = DateTime.now();
//   late double width;
//   late double height;

//   TextEditingController routerNameController = TextEditingController();
//   TextEditingController routerImageController = TextEditingController();
//   List<TextEditingController> nameChangeController = [];
//   bool error = false;
//   bool isNewRouter = true;
//   Color routerClickedColor = Colors.white;
//   List<Color> hexColors = [
//     Colors.purple,
//     Colors.pink,
//     Colors.red,
//     Colors.deepOrange,
//     Colors.orange,
//     Colors.yellow,
//     Colors.lime,
//     Colors.lightGreen,
//     Colors.green,
//     Colors.lightBlue,
//     Colors.blue,
//     Colors.deepPurple,
//     Colors.blueGrey,
//     Colors.grey
//   ];
//   List<IconData> cbIcon = [
//     Icons.ac_unit,
//     Icons.gavel,
//     Icons.extension,
//     Icons.settings_input_antenna,
//     Icons.settings_input_component,
//     Icons.polymer,
//     Icons.code_off,
//     Icons.insights,
//     Icons.stream,
//     Icons.gesture,
//     Icons.grain,
//     Icons.texture,
//     Icons.dialpad,
//     Icons.bubble_chart
//   ];

//   late String epic;

//   @override
//   void initState() {
//     start();
//     super.initState();
//   }

//   void start() {
//     selectedRouter = widget.startRouter ?? '';
//   }

//   void reset() {
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     FocusManager.instance.primaryFocus?.unfocus();
//     super.dispose();
//   }

//   // Sets up data to be displayed in update dialog for a router
//   void setUpdateData(int i) {
//     routerClickedColor = Colors.white;
//     setState(() {
//       isNewRouter = false;
//       routerNameController.text = widget.routerData[i].title;
//       selectedDate = DateTime.now();
//       assignedDate = '';
//       routerClickedColor = Color(widget.routerData[i].color);
//     });
//   }

//   // Displays Created By, Creation date, and due date of routers
//   Widget info(RouterData data, Color color) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
//       margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.all(Radius.circular(2)),
//         color: Theme.of(context).canvasColor,
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Column(
//           children: [
//             Row(children: [
//               Text(
//                 'Created By: ',
//                 style: TextStyle(
//                     color: Theme.of(context).primaryTextTheme.labelSmall!.color,
//                     fontFamily: 'NotoSans Bold',
//                     package: 'css',
//                     fontSize: 14),
//               ),
//               Text(
//                 data.createdBy,
//                 style: TextStyle(
//                     color: color,
//                     fontFamily: 'NotoSans',
//                     package: 'css',
//                     fontSize: 14),
//               )
//             ]),
//             Row(children: [
//               Text(
//                 'Date Created: ',
//                 style: TextStyle(
//                     color: Theme.of(context).primaryTextTheme.labelSmall!.color,
//                     fontFamily: 'NotoSans Bold',
//                     package: 'css',
//                     fontSize: 14),
//               ),
//               Text(
//                 data.dateCreated.split('T')[0],
//                 style: TextStyle(
//                     color: color,
//                     fontFamily: 'NotoSans',
//                     package: 'css',
//                     fontSize: 14),
//               )
//             ]),
//             Container(height: 16),
//           ],
//         )
//       ]),
//     );
//   }

//   /// Displays the router name
//   Widget title(String title, String subtitle, Color color) {
//     return Container(
//       width: widget.cardWidth,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.only(
//             topRight: Radius.circular(15), topLeft: Radius.circular(15)),
//         color: Theme.of(context).cardColor,
//       ),
//       child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//                 width: widget.cardWidth,
//                 alignment: Alignment.centerLeft,
//                 margin: const EdgeInsets.only(bottom: 10, top: 15),
//                 padding: const EdgeInsets.only(left: 10),
//                 color: Theme.of(context).splashColor,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       width: widget.cardWidth - 40,
//                       child: Text(
//                         subtitle,
//                         style: TextStyle(
//                             color: color,
//                             fontFamily: Theme.of(context)
//                                 .primaryTextTheme
//                                 .bodyMedium!
//                                 .fontFamily,
//                             decoration: TextDecoration.none),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if(widget.canArchiveRouter != null && widget.canArchiveRouter!(title))FocusedInkWell(
//                       onTap: () {
//                         if (widget.onRouterDelete != null &&
//                             widget.allowEditing) {
//                           widget.onRouterDelete!(title);
//                         }
//                       },
//                       child: Icon(
//                         Icons.delete_forever,
//                         size: 20,
//                         color: Theme.of(context)
//                             .primaryTextTheme
//                             .bodyMedium!
//                             .color,
//                       ),
//                     )
//                   ],
//                 )),
//           ]),
//     );
//   }

//   // Function that builds list of routerCard Widgets
//   List<Widget> routerCards() {
//     List<Widget> projects = [];
//     int numOfPro = widget.routerData.length;
//     for (int i = 0; i < numOfPro; i++) {
//       projects.add(FocusedInkWell(
//         onLongPress: () {
//           editRouter = widget.routerData[i].id;
//           setUpdateData(i);
//           showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return projectName();
//               });
//         },
//         onDoubleTap: () {
//           editRouter = widget.routerData[i].id;
//           setUpdateData(i);
//           showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return projectName();
//               });
//         },
//         onTap: () {
//           if (widget.onRouterTap != null) {
//             widget.onRouterTap!(widget.routerData[i].id);
//           }
//           setState(() {
//             selectedRouter = widget.routerData[i].id;
//           });
//         },
//         child: Container(
//           margin: const EdgeInsets.only(top: 20, right: 5, left: 5),
//           width: widget.cardWidth,
//           decoration: BoxDecoration(
//               borderRadius: const BorderRadius.all(Radius.circular(15)),
//               color: Theme.of(context).cardColor,
//               border: Border.all(
//                 width: 2,
//                 color: (selectedRouter == widget.routerData[i].id)
//                     ? Theme.of(context).secondaryHeaderColor
//                     : Theme.of(context).cardColor,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Theme.of(context).shadowColor,
//                   blurRadius: 5,
//                   offset: const Offset(0, 2),
//                 ),
//               ]),
//           child: Column(
//             children: [
//               title(widget.routerData[i].id, widget.routerData[i].title,
//                   Color(widget.routerData[i].color)),
//               info(widget.routerData[i], Color(widget.routerData[i].color))
//             ],
//           ),
//         ),
//       ));
//     }
//     if (numOfPro > 0) {
//       int allowed = (width / (widget.cardWidth)).floor();
//       int leftOver = numOfPro - (numOfPro ~/ allowed) * allowed + 1;
//       for (int i = 0; i < leftOver; i++) {
//         projects.add(SizedBox(
//           width: widget.cardWidth,
//           height: 265 / 2,
//         ));
//       }
//     }

//     return projects;
//   }

//   /// Creates Color Indicators to select colors for customization
//   Widget createColorIndicators(void Function() callback) {
//     List<Widget> colorsWidget = [];
//     for (int i = 0; i < hexColors.length - 1; i++) {
//       colorsWidget.add(FocusedInkWell(
//         onTap: () {
//           routerClickedColor = hexColors[i];
//           callback();
//         },
//         child: Container(
//           height: 320 / hexColors.length,
//           width: 320 / hexColors.length,
//           decoration: BoxDecoration(
//               color: hexColors[i],
//               borderRadius: const BorderRadius.all(Radius.circular(10))),
//           child: (routerClickedColor.value == hexColors[i].value)
//               ? Icon(Icons.check,
//                   size: 320 / hexColors.length, color: Colors.white)
//               : Container(),
//         ),
//       ));
//     }
//     colorsWidget.add(FocusedInkWell(
//       onTap: () {
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Pick a color!'),
//                 content: SizedBox(
//                   width: 250,
//                   height: 260,
//                   child: ColorPicker(
//                     pickerColor: routerClickedColor,
//                     onColorChanged: (color) {
//                       setState(() {
//                         routerClickedColor = color;
//                       });
//                     },
//                     colorPickerWidth: 250,
//                     pickerAreaHeightPercent: 0.7,
//                     portraitOnly: true,
//                     enableAlpha: false,
//                     labelTypes: [],
//                     pickerAreaBorderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 actions: <Widget>[
//                   ElevatedButton(
//                     child: const Text('Got it'),
//                     onPressed: () {
//                       callback();
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               );
//             }).then((value) {
//           callback();
//         });
//         callback();
//       },
//       child: Container(
//         height: 320 / hexColors.length,
//         width: 320 / hexColors.length,
//         decoration: BoxDecoration(
//             color: routerClickedColor,
//             borderRadius: const BorderRadius.all(Radius.circular(10))),
//         child: Icon(Icons.color_lens,
//             size: 320 / hexColors.length,
//             color: CSS.responsiveColor(routerClickedColor, 0.5)),
//       ),
//     ));
//     return Wrap(
//         //mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: colorsWidget);
//   }

//   // Widget for router creation/editing dialog
//   Widget projectName() {
//     return StatefulBuilder(builder: (context, setState) {
//       // Creates handles the date picker for the project due date
//       void _selectDate(BuildContext context) async {
//         final DateTime? picked = await showDatePicker(
//           context: context,
//           initialDate: selectedDate.isBefore(DateTime.now())
//               ? DateTime.now()
//               : selectedDate,
//           firstDate: DateTime.now(),
//           lastDate: DateTime(DateTime.now().year + 5),
//         );
//         if (picked != null && picked != selectedDate) {
//           setState(() {
//             var formatter = DateFormat('MM-dd-yyyy');
//             assignedDate = formatter.format(picked);
//             selectedDate = picked;
//           });
//         }
//       }

//       return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             height: 380,
//             width: CSS.responsive(),
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: const BorderRadius.all(Radius.circular(10)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Theme.of(context).shadowColor,
//                   blurRadius: 5,
//                   offset: const Offset(2, 2),
//                 ),
//               ]
//             ),
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Text(
//                     "Please Enter The Name Of The Router!",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Theme.of(context)
//                             .primaryTextTheme
//                             .bodyMedium!
//                             .color,
//                         fontFamily: 'NotoSans',
//                         package: 'css',
//                         fontSize: 20),
//                   ),
//                   Wrap(
//                     children: [
//                       Text(
//                         "Name: ",
//                         style: TextStyle(
//                             color: Theme.of(context)
//                                 .primaryTextTheme
//                                 .bodyMedium!
//                                 .color,
//                             fontFamily: 'NotoSans',
//                             package: 'css',
//                             fontSize: 20),
//                       ),
//                       EnterTextFormField(
//                         width: CSS.responsive() - 120,
//                         height: 35,
//                         color: Theme.of(context).canvasColor,
//                         maxLines: 1,
//                         label: 'Router Name',
//                         controller: routerNameController,
//                         onTap: () {
//                           if (widget.onFocusNode != null) {
//                             widget.onFocusNode!();
//                           }
//                         },
//                       )
//                     ],
//                   ),
//                   createColorIndicators(() {
//                     setState(() {});
//                   }),
//                   (error)?const Text(
//                     "Field is missing Data!",
//                     style: TextStyle(
//                         color: Colors.red,
//                         fontFamily: 'NotoSans',
//                         package: 'css',
//                         fontSize: 20),
//                   ):Container(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       LSIWidgets.squareButton(
//                         text: 'cancel',
//                         onTap: () {
//                           setState(() {
//                             routerNameController.text = '';
//                           });
//                           routerClickedColor = Colors.white;
//                           error = false;
//                           Navigator.of(context).pop();
//                         },
//                         buttonColor: Colors.transparent,
//                         borderColor: Theme.of(context)
//                             .primaryTextTheme
//                             .bodyMedium!
//                             .color,
//                         height: 45,
//                         radius: 45 / 2,
//                         width: 320 / 3 - 10,
//                       ),
//                       const SizedBox(width: 10),
//                       (!isNewRouter)?LSIWidgets.squareButton(
//                         text: 'complete',
//                         onTap: () {
//                           if (widget.onComplete != null) {
//                             widget.onComplete!(editRouter);
//                           }
//                           setState(() {
//                             error = false;
//                             routerNameController.text = '';
//                           });
//                           routerClickedColor = Colors.white;
//                           Navigator.of(context).pop();
//                         },
//                         textColor: Theme.of(context).indicatorColor,
//                         buttonColor: Theme.of(context)
//                             .primaryTextTheme
//                             .bodyMedium!
//                             .color!,
//                         height: 45,
//                         radius: 45 / 2,
//                         width: 320 / 3 - 10,
//                       ):const SizedBox(),
//                       const SizedBox(width: 10),
//                       LSIWidgets.squareButton(
//                         text: (isNewRouter) ? 'submit' : 'update',
//                         onTap: () {
//                           if (routerNameController.text != '') {
//                             if (isNewRouter) {
//                               if (widget.onSubmit != null) {
//                                 widget.onSubmit!(
//                                   routerNameController.text,
//                                   routerImageController.text,
//                                   '',
//                                   routerClickedColor.value
//                                 );
//                               }
//                             } else {
//                               if (widget.onUpdate != null) {
//                                 widget.onUpdate!(
//                                   routerNameController.text,
//                                   routerImageController.text,
//                                   '',
//                                   routerClickedColor.value,
//                                   editRouter
//                                 );
//                               }
//                             }
//                             setState(() {
//                               error = false;
//                               routerNameController.text = '';
//                             });
//                             routerClickedColor = Colors.white;
//                             Navigator.of(context).pop();
//                           }
//                         },
//                           buttonColor: Colors.transparent,
//                           borderColor: Theme.of(context)
//                               .primaryTextTheme
//                               .bodyMedium!
//                               .color,
//                           height: 45,
//                           radius: 45 / 2,
//                           width: 320 / 3 - 10,
//                         ),
//                         // (!isNewRouter) ? LSIWidgets.squareButton(
//                         //   text: 'complete',
//                         //   onTap: () {
//                         //     if (widget.onComplete != null) {
//                         //       widget.onComplete!(editRouter);
//                         //     }
//                         //     setState(() {
//                         //       error = false;
//                         //       routerNameController.text = '';
//                         //     });
//                         //     routerClickedColor = Colors.white;
//                         //     Navigator.of(context).pop();
//                         //   },
//                         //   textColor: Theme.of(context).indicatorColor,
//                         //   buttonColor: Theme.of(context)
//                         //       .primaryTextTheme
//                         //       .bodyMedium!
//                         //       .color!,
//                         //   height: 45,
//                         //   radius: 45 / 2,
//                         //   width: 320 / 3 - 10,
//                         // ) : Container(),
//                         LSIWidgets.squareButton(
//                           text: (isNewRouter) ? 'submit' : 'update',
//                           onTap: () {
//                             if (routerNameController.text != '') {
//                               if (isNewRouter) {
//                                 if (widget.onSubmit != null) {
//                                   widget.onSubmit!(
//                                       routerNameController.text,
//                                       routerImageController.text,
//                                       (assignedDate != '')
//                                           ? selectedDate
//                                               .toString()
//                                               .replaceAll(' ', 'T')
//                                           : '',
//                                       routerClickedColor.value);
//                                 }
//                               } else {
//                                 if (widget.onUpdate != null) {
//                                   widget.onUpdate!(
//                                       routerNameController.text,
//                                       routerImageController.text,
//                                       (assignedDate != '')
//                                           ? selectedDate
//                                               .toString()
//                                               .replaceAll(' ', 'T')
//                                           : '',
//                                       routerClickedColor.value,
//                                       editRouter);
//                                 }
//                               }
//                               setState(() {
//                                 error = false;
//                                 routerNameController.text = '';
//                               });
//                               routerClickedColor = Colors.white;
//                               Navigator.of(context).pop();
//                             } else {
//                               setState(() {
//                                 error = true;
//                               });
//                             }
//                           },
//                           textColor: Theme.of(context).indicatorColor,
//                           buttonColor: Theme.of(context)
//                               .primaryTextTheme
//                               .bodyMedium!
//                               .color!,
//                           height: 45,
//                           radius: 45 / 2,
//                           width: 320 / 3 - 10,
//                         )
//                       ])
//                 ]),
//           ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // if (widget.epic != epic) {
//       //   setState(() {
//       //     start();
//       //   });
//       // }
//     });
//     width = (widget.width == null)
//         ? MediaQuery.of(context).size.width
//         : widget.width!;
//     height = (widget.height == null)?MediaQuery.of(context).size.height: widget.height!;
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         mouseCursor: MouseCursor.defer,
//         onTap: () {
//           setState(() {
//             FocusManager.instance.primaryFocus?.unfocus();
//           });
//         },
//         child: Stack(
//           alignment: AlignmentDirectional.bottomEnd,
//           children: [
//             (widget.routerData.isNotEmpty) ? Container(
//               height: height,
//               width: width,
//               color: Theme.of(context).canvasColor,
//               child: ListView(
//                 padding: const EdgeInsets.all(0),
//                 children: [
//                   Wrap(
//                     alignment: WrapAlignment.spaceAround,
//                     children: routerCards()
//                   )
//                 ]
//               )
//             ) : Container(
//               height: height,
//               width: width,
//               color: Theme.of(context).canvasColor,
//             ),
//             LSIFloatingActionButton(
//               allowed: widget.allowEditing,
//               color: Theme.of(context).secondaryHeaderColor,
//               icon: Icons.add,
//               onTap: () {
//                 setState(() {
//                   isNewRouter = true;
//                 });
//                 showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return projectName();
//                     });
//               }
//             ),
//           ]
//         )
//       )
//     );
//   }
// }

// Router Manager Screen - Displays list of routers and allows for CRUD operations
import 'package:flutter/material.dart';
import '../data/routerData.dart';
import '../data/jobData.dart';
import '../data/processTemplates.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import '../models/router_model.dart';
import '../data/processData.dart';

class RouterManager extends StatefulWidget {
  const RouterManager({
    super.key,
    this.onRouterSelected,
  });

  static List<RouterData> get routers => _RouterManagerState.routers;

  final Function(String routerId, List<RouterData> routers)? onRouterSelected;

  static get routerJobs => _RouterManagerState.routerJobs;

  static get processIdToType => _RouterManagerState.processIdToType;
  // final void Function(String title) onAdd;
  // final void Function(String id, String newTitle) onEdit;
  // final void Function(String id) onDelete;

  @override
  State<RouterManager> createState() => _RouterManagerState();
}

class _RouterManagerState extends State<RouterManager> {
  static List<RouterData> routers = [];

  static Map<String, List<JobData>> routerJobs = {};

  // Map process IDs to process types for job template
  static Map<String, String> processIdToType = {};

  // Counter for generating unique IDs
  static int _nextRouterId = 1;
  static int _nextProcessId = 1;

  // Track selected router ID
  String? selectedRouterId;

  @override
  void initState() {
    super.initState();
    
    _initializeSampleData();

    if (routers.isNotEmpty) {
      selectedRouterId = routers[0].id;
    }
  }

  // Initialize with sample routers for testing
  void _initializeSampleData() {
    routers = [
      RouterData(
        id: 'router_1',
        title: 'Router 1',
        color: 0xFFFF5252,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: 'process_1',
      ),
      RouterData(
        id: 'router_2',
        title: 'Router 2',
        color: 0xFF2196F3,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: 'process_2',
      ),

      RouterData(
        id: 'router_3',
        title: 'Archived Router',
        color: 0xFF4CAF50,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: 'process_3', 
        dateArchived: DateTime.now().toIso8601String(),
        archivedBy: 'testUser',
      ),

      RouterData(
        id: 'router_4',
        title: 'Router 4',
        color: 0xFFFFC107,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: 'process_4',
      ),

      RouterData(
        id: 'router_5',
        title: 'Archived Router 2',
        color: 0xFF9C27B0,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: 'process_5', 
        dateArchived: DateTime.now().toIso8601String(),
        archivedBy: 'testUser',
      ),
    ];
    _nextRouterId = 6; 
    _nextProcessId = 6; 

    // Map process IDs to types for initial sample data
    processIdToType['process_1'] = 'Core Parts';
    processIdToType['process_2'] = 'Cosmetic Sleeves';
    processIdToType['process_3'] = 'Magnets/Magnet Holders';
    processIdToType['process_4'] = 'Core Parts';
    processIdToType['process_5'] = 'Cosmetic Sleeves';

    // Create jobs for all sample routers
    for (var router in routers) {
      final processType = processIdToType[router.processId];
      if (processType != null) {
        routerJobs[router.id] = _createJobsFromTemplate(router.processId, processType, router.id);
      }
    }
  }

  // Helper to create jobs from template using process ID and type
  static List<JobData> _createJobsFromTemplate(String processId, String processType, String routerId) {
    final template = ProcessTemplates.getTemplate(processType);
    if (template.isEmpty) {
      return []; // No template for this process
    }

    return template.map((jobTemplate) {
      final order = jobTemplate['order'] as int;
      return JobData(
        id: '${routerId}_job_$order',
        title: jobTemplate['title'] as String,
        description: jobTemplate['description'] as String? ?? '',
        processId: processId, // Use unique process instance ID
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        status: JobStatus.notStarted,
        priority: 1,
        workers: [],
        approvers: [],
      );
    }).toList();
  }

  // Helper to create a new process instance ID and map it to a process type
  static String _createProcessInstance(String processType) {
    final processId = 'process_$_nextProcessId';
    _nextProcessId++;
    processIdToType[processId] = processType;
    return processId;
  }

  // Delete a router from the list
  void _deleteRouter(int index) {
    setState(() {
      final routerTitle = routers[index].title;
      final deletedRouterId = routers[index].id;
      final deletedProcessId = routers[index].processId;
      
      routers.removeAt(index);

      // Delete associated process mapping
      processIdToType.remove(deletedProcessId);
      
      // Delete associated jobs
      routerJobs.remove(deletedRouterId);

      // Update selection if deleted router was selected
      if (selectedRouterId == deletedRouterId) {
        selectedRouterId = routers.isNotEmpty ? routers[0].id : null;
      }

      debugPrint('Deleted router: $routerTitle');
    });
  }

  // Add a new router to the list
  Future<void> _addRouter() async {
    // Confirmation dialog before archiving during creation
    Future<bool> confirmArchive() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Archive Router'),
            content:
                const Text('Are you sure you want to archive this router?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text('Archive'),
              ),
            ],
          );
        },
      );
      return confirmed ?? false;
    }

    final result = await showDialog<RouterModel>(
      context: context,
      builder: (BuildContext context) {
        return CreateRouterFormWidget(onArchiveRequest: confirmArchive);
      },
    );

    if (result != null) {
      setState(() {
        final routerId = 'router_$_nextRouterId';
        
        // Create process instance for this router
        final processId = _createProcessInstance(result.process);
        
        final newRouter = RouterData(
          id: routerId,
          title: result.title,
          color: _colorsList[result.color]
              .value, // Convert color index to color value
          dateCreated: DateTime.now().toIso8601String(),
          createdBy: 'testUser', // Using test user for now
          processId: processId, // Reference the unique process instance ID
          dateArchived:
              result.isArchived ? DateTime.now().toIso8601String() : '',
          archivedBy: result.isArchived ? 'testUser' : '',
        );

        routers.add(newRouter);
        _nextRouterId++;
        
        // Create template jobs for the new router
        routerJobs[newRouter.id] = _createJobsFromTemplate(processId, result.process, newRouter.id);
        
        // Auto-select newly added router
        selectedRouterId = newRouter.id;
        debugPrint('Added new router: ${result.title}');
        debugPrint('Process ID: $processId (type: ${result.process})');
        debugPrint('Created ${routerJobs[newRouter.id]?.length ?? 0} template jobs');
      });
    }
  }

  // Edit an existing router
  Future<void> _editRouter(int index) async {
    final currentRouter = routers[index];
    
    // Get current process type
    final currentProcessType = processIdToType[currentRouter.processId] ?? '';

    // Find current color index
    int currentColorIndex = 0;
    for (int i = 0; i < _colorsList.length; i++) {
      if (_colorsList[i].value == currentRouter.color) {
        currentColorIndex = i;
        break;
      }
    }

    // Confirmation dialog before archiving
    Future<bool> confirmArchive() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Archive Router'),
            content: Text(
                'Are you sure you want to archive "${currentRouter.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text('Archive'),
              ),
            ],
          );
        },
      );
      return confirmed ?? false;
    }

    final result = await showDialog<RouterModel>(
      context: context,
      builder: (BuildContext context) {
        return EditRouterFormWidget(
          initialTitle: currentRouter.title,
          initialProcess: currentProcessType, // Pass process type, not instance ID
          initialColorIndex: currentColorIndex,
          isCurrentlyArchived: currentRouter.dateArchived.isNotEmpty,
          onArchiveRequest: confirmArchive,
        );
      },
    );

    if (result != null) {
      setState(() {
        routers[index] = RouterData(
          id: currentRouter.id,
          title: result.title,
          color: _colorsList[result.color].value,
          dateCreated: currentRouter.dateCreated,
          createdBy: currentRouter.createdBy,
          processId: currentRouter.processId,
          dateArchived: result.isArchived
              ? (currentRouter.dateArchived.isEmpty
                  ? DateTime.now().toIso8601String()
                  : currentRouter.dateArchived)
              : '',
          archivedBy: result.isArchived
              ? (currentRouter.archivedBy.isEmpty
                  ? 'testUser'
                  : currentRouter.archivedBy)
              : '',
        );
        debugPrint('Updated router: ${result.title}');
      });
    }
  }

  // Unarchive a router
  void _unarchiveRouter(int index) {
    setState(() {
      final currentRouter = routers[index];
      routers[index] = RouterData(
        id: currentRouter.id,
        title: currentRouter.title,
        color: currentRouter.color,
        dateCreated: currentRouter.dateCreated,
        createdBy: currentRouter.createdBy,
        processId: currentRouter.processId,
        dateArchived: '',
        archivedBy: '',
      );
      debugPrint('Unarchived router: ${currentRouter.title}');
    });
  }

  // Show router details in a dialog
  void _showRouterDetails(BuildContext context, RouterData router) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 32,
                            color: css.CSS.lsiTheme.secondaryHeaderColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Router Details",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: css.CSS.lsiTheme.secondaryHeaderColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // Balance the close button
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ViewDetailsWidget(routerData: router),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Color list matching the dialog's color picker
  final List<Color> _colorsList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.redAccent,
    Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    // Show only non-archived (active) routers
    final filteredRouters = routers.where((router) {
      final isArchived = router.dateArchived.isNotEmpty;
      return !isArchived; // Only show active routers
    }).toList();

    return Column(
      children: [
        Expanded(
          child: filteredRouters.isEmpty
              ? _buildEmptyState(false)
              : Scrollbar(
                  thumbVisibility: true,
                  // ignore: sort_child_properties_last
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: filteredRouters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final router = filteredRouters[index];
                      final actualIndex = routers.indexOf(router);
                      final isSelected = router.id == selectedRouterId;
                      return RouterCard(
                        title: router.title,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedRouterId = router.id;
                          });
                          // Notify parent about selection
                          if (widget.onRouterSelected != null) {
                            widget.onRouterSelected!(router.id, routers);
                          }
                          debugPrint('Router selected: ${router.title}');
                        },
                        color: Color(router.color),
                        onEdit: () {
                          _editRouter(actualIndex);
                        },
                        onDelete: () {
                          _deleteRouter(actualIndex);
                        },
                        onInfo: () {
                          _showRouterDetails(context, router);
                        },
                      );
                    },
                  ),
                  controller: ScrollController(initialScrollOffset: 0.0),
                ),
        ),
        FloatingActionButton(
          backgroundColor: css.purple,
          onPressed: _addRouter,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget to display when there are no routers
  Widget _buildEmptyState(bool isArchiveView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            isArchiveView ? 'No archived routers' : 'No routers yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArchiveView
                ? 'Archived routers will appear here'
                : 'Tap the + button to create your first router',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewDetailsWidget extends StatelessWidget {
  const ViewDetailsWidget({
    super.key,
    required this.routerData,
  });

  final RouterData routerData;

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: css.darkGrey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 32, thickness: 1.5),
          _buildDetailRow("Router Name:", routerData.title),
          _buildDetailRow("Router ID:", routerData.id),
          _buildDetailRow("Process:", routerData.processId),
          _buildDetailRow("Created By:", routerData.createdBy),
          _buildDetailRow("Date Created:", _formatDate(routerData.dateCreated)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CreateRouterFormWidget extends StatefulWidget {
  final Future<bool> Function()? onArchiveRequest;

  const CreateRouterFormWidget({super.key, this.onArchiveRequest});

  @override
  _CreateRouterFormWidgetState createState() => _CreateRouterFormWidgetState();
}

class _CreateRouterFormWidgetState extends State<CreateRouterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _routerName = '';
  int _routerColor = 0;
  String _processId = '';
  bool _isArchived = false;
  String? newProcess = null;
  final List<String> _processes = [
    'Core Parts',
    'Cosmetic Sleeves',
    'Magnets/Magnet Holders',
    'Game Controller',
    'Game Controller Electronics',
    'Arm Box',
    'Socket',
    'Socket Electronics',
    'Boa Assembly',
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.redAccent,
    Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: css.CSS.lsiTheme.primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(),
                ),
                Center(
                  child: Text(
                    "Add a New Router",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: css.CSS.lsiTheme.secondaryHeaderColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Router Name",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter router name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a router name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _routerName = value!;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Process",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  dropdownColor: css.lightGrey,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  isExpanded: true,
                  items: _processes
                      .map(
                        (process) => DropdownMenuItem<String>(
                          value: process,
                          child: Text(process),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _processId = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a process';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _routerColor = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _routerColor == index
                                ? Border.all(color: Colors.black, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.onArchiveRequest != null) {
                        final confirmed = await widget.onArchiveRequest!();
                        if (confirmed) {
                          setState(() {
                            _isArchived = true;
                          });
                        }
                      } else {
                        setState(() {
                          _isArchived = true;
                        });
                      }
                    },
                    child: Text('Archive Router'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: css.darkBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.of(context).pop(
                          RouterModel(
                            title: _routerName,
                            process: _processId,
                            color: _routerColor,
                            isArchived: _isArchived,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Add Router",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Edit Router Dialog Widget
class EditRouterFormWidget extends StatefulWidget {
  final String initialTitle;
  final String initialProcess;
  final int initialColorIndex;
  final bool isCurrentlyArchived;
  final Future<bool> Function()? onArchiveRequest;

  const EditRouterFormWidget({
    super.key,
    required this.initialTitle,
    required this.initialProcess,
    required this.initialColorIndex,
    required this.isCurrentlyArchived,
    this.onArchiveRequest,
  });

  @override
  _EditRouterFormWidgetState createState() => _EditRouterFormWidgetState();
}

class _EditRouterFormWidgetState extends State<EditRouterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _routerName;
  late int _routerColor;
  late String _processId;
  late bool _isArchived;

  final List<String> _processes = [
    'Core Parts',
    'Cosmetic Sleeves',
    'Magnets/Magnet Holders',
    'Game Controller',
    'Game Controller Electronics',
    'Arm Box',
    'Socket',
    'Socket Electronics',
    'Boa Assembly',
  ];

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.redAccent,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _routerName = widget.initialTitle;
    _routerColor = widget.initialColorIndex;
    _processId = widget.initialProcess;
    _isArchived = widget.isCurrentlyArchived;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: css.CSS.lsiTheme.primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(),
                ),
                Center(
                  child: Text(
                    "Edit Router",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: css.CSS.lsiTheme.secondaryHeaderColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  "Router Name",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),

                const SizedBox(height: 8.0),
                TextFormField(
                  initialValue: _routerName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter router name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a router name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _routerName = value!;
                  },
                ),

                const SizedBox(height: 16.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Process: $_processId",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: css.darkGrey,
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: css.darkGrey,
                      )
                    ]),
                // const SizedBox(height: 8.0),
                // DropdownButtonFormField<String>(
                //   value:
                //       _processId.isNotEmpty && _processes.contains(_processId)
                //           ? _processId
                //           : null,
                //   dropdownColor: css.lightGrey,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     hintText: 'Select a process',
                //     hintStyle: TextStyle(color: css.darkGrey),
                //     contentPadding:
                //         EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                //   ),
                //   isExpanded: true,
                //   items: _processes
                //       .map(
                //         (process) => DropdownMenuItem<String>(
                //           value: process,
                //           child: Text(process),
                //         ),
                //       )
                //       .toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       _processId = value!;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select a process';
                //     }
                //     return null;
                //   },
                // ),

                // User should not be able to change process after creation?

                const SizedBox(height: 16.0),
                const Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _routerColor = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _routerColor == index
                                ? Border.all(color: Colors.black, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Archive checkbox
                CheckboxListTile(
                  title: const Text(
                    'Archive this router',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isArchived,
                  onChanged: (bool? value) async {
                    if (value == true && !_isArchived) {
                      // Archiving - show confirmation
                      if (widget.onArchiveRequest != null) {
                        final confirmed = await widget.onArchiveRequest!();
                        if (confirmed) {
                          setState(() {
                            _isArchived = true;
                          });
                        }
                      } else {
                        setState(() {
                          _isArchived = true;
                        });
                      }
                    } else {
                      // Unarchiving - no confirmation needed
                      setState(() {
                        _isArchived = value ?? false;
                      });
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: css.darkBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.of(context).pop(
                          RouterModel(
                            title: _routerName,
                            process: _processId,
                            color: _routerColor,
                            isArchived: _isArchived,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Update Router",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
