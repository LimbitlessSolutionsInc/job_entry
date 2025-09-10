class CardData {
  CardData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.priority,
    this.level,
    this.description,
    this.dueDate,
    this.points,
    this.assigned = const [],
    this.editors = const [],
    this.checkList,
    this.comments,
    this.boardId,
    this.labels,
    this.isRouter = false,
    this.completedDate,
    this.status,
    this.good,
    this.bad,
    this.isApproved,
    this.isArchive,
    this.routers,
  });

  String? title;
  String? dateCreated;
  String? createdBy;
  String? id;
  Map<String,dynamic>? comments;
  Map<String,dynamic>? checkList;
  List<String>? assigned;
  List<String> editors;
  int? points;
  String? dueDate;
  String? description;
  String? boardId;
  int? priority;
  String? level;
  Map<String,dynamic>? labels;
  bool isRouter;
  String? completedDate;
  String? status;
  int? good;
  int? bad;
  bool? isApproved;
  bool? isArchive; // if archieved, should be added to the list of assembilies of this router
  List<CardData>? routers; // list of assembilies for job packet
}