class ProcessData {
  ProcessData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.index,
    this.color,
    this.notify = false
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
  int? index;
  final bool notify;
  final int? color;
}