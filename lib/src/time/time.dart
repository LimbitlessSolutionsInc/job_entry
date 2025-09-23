import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../styles/globals.dart';
import '../functions/lsi_functions.dart';
import '../database/database.dart';
import '../../styles/savedWidgets.dart';
import '../database/push.dart';

enum TimeSheetType{LPER,FILLED,LOGGER,CHANGETIME}
enum FilledType{IN,OUT,LPER}

class ZTime{
  ZTime({
    this.missingOut = false,
    this.totalTime = 0,
    required this.times,
    this.isVirtual = false
  }){
    //this.virtual = virtual??List.filled(times.length, false);
  }

  bool missingOut;
  int totalTime;
  List<int> times;
  bool isVirtual;
}

class SendTime{
  SendTime({
    this.averageDay = 0,
    this.averageWeek = 0,
    required this.total,
    this.endDate,
    this.startDate
  });
  int total;
  int averageDay;
  int averageWeek;
  DateTime? startDate;
  DateTime? endDate;
}

class TimeTextFormFeild extends StatelessWidget{
  const TimeTextFormFeild({
    Key? key,
    this.textKey,
    required this.controller,
    this.onTap,
    this.hintText = '0:00',
    this.textColor,
    this.hintTextColor,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.width,
    this.flex = 1,
    this.constraints,
    this.margin = const EdgeInsets.all(0),
    this.keyBoard = const TextInputType.numberWithOptions(decimal: true),
    this.focusNode,
    this.enabled = true,
  }):super(key: key);

  final Key? textKey;
  final bool enabled;
  final TextEditingController controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final String? hintText;
  final Color? textColor;
  final Color? hintTextColor;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final double? width;
  final int flex;
  final BoxConstraints? constraints;
  final EdgeInsets margin;
  final TextInputType keyBoard;
  final FocusNode? focusNode;

  Widget tff(){
    return Container(
      height: 35,
      constraints: constraints,
      width: width,
      margin: margin,
      child:TextFormField(
        key: textKey,
        controller: controller,
        keyboardType: keyBoard,
        autofocus: false,
        onTap: onTap,
        focusNode: focusNode,
        //initialValue: value,
        decoration: InputDecoration(
          enabled: enabled,
          //fillColor: Theme.of(context).canvasColor,
          hintText: hintText,//(value != null)?value:'0:00',
          hintStyle: TextStyle(color: hintTextColor,decoration: TextDecoration.none,),//color: color),
          //filled: true,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent,width: 0),
            borderRadius: BorderRadius.circular(10),
          ),
          errorStyle: const TextStyle(
            color: Colors.black,
            wordSpacing: 5.0,
            decoration: TextDecoration.none,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red,width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
        ),
        autocorrect: false,
        style: TextStyle(
          color: textColor,//(type == FilledType.OUT)?chartRed:chartGreen,
          fontSize: 16.0,
          fontFamily: 'MuseoSans',
          package: 'css',
          decoration: TextDecoration.none,
          //fontWeight: FontWeight.bold
        ),
        onChanged: (String val){
          if(controller.text.contains('.')){
            controller.text = controller.text.replaceAll('.', ':');
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          }
          if(onChanged != null){
            onChanged!(val);
          }
        },
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return (width == null)?Expanded(
      flex: flex,
      child: tff()
    ):tff();
  }
}

class Time{
  static void editTimeRequest({
    required BuildContext context,
    DateTime? submitDate,
    dynamic data,
    String? key
  }){
    List<TextEditingController> timeCont = [
      TextEditingController(),
      TextEditingController()
    ];
    List<DropDownItems> allDates = [];
    DateFormat dayFormatter = DateFormat('M/d/y');
    int openField = 1;
    data = data??{};
    if(submitDate == null){
      for(int i = 0; i < 30; i++){
        DateTime date = DateTime.now().subtract(Duration(days: i));
        String format = dayFormatter.format(date);
        allDates.add(
          DropDownItems(
            value: date.toString(), 
            text: format
          )
        );
      }
    }
    else{
      String format = dayFormatter.format(submitDate);
      allDates.add(
        DropDownItems(
          value: submitDate.toString(), 
          text: format
        )
      );
    }
    List<DropdownMenuItem<dynamic>> dates = LSIFunctions.setDropDownItems(allDates);
    String selectedDate = allDates[0].value;
    String error = '';

    void reset(){
      openField = 1;
      timeCont = [
        TextEditingController(),
        TextEditingController()
      ];
      data = {};
    }

    void getData(){
      if(data.toString() == '{}'){
        DateTime date = DateTime.parse(selectedDate);
        dynamic ymd = Time.getYMD(date, clickedUserData?['jibble']);
        data = clickedUserData?['jibble']?[ymd['year']]?[ymd['month']]?[ymd['day']] ?? {};
      }
      if(data.toString() != '{}'){
        if (data['in'] != null) {
          for (int j = 0; j < data['in'].length; j++) {
            int controllerInt = (2 * j);
            if(timeCont.length-1 > j){
              timeCont[controllerInt].text = data['in'][j];
            }
            else{
              timeCont.add(TextEditingController(text: data['in'][j]));
              timeCont.add(TextEditingController());
            }
            openField = data['in'].length;
          }
        }
        if (data['out'] != null) {
          for (int j = 0; j <  data['out'].length; j++) {
            int controllerInt = (2 * j + 1);
            timeCont[controllerInt].text = data['out'][j];
          }
        }
      }
    }
    getData();
    showDialog(
      context: context, 
      builder: (BuildContext context) => StatefulBuilder(builder: (context, setState) {
        Widget textField(FilledType type, int cont){
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                SizedBox(
                  width: 40,
                  child: Text(
                    (type.toString()).split('.')[1].toUpperCase(),
                    style: const TextStyle(
                      color: darkGrey,
                      fontFamily: 'Klavika',
                      package: 'css',
                      decoration: TextDecoration.none,
                      fontSize: 16
                    ),
                  )
                ),
                InkWell(
                  onTap: (){
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) => StatefulBuilder(builder: (context, setState) {
                        return TimePickerDialog(
                          initialTime: TimeOfDay.now(),
                        );
                      })
                    ).then((value){
                      timeCont[cont].text = value.hour.toString()+':'+(value.minute < 10?'0'+value.minute.toString():value.minute.toString());
                      List<String> tempIn = [];
                      List<String> tempOut = [];
                      for(int i = 0; i < timeCont.length;i++){
                        if(i%2 == 0){
                          tempIn.add(timeCont[i].text);
                        }
                        else{
                          tempOut.add(timeCont[i].text);
                        }
                      }
                      data['out'] = tempOut;
                      data['in'] = tempIn;
                    });
                  },
                  child: TimeTextFormFeild(
                    enabled: false,
                    width: 80,
                    hintTextColor: (type == FilledType.OUT)?chartRedT:chartGreenT,
                    hintText: '0:00',
                    textColor: (type == FilledType.OUT)?chartRed:chartGreen,
                    controller: timeCont[cont],
                  )
                )
            ])
          );
        }

        Widget allFeilds(){
          List<Widget> widgets = [];
          for(int i = 0; i < 2*openField;i++){
            widgets.add(
              textField(
                i%2 == 0?FilledType.IN:FilledType.OUT, 
                i
              )
            );
          }

          return Column(children: widgets+[
            Time.addRow(
              onTap: (){
                setState((){
                  timeCont.add(TextEditingController());
                  timeCont.add(TextEditingController());
                  openField++;
                });
                
                getData();
              }
            )
          ],);
        }
        
        return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              height: error == ''?368+(openField-1)*90:368+(openField-1)*90+18,
              width: CSS.responsive(),
              decoration:BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [BoxShadow(
                  color:Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(0,5),
                ),]
              ),
              padding: const EdgeInsets.fromLTRB(10,25,10,25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Edit Time Request',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).primaryTextTheme.headlineLarge
                ),
                const SizedBox(height: 30),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.baseline,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  LSIWidgets.dropDown(
                    height: 35,
                    radius: 10,
                    padding: const EdgeInsets.only(left:10),
                    color: Theme.of(context).indicatorColor,
                    itemVal: dates,
                    value: selectedDate,
                    style: Theme.of(context).primaryTextTheme.labelLarge!,
                    onchange: (val){
                      reset();
                      selectedDate = val;
                      getData();
                      setState(() {

                      });
                    },
                    width: 150,
                  ),
                  allFeilds(),
                ],),
                const SizedBox(height: 15,),
                error == ''?const SizedBox(height:0):Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).primaryTextTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if(submitDate == null){
                        bool allow = true;
                        for(int i = 1; i < timeCont.length;i=i+1){
                          if( i == 1 && (timeCont[0].text == '' || timeCont[1].text == '')){
                            setState((){
                              error = 'Looks like you forgot to put in a time!';
                            });
                            allow = false;
                            break;
                          }

                          int _in = Time.convertTimeToMinutes(timeCont[i-1].text);
                          int _out = Time.convertTimeToMinutes(timeCont[i].text);
                          if(_out-_in < 5){
                            setState((){
                              error = 'Looks like one of you have less then 5 minutes in!';
                            });
                            allow = false;
                            break;
                          }
                        }

                        if(allow){
                          Database.push(
                            'team',
                            children: 'users/${clickedUser.uid}/changeTime/',
                            data: {
                              'date': selectedDate,
                              'data': data,
                            }
                          ).then((value){
                            Messaging.sendPushMessage(
                              [userData['orgData']['manager']],
                              'Time Change Request', 
                              '${currentUser.displayName} has submitted a time change request!'
                            );
                          });
                          Navigator.pop(context);
                        }
                        else{
                          setState((){
                            error = 'Looks like somthing went wrong!';
                          });
                        }
                      }
                      else{
                        List<String?> dayIn = [];
                        List<String?> dayOut = [];
                        String year = (submitDate.year-2000).toString();
                        String month = submitDate.month.toString();
                        String day = submitDate.day.toString();
                        for(int i = 0; i < data['in'].length;i++){
                          String cIn = data['in'][i];
                          String cOut = data['out'][i];
                          if (cIn != '' && Time.convertTimeToMinutes(cIn) != 0) {
                            dayIn.add(cIn);
                          } 
                          else{
                            dayIn.add(null);
                          }
                          if (cOut != '' && Time.convertTimeToMinutes(cOut) != 0) {
                            dayOut.add(cOut);
                          } 
                          else{
                            dayOut.add(null);
                          }
                        }
                        if (dayIn.isNotEmpty) {
                          dynamic toSubmit = {'in': dayIn, 'out': dayOut};
                          Database.update(
                            'team',
                            children: "users/${clickedUser.uid}/jibble/$year/$month/",
                            location: day,
                            data: toSubmit
                          ).then((value){
                            Database.update(
                              'team',
                              children: "users/${clickedUser.uid}/changeTime/",
                              location: key!,
                            );
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    child: Text(
                      submitDate == null?'Save':'Approve',
                      style: Theme.of(context).primaryTextTheme.bodyMedium,
                    ),
                  ),
                ],)
              ],)
            )
          );
      })
    );
  }

  static Widget chartlegend({
    required int week,
    required int currentWeek,
    double width = 200
  }){
    DateTime ppStart = Time.getStartofPP();
    DateFormat formatter = DateFormat('M/d');

    List<Widget> legend = [];
    List<String> names = ['fri','sat','sun','mon','tue','wed','thu'];
    for(int i = 0; i < 7; i++){
      int iter = (week ==1)?i:i+7;
      String date = formatter.format(DateTime.parse(ppStart.toString()).add(Duration(days:(currentWeek*14)+iter)));
      List<String> holidays = Time.getHolidays();
      for(int i = 0; i < holidays.length;i++){
        if(date == holidays[i]){
          date = 'HOL';
          break;
        }
      }

      legend.add(
        SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
              names[i].toUpperCase(),
              style: const TextStyle(
                color: chartNameGrey,
                fontFamily: 'Klavika',
                package: 'css',
                decoration: TextDecoration.none,
                fontSize: 12
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Klavika Bold',
                package: 'css',
                decoration: TextDecoration.none,
                fontSize: 14
              ),
            ),
          ],)
        )
      );
    }

    return 
    Container(
      height: 60,
      decoration: const BoxDecoration(
        color: chartGrey,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child:
      Row(
        children:<Widget>[
          Container(
            padding: const EdgeInsets.only(right:10),
            alignment: Alignment.centerRight,
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WEEK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: chartNameGrey,
                    fontFamily: 'Klavika',
                    package: 'css',
                    decoration: TextDecoration.none,
                    fontSize: 16
                  ),
                ),
                Text(
                  week.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: chartNameGrey,
                    fontFamily: 'Klavika',
                    package: 'css',
                    decoration: TextDecoration.none,
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: width-80,
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,children: legend),
          )
        ]
      ),
    );
  }
  static Widget addRow({
    Function()? onTap,
    Color bgColor = Colors.transparent,
    Key? key,
  }){
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        FocusedInkWell(
          onTap: onTap,
          bgColor: bgColor,
          child: Row(
            children: [
              const Icon(
                Icons.add_circle,
                color: lightBlue,
              ),
              Text(
                ' add new row'.toUpperCase(),
                key: key,
                style: const TextStyle(
                  color: lightBlue,
                  fontFamily: 'Klavika',
                  package: 'css',
                  decoration: TextDecoration.none,
                  fontSize: 16
                ),
              )
            ]
          )
        ),
      ],);
  }
  static List<String> weekday = ['Friday','Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
  static List<String> weekdayDateTime = ['', 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];   
  static bool hasFilledData(String year, String month, String day, dynamic data) {
    dynamic temp = data?[year]?[month]?[day];
    return temp == null ? false : true;
  }
  static dynamic fillTime(String position, String totalDate, String type, String? val, dynamic tempData){
    //String position = positions.toString();
    List<String> date = totalDate.replaceAll(' ', '').split('/');
    String year = date[0];
    String day = date[2];
    String month = date[1];

    if(tempData == null){
      tempData = {year:{month:{day:{type:{position:val}}}}};
    }
    else if(tempData[year] == null){
      tempData[year] = {month:{day:{type:{position:val}}}};
    }
    else if(tempData[year][month] == null){
      tempData[year][month] = {day:{type:{position:val}}};
    }
    else if(tempData[year][month][day] == null){
      tempData[year][month][day] = {type:{position:val}};
    }
    else if(tempData[year][month][day][type] == null){
      tempData[year][month][day][type] = {position:val};
    }
    else{
      tempData[year][month][day][type][position] = val;
    }

    if(val == null){
      tempData = LSIFunctions.removeNull(tempData);
    }

    return tempData;
  }
  static dynamic dothething(dynamic? data, String totalDate, TimeSheetType tsType,bool useString, dynamic tempData){
    if(tsType == TimeSheetType.LPER){
      for(var test in data.keys){
        tempData = fillTime(test, totalDate, 'lper', data[test], tempData);
      }
    }
    else{
      if(data != null && data['in'] != null){
        for(int position = 0; position < data['in'].length; position++){
          tempData = fillTime(position.toString(), totalDate, 'in', data['in'][(useString)?position.toString():position],tempData);
        }
      }
      if(data != null && data['out'] != null){
        for(int position = 0; position < data['out'].length; position++){
          tempData = fillTime(position.toString(), totalDate, 'out', data['out'][(useString)?position.toString():position],tempData);
        }
      }
    }
    return tempData;
  }
  static dynamic getTempData3(TimeSheetType tsType, int currentWeek){
    dynamic tempData;
    List<String> dates = getTimesheetDates('M/d/y', currentWeek).split('-');
    String yearStart = (dates[0].split('/')[2]).replaceAll(' ', '');
    String yearEnd = (dates[1].split('/')[2]).replaceAll(' ', '');
    int yearLength = 1;

    String monthStart = dates[0].split('/')[0].replaceAll(' ', '');
    String monthEnd = dates[1].split('/')[0].replaceAll(' ', '');
    int monthLength = 1;

    String useInfo = '';

    if(tsType == TimeSheetType.LOGGER){
      useInfo = 'jibble';
    }
    else if(tsType == TimeSheetType.FILLED){
      useInfo = 'filledtime';
    }
    else{
      useInfo = 'LPER';
    }

    if(yearStart != yearEnd){
      yearLength = 2;
    }
    if(monthStart != monthEnd){
      monthLength = 2;
    }

    if(clickedUserData[useInfo] != null){
      for(int i = 0; i < yearLength; i++){
        var year = getCheckType(clickedUserData[useInfo],int.parse(yearStart)+i);
        if(year != 'none'){
          for(int j = 0; j < monthLength; j++){
            var month = getCheckType(clickedUserData[useInfo][year],int.parse(monthStart)+j);
            if(month != 'none'){
              for(int k = 1; k < 31;k++){
                var day = getCheckType(clickedUserData[useInfo][year][month],k);
                if(day != 'none'){
                  String totalDate = '$year/$month/$day';
                  tempData = dothething(clickedUserData[useInfo][year][month][day], totalDate, tsType,false,tempData);
                }
              }
            }
          }
        }
      }
    }
    return tempData;
  }
  static dynamic getTempData(TimeSheetType tsType, int currentWeek){
    dynamic tempData;
    List<String> dates = Time.getTimesheetDates('y-MM-dd', currentWeek).split(' - ');
    String useInfo = '';

    if(tsType == TimeSheetType.LOGGER){
      useInfo = 'jibble';
    }
    else if(tsType == TimeSheetType.FILLED){
      useInfo = 'filledtime';
    }
    else if(tsType == TimeSheetType.CHANGETIME){
      useInfo = 'changeTime';
    }
    else{
      useInfo = 'LPER';
    }

    if(clickedUserData[useInfo] != null){
      for(int i = 0; i < 14 ;i++){
        DateTime newdate = DateTime.parse(dates[0]).subtract(Duration(days: -i)).add(const Duration(hours: 7));
        DateFormat formatter = DateFormat('M/d/y');
        String date = formatter.format(newdate);

        var year = Time.getCheckType(clickedUserData[useInfo],int.parse(date.split('/')[2])-2000);
        if(year != 'none'){
          var month = Time.getCheckType(clickedUserData[useInfo][year],int.parse(date.split('/')[0]));
          if(month != 'none'){
            var day = Time.getCheckType(clickedUserData[useInfo][year][month],int.parse(date.split('/')[1]));
            if(day != 'none'){
              String totalDate = '$year/$month/$day';
              tempData = dothething(clickedUserData[useInfo][year][month][day], totalDate, tsType,false,tempData);
            }
          }
        }
      }
    }

    return tempData;
  }
  
  static bool determinIfTimeSheetDue(){
    int diffInDays = DateTime.now().difference(DateTime.parse("2018-06-01 04:00:00")).inDays;
    int diffInWeeks = ((diffInDays / 7)+1).floor();
    
    return (diffInWeeks%2 == 0);
  }
  static getCheckType(dynamic data, int think){
    try{
      if(data != null && data[think] != null){
        return think;
      }
      else if(data != null && data[think.toString()] != null){
        return think.toString();
      }
      else{
        return 'none';
      }
    }
    catch(e){
      return 'none';
    }
  }
  static String splitSemester(String semes){
    if(semes.contains('summer')){
      String year = semes.split('r')[1];
      return 'Summer 20$year';
    }
    else if(semes.contains('fall')){
      String year = semes.split('ll')[1];
      return 'Fall 20$year';
    }
    else{
      String year = semes.split('g')[1];
      return 'Spring 20$year';
    }
  }
  static String getSemester({bool fullYear = false, int? semester, bool toUppercase = true}){
    semDateLocation = (otherData['semester']['begins'].length-1);
    String begDate = otherData['semester']['begins'][semester??semDateLocation].replaceAll('T', ' ');
    DateTime other = DateTime.parse(begDate);

    String year = (fullYear)?other.year.toString():(other.year-2000).toString();
    int month = other.month;

    String sem = "Spring $year";
    if(month == 5){
      sem = "Summer $year";
    }
    else if(month == 8){
      sem = "Fall $year";
    }
    
    return toUppercase?sem.toUpperCase():sem;
  }
  static List<String> getSemesterDates(){
    DateTime currentDate = DateTime.now();
    int check = 0;
    for(int i = 0; i < otherData['semester']['begins'].length;i++){
      String begDate = otherData['semester']['begins'][i].replaceAll('T'," ");

      DateTime other = DateTime.parse(begDate);
      if(currentDate.isAfter(other)){
        check++;
      }
    } 
    semDateLocation = check-1;

    return [otherData['semester']['begins'][semDateLocation].split('T')[0],otherData['semester']['ends'][semDateLocation].split('T')[0]];
  }
  static int determinTimeSheetTime(dynamic data, int start,bool string){
    DateTime newStart = getStartofPP();
    DateTime ppStart = newStart.add(Duration(days: (start*14)));
    int total = 0;

    for(int i = 0; i < 14; i++){
      ZTime alltime = Time.getztime(
        date: ppStart.add(Duration(days: i)),
        data: data, 
        isString: string
      );
      total = total + alltime.totalTime;
    }

    return total;
  }
  static SendTime determinSemesterTime(dynamic userData,{String? uid, int? semester}){
    int total = 0;
    int totalWorkDays = 0;
    int weeks = 0;
    int averageDay = 0;
    int averageWeek = 0;

    List<dynamic> sembegin = otherData["semester"]["begins"];
    List<dynamic> semend = otherData["semester"]["ends"];
    int whichSemester = semester??semDateLocation;

    DateTime sStart = DateTime.parse(sembegin[whichSemester].replaceAll("T", " "));
    DateTime sEnd = DateTime.parse(semend[whichSemester].replaceAll("T", " "));
    int difference;
    if(DateTime.now().isAfter(sStart) && DateTime.now().isBefore(sEnd)){
      difference = DateTime.now().subtract(const Duration(days: 1)).difference(sStart).inDays;
    }
    else{
      difference = sEnd.difference(sStart).inDays;
    }

    for(int i = 0; i < difference; i++){
      DateTime newDate = sStart.add(Duration(days: i));
      ZTime alltime;
      try{
        alltime = Time.getztime(
          date: newDate,
          data: userData,
          isString: false, 
          uid: uid
        );
      }
      catch(e){
        alltime = ZTime(
          times: [0,0],
          totalTime: 0,
          missingOut: true,
          isVirtual: false
        );
      }

      if(i == difference-2 && totalWorkDays != 0 && weeks != 0){
        averageDay = total~/totalWorkDays;
        averageWeek = total~/weeks;
      }
      if(newDate.weekday == 5){
        weeks++;
      }
      if(alltime.totalTime != 0){
        totalWorkDays++;
      }

      total = total + alltime.totalTime;
    }

    return SendTime(
      total: total, 
      averageDay: averageDay,
      averageWeek: averageWeek,
      startDate: sStart,
      endDate: sStart.add(Duration(days: difference))
    );
  }
  static int daysSinceStartofSemester(){
    List<dynamic> sembegin = otherData["semester"]["begins"];
    DateTime sStart = DateTime.parse(sembegin[semDateLocation].replaceAll("T", " "));
    return DateTime.now().difference(sStart).inDays;
  }
  static DateTime getStartofPP({DateTime? date}){
    DateTime now = DateTime.now();
    DateTime startDate = date ?? DateTime(now.year, now.month, now.day, 1);
    int difference = startDate.difference(DateTime.parse("2018-06-01 01:00:00")).inDays;
    double days = difference/14;
    int getCeil = days.floor();
    double dec = days-getCeil;
    int daysto = (dec*14).round();
    DateTime newDate = startDate.subtract(Duration(days:daysto));
    return newDate;
  }
  static String getTimesheetDates(String format, int start){
    DateTime newStart = getStartofPP();//DateTime.parse('2022-04-01 00:00:00.000');
    DateTime ppStart = newStart.add(Duration(days: (start*14)));
    DateTime ppEnd = newStart.add(Duration(days: (start*14)+13));

    DateFormat formatter = DateFormat(format);
    String endDate = formatter.format(ppEnd);
    String startDate = formatter.format(ppStart);
    if(format == 'M/d/y'){
      int yearStart = int.parse(startDate.split('/')[2])-2000;
      int yearEnd = int.parse(endDate.split('/')[2])-2000;

      startDate = startDate.replaceAll(startDate.split('/')[2], yearStart.toString());
      endDate = endDate.replaceAll(endDate.split('/')[2], yearEnd.toString());

    }
    return '$startDate - $endDate';
  }
  static String weekDate([DateFormat? formatter,int subtractWeeks = 0]){
    formatter = formatter ?? DateFormat('M/d/y');
    DateTime changeDate = DateTime.now().add(Duration(days:(subtractWeeks*7)));
    int cDI = changeDate.weekday;
    List<int> dayweek = [3,4,5,6,0,1,2];
    DateTime ppStart = changeDate.subtract(Duration(days: dayweek[cDI-1]));
    DateTime ppEnd = ppStart.add(const Duration(days: 6));
    String endDate = formatter.format(ppEnd);
    String startDate = formatter.format(ppStart);
    return '$startDate - $endDate';
  }
  static String semesterDate(dynamic otherData){
    dynamic semBegins = otherData["semester"]["begins"];
    dynamic semEnds = otherData["semester"]["ends"];

    DateFormat formatter = DateFormat('M/d/y');
    String endDate = formatter.format(DateTime.parse(semEnds[semDateLocation].replaceAll('T', ' ')));
    String startDate = formatter.format(DateTime.parse(semBegins[semDateLocation].replaceAll('T', ' ')));
    return startDate+' - '+endDate;
  }

  static String handleCheckTS({
    int workHours = 20, 
    required List<TextEditingController> data, 
    required int currentTimeSheet,
    required int openField,
  }){
    List<String> holidays = getHolidays();
    String toReturn = 'Timesheet is accurate and ready to submit! Please make sure this is correct!';
    DateFormat formatter = DateFormat('M/d');
    String dates = getTimesheetDates('y-MM-dd',currentTimeSheet);
    List<String> date = dates.split(' - ');

    int week = 1;
    List<int> weeks = [0,0];
    List<int> days = List.filled(14, 0);//List(14);

    for(int i = 0; i < 14; i++){
      String checkDate = formatter.format(DateTime.parse(date[0]).subtract(Duration(days:-i)));


      if(i != 0 && i%7 == 0){
        week++;
      }

      int iter = (week == 1)?i:(i-7)+(7*8);
      List<int?> dayIn = List.filled(14, null);
      List<int?> dayOut = List.filled(14, null);

      for(int pos = 0; pos <= openField; pos++){
        int controllerIntIn = iter+7*(2*pos);
        int controllerIntOut = iter+7*(2*pos+1);
        
        if(data != null && data[controllerIntIn].text != null && data[controllerIntIn].text != ''){
          dayIn[pos] = Time.convertTimeToMinutes(data[controllerIntIn].text);
          dayOut[pos] = Time.convertTimeToMinutes(data[controllerIntOut].text);
        
          int tempDay = dayOut[pos]!-dayIn[pos]!;

          days[i] += tempDay;

          for(int j = 0; j < holidays.length;j++){
            if(checkDate == holidays[j]){
              return '$checkDate is a holiday, no time permitted!';
            }
          }

          if(tempDay < 0){
            return '$checkDate is missing an out!';
          }
          else if(changeToQuterHour(tempDay) > 5){
            return '$checkDate has a time period with more than 5 hours!';
          }
        }
      }
      if(changeToQuterHour(days[i]) > 10){
        toReturn = '$checkDate more than 10 hours for the day! Please make sure this is correct!';
      }
      
      if(i<7){
        weeks[0] += days[i];
      }
      else{
        weeks[1] += days[i];
      }
    }

    double tsTotal = changeToQuterHour(weeks[0]+weeks[1]);

    //people who work less than 40 hours
    if(workHours < 40 && tsTotal > 50){
      return 'Your Total Hours are over 50! Please make sure this is correct!';
    }
    else if(workHours < 40 && changeToQuterHour(weeks[0]) > 25){
      return 'Your total hours for week 1 are over 25! Please make sure this is correct!';
    }
    else if(workHours < 40 && changeToQuterHour(weeks[1]) > 25){
      return 'Your total hours for week 2 are over 25! Please make sure this is correct!';
    }

    //people who work over 40 hours
    if(workHours == 40 && tsTotal > 80){
      return 'Your Total Hours are over 80! Please make sure this is correct!';
    }
    else if(workHours == 40 && changeToQuterHour(weeks[0]) > 40){
      return 'Your total hours for week 1 are over 40! Please make sure this is correct!';
    }
    else if(workHours == 40 && changeToQuterHour(weeks[1]) > 40){
      return 'Your total hours for week 2 are over 40! Please make sure this is correct!';
    }

    return toReturn;
  }
  static String handleCheckLper({
    required List<TextEditingController> data, 
    //@required List<String> dates,
    required List<String> startDates, 
    required List<String> endDates,
    required int currentTimeSheet,
    required int openRows,
    required List<String> leaveTypes,
  }){
    String toReturn = 'LAPER is accurate and ready to submit! Please make sure this is correct!';

    List<double> lperHours = [0,0];
    int lperTotals = 0;

    for(int i = 0; i <= openRows; i++){
      int inTime = convertTimeToMinutes(data[i*3].text);
      int outTime = convertTimeToMinutes(data[i*3+1].text);
      String reason = data[i*3+2].text;

      if(startDates[i] == 'Choose' && endDates[i] == 'Choose' && inTime == 0 && outTime == 0 && reason == '' && leaveTypes[i] == 'Choose'){
        print('has blank field');
      }
      else{
        if(inTime == 0){
          return 'Field ${(i+1).toString()}is missing an Start Time!';
        }
        if(outTime == 0){
          return 'Field ${(i+1).toString()}is missing an End Time!';
        }

        if(Time.changeToQuterHour(outTime-inTime)-1 > 8){
          return 'Field ${(i+1).toString()} has a time period with more than 8 hours!';
        }

        if(startDates[i] == 'Choose'){
          return 'Field ${(i+1).toString()} is missing its Start Date!';
        }
        else if(endDates[i] == 'Choose'){
          return 'Field ${(i+1).toString()} is missing its End Date!';
        }
        else if(startDates[i] != 'Choose' && endDates[i] != 'Choose'){
          List<String> startDate = startDates[i].split('/');
          DateTime start = DateTime(
            int.parse(startDate[2])+2000,
            int.parse(startDate[0]),
            int.parse(startDate[1]),
          );
          List<String> endDate = startDates[i].split('/');
          DateTime end = DateTime(
            int.parse(endDate[2])+2000,
            int.parse(endDate[0]),
            int.parse(endDate[1]),
          );
          int difference = end.difference(start).inDays;
          lperTotals = difference*(outTime-inTime);
        }
      }
    }

    if(changeToQuterHour(lperTotals) > 80 ){
      return 'Your Total Hours are over 80';
    }
    // else if(lperHours[0] > 40)
    //   return 'Your total hours for week 1 are over 40';
    // else if(lperHours[1] > 40)
    //   return 'Your total hours for week 2 are over 40';
    return toReturn;
  }

  /// requires: intl: ^0.15.2
  static String getDateNow(String format) {
    var now = DateTime.now();
    var formatter = DateFormat(format);
    return formatter.format(now);
  }
  static Map<String,dynamic> getYMD(DateTime newdate, dynamic data){
    var day;
    var month;
    var year;

    try{
      if(data[(newdate.year - 2000)] != null){
        year = (newdate.year - 2000);
      }
      else{
        year = (newdate.year - 2000).toString();
      }
      
      if(data[year][newdate.month] != null){
        month = newdate.month;
      }
      else{
        month = newdate.month.toString();
      }

      if(data[year][month][newdate.day] != null){
        day = newdate.day;
      }
      else{
        day = newdate.day.toString();
      }
    }
    catch(e){
      return {
        'day': null,
        'month': null,
        'year': null
      };
    }

    return {
      'day':day,
      'month':month,
      'year':year
    };
  }
  static bool allowJibble({
    required String time,
    required DateTime date,
    FilledType? type
  }){
    bool allowed = false;
    dynamic dateSplit = Time.getYMD(date, userData["jibble"]);

    var year = dateSplit['year'];
    var month = dateSplit['month'];
    var day = dateSplit['day'];

    if(year == null){
      year = (date.year-2000).toString();
      try{
        month = date.month.toString();
        print(userData?["jibble"]?[year]?[month]);
      }
      catch(_){
        month = date.month;
      }
      day = date.day.toString();
    }
    dynamic currentJibble;// = userData?["jibble"]?[year]?[month]?[day];
    try{
      currentJibble = userData?["jibble"]?[year]?[month]?[day];
    }
    catch(_){}
    bool fout = true;
    bool fin = true;
    if(type != null){
      if(type == FilledType.IN){
        fout = false;
      }
      else{
        fin = false;
      }
    }
    
    if(currentJibble == null && fin){
      return true;
    }
    else if(currentJibble == null && fout){ 
      return false;
    }
    else if(currentJibble['in'] == null && fin){
      return true;
    } 
    else if(currentJibble['in'] == null && fout){ 
      return false;
    }
    else if(currentJibble['out'] == null && fout){
      int inMin = Time.convertTimeToMinutes(currentJibble['in'][0]);
      int curMin = Time.convertTimeToMinutes(time);
      if(curMin-inMin > 5){
        return true;
      }
    }
    else{
      if(currentJibble['in'].length > currentJibble['out'].length && fin){
        int inMin = Time.convertTimeToMinutes(currentJibble['in'][currentJibble['in'].length-1]);
        int curMin = Time.convertTimeToMinutes(time);
        if(curMin-inMin > 5){
          return true;
        }
      }
      else if(currentJibble['in'].length > currentJibble['out'].length && fout){
        return false;
      }
      else{
        int inMin = Time.convertTimeToMinutes(currentJibble['out'][currentJibble['out'].length-1]);
        int curMin = Time.convertTimeToMinutes(time);
        if(curMin-inMin > 5){
          return true;
        }
      }
    }

    return allowed;
  }
  static int getLperTimeDayTotals({
    required String date,
    required int i,
    dynamic data,
  }){
    DateTime newdate = DateTime.parse(date).subtract(Duration(days: i));

    dynamic allDateInfo = getYMD(newdate, data);
    var day = allDateInfo['day'];
    var month = allDateInfo['month'];
    var year = allDateInfo['year'];

    dynamic lper = [];

    //in
    try{
      lper = data[year][month][day];
    }
    catch(e){
      return 0;
    }

    int tTime = 0;

    if (lper != null){
      for (var options in lper.keys){
        List<String> intime = lper[options].split(":");
        tTime += int.parse(intime[0]) * 60 + int.parse(intime[1]);
      }
    }
    
    return tTime;
  }
  static int getTotalSemesters(dynamic jibble){
    int numSem = 0;
    if(jibble != null){
      int length = otherData["semester"]["begins"].length;
      for(int i = length-1; i >= 0; i--){
        SendTime time = Time.determinSemesterTime(jibble,semester: i);
        int total = time.total;

        if(total != 0){
          numSem++;
        }
      }
    }
    return numSem;
  }
  static ZTime getztime({
    required DateTime date, 
    dynamic data, 
    required bool isString,
    bool useTodaysTime = true,
    String? uid
  }){
    int Ttime = 0;
    bool missingOut = true;
    List<int> week = [];
    bool isVirtual = false;
    int minute = DateTime.now().minute;
    int hour = DateTime.now().hour;

    DateTime newdate = date;//.subtract(Duration(days: i));

    dynamic allDateInfo = getYMD(newdate, data);
    var day = allDateInfo['day'];
    var month = allDateInfo['month'];
    var year = allDateInfo['year'];

    String newDate = '$month/$day/$year';
    String curDate = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year-2000}';
    
    dynamic jibbleIn;
    dynamic jibbleOut;
    try{
    jibbleIn = data?[year]?[month]?[day]?["in"];
    jibbleOut = data?[year]?[month]?[day]?["out"];}
    catch(_){}

    if(jibbleIn == null){
      return ZTime(
        times:[0,0],
      );
    }

    int jibbleInLength = jibbleIn.length;

    if (jibbleOut != null) {
      int jibbleOutLength = jibbleOut.length;
      List<int> t1 = [];
      List<int> t2 = [];

      //get the in time in minutes
      for (int i = 0; i <= jibbleInLength - 1; i++){
        var intime = (!isString)?jibbleIn[i]:jibbleIn[i.toString()];
        List<String> intimes = [];
        if(intime != null){
          intimes = intime.split(":");
        }
        else{
          intimes = ['0','0'];
        }
        t1.add(int.parse(intimes[0]) * 60 + int.parse(intimes[1].split('.')[0]));
      }

      //get the out time in minutes
      for (int i = 0; i <= jibbleOutLength - 1; i++) {
        var outtime = (!isString)?jibbleOut[i]:jibbleOut[i.toString()];
        List<String> outtimes = [];

        if(outtime != null){
          outtimes = outtime.split(":");
        }
        else{
          outtimes = ['0','0'];
        }

        if (int.parse(outtimes[0]) == 0 && int.parse(outtimes[1].split('.')[0]) == 0){
          t2.add(hour * 60 + minute * 1);
        }
        else {
          t2.add(int.parse(outtimes[0]) * 60 + int.parse(outtimes[1].split('.')[0]));
        }
      }

      //if the lengths are equal get total time
      if (jibbleInLength == jibbleOutLength) {
        for(int i = 0; i <= jibbleInLength - 1; i++){
          week.add(t2[i] - t1[i]);
          Ttime = t2[i] - t1[i] + Ttime;
        }
        missingOut = false;
      }
      else {
        int tempLength = jibbleOutLength;
        if(jibbleInLength < jibbleOutLength){
          tempLength = jibbleInLength;
          print('Error:$uid has too many outs');
        }
        for(int i = 0; i < tempLength; i++){
          int checkTime = t2[i] - t1[i];
          if(checkTime < 0){
            checkTime = 0;
          }
          week.add(checkTime);
          Ttime = checkTime + Ttime;
        }
        int checkTime = (hour*60 + minute) - t1[jibbleInLength - 1];

        if(newDate == curDate){
          checkTime = (hour*60 + minute) - t1[jibbleInLength - 1];
        }
        else{
          checkTime = (24*60) - t1[jibbleInLength - 1];
        }

        if(checkTime < 0){
          checkTime = 0;
        }
        
        week.add(checkTime);
        Ttime = checkTime + Ttime;
      }
    }
    else if(useTodaysTime){
      var intime= (!isString)?jibbleIn[0]:jibbleIn['0'];
      List<String> intimes = [];

      if(intime != null){
        intimes = intime.split(":");
      }
      else{
        intimes = ['0','0'];
      }
      List<String> virChek = intimes[1].split('.');
      if(virChek.length > 1 && virChek[1] == '01'){
        isVirtual = true;
      }
      int t1 = int.parse(intimes[0])*60 + int.parse(intimes[1].split('.')[0]);
      int t2 = hour*60 + minute;
      
      if(newDate != curDate){
        t2 = (24*60);
      }

      int checkTime = t2 - t1;
      if(checkTime < 0){
        checkTime = 0;
      }
      Ttime = checkTime;
    }
    else{
      Ttime = 0;
    }

    return ZTime(
      times: week,
      totalTime: Ttime,
      missingOut: missingOut,
      isVirtual: isVirtual
    );
  }
  static String? getSemesterFromDate(DateTime date){
    List<String> sems = ['summer','fall','spring'];
    String? exportSem;
    int j = 0;
    for(int i = 0; i < otherData['semester']['begins'].length;i++){
      String begDate = otherData['semester']['begins'][i].replaceAll('T', ' ');
      DateTime bd = DateTime.parse(begDate).subtract(const Duration(days: 1));
      String? endDate = otherData['semester']['ends'][i].replaceAll('T', ' ');
      DateTime ed = endDate!= null?DateTime.parse(endDate).add(const Duration(days: 1)):DateTime.now();
      if(date.isAfter(bd) && date.isBefore(ed)){
        int year = date.year-2000;
        return '${sems[j]}$year';
      }
      j++;
      if(j == 3){
        j=0;
      }
    }

    return exportSem;
  }
  static List<DateTime>? getDateFromSemester(String semester){
    List<String> sems = ['summer','fall','spring'];
    int j = 0;
    for(int i = 0; i < otherData['semester']['begins'].length;i++){
      String begDate = otherData['semester']['begins'][i].replaceAll('T', ' ');
      DateTime bd = DateTime.parse(begDate).subtract(const Duration(days: 1));
      String? endDate = otherData['semester']['ends'][i].replaceAll('T', ' ');
      DateTime ed = endDate!= null?DateTime.parse(endDate).add(const Duration(days: 1)):DateTime.now();
      int year = bd.year-2000;
      String exportSem = '${sems[j]}$year';

      if(exportSem == semester){
        return [bd,ed];
      }
      j++;
      if(j > 2){
        j=0;
      }
    }

    return null;
  }
  static String getNextemester(String semester){
    int year = int.parse(semester.replaceAll('fall', '').replaceAll('spring', '').replaceAll('summer', ''));
    if(semester.contains('summer')){
      return 'fall$year';
    }
    else if(semester.contains('spring')){
      return 'summer$year';

    }
    else{
      return 'spring${year+1}';
    }
  }
  static String converMinutesToString(int minutes){
    String converttime = '';
    String tHour = '00';
    String tMinute;

    if (minutes < 60) {
      if(minutes < 10){
        tMinute = '0$minutes';
      }
      else{
        tMinute = minutes.toString();
      }
    }
    else {
      int hour = (minutes/60).floor();
      int minute = minutes - hour*60;

      tHour = hour.toString();
      tMinute = minute.toString();
      if(hour < 10){
        tHour = '0$hour';
      }
      if(minute < 10){
        tMinute = '0$minute';
      }
    }

    converttime = '$tHour:$tMinute';

    return converttime;
  }
  static String convertToHoursandMinutes(int minutes){
    int hour = (minutes/60).floor();
    int minute = minutes-(hour*60);
    return '${hour}h${minute}m';
  }
  static String convertQuterHoursToString(double time){
    if(time == 0){
      return '';
    }
    List<String> split = time.toString().split('.');
    String hour = split[0];
    String minute = '0';
    if(split.length == 2){
      minute = split[1];
    }
    if(minute == '0' && hour == '0'){
      return '';
    }
    else if(minute == '0'){
      return hour;
    }
    else {
      return time.toString();
    }
  }
  static double changeToQuterHour(int minutes){
    return ((((minutes/60)*4).round())/4);
  }
  static int convertTimeToMinutes(String? minutes){
    if((minutes == null || minutes == '') || !minutes.contains(':') || (minutes.contains(':') && minutes.split(":")[1] == '')){
      return 0;
    }

    int changedTime = 0;
    String hour = minutes.split(":")[0];
    String minute = minutes.split(":")[1].split('.')[0];

    int changedHours = (int.tryParse(hour) ?? 0)*60;
    int changedMinutes = int.tryParse(minute) ?? 0;

    changedTime = changedHours+changedMinutes;

    return changedTime;

  }
  static bool hereOnHaloween(dynamic data,){
    const startYear = 2017;
    int endYear = DateTime.now().year;
    for(int i = 0; i < endYear-startYear+1;i++){
      ZTime alltime = Time.getztime(
        date:DateTime(startYear+i,10,31),
        data: data,
        isString: false
      );

      if(alltime.totalTime != 0){
        return true;
      }
    }
    return false;
  }
  static ZTime determinTotalDayTime(dynamic data,DateTime date){
    ZTime alltime = Time.getztime(
      date:date,
      data: data,
      isString: false
    );
    return alltime;
  }
  static Map<String,dynamic> determinTotalWeekTime(dynamic data, DateTime date, bool isString){
    int cDI = date.weekday;
    //String dayDates = '';
    String dates = '';
    DateFormat dayFormatter = DateFormat('MMMM dd, yyyy');
    int total = 0;
    int j = 0;
    int k = 0;

    List<int> dayweek = [3,4,5,6,0,1,2];
    List<int> dayTimes = [0,0,0,0,0];

    for(int i = 0; i < 7; i++){
      j = dayweek[cDI-1]-i;
      if(i == 0){
        DateTime newdate = date.subtract(Duration(days: j));
        dates += dayFormatter.format(newdate);
      }
      if(i == 6){
        DateTime newdate = date.subtract(Duration(days: j));
        dates += '-${dayFormatter.format(newdate)}';
      }
      ZTime alltime = getztime(
        date: date.subtract(Duration(days: j)),
        data: data,
        isString: isString
      );
      int ztime = alltime.totalTime;
      total = total + ztime;

      if(i > 2 && !isString){
        dayTimes[k] = ztime;
        //dayTimesString[k] = hour.toString()+'h'+minute.toString()+'m';
        k++;
      }
    }
    
    return {
      'total':total,
      'dayTimes':dayTimes,
      'dates': dates
      //'dayDates':dayTimesString
    };
  }
  static SendTime determinTotalMonthTime(dynamic data,DateTime date, bool isString){
    int total = 0;
    DateTime endDate = DateTime(date.year,date.month+1);
    int length = DateTimeRange(
      start: date,
      end: endDate
    ).duration.inDays;

    int weeks = 0;
    int totalWorkDays = 0;
    int averageDay = 0;
    int averageWeek = 0;

    for(int i = 0; i < length; i++){
      DateTime newDate = date.add(Duration(days: i));
      ZTime alltime = getztime(
        date: newDate,
        data: data,
        isString: isString
      );

      if(i == length-2 && totalWorkDays != 0){
        averageDay = total~/totalWorkDays;
        averageWeek = total~/weeks;
      }
      if(newDate.weekday == date.weekday){
        weeks++;
      }
      if(alltime.totalTime != 0){
        totalWorkDays++;
      }

      total = total + alltime.totalTime;
    }
    return SendTime(
      total: total,
      averageDay: averageDay,
      averageWeek: averageWeek,
      startDate: date,
      endDate: endDate
    );
  }
  static int determinTotalYearTime(dynamic data,DateTime date, bool isString){
    int total = 0;
    for(int i = 1; i < 12; i++){
      total += determinTotalMonthTime(data, DateTime(date.year,i), isString).total;
    }
    return total;
  }
  static List<String> getHolidays(){
    String year = (DateTime.now().year).toString();
    String jan = "$year-01-01 08:00:00.000Z";
    String may = "$year-05-01 08:00:00.000Z";
    String sept = "$year-09-01 08:00:00.000Z";
    String nov = "$year-11-01 08:00:00.000Z";

    String mlk = '';
    String md = '';
    String ld = '';
    String td = '';
    String tde = '';

    int m = 0;
    int j = 0;
    int k = 0;

    for (int i = 0; i <= 30; i++) {
      int janDay = DateTime.parse(jan).add(Duration(days: i)).weekday;
      int mayDay = DateTime.parse(may).add(Duration(days: i)).weekday;
      int septDay = DateTime.parse(sept).add(Duration(days: i)).weekday;
      int novDay = DateTime.parse(nov).add(Duration(days: i)).weekday;

      if (janDay == 1 && m <= 2) {
        m++;
        mlk = "1/${i+1}";
      }

      if (mayDay == 1) {
        md = "5/${i+1}";
      }

      if (septDay == 1 && j == 0) {
        j++;
        ld = "9/${i+1}";
      }

      if (novDay == 5 && k <= 4) {
        k++;
        td = "11/${i+1}";
        tde = "11/${i+2}";
      }
    }
    return ["1/1", mlk, md , '7/4', ld, '11/11', td, tde, '12/25'];
  }
}

