import '../functions/lsi_functions.dart';
import 'emblems.dart';

enum OrgStatus{admin,affiliatedFaculty,vendor,assistant,associate,graduate,bot,none,visitingScholar}
enum StatusAllowed{adminOnly,vendorOnly,studentOnly,hasTimeSheet,allAdmins, all, president,trainer,allBut,bot}
enum Trainings{mill,lathe,tanks,thermoform,eye_wash,printer_3d,laser_safety,painting,horizontal_band_saw,vertical_band_saw,belt_sander,citi,injection_molding,sand_blasting,iso}

class Org{
  static String adminSig = 'https://firebasestorage.googleapis.com/v0/b/limbitless-solutions-team/o/sign%2FAlbert%20Manero.png?alt=media&token=023b8b80-2396-44ea-af9d-3e15298ae5a5';
  static dynamic convertData(dynamic data, [String? displayName]){
    dynamic newData = {};
    if(data['orgData'] != null){
      data['orgData']['dateCreated'] = data['orgData']?['dateCreated'] ?? getFirstDate(data?['jibble']);
      data['orgData']['status'] = 'OrgStatus.${(getStatus(data['orgData']['status']) ?? 'none')}';
      data['orgData']['updated'] = DateTime.now().toString();
      data['badges'] = convertBadges(data?['badges']);
      return data;
    }
    else{
      newData['LPER'] = data?['LPER'];
      newData['OP'] = data?['OP'];
      newData['selfEval'] = data?['selfEval'];
      newData['adminEval'] = data?['adminEval'];
      newData['signed'] = data?['signed'];
      newData['printed'] = data?['printed'];
      newData['token'] = data?['token'];
      newData['weekly'] = data?['weekly'];
      newData['weeklyReport'] = data?['weeklyReport'];
      newData['customization'] = data?['customization'];
      newData['filledtime'] = data?['filledtime'];
      newData['jibble'] = data?['jibble'];
      newData['notifications'] = data?['notifications'];
      newData['settings'] = data?['settings'] ?? {'theme':false};
      newData['timeData'] = _getTimeData(data);

      newData['studentData'] = data?['studentData'] ?? {
        'standing': data?['standing'],
        'surveyClicked': 0,
        'surveyOptOut': data?['surveyOptOut'] ?? false,
        'athlete': data?['Athlete']
      };
      newData['orgData'] = data?['orgData'] ?? {
        'active': false,
        'blogger': data?['blogger'],
        'department': getDEP(data['Dep'] ?? data['DEP']),
        'displayName': data['displayName'] ?? displayName,
        'manager': getManagerUidFromName(getFullManagerName(data['Manager'].toString().split(' ')[0])),
        'organization': 'limbitless',
        'sigFile': data['sigFile'],
        'status': getOldStatus(
          data?['Status']) == null?null:'OrgStatus.${getOldStatus(data?['Status'])!.toLowerCase()}',
        'timeSheet': data?['timesheet'],
        'dateCreated': getFirstDate(data?['jibble']) ?? DateTime.now.toString(),
        'updated': DateTime.now.toString()
      };
      newData['badges'] = convertBadges(data?['badges']);
        // ((data?['badges']?['1_welcome'] != null && data?
        // ['badges']?['1_welcome'] is bool) || data?['badges']?['1_welcome']?['active'] == null)? convertBadges(data?['badges']):
        // data['badges'];
    }
    return newData;
  }
  static dynamic _getTimeData(dynamic data){
    return {
      'group': '6101',
      'pid': data['pid'],
      'timeMaster': false,
      'tutorial': false,
      'workGroup': 'OPSH',
      'workHours': 20,
    };
  }
  static String? getFirstDate(dynamic jibbleDate){
    if(jibbleDate != null){
      String year = jibbleDate.keys.first;
      late dynamic month;
      if(jibbleDate[year] is List<dynamic>){
        for(int i = 1; i < 13;i++){
          if(jibbleDate[year]?[i] != null){
            month = i;
            break;
          }
        }
      }
      else{
        month = jibbleDate[year].keys.first;
      }
      late String day;
      if(jibbleDate[year][month] is List<dynamic>){
        for(int i = 1; i < 32;i++){
          if(jibbleDate[year][month]?[i] != null){
            day = i.toString();
            break;
          }
        }
      }
      else{
        day = jibbleDate[year][month].keys.first;
      }
      return DateTime(int.parse(year)+2000,int.parse(month.toString()),int.parse(day)).toString();
    }
    return null;
  }
  static dynamic convertBadges(dynamic oldBadges){ 
    dynamic newBadges = {};
    if(oldBadges == null){
      for(int i = 0; i < Emblems.allEmblems.length;i++){
        for(String key in Emblems.allEmblems[i]){
          newBadges[key] = {
            'active': false,
            'date': DateTime.now().toString()
          };
        }
      }
    }
    else{
      for(String key in oldBadges.keys){
        if(oldBadges[key] is bool){
          newBadges[key] = {
            'active': oldBadges[key],
            'date': DateTime.now().toString()
          };
        }
        else{
          newBadges[key] = oldBadges[key];
        }
      }
    }
    return newBadges;
  }
  static bool checkInDepartment(dynamic userData, String department){
    department = Org.getDEP(department);
    dynamic temp = userData?['orgData'];
    if(temp == null) return false;
    if(temp['department'] == department){
      return true;
    }
    else if(temp['subDepartments'] !=  null && temp['subDepartments'] == department){
      return true;
    }
    else if(temp['otherDepartments'] !=  null){
      for(String key in temp['otherDepartments'].keys){
        if(temp['otherDepartments'][key] == department){
          return true;
        }
      }
    }

    return false;
  }
  static bool isFirstSemester(dynamic userData){
    if(userData['orgData'] != null && userData['orgData']['status'] != null){
      if(statusAllowed(StatusAllowed.studentOnly, getOrgStatusFromString(userData['orgData']['status'])) && (userData['weeklyReport'] == null || userData['weeklyReport']?.length <= 1)){
        return true;
      }
    }
    return false;
  }
  static bool statusAllowed(StatusAllowed allowed, OrgStatus status, {bool hasTimeSheet = false, String uid = ''}){
    switch (allowed) {
      case StatusAllowed.adminOnly:
        if(status == OrgStatus.admin){
          return true;
        }
        break;
      case StatusAllowed.studentOnly:
        if(status == OrgStatus.assistant || status == OrgStatus.associate || status == OrgStatus.graduate || status == OrgStatus.visitingScholar){
          return true;
        }
        break;
      case StatusAllowed.vendorOnly:
        if(status == OrgStatus.admin || status == OrgStatus.vendor){
          return true;
        }
        break;
      case StatusAllowed.allAdmins:
        if(status == OrgStatus.admin || status == OrgStatus.affiliatedFaculty){
          return true;
        }
        break;
      case StatusAllowed.hasTimeSheet:
        if(status == OrgStatus.admin || status == OrgStatus.associate || hasTimeSheet){
          return true;
        }
        break;
      case StatusAllowed.bot:
        if(status == OrgStatus.bot){
          return true;
        }
        break;
      case StatusAllowed.all:
        if(status != OrgStatus.vendor && status != OrgStatus.bot){
          return true;
        }
        break;
      case StatusAllowed.president:
        if(status == OrgStatus.admin && uid == presidentUid){
          return true;
        }
        break;
      case StatusAllowed.trainer:
        for(int i = 0; i < trainers.length;i++){
          if(status == OrgStatus.admin && uid == trainers[i]){
            return true;
          }
        }
        break;
      case StatusAllowed.allBut:
        if(status != OrgStatus.affiliatedFaculty && status != OrgStatus.vendor && status != OrgStatus.bot){
          return true;
        }
        break;
      default:
        return false;
    }

    return false;
  }
  static String presidentUid = 'nPIiU7wbg8W6BOXIjtELTSHD4GI3';
  static String orgStatusToString(OrgStatus status){
    switch (status) {
      case OrgStatus.admin:
        return 'Admin';
      case OrgStatus.affiliatedFaculty:
        return 'Affiliated Faculty';
      case OrgStatus.vendor:
        return 'Vendor';
      case OrgStatus.assistant:
        return 'Assistant';
      case OrgStatus.associate:
        return 'Associate';
      case OrgStatus.graduate:
        return 'Graduate';
      case OrgStatus.bot:
        return 'Bot';
      case OrgStatus.visitingScholar:
        return 'Visiting Scholar';
      default:
        return 'Non-Applicable';
    }
  }
  static String getManagerUidFromName(String name){
    for(int i = 0; i < managers.length;i++){
      if(managers[i].text == name){
        return managers[i].value;
      }
    }
    return '';
  } 
  static List<String> gender = ['M','F','Prefer not to say']; //['M','F','I','X','Prefer not to say'];
  static List<String> stateAccro = ["Choose One...","AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
    "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS",
    "MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA",
    "RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"];
  static bool isTrainer(String uid){
    for(int i = 0; i < trainers.length;i++){
      if(uid == trainers[i]){
        return true;
      }
    }
    return false;
  }
  static Trainings? convertStringToTrainings(String training){
    for(int i = 0; i < Trainings.values.length; i++){
      if(training.toLowerCase() == Trainings.values[i].name.toLowerCase()){
        return Trainings.values[i];
      }
    }
    return null;
  } 
  static Map<String, String>? getTrainingQuiz(Trainings? training){
    if(training == null) return null;
    switch (training){
      case Trainings.iso:
        return {
          'Have you read the SOP document?': 'No,Yes',
          'Where is the ISO binder?': 'I do not know.,Above the first aid kit next to the Manufacturing room.',
          'Are you aware of the quality policy?': 'No,Yes',
          'Are you aware of the relevant quality objectives?': 'No,Yes',
          'Are you aware of the benefits of improved personal performance?': 'No,Yes',
          'Are you aware of the potential consequences of not conforming to the QMS requirements?': 'No,Yes',
        };
      case Trainings.mill:
      case Trainings.lathe:
      case Trainings.tanks:
      case Trainings.printer_3d:
      case Trainings.laser_safety:
      case Trainings.thermoform:
      case Trainings.painting:
      case Trainings.vertical_band_saw:
      case Trainings.horizontal_band_saw:
      case Trainings.belt_sander:
      case Trainings.injection_molding:
      case Trainings.sand_blasting:
        return {'Have you read the SOP document?': 'No,Yes'};
      default:
        return null;
    }
  }
  static String? checkAnswer(String question){
    switch(question){
      case 'Have you read the SOP document?':
        return 'Yes';
      case 'Where is the ISO binder?':
        return 'Above the first aid kit next to the Manufacturing room.';
      default:
        return null;
    }
  }
  static String? getTrainingDocumentId(Trainings? training){
    if(training == null) return null;
    switch (training) {
      case Trainings.mill:
        return '1xRfGYBwRPAY2AvFUD4u8oRZOFKJkSaS_zvWwaHE0tyE';
      case Trainings.lathe:
        return '1Tz2zSf-NWFQCYxqMF9B-MddLERPNdEViAdR8OzLoBVI';
      case Trainings.tanks:
        return '1Kc11moQi5HqjkFHF-vwfJvvYVODfWPa2nFKfYiE45AI';
      case Trainings.eye_wash:
        return null;
      case Trainings.printer_3d:
        return '1xGdWc4jxLSpj80i08S4-hErksteEQxIf7QQiDxtTYRU';
      case Trainings.laser_safety:
        return '19xcjAfMz7rMqgPWA_7aQjDrDW98EEv5Vzs9wchuMTmc';
      case Trainings.thermoform:
        return '14DlXwoRVW2TQNVeRbFzm4tfADWz13DzfcZYRH7gbIz8';
      case Trainings.painting:
        return '1G6iDwSem_uwJ89Lc84PDEFxqnTfZeJ3udFURDx58qQA';
      case Trainings.vertical_band_saw:
        return '15bTVUIeqsmnhKU75tV285wqc2eqaEUP3zcgmmjfoRRE';
      case Trainings.horizontal_band_saw:
        return '1Jrwlz9VSgXkMCCWBihbm_lfuauhdEQeq-odDpFUt-b8';
      case Trainings.belt_sander:
        return '1DrsjSEoq5ijEbDfuALLs7z6hW8r2gMMOxSnVbCCsgRI';
      case Trainings.injection_molding:
        return '1MYye1UXzf_lPqoC86-_4rPltpH2Wf_RyWNPLFwzKGT8';
      case Trainings.sand_blasting:
        return '1RDMCTve_DgKrUwqBjhWdTRVL2WSUYp01lALviYDl5S4';
      case Trainings.iso:
        return '1Qx4jYj2zOWZ0pDglYOZXRGNdSVt1jtgvKh8YQCWQXjo';
      default:
        return null;
    }
  }

  static OrgStatus getOrgStatusFromString(String? value){
    for(int i = 0; i < OrgStatus.values.length; i++){
      if(OrgStatus.values[i].toString() == value!.replaceAll(' ', '')){
        return OrgStatus.values[i];
      }
    }
    return OrgStatus.none;
  }

  static List<String> op = [
    'fname',
    'lname',
    'address',
    'city',
    'zip',
    'phone',
    'pEmail',
    'kEmail',
    'major'
  ];
  static List<String> standingNames = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior+',
    'Graduate',
    'Non-Applicable',
  ];
  static List<String> teamNames = [
    'Advocacy',
    'Computer Science',
    'Electrical',
    'REU',
    //'Engineering',
    'Game Design',
    'Digital Design',
    'OPAL',
    'Outreach',
    'Research',
    'R&D',
    'Manufacturing',
    'Production',
    'Web Design',
    'Finishing',
    //'Studio Art', //
    'Staff',
    'Quality',
    'NONE'
  ];
  static List<String> trainers = [
    'RidrAZIh7jYOVHllkfYs8wVoykk2',//'John Sparkman'
    'nPIiU7wbg8W6BOXIjtELTSHD4GI3',//'Albert Manero'
    'Jxs989s9TqVrOlr3OtLZNZcGgUI2'
  ];
  static List<String> managersNames = [
    'John Sparkman',
    'Albert Manero',
    'Peter Smith',
    'Matt Dombrowski',
    'Emely Benjamin',
    'Nadia Wilson'
  ];
  static List<DropDownItems> managers = [
    DropDownItems(
      value: 'RidrAZIh7jYOVHllkfYs8wVoykk2', 
      text: 'John Sparkman'
    ),
    DropDownItems(
      value: 'nPIiU7wbg8W6BOXIjtELTSHD4GI3', 
      text: 'Albert Manero'
    ),
    DropDownItems(
      value: 'Fh77ZvY7CxOFDGOI77gOgFUZ3JG3', 
      text: 'Peter Smith'
    ),
    DropDownItems(
      value: 'w2Bkw2987xchVb4NIabeJcWpZzp1', 
      text: 'Matt Dombrowski'
    ),
    DropDownItems(
      value: 'jgBWDTJYV2bRp4xcMcGHaVDqM6G3', 
      text: 'Emely Benjamin'
    ),
    DropDownItems(
      value: 'Jxs989s9TqVrOlr3OtLZNZcGgUI2', 
      text: 'Nadia Wilson'
    ),
  ];
  static List<String> colleges = [
    'Arts and Humanities',
    'Business',
    'Community Innovation and Education',
    'Engineering and Computer Science',
    'Graduate Studies',
    'Health Professions and Sciences',
    'Medicine',
    'Nursing',
    'Optics and Photonics',
    'Sciences',
    'Undergraduate Studies',
    'Hospitality Management'
  ];
  static List<String> collegesABV = [
    'CAH',
    'CBA',
    'CIE',
    'CECS',
    'CGS',
    'CHPS',
    'COM',
    'CON',
    'CREOL',
    'COS',
    'CUS',
    'RCHM'
  ];
  static String getGender(String? gender){
    if(gender == null) return 'Prefer not to say';
    switch (gender) {
      case 'M':
        return 'M';
      case 'Male':
        return 'M';
      case 'F':
        return 'F';
      case 'Female':
        return 'F';
      case 'I':
        return 'I';
      case 'X':
        return 'X';
      default:
        return 'Prefer not to say';
    }
  }
  static String getColleges(String college){
    for(int i = 0; i < colleges.length; i++){
      if(college == colleges[i]){
        return college;
      }
    }
    return 'Hospitality Management';
  }
  static String? getStatus(String? status){
    if(status == null) return null;
    status = status.replaceAll('OrgStatus.', '').toLowerCase();
    switch (status) {
      case 'associate':
        return 'associate';
      case 'graduate':
        return 'graduate';
      case 'assistant':
        return 'assistant';
      case 'admin':
        return 'admin';
      case 'affiliated':
        return 'affiliatedFaculty';
      case 'visitingscholar':
      case 'visiting scholar':
        return 'visitingScholar';
      case 'affiliatedfaculty':
        return 'affiliatedFaculty';
      case 'intern':
        return 'associate';
      case 'scholar':
        return 'assistant';
      case 'bot':
        return 'bot';
      case 'vendor':
        return 'vendor';
      default:
        return 'none';
    }
  }
  static String? getOldStatus(String? status){
    if(status == null) return null;
    status = status.replaceAll('OrgStatus.', '').toLowerCase();
    switch (status) {
      case 'assistant':
        return 'associate';
      case 'intern':
        return 'associate';
      case 'scholar':
        return 'assistant';
      default:
        return null;
    }
  }
  static String getFullManagerName(String first){
    for(int i = 0; i < managersNames.length;i++){
      if(first == managersNames[i].split(' ')[0]){
        return managersNames[i];
      }
    }
    return managersNames[0];
  }
  static String getDeptABV(String dep){
    switch(dep) {
      case 'Computer Science':
        return 'CS';
      case 'Advocacy':
        return 'OR';//'Advo';
      case 'Digital Design':
        return 'Digi';
      case 'Engineering':
        return 'Eng';
      case 'Game Design':
        return 'Game';
      case 'Studio Art':
        return 'Studio';
      case 'Electrical':
        return 'Ele';
      case 'Staff':
        return "Staff";
      case 'Research':
        return "Res";
      case 'R&D':
        return 'R&D';
      case 'Manufacturing':
        return 'Man';
      case 'Production':
        return 'Pro';
      case 'Web Design':
        return 'Web';
      case 'Finishing':
        return 'Finish';
      case 'OPAL':
      case 'Outreach':
        return 'OR';
      case 'Quality':
        return 'Qlt';
      case 'REU':
        return 'REU';
      default:
        return 'NONE';
    }
  }
  static String getDEP(String? abv){
    if(abv == null) return '';
    abv = abv.toLowerCase().replaceAll(' ', '');
    switch(abv) {
      case 'cs':
      case 'computerscience':
        return 'Computer Science';
      case 'admin':
        return 'OPAL';
      case 'electrical':
      case 'ele':
        return 'Electrical';
      case 'digi':
      case 'digitaldesign':
      case 'digitalartist':
      case 'graphicdesign':
      case 'creativedesign':
        return 'Digital Design';
      case 'reu':
        return 'REU';
      case 'eng':
        return 'R&D';
      case 'engineering':
        return 'R&D';
      case 'game':
      case 'games':
        return 'Game Design';
      case 'gamedesign':
        return 'Game Design';
      case 'studio':
      case 'art':
      case 'studioart':
      case 'creativearts':
      case 'visualartist':
      case 'finishing':
      case 'finish':
        return 'Finishing';
      case 'staff':
        return "Staff";
      case 'res':
        return 'Research';
      case 'research':
        return 'Research';
      case 'production':
      case 'pro':
        return 'Production';
      case 'r&d':
        return 'R&D';
      case 'manufacturing':
      case 'man':
        return 'Manufacturing';
      case 'web':
      case 'webdesign':
        return 'Web Design';
      case 'opal':
      case 'or':
      case 'outreach':
      case 'advo':
      case 'advocacy':
      case 'pr':
        return 'Outreach';
      case 'events':
        return 'EVENTS';
      case 'qlt':
      case 'quality':
        return 'Quality';
      default:
        return 'NONE';
    }
  }
  static String depCheck(String badge){
    switch(badge){
      case 'Computer Science':
        return 'computerScience';
      case 'Digital Design':
        return 'graphicDesign';
      case 'Engineering':
        return 'engineering';
      case 'Electrical':
        return 'electrical';
      case 'Game Design':
        return 'gameDesign';
      case 'Studio Art':
        return 'studioArt';
      case 'Research':
        return 'research';
      case 'R&D':
        return 'r&d';
      case 'Manufacturing':
        return 'manufacturing';
      case 'Production':
        return 'production';
      case 'Web Design':
        return 'webdesign';
      case 'Finishing':
        return 'finishing';
      case 'OPAL':
      case 'Outreach':
      case 'Advocacy':
        return 'Outreach'; //'OPAL';
      case 'Quality':
        return 'quality';
      case 'REU':
        return 'reu';
      default:
        return 'NONE';
    }
  }
  static String getStanding(String standing){
    switch(standing) {
      case 'F':
        return 'Freshman';
      case 'S':
        return 'Sophomore';
      case 'J':
        return 'Junior';
      case 'S+':
        return 'Senior+';
      case 'Freshman':
        return 'Freshman';
      case 'Sophomore':
        return 'Sophomore';
      case 'Junior':
        return 'Junior';
      case 'Senior+':
        return 'Senior+';
      case 'Graduate':
        return 'Graduate';
      default:
        return 'Non-Applicable';
    }
  }
  static dynamic getBadgeImage(String dep){
    String stringStart = 'assets/emblems/team/emb_team_';
    switch(dep) {
      case 'Computer Science':
        return {'file': '${stringStart}computerScience_md.png', 'label': 'A cartoon of a computer.'};
      case 'Production':
        return {'file': '${stringStart}production_md.png', 'label': 'A cartoon of a wrench.'};
      case 'Quality':
        return {'file': '${stringStart}quality_md.png', 'label': 'A cartoon of a checklist.'};
      case 'Manufacturing':
        return {'file': '${stringStart}manufacturing_md.png', 'label': 'A cartoon of an assortment of screws.'};
      case 'Finishing':
        return {'file': '${stringStart}finishing_md.png', 'label': 'A cartoon of a robotic hand.'};
      case 'R&D':
        return {'file': '${stringStart}r&d_md.png', 'label': 'A cartoon of a mechanical arm.'};
      case 'Web Design':
        return {'file': '${stringStart}webdesign_md.png', 'label': 'A cartoon of a computer with a paint brush.'};
      case 'Digital Design':
        return {'file': '${stringStart}graphicDesign_md.png', 'label': 'A cartoon of a fountain pen.'};
      case 'Engineering':
        return {'file': '${stringStart}engineering_md.png', 'label': 'A cartoon of an assortment of gears.'};
      case 'Electrical':
        return {'file': '${stringStart}electrical_md.png', 'label': 'A cartoon of an assortment of electronic wires.'};
      case 'Game Design':
        return {'file': '${stringStart}gameDesign_md.png', 'label': 'A cartoon of a joystick controller.'};
      case 'Advocacy':
        return {'file': '${stringStart}advocacy_md.png', 'label': 'A cartoon of a speech bubble with a heart.'};
      case 'OPAL':
        return {'file': '${stringStart}advocacy_md.png', 'label': 'A cartoon of a speech bubble with a heart.'};
      case 'Outreach':
        return {'file': '${stringStart}advocacy_md.png', 'label': 'A cartoon of a speech bubble with a heart.'};
      case 'Studio Art':
        return {'file': '${stringStart}studioArt_md.png', 'label': ''};
      case 'REU':
        return {'file': '${stringStart}reu_md.png', 'label': 'A cartoon of a paper plane.'};
      case 'Research':
        return {'file': '${stringStart}research_md.png', 'label': 'A cartoon of a lab coat.'};
      default:
        return null;
    }
  }

  static dynamic getProgramImage(String status){
    String stringStart = 'assets/emblems/program/emb_program_';
    switch(getStatus(status)) {
      case 'Graduate':
        return {'file': '${stringStart}graduate_md.png', 'label': 'A cartoon of an open book with three sparkels.'};
      case 'Associate':
        return {'file': '${stringStart}associate_md.png', 'label': 'A cartoon of an open book with one sparkels.'};
      default:
        return {'file': '${stringStart}assistant_md.png', 'label': 'A cartoon of an open book.'};
    }
  }
}