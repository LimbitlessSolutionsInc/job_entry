class JobModel {
  JobModel({
    required this.title,
    this.workers,
    this.approvers,
    this.dueDate,
    this.startDate,
    this.notes,
    this.priority,
    this.completeDate,
    required this.status,
    required this.good,
    required this.bad,
  });

  final String title;
  List<String>? workers;
  List<String>? approvers;
  String? dueDate;
  String? startDate;
  Map<String, dynamic>? notes;
  int? priority;
  String? completeDate;
  final dynamic status;
  final int good;
  final int bad;
}