enum JobStatus {
  notStarted,
  inProgress,
  completed,
}

class JobData {
  JobData({
    this.id,
    this.title,
    this.dateCreated,
    this.createdBy,
    this.processId,
    this.dueDate,
    this.completeDate,
    this.workers = const [],
    this.notes,
    this.status,
    this.good,
    this.bad,
    this.numApprovals = 2, // default to 2 approvals needed
    this.isApproved = false,
    this.isArchive = false,
    this.approvers = const [],
    this.prevJobs,
  });

  factory JobData.fromPrevious(JobData oldJob) {
    return JobData(
      title: oldJob.title,
      dateCreated: DateTime.now().toIso8601String(),
      createdBy: oldJob.createdBy,
      processId: oldJob.processId,
      notes: oldJob.notes,
      status: JobStatus.notStarted,
      good: oldJob.good,
      bad: 0,
      workers: oldJob.workers,
      approvers: oldJob.approvers,
      isApproved: false,
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
  Map<String, dynamic>? notes;
  String? processId;
  String? completeDate;
  JobStatus? status;
  int? good;
  int? bad;
  int numApprovals;
  bool isApproved;
  bool isArchive;
  Map<String, dynamic>? prevJobs;
}