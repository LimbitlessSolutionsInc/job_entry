class Emblems{
  static String getEmblemLocation(String name, String size){
    for(int i = 0; i < teamEmblems.length;i++){
      String start = 'assets/emblems/team/emb_';
      if(teamEmblems[i] == name){
        return start+'team_'+name+'_'+size+'.png';
      }
    }
    for(int i = 0; i < programEmblems.length;i++){
      String start = 'assets/emblems/program/emb_';
      if(programEmblems[i] == name){
        return start+'program_'+name+'_'+size+'.png';
      }
    }
    for(int i = 0; i < semesterEmblems.length;i++){
      String start = 'assets/emblems/semester/emb_';
      if(semesterEmblems[i] == name){
        return start+'semester_'+name+'_'+size+'.svg';
      }
    }
    for(int i = 0; i < specialEmblems.length;i++){
      String start = 'assets/emblems/special/emb_';
      if(specialEmblems[i] == name){
        return start+'special_'+name+'_'+size+'.svg';
      }
    }
    for(int i = 0; i < trainingEmblems.length;i++){
      String start = 'assets/emblems/training/emb_';
      if(trainingEmblems[i] == name){
        return start+name+'_'+size+'.png';
      }
    }
    return '';
  }
  static String getYearBadgeName(String year){
    String send = year.split('_')[1];
    return send.replaceFirst(send[0], send[0].toUpperCase());
  }
  static List<String> emblemSize = [
    'sm',
    'md',
    'lg'
  ];
  static List<String> embLoc = [
    'semester',
    'program',
    'special',
    'training',
    'team',
  ];
  static List<List<String>> allEmblems = [
    semesterEmblems,
    programEmblems,
    specialEmblems,
    trainingEmblems,
    teamEmblems
  ];
  static List<String> trainingEmblems = [
    'thermoform',
    'tanks',
    'painting',
    'laser_safety',
    'mill',
    'lathe',
    'citi',
    'belt_sander',
    'horizontal_band_saw',
    'vertical_band_saw',
    'printer_3d', 
    'iso',
    'hand_tools',
    'soldering',
    'auditor',
    'auditor_trainer'
  ];
  static List<String> specialEmblems = [
    'grad',
    'honors'
  ];
  static List<String> teamEmblems = [
    'advocacy',
    'computerScience',
    'electrical',
    'r&d',
    'production',
    'manufacturing',
    'finishing',
    'engineering',
    'gameDesign',
    'graphicDesign',
    'research',
    'webdesign',
    'quality',
    'reu'
  ];
  static List<String> programEmblems = [
    'assistant',
    'associate',
    'graduate'
  ];
  static List<String> semesterEmblems = [
    '1_welcome',
    '2_beginner',
    '3_apprentice',
    '4_intermediate',
    '5_accomplished',
    '6_expert',
    '7_master',
    '8_grandmaster',
    '9_grandmaster',
    '10_legend',
    '11_legend',
    '12_legend',
  ];
}