class RouterData {
  RouterData({
    required this.color,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.id,
    required this.processId,
    this.dateArchived = '',
    this.archivedBy = '',
  });

  final int color;
  String title;
  final String dateCreated;
  final String createdBy;
  final String id;
  final String processId;
  String dateArchived;
  String archivedBy;

  copyWith({required String title}) {}
}