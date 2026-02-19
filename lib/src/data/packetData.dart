class PacketData {
  PacketData({
    required this.id,
    required this.title,
    required this.dateCreated,
    required this.createdBy,
    required this.color,
    this.routerIds = const [],
    this.dateArchived = '',
    this.archivedBy = '',
    this.notes = '',
  });

  final String id;
  String title;
  final String dateCreated;
  final String createdBy;
  final int color;
  List<String> routerIds; // List of router IDs in this packet
  String dateArchived;
  String archivedBy;
  String notes;

  bool get isArchived => dateArchived.isNotEmpty;
}
