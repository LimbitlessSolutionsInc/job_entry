class BoardData {
  BoardData({
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.id,
    this.priority,
    this.color,
    this.archive = false,
    this.notify = false
  });

  String title;
  final String dateCreated;
  final String createdBy;
  final String id;
  int? priority;
  final int? color;
  final bool archive;
  final bool notify;
}