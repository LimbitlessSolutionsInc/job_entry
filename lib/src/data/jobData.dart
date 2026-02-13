enum JobStatus {
  notStarted,
  inProgress,
  completed,
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
    this.workers = const [],
    required this.notes,
    required this.status,
    required this.good,
    required this.bad,
    this.numApprovals = 2, // default to 2 approvals needed //will need to double check this later -nlw
    this.isApproved = const [],
    this.approvers = const [],
    //this.prevJobs,
  });

  // factory JobData.fromPrevious(JobData oldJob) {
  //   return JobData(
  //     title: oldJob.title,
  //     description: oldJob.description,
  //     dateCreated: DateTime.now().toIso8601String(),
  //     dueDate: oldJob.dueDate,
  //     startDate: oldJob.startDate,
  //     createdBy: oldJob.createdBy,
  //     processId: oldJob.processId,
  //     notes: oldJob.notes,
  //     status: JobStatus.notStarted,
  //     good: oldJob.good,
  //     bad: 0,
  //     workers: oldJob.workers,
  //     approvers: oldJob.approvers,
  //     isArchive: false,
  //     prevJobs: oldJob.prevJobs,
  //   );
  // }

  String title;
  String dateCreated;
  String createdBy;
  String id;
  List<String> workers;
  List<String> approvers;
  String dueDate;
  String startDate;
  Map<String, dynamic> notes;
  String processId;
  int priority;
  String completeDate;
  JobStatus status;
  int good;
  int bad;
  int numApprovals;
  List<String> isApproved;
  //Map<String, dynamic>? prevJobs;
}