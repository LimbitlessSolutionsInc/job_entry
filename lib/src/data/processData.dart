class ProcessData {
  ProcessData({
    this.title,
    this.dateCreated,
    this.createdBy,
    this.id,
    this.routerId,
    this.order,
    this.notify = false,
    required this.processType,
  });

  String? title;
  final String? dateCreated;
  final String? createdBy;
  final String? id; 
  final String? routerId;
  int? order;
  final bool notify;
  final String processType; // Process type/template name (e.g., "Core Parts", "Cosmetic Sleeves")
}