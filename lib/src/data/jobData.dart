enum JobStatus {
  notStarted,
  partsReceived,
  inProgress,
  completed,
  skipped,
}

class JobData {
  JobData({
    required this.id,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.processId,
    required this.priority,
    required this.dueDate,
    required this.completeDate,
    required this.startDate,
    required this.partsReceivedDate,
    this.workers = const [],
    this.partsReceivedBy = const [],
    required this.notes,
    required this.status,
    required this.good,
    required this.bad,
    this.numApprovals = 2, // default to 2 approvals needed //will need to double check this later -nlw
    this.approvers = const [],
    //this.prevJobs,
  });

  String title;
  String dateCreated;
  String createdBy;
  String id;
  List<String> workers;
  List<String> partsReceivedBy;
  List<String> approvers;
  String dueDate;
  String startDate;
  Map<String, dynamic> notes;
  String processId;
  String priority;
  String completeDate;
  String partsReceivedDate;
  JobStatus status;
  int good;
  int bad;
  int numApprovals;
  //Map<String, dynamic>? prevJobs;
}