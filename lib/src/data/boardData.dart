class BoardData {
  BoardData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.priority,
    this.color,
    this.notify = false,
    this.isAssembly = false,
    this.index,
    this.isArchive
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
  int? priority;
  final int? color;
  final bool? notify;
  bool isAssembly;
  int? index; // order of the board for the assembly order
  bool? isArchive;
}