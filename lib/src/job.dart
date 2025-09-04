// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:job_entry/styles/savedWidgets.dart';
import 'package:job_entry/styles/globals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:job_entry/src/database/database.dart';
import 'package:job_entry/src/functions/lsi_functions.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;

enum SelectedView{detail, list}
enum SelectedSubView{assemblies, materials, workers, notes}

class JobScreen extends StatefulWidget {
  JobScreen({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  // late double deviceWidth;
  // late double deviceHeight;
  dynamic jobs;
  dynamic inventory;
  dynamic parts;
  dynamic molds;
  DateTime? lastRan;
  DateTime? lastUsed;
  String selectedJobKey = '';
  String status = '';
  Size currentSize = Size(0, 0);
  SelectedView selectedView = SelectedView.detail;
  SelectedSubView selectedSubView = SelectedSubView.assemblies;
  MultiSelectController msController = MultiSelectController();
  
  bool isJobNew = true;
  bool isArchived = false;
  bool testing = true;
  bool save = false;
  bool delete = false;
  bool showDetailView = true;
  bool isTemplate = false;

  List<List<dynamic>> listDataToExport = [];

  Timer? saveTimer;
  Timer? deleteTimer;

  int count = 2;
  
  StreamSubscription<DatabaseEvent>? fbchanged;
  StreamSubscription<DatabaseEvent>? fbadded;
  StreamSubscription<DatabaseEvent>? fbremoved;
  StreamSubscription<DatabaseEvent>? ifbchanged;
  StreamSubscription<DatabaseEvent>? ifbadded;
  StreamSubscription<DatabaseEvent>? ifbremoved;
  StreamSubscription<DatabaseEvent>? pfbchanged;
  StreamSubscription<DatabaseEvent>? pfbadded;
  StreamSubscription<DatabaseEvent>? pfbremoved;

  TextEditingController _searchbarController = TextEditingController();
  List<TextEditingController> _detailsController = [
    TextEditingController(), TextEditingController(),
    TextEditingController(), TextEditingController()
  ];
  List<TextEditingController> _subsController = [
    TextEditingController(text: ''), TextEditingController(text: '')
  ];
  List<DateTime?> dates = [null, null, null];
  List<DropDownItems> partsList = [];

  @override
  void initState() {
    currentSize = widget.size;
    deviceWidth = currentSize.width;
    deviceHeight = currentSize.height;
    listenToFirebase();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenToFirebase() async{
    try{
      if(testing){
        jobs = {
          'job1': {
            'name': 'Test Job 1',
            'status': 'Not Started',
            'part': 'part1',
            'qty': '10',
            'template': true,
            'reqDate': DateTime.now().add(Duration(days: 14)).toString(),
            'assemblies': ['job2', 'job3'],
            'materials': {},
            'assigned': ['user1', 'user2'],
            'notes': {
              'note1': {
                'createdBy': 'user1',
                'comment': 'This is a note for job 1',
                'postDate': DateTime.now().toString(),
              },
              'note2': {
                'createdBy': 'user1',
                'comment': 'This is another note for job 1',
                'postDate': DateTime.now().toString(),
              },
            },
            'archived': false
          },
          'job2': {
            'name': 'Test Job 2',
            'status': 'In Progress',
            'part': 'part2',
            'qty': '5',
            'template': false,
            'startDate': DateTime.now().subtract(Duration(days: 7)).toString(),
            'reqDate': DateTime.now().add(Duration(days: 7)).toString(),
            'assemblies': [],
            'materials': {},
            'assigned': ['user2'],
            'notes': {},
            'archived': false
          },
          'job3': {
            'name': 'Test Job 3',
            'status': 'Complete',
            'part': 'part3',
            'qty': '20',
            'template': false,
            'quality': 'Fair',
            'startDate': DateTime.now().subtract(Duration(days: 14)).toString(),
            'reqDate': DateTime.now().subtract(Duration(days: 7)).toString(),
            'endDate': DateTime.now().subtract(Duration(days: 2)).toString(),
            'assemblies': [],
            'materials': {},
            'assigned': ['user3'],
            'notes': {},
            'archived': false
          },
        };
        inventory = {
          'material1': {
            'name': 'Material A',
            'About': 'Description of Material A',
            'dateCreated': DateTime.now().toString(),
          },
          'material2': {
            'name': 'Material B',
            'About': 'Description of Material B',
            'dateCreated': DateTime.now().toString(),
          },
          'material3': {
            'name': 'Material C',
            'About': 'Description of Material C',
            'dateCreated': DateTime.now().toString(),
          }
        };
        parts = {
          'part1': {
            'name': 'Part A',
            'About': 'Description of Part A',
            'dateCreated': DateTime.now().toString(),
          },
          'part2': {
            'name': 'Part B',
            'About': 'Description of Part B',
            'dateCreated': DateTime.now().toString(),
          },
          'part3': {
            'name': 'Part C',
            'About': 'Description of Part C',
            'dateCreated': DateTime.now().toString(),
          }
        };
        setState(() {});
      }
      else{
        //retrive all jobs
        DatabaseReference ref = Database.reference("jobs",'team');

        await Database.once('jobs', 'team').then((value) {
          jobs = value;
          setState(() {});
        });
        fbadded = ref.orderByChild('dateCreated').startAt(DateTime.now().toString()).onChildAdded.listen((event){
          jobs[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
        fbchanged = ref.onChildChanged.listen((event){
          jobs[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
        fbremoved = ref.onChildRemoved.listen((event){
          setState(() {
            jobs[event.snapshot.key] = null;
            jobs = LSIFunctions.removeNull(jobs);
          });
        });

        //retrive all inventory
        DatabaseReference invRef = Database.reference("inventory",'team');

        await Database.once('inventory', 'team').then((value) {
          inventory = value;
          setState(() {});
        });
        ifbadded = invRef.orderByChild('dateCreated').startAt(DateTime.now().toString()).onChildAdded.listen((event){
          inventory[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
       ifbchanged = invRef.onChildChanged.listen((event){
          inventory[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
        ifbremoved = invRef.onChildRemoved.listen((event){
          setState(() {
            inventory[event.snapshot.key] = null;
            inventory = LSIFunctions.removeNull(inventory);
          });
        });

        //retrive all parts
        DatabaseReference partRef = Database.reference("parts",'team');

        await Database.once('parts', 'team').then((value) {
          parts = value;
          setState(() {});
        });
        pfbadded = partRef.orderByChild('dateCreated').startAt(DateTime.now().toString()).onChildAdded.listen((event){
          parts[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
       pfbchanged = partRef.onChildChanged.listen((event){
          parts[event.snapshot.key] = event.snapshot.value;
          setState(() {});
        });
        pfbremoved = partRef.onChildRemoved.listen((event){
          setState(() {
            parts[event.snapshot.key] = null;
            parts = LSIFunctions.removeNull(parts);
          });
        });
      }

      for(var keys in parts.keys){
        partsList.add(
          DropDownItems(
            value: keys,
            text: parts[keys]['name'] ?? 'Unknown Part',
          )
        );
      }
    }
    catch(e){
      print('Exception (listentoFirebase): $e');
    }
  }

  void setDetailInfo(){
    if(selectedJobKey.isNotEmpty && jobs.containsKey(selectedJobKey)){
      //_detailsController[0] = part
      //_detailsController[1] = qty
      var job = jobs[selectedJobKey];
      _searchbarController.text = job['name'] ?? '';
      _detailsController[0].text = job['status'] ?? 'Not Started';
      _detailsController[1].text = job['part'] ?? '';
      _detailsController[2].text = job['qty'] ?? '';
      _detailsController[3].text = job['quality'] ?? '';

      dates[0] = job['startDate'] != null ? DateTime.parse(job['startDate']) : null;
      dates[1] = job['reqDate'] != null ? DateTime.parse(job['reqDate']) : null;
      dates[2] = job['endDate'] != null ? DateTime.parse(job['endDate']) : null;

      isJobNew = false;
      isArchived = job['archived'] ?? false;
      isTemplate = job['template'] ?? false;

      setState(() {});
    }
  }

  void autofillDetailFields() {
    if(selectedJobKey.isNotEmpty && jobs.containsKey(selectedJobKey)){
      var job = jobs[selectedJobKey];
      _searchbarController.text = '';
      _detailsController[0].text = 'Not Started';
      _detailsController[1].text = job['part'] ?? '';
      _detailsController[2].text = job['qty'] ?? '';
      _detailsController[3].text = job['quality'] ?? '';

      jobs[selectedJobKey]['notes'] = {};

      dates[0] = null;
      dates[1] = null;
      dates[2] = null;

      isJobNew = true;
      isArchived = false;
      isTemplate = false;
      
      setState(() {});
    }
  }
  
  void clearDetailFields() {
    _searchbarController.clear();
    for (var controller in _detailsController) {
      controller.clear();
    }
    
    isJobNew = true;
    isArchived = false;
    selectedJobKey = '';
    isTemplate = false;
    setState(() {});
  }

  void addLineToExportList(bool isHeader, String name, String part, String qty, String quality, String reqDate, String status) {
    List<dynamic> data = [];

    data.add(name);
    data.add(part);
    data.add(qty);
    data.add(quality);
    data.add(reqDate);
    data.add(status);

    if (isHeader) {
      listDataToExport.insert(0, data);
    } else {
      listDataToExport.add(data);
    }
  }

  dynamic createCsvString() {
    dynamic csvString;
    csvString = ListToCsvConverter().convert(listDataToExport);
    return csvString;
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [ 
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}"),
                  ]
                )
              ]
            ),
            pw.SizedBox(height: 40),
            pw.Container(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Container(child: 
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start, 
                      children: [
                        pw.Text("Job name: "),
                        pw.Text("Workers: "),
                      ]
                    ))),
                  pw.Container(height: 40),
                  pw.Expanded(child: pw.Container(child: 
                    pw.Column( 
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Start Date: __/__/____"),
                        pw.Text("Finish Date: __/__/____"),
                        pw.Text("Required By: __/__/____"),
                      ]
                    )
                  )),
                ]
              )
            ),
            pw.SizedBox(height: 40),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  // single job export
  Future<void> exportJobInfo(BuildContext context, String filename) async {
    if (selectedJobKey == '' || isJobNew) {
      // should we error message or save a template version of the single job PDF?
      errorMessage('Job Not Saved', 'Please save the job before attempting to export.');
    } else {
      final bytes = await generatePdf();

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: filename,
          bytes: bytes,
          fileExtension: 'pdf',
          mimeType: MimeType.pdf,
        );
      } else {
        var status = await Permission.storage.request();
        if (status.isGranted) {
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            final path = '${directory.path}/$filename.pdf';
            final file = File(path);
            await file.writeAsBytes(bytes);
          }
        } else {
          errorMessage('Permission Denied', 'Storage permission denied.');
        }
      }
    }
  }

  // auto download the csvString as a csv file
  Future<void> exportCsv(String csvContent, String filename) async {
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvContent));
    
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: filename,
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
    } else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final path = '${directory.path}/$filename.csv';
          final file = File(path);
          await file.writeAsBytes(bytes);
        }
      } else {
        errorMessage('Permission Denied', 'Storage permission denied.');
      }
    }
  }

  void errorMessage(String title, String message) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: CSS.lighten(Theme.of(context).canvasColor, 0.06),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
            fontFamily: 'Klavika',
            package: 'css',
            fontSize: 20,
            decoration: TextDecoration.none
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
            fontFamily: 'Klavika',
            package: 'css',
            fontSize: 16,
            decoration: TextDecoration.none
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                fontFamily: 'Klavika',
                package: 'css',
                fontSize: 16,
                decoration: TextDecoration.none
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget addToCurrentJob(String screen){
    try{
      List<DropDownItems> jobsList = [];
      List<DropDownItems> inventoryList = [];
      List<DropDownItems> usersList = [];
      for(String key in jobs.keys){
        if(key != selectedJobKey){
          jobsList.add(
            DropDownItems(
              value: key,
              text: jobs[key]['name'] ?? 'Unknown Job',
            )
          );
        }
      }
      for(String key in inventory.keys){
        inventoryList.add(
          DropDownItems(
            value: key,
            text: inventory[key]['name'] ?? 'Unknown Material',
          )
        );
      }
      if(usersProfile == null || usersProfile == {}){
        usersProfile = {
          'user1': {'name': 'John Doe', 'displayName': 'John'},
          'user2': {'name': 'Jane Smith', 'displayName': 'Jane'},
          'user3': {'name': 'Bob Johnson', 'displayName': 'Bob'}
        };
      }
      for(String key in usersProfile.keys){
        usersList.add(
          DropDownItems(
            value: key,
            text: usersProfile[key]['name'] ?? 'Unknown User',
          )
        );
      }

      return StatefulBuilder(builder: (context1, setState) {
        return Dialog(
          backgroundColor: CSS.lighten(Theme.of(context).canvasColor, 0.06),
          child: Container(
            width: 400,
            height: 250,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if(screen == 'assemblies')Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "Assembly: ",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                          fontFamily: 'Klavika',
                          package: 'css',
                          fontSize: 20,
                          decoration: TextDecoration.none
                        )
                      )
                    ),
                    LSIWidgets.dropDown(
                      width: 250,
                      height: 35,
                      itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select an assembly ...']) + jobsList),
                      value: _subsController[0].text.isEmpty?'Select an assembly ...':_subsController[0].text,
                      color: Theme.of(context).primaryColorLight,
                      style: Theme.of(context).primaryTextTheme.labelLarge!,
                      padding: const EdgeInsets.all(5.25),
                      margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                      radius: 10.0,
                      onchange: (val) {
                        setState(() {
                          _subsController[0].text = val;
                        });
                      }
                    ),
                  ]
                ),
                if(screen == 'materials')Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            "Material: ",
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ),
                        LSIWidgets.dropDown(
                          width: 250,
                          height: 35,
                          itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select a material ...']) + inventoryList),
                          value: _subsController[0].text.isEmpty?'Select a material ...':_subsController[0].text,
                          color: Theme.of(context).primaryColorLight,
                          style: Theme.of(context).primaryTextTheme.labelLarge!,
                          padding: const EdgeInsets.all(5.25),
                          margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                          radius: 10.0,
                          onchange: (val) {
                            setState(() {
                              _subsController[0].text = val;
                            });
                          }
                        ),
                      ]
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children:[
                        SizedBox(
                          width: 100,
                          child: Text(
                            "Qty: ",
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ),
                        EnterTextFormField(
                          controller: _subsController[1],
                          keyboardType: TextInputType.number,
                          margin: EdgeInsets.all(10),
                          width: 125,
                          height: 30,
                          maxLines: 1,
                          color: Theme.of(context).primaryColorLight,
                          textStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryTextTheme.labelLarge!.color),
                          onEditingComplete: () {},
                          onSubmitted: (text) {
                          },
                        ),
                      ]
                    )
                  ]
                ),
                if(screen == 'workers')Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "Employee(s): ",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                          fontFamily: 'Klavika',
                          package: 'css',
                          fontSize: 18,
                          decoration: TextDecoration.none
                        )
                      )
                    ),
                    LSIWidgets.dropDown(
                      width: 250,
                      height: 35,
                      itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select an employee ...']) + usersList),
                      value: _subsController[0].text.isEmpty?'Select an employee ...':_subsController[0].text,
                      color: Theme.of(context).primaryColorLight,
                      style: Theme.of(context).primaryTextTheme.labelLarge!,
                      padding: const EdgeInsets.all(5.25),
                      margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                      radius: 10.0,
                      onchange: (val) {
                        setState(() {
                          _subsController[0].text = val;
                        });
                      }
                    ),
                  ]
                ),
                if(screen == 'notes')EnterTextFormField(
                  controller: _subsController[0],
                  keyboardType: TextInputType.text,
                  margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
                  label: "Notes",
                  width: 350,
                  height: 120,
                  maxLines: 5,
                  color: Theme.of(context).primaryColorLight,
                  textStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryTextTheme.labelLarge!.color),
                  onEditingComplete: () {},
                  onSubmitted: (text) {
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    LSIWidgets.squareButton(
                      text: 'cancel',
                      onTap: () {
                        Navigator.pop(context1);
                      },
                      buttonColor: Colors.transparent,
                      borderColor: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                      height: 45,
                      radius: 45 / 2,
                      width: 100,
                      margin: const EdgeInsets.only(bottom: 15)
                    ),
                    LSIWidgets.squareButton(
                      text: 'submit',
                      onTap: () {
                        if(screen == 'assemblies' && _subsController[0].text.isEmpty){
                          errorMessage('Missing Fields', 'Please select a job to add as an assembly');
                          return;
                        }
                        if(screen == 'materials' && (_subsController[0].text.isEmpty || _subsController[1].text.isEmpty)){
                          errorMessage('Missing Fields', 'Please select an item and enter a quantity');
                          return;
                        }
                        if(screen == 'workers' && _subsController[0].text.isEmpty){
                          errorMessage('Missing Fields', 'Please select a worker');
                          return;
                        }
                        if(screen == 'notes' && _subsController[0].text.isEmpty){
                          errorMessage('Missing Fields', 'Please enter a note');
                          return;
                        }

                        if(testing){
                          if(screen == 'assemblies'){
                            jobs[selectedJobKey]['assemblies'].add(_subsController[0].text);
                          }
                          else if(screen == 'materials'){
                            if(!jobs[selectedJobKey]['materials'].containsKey(_subsController[0].text)){
                              jobs[selectedJobKey]['materials'][_subsController[0].text] = {
                                'uid': _subsController[0].text,
                                'qty': _subsController[1].text
                              };
                            }
                            else{
                              jobs[selectedJobKey]['materials'][_subsController[0].text]['qty'] = _subsController[1].text;
                            }
                          }
                          else if(screen == 'workers'){
                            if(!jobs[selectedJobKey]['assigned'].contains(_subsController[0].text)){
                              jobs[selectedJobKey]['assigned'].add(_subsController[0].text);
                            }
                          }
                          else if(screen == 'notes'){
                            String noteId = DateTime.now().millisecondsSinceEpoch.toString();
                            jobs[selectedJobKey]['notes'][noteId] = {
                              'createdBy': 'user1', // Replace with actual user ID
                              'comment': _subsController[0].text,
                              'postDate': DateTime.now().toString()
                            };
                          }
                        }
                        else{
                          if(screen == 'assemblies'){
                            jobs[selectedJobKey]['assemblies'].add(_subsController[0].text);
                            Database.update(
                              'team',
                              children: 'jobs/$selectedJobKey',
                              location: 'assemblies',
                              data:  jobs[selectedJobKey]['assemblies']
                            );
                          }
                          else if(screen == 'materials'){
                            if(!jobs[selectedJobKey]['materials'].containsKey(_subsController[0].text)){
                              Database.push(
                                'team',
                                children: 'jobs/$selectedJobKey/materials', 
                                data: {
                                  'uid': _subsController[0].text,
                                  'qty': _subsController[1].text
                                }
                              );
                            }
                            else{
                              Database.update(
                                'team',
                                children:'jobs/$selectedJobKey/materials', 
                                location: _subsController[0].text,
                                data: {
                                  'qty': _subsController[1].text
                                }
                              );
                            }
                          }
                          else if(screen == 'workers'){
                            jobs[selectedJobKey]['workers'].add(_subsController[0].text);
                            Database.update(
                              'team',
                              children: 'jobs/$selectedJobKey',
                              location: 'workers',
                              data:  jobs[selectedJobKey]['workers']
                            );
                          }
                          else if(screen == 'notes'){
                            Database.push(
                              'team',
                              children: 'jobs/$selectedJobKey/notes', 
                              data: {
                                'createdBy': 'user1', // Replace with currentUser.uid
                                'comment': _subsController[0].text,
                                'postDate': DateTime.now().toString()
                              }
                            );
                          }
                        }

                        Navigator.pop(context1);
                      },
                      buttonColor: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      height: 45,
                      radius: 45 / 2,
                      width: 100,
                      margin: const EdgeInsets.only(bottom: 15)
                    ),
                  ]
                ),
              ]
            ),
          ),
        );
      });
    }
    catch(e){
      print('job.dart -> addToCurrentJob(): Exception: $e');
      return const SizedBox();
    }
  }

  Widget subView(String screen){
    try{
      List<Widget> cards = [];
      if(selectedJobKey.isNotEmpty){
        switch (screen) {
          case 'assemblies':
            for(int i = 0; i < jobs[selectedJobKey]['assemblies'].length; i++){
              String key = jobs[selectedJobKey]['assemblies'][i];
              dynamic assembly = jobs[key];
              List<String> uids = assembly['assigned']!=null?List.from(assembly['assigned']):[];
              cards.add(
                Container(
                  width: 200,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: assembly['status']=='Complete'?chartGreen:chartRed,
                      width: 2
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Name: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            assembly['name'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Part: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            assembly['part'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Qty: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            assembly['qty'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      if(assembly['status']=='Complete')Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size:15,
                            color: Theme.of(context).primaryTextTheme.bodySmall!.color
                          ),
                          Text(
                            ' ${DateFormat('MM/dd/yy').format(DateTime.parse(assembly['endDate'].toString()))}',
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodySmall!.color,
                              fontFamily: 'Museo Sans, 500',
                              package: 'css',
                              fontSize: 16
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      if(uids.isNotEmpty)LSIUserIcon(
                        uids: uids, 
                        colors: [Colors.teal[200]!, Colors.teal[600]!],
                        iconSize: 35,
                        viewidth: 125,
                      )
                    ],
                  )
                )
              );
            }
          break;
          case 'materials':
            for(String item in jobs[selectedJobKey]['materials'].keys){
              String key = jobs[selectedJobKey]['materials'][item]['uid'];
              dynamic material = inventory[key];
              cards.add(
                Container(
                  width: 250,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Name: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            material['name'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "About: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              material['About'],
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Qty: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            jobs[selectedJobKey]['materials'][item]['qty'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                    ],
                  )
                )
              );
            }
          break;
          case 'workers':
            for(int i = 0; i < jobs[selectedJobKey]['assigned'].length; i++){
              String uid = jobs[selectedJobKey]['assigned'][i];
              cards.add(
                Container(
                  width: 150,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Row(
                    children: [
                      LSIUserIcon(
                        uids: [uid], 
                        colors: [Colors.teal[200]!, Colors.teal[600]!],
                        iconSize: 35,
                        viewidth: 50,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        testing?uid:usersProfile[uid]['displayName'],
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                          fontFamily: 'Klavika',
                          package: 'css',
                          fontSize: 20,
                          decoration: TextDecoration.none
                        )
                      )
                    ],
                  )
                )
              );
            }
          break;
          case 'notes':
            for(String key in jobs[selectedJobKey]['notes'].keys){
              dynamic note = jobs[selectedJobKey]['notes'][key];
              cards.add(
                Container(
                  width: 250,
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  margin: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              "Posted By:  ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Text(
                            testing?note['createdBy']:usersProfile[note['createdBy']]['displayName'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ]
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 230,
                        child: Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            note['comment'],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                              fontFamily: 'Klavika',
                              package: 'css',
                              fontSize: 20,
                              decoration: TextDecoration.none
                            )
                          )
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size:15,
                            color: Theme.of(context).primaryTextTheme.bodySmall!.color
                          ),
                          Text(
                            ' ${DateFormat('MM/dd/yy').format(DateTime.parse(note['postDate'].toString()))}',
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.bodySmall!.color,
                              fontFamily: 'Museo Sans, 500',
                              package: 'css',
                              fontSize: 16
                            )
                          )
                        ]
                      )
                    ],
                  )
                )
              );
            }
          break;
          default:
        }
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0.0),
        width: deviceWidth,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1
            )
          )
        ),
        child: Stack(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: cards
            ),
            if(selectedJobKey.isEmpty)Center(
              child: Text(
                'Select a job to view $screen',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  fontFamily: 'Klavika',
                  package: 'css',
                  fontSize: 20,
                  decoration: TextDecoration.none
                )
              )
            ),
            if(selectedJobKey.isNotEmpty && cards.isEmpty)Center(
              child: Text(
                'No $screen added to this job',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                  fontFamily: 'Klavika',
                  package: 'css',
                  fontSize: 20,
                  decoration: TextDecoration.none
                )
              )
            ),
            if(selectedJobKey.isNotEmpty)LSIFloatingActionButton(
              allowed: true,
              alignment: Alignment.bottomLeft,
              message: 'Add $screen',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => addToCurrentJob(screen),
                ).then((val){
                  _subsController[0].clear();
                  _subsController[1].clear();

                  setState(() { });
                });
              },
              color: Theme.of(context).secondaryHeaderColor,
              icon: Icons.add,
            )
          ]
        )
      );
    }
    catch(e){
      print('job.dart -> subView(): Exception: $e');
      return const SizedBox();
    }
  }

  Widget detailView(){
    try{
      return Container(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0, 0.0),
        width: deviceWidth,
        height: deviceHeight - 40,
        color: Theme.of(context).cardColor,
        child: ListView(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: [
                Container( 
                  width: 365,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Name: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          EnterTextFormField(
                            controller: _searchbarController,
                            keyboardType: TextInputType.text,
                            margin: EdgeInsets.fromLTRB(10,0,10,10),
                            width: 150,
                            height: 30,
                            maxLines: 1,
                            color: Theme.of(context).primaryColorLight,
                            textStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryTextTheme.labelLarge!.color),
                            onEditingComplete: () {
                              for(String key in jobs.keys){
                                if(jobs[key]['name'].toString().toLowerCase() == _searchbarController.text.toLowerCase()){
                                  setState(() {
                                    selectedJobKey = key;
                                  });
                                  setDetailInfo();
                                  return;
                                }
                              }
                            },
                            onSubmitted: (text) {
                            },
                          ),
                          FocusedInkWell (
                            onTap: () {
                              clearDetailFields();
                            },
                            child: Tooltip(
                              message: 'Refresh',
                              child: Container(
                                width: 40,
                                height: 30,
                                margin: EdgeInsets.all(1),
                                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20
                                )
                              )
                            )
                          ),
                          // To export only a single job's information
                          FocusedInkWell (
                            onTap: () {
                              exportJobInfo(context, _searchbarController.text);
                            },
                            child: Tooltip(
                              message: 'Export',
                              child: Container(
                                width: 40,
                                height: 30,
                                margin: EdgeInsets.all(5),
                                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(
                                  Icons.download,
                                  color: Theme.of(context).primaryColorLight,
                                  size: 20
                                )
                              )
                            )
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Status: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          LSIWidgets.dropDown(
                            width: 200,
                            height: 35,
                            itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select a status ...','Not Started','In Progress', 'Complete', 'On Hold'])),
                            value: _detailsController[0].text.isEmpty?'Select a status ...':_detailsController[0].text,
                            color: Theme.of(context).primaryColorLight,
                            style: Theme.of(context).primaryTextTheme.labelLarge!,
                            padding: const EdgeInsets.all(5.25),
                            margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                            radius: 10.0,
                            onchange: (val) {
                              if(!isArchived){
                                setState(() {
                                  _detailsController[0].text = val;
                                });
                              }
                            }
                          ),
                        ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Part: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          LSIWidgets.dropDown( //might have to change how the parts are saved in a dropdown; FocusedDropdown
                            width: 200,
                            height: 35,
                            itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select a part ...']) + partsList),
                            value: _detailsController[1].text.isEmpty?'Select a part ...':_detailsController[1].text,
                            color: Theme.of(context).primaryColorLight,
                            style: Theme.of(context).primaryTextTheme.labelLarge!,
                            padding: const EdgeInsets.all(5.25),
                            margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                            radius: 10.0,
                            onchange: (val) {
                              if(!isArchived){
                                setState(() {
                                  _detailsController[1].text = val;
                                });
                              }
                            }
                         ),
                        ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Qty: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          EnterTextFormField(
                            controller: _detailsController[2],
                            keyboardType: TextInputType.number,
                            margin: EdgeInsets.all(10),
                            width: 125,
                            height: 30,
                            maxLines: 1,
                            color: Theme.of(context).primaryColorLight,
                            textStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryTextTheme.labelLarge!.color),
                            onEditingComplete: () {},
                            onSubmitted: (text) {
                            },
                          ),
                        ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Quality: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          LSIWidgets.dropDown(
                            width: 200,
                            height: 35,
                            itemVal: LSIFunctions.setDropDownItems(LSIFunctions.setDropDownFromString(['Select a quality ...','Excellent','Good', 'Fair', 'Poor'])),
                            value: _detailsController[3].text.isEmpty?'Select a quality ...':_detailsController[3].text,
                            color: Theme.of(context).primaryColorLight,
                            style: Theme.of(context).primaryTextTheme.labelLarge!,
                            padding: const EdgeInsets.all(5.25),
                            margin: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                            radius: 10.0,
                            onchange: (val) {
                              if(!isArchived){
                                setState(() {
                                  _detailsController[3].text = val;
                                });
                              }
                            }
                          ),
                        ]
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              "Set as Template:",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Tooltip(
                            message: 'Set as template',
                            child: Checkbox(
                              value: isTemplate,
                              activeColor: Theme.of(context).primaryColorDark,
                              checkColor: Theme.of(context).primaryColorLight,
                              side: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                                width: 2
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  isTemplate = value!;
                                });
                              }
                            )
                          ),
                        ]
                      ),
                    ],
                  )
                ),
                Container(
                  width: 270,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 125,
                            child: Text(
                              "Start Date: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Container(
                            width: 115,
                            height: 35,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              dates[0] != null?DateFormat('MM/dd/y').format(dates[0]!):'',
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.labelLarge!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                        ]
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 125,
                            child: Text(
                              "Required By: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Container(
                            width: 115,
                            height: 35,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              dates[1] != null?DateFormat('MM/dd/y').format(dates[1]!):'',
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.labelLarge!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                        ]
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 125,
                            child: Text(
                              "Finish Date: ",
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.bodyMedium!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Container(
                            width: 115,
                            height: 35,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              dates[2] != null?DateFormat('MM/dd/y').format(dates[2]!):'',
                              style: TextStyle(
                                color: Theme.of(context).primaryTextTheme.labelLarge!.color,
                                fontFamily: 'Klavika',
                                package: 'css',
                                fontSize: 20,
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                        ]
                      )
                    ]
                  )
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              height: 450,
              padding: const EdgeInsets.only(right: 5),
              //color: Theme.of(context).canvasColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child:Tabs(
                      tabs: const ['Assemblies', 'Materials', 'Workers', 'Notes'],
                      selectedTab: selectedSubView.index,
                      height: 25,
                      onTap: (val){
                        setState(() {
                          selectedSubView = SelectedSubView.values.elementAt(val);
                        });
                      },
                    ),
                  ),
                  subView(selectedSubView.name)
                ],
              ),
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LSIWidgets.squareButton(
                  buttonColor: (!isArchived) ? ((!save) ? lightBlue : darkGreen) : Colors.grey, 
                  text: 'Save',
                  textColor: Colors.white,
                  width: 80,
                  height: 35,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  onTap: () async {
                    if(!isArchived){
                      if(_detailsController[0].text.isEmpty || _detailsController[2].text.isEmpty || _detailsController[3].text.isEmpty || _searchbarController.text.isEmpty){
                        errorMessage('Missing Fields', 'Please fill out the following fields: ${_detailsController[0].text.isEmpty?'\nQty Produced': ''}${_detailsController[2].text.isEmpty?'\nQuality': ''}${_detailsController[3].text.isEmpty?'\nName': ''}');
                        return;
                      }

                      setState(() {
                        save = true;
                      });

                      saveTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
                        setState(() {
                          save = false;
                          setDetailInfo();
                          saveTimer?.cancel();
                        });
                      });

                      if(testing){
                        if(isJobNew){
                          
                        }
                        else{
                          
                        }
                      }
                      else{
                        if(isJobNew){
                          
                        }
                        else{
                          
                        }
                      }
                    }
                  }
                ),
                LSIWidgets.squareButton(
                  buttonColor: (!delete) ? chartRed : darkGreen, 
                  text: !isArchived ? 'Archive' : 'Unarchive',
                  textColor: Colors.white,
                  width: !isArchived ? 85 : 110,
                  height: 35,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(5),
                  onTap: () {
                    setState(() {
                      delete = true;
                    });

                    deleteTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
                      setState(() {
                        delete = false;
                        deleteTimer?.cancel();
                      });
                    });

                    if(testing){

                    }
                    else{

                    }
                    clearDetailFields();
                  }
                ),
              ],
            )
          ],
        )
      );
    }
    catch(e){
      print('job.dart -> detailView(): Exception: $e');
      return const SizedBox();
    }
  }

  Widget jobListView(){
    double minSize = 941-(deviceWidth > 941?0:200);
    double diff = deviceWidth-minSize;
    double size = diff>0?minSize+diff:minSize;
    
    Widget row(bool isHeader, String key, String name, String part, String qty, String quality, String reqDate, String status, String template, bool archived, bool legend) {
      addLineToExportList(isHeader, name, part, qty, quality, reqDate, status);
      try{
        return InkWell( 
          onTap: () {
            if(!legend){
              setState(() {
                selectedJobKey = key;
                selectedView = SelectedView.detail;
              },);
              setDetailInfo();
            }
          },
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).canvasColor, width: 2)
              ),
              color: !archived?Theme.of(context).cardColor:Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 3,
                  offset: const Offset(2, 2)
                )
              ]
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    name,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    part,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                Container(
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    qty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                Container(
                  width: 120,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    quality,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                Container(
                  width: 120,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    reqDate,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                Container(
                  width: 120,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).canvasColor,
                        width: 2
                      ) 
                    )
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  )
                ),
                InkWell( 
                  onTap: () {
                     setState(() {
                      selectedJobKey = key;
                      selectedView = SelectedView.detail;
                    },);
                    autofillDetailFields();
                  }, 
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).canvasColor,
                          width: 2
                        ) 
                      )
                    ),
                    child: Text(
                      template,
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                    )
                  )
                ),
              ],
            ),
          )
        );
      }
      catch(e){
        print('Exception (jobListView -> row): $e');
        return const SizedBox();
      }
    }

    List<Widget> rows = [];
    try{
      for (String key in jobs.keys) {
        rows.add(
          row(
            false,
            key,
            jobs[key]['name'] ?? '',
            jobs[key]['part']==null?'':parts[jobs[key]['part']]['name'] ?? '',
            jobs[key]['qty']?.toString() ?? '',
            jobs[key]['quality'] ?? '',
            jobs[key]['reqDate'] ?? '-',
            jobs[key]['status'] ?? 'Not Started',
            jobs[key]['template'] ? 'Use Template' : '',
            jobs[key]['archived'] ?? false,
            false
          )
        );
      }
    }
    catch(e){
      print('job.dart -> listView() -> items -> Exception: $e');
    }

    return Container(
      height: deviceHeight - 40,
      width: deviceWidth,
      color: Theme.of(context).cardColor,
      child: Stack(children: [
          LSIFloatingActionButton(
            allowed: true,
            alignment: Alignment.bottomRight,
            message: 'Export',
            onTap: () {
              exportCsv(createCsvString(), 'all_jobs');
            },
            color: Theme.of(context).secondaryHeaderColor,
            icon: Icons.download,
          ),
          SingleChildScrollView (
            child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column (
              children: [
              const SizedBox(
                height: 10.0,
              ),
              row(
                true, 
                '',
                'Name',
                'Part', 
                'Qty',
                'Quality',
                'Req Date',
                'Status',
                'Template',
                false,
                true
              )
            ] + rows,)))
      ]));
  }

  @override
  Widget build(BuildContext context) {
    currentSize = MediaQuery.sizeOf(context);
    deviceHeight = currentSize.height;
    deviceWidth = currentSize.width;

    return Scaffold(
      //canPop: false,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10),
                width: deviceWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).primaryColorDark, width: 1),
                  ),
                ),
                child:Tabs(
                  tabs: const ['Detail', 'List'],
                  selectedTab: selectedView.index,
                  height: 25,
                  onTap: (val){
                    setState(() {
                      selectedView = SelectedView.values.elementAt(val);
                    });
                  },
                ),
              ),
              selectedView==SelectedView.detail?detailView():jobListView()
            ],
          ),
        ],
      ),
    );
  }
}
