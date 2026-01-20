class ProcessData {
  ProcessData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.routerId,
    this.order,
    this.color,
    this.notify = false
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
  final String? routerId;
  int? order;
  final bool notify;
  final int? color;
}