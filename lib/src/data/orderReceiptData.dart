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
    this.approvedBy = '',
    this.approvedOn = '',
    this.shippedBy = '',
    this.shippedOn = '',
    this.status = 'draft',
  });

  final String id;
  String dateCreated;
  String createdBy;
  List<String> packetIds;
  String approvedBy;
  String approvedOn;
  String shippedBy;
  String shippedOn;
  String status;
  Map<String, OrderItem> items;

  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isNeedsReview => status.toLowerCase() == 'needs review';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isShipped => status.toLowerCase() == 'shipped';
}

