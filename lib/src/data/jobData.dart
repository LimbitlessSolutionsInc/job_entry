enum JobStatus {
  notStarted,
  inProgress,
  completed,
}

class JobData {
  JobData({
    this.id,
    this.title,
    this.description,
    this.dateCreated,
    this.createdBy,
    this.processId,
    this.priority,
    this.dueDate,
    this.completeDate,
    this.startDate,
    this.workers = const [],
    this.notes,
    this.status,
    this.good,
    this.bad,
    this.numApprovals = 2, // default to 2 approvals needed //will need to double check this later -nlw
    this.isApproved = const [],
    this.isArchive = false,
    this.approvers = const [],
    this.prevJobs,
  });

  factory JobData.fromPrevious(JobData oldJob) {
    return JobData(
      title: oldJob.title,
      description: oldJob.description,
      dateCreated: DateTime.now().toIso8601String(),
      dueDate: oldJob.dueDate,
      startDate: oldJob.startDate,
      createdBy: oldJob.createdBy,
      processId: oldJob.processId,
      notes: oldJob.notes,
      status: JobStatus.notStarted,
      good: oldJob.good,
      bad: 0,
      workers: oldJob.workers,
      approvers: oldJob.approvers,
      isArchive: false,
      prevJobs: oldJob.prevJobs,
    );
  }

  String? title;
  String? dateCreated;
  String? createdBy;
  String? id;
  String? description;
  List<String> workers;
  List<String> approvers;
  String? dueDate;
  String? startDate;
  Map<String, dynamic>? notes;
  String? processId;
  int? priority;
  String? completeDate;
  JobStatus? status;
  int? good;
  int? bad;
  int numApprovals;
  List<String> isApproved;
  bool isArchive;
  Map<String, dynamic>? prevJobs;
}