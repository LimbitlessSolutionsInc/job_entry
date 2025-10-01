class ProcessData {
  ProcessData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.isArchive = false,
    required this.index,
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id;
  bool isArchive;
  int index;
}