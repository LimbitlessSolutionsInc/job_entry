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
    this.isApproved,
    this.isArchive,
    this.approvers,
    this.jobs,
  });

  String? title;
  String? dateCreated;
  String? createdBy;
  String? id;
  List<String> workers;
  List<String>? approvers;
  String? dueDate;
  Map<String, dynamic>? notes;
  String? processId;
  String? completeDate;
  String? status;
  int? good;
  int? bad;
  bool? isApproved;
  bool? isArchive; // if archived, should be added to the list of assembilies of this router
  List<String>? jobs; // list of assembilies for job packet but id of the job
}