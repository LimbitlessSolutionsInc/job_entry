import 'package:job_entry/src/data/cardData.dart';

class RouterData extends CardData {
  RouterData({
    this.completedDate,
    this.status,
    this.good,
    this.bad,
    this.isApproved,
    this.isArchive,
    this.routers,
  }) : super();

  String? completedDate;
  String? status;
  int? good;
  int? bad;
  bool? isApproved;
  bool? isArchive;
  List<RouterData>? routers;
}