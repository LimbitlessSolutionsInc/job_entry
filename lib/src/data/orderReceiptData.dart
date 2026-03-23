import 'package:flutter/foundation.dart';

class OrderItem {
  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.notes = '',
  });

  final String id;
  String name;
  int quantity;
  String notes;
}

class OrderReceipt {
  OrderReceipt({
    required this.id,
    required this.dateCreated,
    required this.createdBy,
    required this.packetIds,
    required this.items,
    this.shippedBy = 'Pending',
    this.status = 'Pending',
  });

  final String id;
  String dateCreated;
  String createdBy;
  List<String> packetIds;
  String shippedBy;
  String status;
  Map<String, OrderItem> items;

  bool get isShipped => shippedBy.isNotEmpty && shippedBy.toLowerCase() != 'pending';
}
