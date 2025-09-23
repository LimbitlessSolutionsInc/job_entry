class ProjectData {
  ProjectData({
    required this.color,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    this.department,
    required this.id,
    this.dueDate,
    this.isQualityCheck = false,
  });

  final int color;
  String title;
  final String dateCreated;
  final String? dueDate;
  final String createdBy;
  final String? department;
  final String id;
  bool isQualityCheck; // if false, is just a task project
}