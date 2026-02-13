class RouterModel {
  RouterModel({
    required this.title,
    required this.process,
    required this.color,
    required this.isArchived,
    this.clearJobs = false,
  });

  final String title;
  final String process;
  final int color;
  final bool isArchived;
  final bool clearJobs;
}