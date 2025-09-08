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
    this.labels
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
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
}