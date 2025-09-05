class CardData {
  CardData({
    this.title,
    this.startDate,
    this.endDate,
    this.reqDate,
    this.createdBy,
    this.id,
    this.status,
    this.workers = const [],
    this.editors = const [],
    this.notes,
    this.boardId,
    this.approve = false,
    this.goodCount,
    this.badCount,
    this.archive = false,
    this.assembilies,
  });

  String? title;
  final String? startDate;
  final String? endDate;
  final String? reqDate;
  final String? createdBy;
  final String? id;
  final String? status;
  Map<String,dynamic>? notes;
  List<String> workers;
  List<String> editors;
  String? boardId;
  int? priority;
  int? goodCount;
  int? badCount;
  final bool approve;
  final bool archive;
  List<CardData>? assembilies;
}