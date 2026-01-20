library my_prj.globals;

import 'dart:io';
import 'package:css/css.dart';
import 'package:flutter/material.dart';
export 'package:css/css.dart';
import '../src/organization/organization.dart';

typedef HomeCallback = void Function({required LSICallbacks call, AppScreens? place, Map<String,dynamic>? info});

class UsersProfile{
  UsersProfile({
    required this.imageUrl,
    required this.uid,
    required this.displayName,
    this.status = OrgStatus.assistant,
    this.canRemoteWork = false
  });

  OrgStatus status;
  String? imageUrl;
  String uid;
  String displayName;
  bool canRemoteWork;
}

enum LSICallbacks{
  Reset,
  Settings,
  Notifications,
  Logout,
  Sign,
  gotoPage,
  PaperWork,
  Expand,
  Updated,
  OpenDrawer,
  CloseDrawer,
  ChangeTheme,
  ClearBanner,
  ExpandBanner,
  UpdatedNav,
  Call,
  updateChat,
  unFocus,
  next,
  back,
  done,
  refresh,
  update,
  start,
  clockOut
}

enum AppScreens{
  admin,
  charts,
  temp,
  main,
  time,
  task,

  schedule,
  room,
  event,
  interview,

  eval,
  weekly,
  reports,
  settings,
  badge,
  profile,
  changeTime,
  bugReport,
  blogs,
  chats,
  customization,
  art,
  qr,
  design,
  past,
  inventory,
  maintenance,
  packages,
  training,
  progress,
  expand,
  press,

  trials,
  statistics,
  vendor,
  view,
  slot,
  purchase,
  devices,
  programs,
  reminders,
  parts,
  keys,
  candidates,
  services,
  hiring,
  travel,

  msds,
  sop,
  wi,
  none
}

AppScreens getAppScreensFromRoute(String route){
  for(int i = 0; i < AppScreens.values.length;i++){
    AppScreens screen = AppScreens.values[i];
    if('/${screen.name}' == route){
      return screen;
    }
  }

  return AppScreens.main;
}

bool isLoggedIn = false;
bool googleNameChange = false;

late UsersProfile currentUser;
late UsersProfile clickedUser;

// Device
bool reminder = false;
bool hasDevices = false;
bool hasServices = false;
bool hasInternet = false;
bool deviceConnected = false;
bool useSideNav = false;
bool drawerIsClosed = true; 
LsiThemes theme = LsiThemes.dark;

dynamic allUsersData;
dynamic userData;
dynamic userSchedules;
dynamic schedules;
dynamic meetingSchedules;
dynamic otherData;
dynamic usersProfile;
dynamic clickedUserData;
dynamic userChats;
dynamic classSchedules;
dynamic cohortSchedules;

dynamic patients = {};

Size navSize = const Size(55,95);
double appBarHeight = 50;
double sideListSize = 250;

bool showList = false;
double deviceWidth = 0;
double deviceHeight = 0;
bool oversized = false;
double dpr = 1.0;

int location = 0;
int currentLevel = 1;                     //for the level used
double sliderValue = 0.0;               //for the gain value
bool deviceSide = true;
bool clockInOut = false;
String totalWorkingTime = '0:00';
double batLvl = 0.0;                        //current battery level
List<double> bumps = [100,300,500,800];
String dName = '';
late String currentDate;
List<String> deviceUID = [];

String firstname = 'Name';

int currentReport = 0;
int reportTotal = 0;
int currentEval = 0;
int surveyTotal = 0;
int badgesEarned = 0;

DateTime classesStart = DateTime.now();
DateTime classesEnd = DateTime.now();
List<dynamic> holidays = [];

late String sem;
late String prevSem;
int semDateLocation = 0;
bool tsDue = false;

void internetCheck()async{
  try {
    final result = await InternetAddress.lookup('trials.limbitless-solutions.org');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty){
      hasInternet = true;
    }
  } on SocketException catch (_) {
    hasInternet = false;
  }
}