import 'package:job_entry/src/data/boardData.dart';

class AssemblyData extends BoardData {
  AssemblyData({
    this.index,
    this.isArchive,
  }) : super();
  
  int? index;
  bool? isArchive;
}