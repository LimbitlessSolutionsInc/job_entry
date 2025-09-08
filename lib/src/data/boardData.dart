class BoardData {
  BoardData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.priority,
    this.color,
    this.notify = false
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
  int? priority;
  final int? color;
  final bool? notify;
}