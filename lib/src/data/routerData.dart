class RouterData {
  RouterData({
    required this.color,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.id,
    this.dateArchived = '',
    this.archivedBy = '',
  });

  final int color;
  String title;
  final String dateCreated;
  final String createdBy;
  final String id;
  String dateArchived;
  String archivedBy;
}