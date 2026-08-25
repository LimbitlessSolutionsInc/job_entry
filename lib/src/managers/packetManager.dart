// Packet Manager - Manages job packets and their routers
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_entry/styles/globals.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/packetData.dart';
import '../data/routerData.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import 'package:uuid/uuid.dart';
import '../organization/organization.dart';

import '../data/orderReceiptData.dart';
import 'routerManager.dart';

String formatDate(String isoDate) {
  if (isoDate.isEmpty) return 'Not set';
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  } catch (e) {
    return isoDate;
  }
}

class PacketManager extends StatefulWidget {
  const PacketManager({
    super.key,
    this.onPacketSelected,
  });

  static List<PacketData> get packets => _PacketManagerState.packets;

  final Function(String packetId)? onPacketSelected;

  @override
  State<PacketManager> createState() => _PacketManagerState();
}

class _PacketManagerState extends State<PacketManager> {
  static const _uuid = Uuid();
  static List<PacketData> packets = [];
  static List<OrderReceipt> receipts = [];
  String? selectedPacketId;

  @override
  void initState() {
    super.initState();
    if (packets.isEmpty) {
      _initializeSampleData();
    }
    if (packets.isNotEmpty) {
      selectedPacketId = packets[0].id;
    }
  }

  void _initializeSampleData() {
    // Sample packet data
    final packet1Id = _uuid.v4();
    final packet2Id = _uuid.v4();

    // Get some router IDs from RouterManager if available
    final availableRouters = RouterManager.routers;
    final routerIds = availableRouters.take(2).map((r) => r.id).toList();

    packets = [
      PacketData(
        id: packet1Id,
        title: 'Sample Packet 1',
        color: 0xFFFF9800,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        routerIds: routerIds.isNotEmpty ? [routerIds.first] : [],
        notes: 'A sample job packet',
      ),
      PacketData(
        id: packet2Id,
        title: 'Sample Packet 2',
        color: 0xFF9C27B0,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        routerIds: [],
        notes: 'Another sample packet',
      ),
    ];
  }

  void _addPacket(
      String title, String notes, int color, List<String> routerIds) {
    setState(() {
      final newPacket = PacketData(
        id: _uuid.v4(),
        title: title,
        color: color,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        routerIds: routerIds,
        notes: notes,
      );
      packets.insert(0, newPacket);
      selectedPacketId = newPacket.id;
    });
  }

  void _editPacket(String id, String title, String notes, int color,
      List<String> routerIds) {
    setState(() {
      final index = packets.indexWhere((p) => p.id == id);
      if (index != -1) {
        packets[index].title = title;
        packets[index].notes = notes;
        packets[index].routerIds = routerIds;
      }
    });
  }

  void _deletePacket(String id) {
    setState(() {
      packets.removeWhere((p) => p.id == id);
      if (selectedPacketId == id && packets.isNotEmpty) {
        selectedPacketId = packets[0].id;
      }
    });
  }

  void _archivePacket(String id) {
    setState(() {
      final index = packets.indexWhere((p) => p.id == id);
      if (index != -1) {
        packets[index].dateArchived = DateTime.now().toIso8601String();
        packets[index].archivedBy = 'testUser';
      }
    });
  }

  void _showCreatePacketDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePacketDialog(
        onSave: (title, notes, color, routerIds) {
          _addPacket(title, notes, color, routerIds);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditPacketDialog(PacketData packet) {
    showDialog(
      context: context,
      builder: (context) => EditPacketDialog(
        packet: packet,
        onSave: (title, notes, color, routerIds) {
          _editPacket(packet.id, title, notes, color, routerIds);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPacketDetailsDialog(PacketData packet) {
    showDialog(
      context: context,
      builder: (context) => PacketDetailsDialog(
        packet: packet,
        onEdit: () {
          Navigator.pop(context);
          _showEditPacketDialog(packet);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(packet.id);
        },
        onArchive: () {
          _archivePacket(packet.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    final packet = packets.firstWhere((p) => p.id == id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Packet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to permanently delete this packet?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(packet.color),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packet.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (packet.routerIds.isNotEmpty)
                          Text(
                            '${packet.routerIds.length} router(s) attached',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deletePacket(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Packet "${packet.title}" deleted'),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _generateOrderReceipt() async {
    final receipt = await showDialog<OrderReceipt>(
      context: context,
      builder: (context) => CreateOrderReceiptDialog(
        availablePackets: packets.where((p) => !p.isArchived).toList(),
        createdBy: currentUser.displayName,
      ),
    );

    if (receipt != null) {
      setState(() {
        receipts.add(receipt);
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${receipt.id.substring(0, 8)} created'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void viewOrderReceipts() {
    showDialog(
      context: context,
      builder: (context) {
        if (receipts.isEmpty) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withOpacity(0.25),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Shipment Orders',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No shipment orders yet',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          );
        }

        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.25),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Shipment Orders',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const CloseButton(),
                      ],
                    ),
                  ),

                  // Receipts list
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: receipts.length,
                          itemBuilder: (context, index) {
                            final receipt = receipts[index];
                            return _buildReceiptListItem(context, receipt);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptListItem(BuildContext context, OrderReceipt receipt) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Order #${receipt.id.substring(0, 8)}'),
        subtitle: Text(
            'Created by ${receipt.createdBy} on ${formatDate(receipt.dateCreated)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: receipt.isShipped
                ? Colors.green.withOpacity(0.16)
                : receipt.isApproved
                    ? Colors.orange.withOpacity(0.16)
                    : receipt.isNeedsReview
                        ? Colors.red.withOpacity(0.16)
                        : Colors.blue.withOpacity(0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            receipt.status,
            style: TextStyle(
              color: receipt.isShipped
                  ? Colors.green
                  : receipt.isApproved
                      ? Colors.orange
                      : receipt.isNeedsReview
                          ? Colors.red
                          : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showReceiptDetailsDialog(context, receipt),
      ),
    );
  }

  void _showReceiptDetailsDialog(BuildContext context, OrderReceipt receipt) {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setStateDialog) => Dialog(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  color: Theme.of(context).cardColor,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .secondaryHeaderColor
                                .withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 32,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Order #${receipt.id.substring(0, 8)}',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                tooltip: 'Export as PDF',
                                onPressed: () =>
                                    _exportReceiptToPdf(context, receipt),
                                iconSize: 28,
                              ),
                              SizedBox(width: 8),
                              const CloseButton(),
                            ],
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Details Section
                              Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow('Created By', receipt.createdBy),
                              _buildDetailRow('Created On',
                                  formatDate(receipt.dateCreated)),
                              _buildDetailRow(
                                'Approved By',
                                receipt.approvedBy.isNotEmpty
                                    ? receipt.approvedBy
                                    : 'Not approved',
                                valueColor: receipt.approvedBy.isNotEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.red,
                              ),
                              _buildDetailRow(
                                'Approved On',
                                receipt.approvedOn.isNotEmpty
                                    ? formatDate(receipt.approvedOn)
                                    : 'TBD',
                                valueColor: receipt.approvedOn.isNotEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.red,
                              ),
                              _buildDetailRow(
                                'Shipped By',
                                receipt.shippedBy.isNotEmpty
                                    ? receipt.shippedBy
                                    : 'Not shipped yet',
                                valueColor: receipt.shippedBy.isNotEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.red,
                              ),
                              _buildDetailRow(
                                'Shipped On',
                                receipt.shippedOn.isNotEmpty
                                    ? formatDate(receipt.shippedOn)
                                    : 'TBD',
                                valueColor: receipt.shippedOn.isNotEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.red,
                              ),
                              _buildDetailRow(
                                'Status',
                                receipt.status,
                                valueColor: receipt.isShipped
                                    ? Colors.green
                                    : receipt.isApproved
                                        ? Colors.orange
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'Included Packets',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),

                              receipt.packetIds.isEmpty
                                  ? Text(
                                      'No packets included',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontStyle: FontStyle.italic),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          receipt.packetIds.map((packetId) {
                                        final packet = packets.firstWhere(
                                          (p) => p.id == packetId,
                                          orElse: () => PacketData(
                                            id: packetId,
                                            title: 'Unknown Packet',
                                            color: 0xFF808080,
                                            dateCreated: '',
                                            createdBy: '',
                                            routerIds: [],
                                            notes: '',
                                          ),
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Text(
                                            '• ${packet.title}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                              const SizedBox(height: 24),

                              // Items section with table
                              Text(
                                'Items',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              receipt.items.isEmpty
                                  ? Text(
                                      'No items',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontStyle: FontStyle.italic),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Item')),
                                          DataColumn(
                                              label: Text('Quantity'),
                                              numeric: true),
                                          DataColumn(label: Text('Notes')),
                                        ],
                                        rows: receipt.items.values.map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(item.name)),
                                              DataCell(Text(
                                                  item.quantity.toString())),
                                              DataCell(Text(
                                                  item.notes.isNotEmpty
                                                      ? item.notes
                                                      : '-')),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),

                              const SizedBox(height: 24),

                              // Status action buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (receipt.isDraft)
                                    ElevatedButton(
                                      onPressed: () {
                                        setStateDialog(() {
                                          receipt.status = 'Needs review';
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColorDark,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text(
                                          'Mark as Ready for Review'),
                                    )
                                  else if (receipt.isNeedsReview)
                                    ElevatedButton(
                                      onPressed:
                                          currentUser.status == OrgStatus.admin
                                              ? () {
                                                  setStateDialog(() {
                                                    receipt.status = 'Approved';
                                                    receipt.approvedBy =
                                                        currentUser.displayName;
                                                    receipt.approvedOn =
                                                        DateTime.now()
                                                            .toIso8601String();
                                                  });
                                                }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentUser.status ==
                                                OrgStatus.admin
                                            ? Theme.of(context).primaryColorDark
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Approve for Shipment'),
                                    )
                                  else if (receipt.isApproved)
                                    ElevatedButton(
                                      onPressed:
                                          currentUser.status == OrgStatus.admin
                                              ? () {
                                                  setStateDialog(() {
                                                    receipt.status = 'Shipped';
                                                    receipt.shippedBy =
                                                        currentUser.displayName;
                                                    receipt.shippedOn =
                                                        DateTime.now()
                                                            .toIso8601String();
                                                  });
                                                }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentUser.status ==
                                                OrgStatus.admin
                                            ? Colors.green
                                            : Colors.grey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Mark as Shipped'),
                                    )
                                  else
                                    Text(
                                      'Order shipped on ${formatDate(receipt.shippedOn)}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Future<void> _exportReceiptToPdf(
      BuildContext context, OrderReceipt receipt) async {
    final includedPackets = _PacketManagerState.packets
        .where((p) => receipt.packetIds.contains(p.id))
        .toList();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header with title and status badge
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Receipt of Shipment',
                    style: pw.TextStyle(
                        fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: receipt.isShipped
                          ? PdfColors.green
                          : receipt.isApproved
                              ? PdfColors.orange
                              : receipt.isNeedsReview
                                  ? PdfColors.red
                                  : PdfColors.blue,
                      width: 2,
                    ),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    receipt.status,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: receipt.isShipped
                          ? PdfColors.green
                          : receipt.isApproved
                              ? PdfColors.orange
                              : receipt.isNeedsReview
                                  ? PdfColors.red
                                  : PdfColors.blue,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('Order Details',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _buildPdfDetailRow('Order ID:', receipt.id),
            _buildPdfDetailRow('Created By:', receipt.createdBy),
            _buildPdfDetailRow(
                'Date Created:', formatDate(receipt.dateCreated)),
            _buildPdfDetailRow(
                'Approved By:',
                receipt.approvedBy.isNotEmpty
                    ? receipt.approvedBy
                    : 'Not approved'),
            _buildPdfDetailRow(
                'Approved On:',
                receipt.approvedOn.isNotEmpty
                    ? formatDate(receipt.approvedOn)
                    : 'TBD'),
            _buildPdfDetailRow(
                'Shipped By:',
                receipt.shippedBy.isNotEmpty
                    ? receipt.shippedBy
                    : 'Not shipped yet'),
            _buildPdfDetailRow(
                'Shipped On:',
                receipt.shippedOn.isNotEmpty
                    ? formatDate(receipt.shippedOn)
                    : 'TBD'),
            pw.SizedBox(height: 24),

            pw.Text('Included Packets',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (includedPackets.isEmpty)
              pw.Text('No packets included', style: pw.TextStyle(fontSize: 12))
            else
              pw.Column(
                children: includedPackets.map((packet) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Bullet(
                      text: packet.title,
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 24),
            pw.Text('Items',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            receipt.items.isEmpty
                ? pw.Text('No items', style: pw.TextStyle(fontSize: 12))
                : pw.Table.fromTextArray(
                    headers: ['Quantity', 'Description', 'Notes'],
                    data: receipt.items.values.map((item) {
                      return [
                        item.quantity.toString(),
                        item.name,
                        item.notes.isNotEmpty ? item.notes : '-'
                      ];
                    }).toList(),
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                      fontSize: 12,
                    ),
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey200,
                    ),
                    cellAlignment: pw.Alignment.centerLeft,
                    cellStyle: pw.TextStyle(fontSize: 11),
                  ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildPdfDetailCell(String value) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(value, style: pw.TextStyle(fontSize: 12)),
      );

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 100,
              child: pw.Text(label,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.Expanded(
              child: pw.Text(value, style: pw.TextStyle(fontSize: 12)),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePackets = packets.where((p) => !p.isArchived).toList();

    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColorLight,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreatePacketDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Packet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Packet list
          Expanded(
            child: activePackets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No job packets yet',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a packet to get started',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activePackets.length,
                    itemBuilder: (context, index) {
                      final packet = activePackets[index];
                      final isSelected = packet.id == selectedPacketId;

                      return PacketCard(
                        packet: packet,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => selectedPacketId = packet.id);
                          widget.onPacketSelected?.call(packet.id);
                          _showPacketDetailsDialog(packet);
                        },
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _generateOrderReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(260, 54),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                  ),
                  child: const Text(
                    'Generate Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: viewOrderReceipts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(260, 54),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                  ),
                  child: const Text(
                    'View Receipts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Packet Card Widget
class PacketCard extends StatelessWidget {
  const PacketCard({
    super.key,
    required this.packet,
    required this.isSelected,
    required this.onTap,
  });

  final PacketData packet;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routerCount = packet.routerIds.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Color(packet.color),
          width: isSelected ? 3 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(width: 16),

              // Packet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packet.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (packet.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        packet.notes,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Packet Details Dialog
class PacketDetailsDialog extends StatelessWidget {
  const PacketDetailsDialog({
    super.key,
    required this.packet,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  final PacketData packet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  void _showRouterDetails(BuildContext context, RouterData router) {
    RouterManagerState.showRouterDetails(context, router);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routers = RouterManager.routers
        .where((r) => packet.routerIds.contains(r.id))
        .toList();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            packet.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CloseButton(
                            onPressed: () => Navigator.pop(context),
                          ),
                        ]),
                    if (packet.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        packet.notes,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Routers section
                    Text(
                      'Routers in this Packet',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (routers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'No routers in this packet',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...routers.map((router) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(router.title),
                              subtitle: Text(
                                  'Created ${_formatDate(router.dateCreated)}'),
                              trailing: TextButton.icon(
                                onPressed: () =>
                                    _showRouterDetails(context, router),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text('View'),
                              ),
                            ),
                          )),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // OutlinedButton.icon(
                            //   onPressed: onDelete,
                            //   icon: const Icon(Icons.delete_outline),
                            //   label: const Text('Delete'),
                            //   style: OutlinedButton.styleFrom(
                            //     foregroundColor: Colors.red,
                            //     side: const BorderSide(color: Colors.red),
                            //   ),
                            // ),
                            // const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: onArchive,
                              icon: const Icon(Icons.archive_outlined),
                              label: const Text('Archive'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColorDark,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

// Create Packet Dialog
class CreatePacketDialog extends StatefulWidget {
  const CreatePacketDialog({
    super.key,
    required this.onSave,
  });

  final Function(String title, String notes, int color, List<String> routerIds)
      onSave;

  @override
  State<CreatePacketDialog> createState() => _CreatePacketDialogState();
}

class _CreatePacketDialogState extends State<CreatePacketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  Color _selectedColor = Colors.lightBlueAccent;
  List<String> _selectedRouterIds = [];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.redAccent,
    Colors.lime,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableRouters =
        RouterManager.routers.where((r) => r.dateArchived.isEmpty).toList();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Job Packet',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Title',
                    style: theme.textTheme.titleMedium,
                  ),
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Packet Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Notes',
                    style: theme.textTheme.titleMedium,
                  ),
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Color picker
                  Text(
                    'Color',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final color = _availableColors[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(color: Colors.black, width: 3.0)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Router selection
                  Text(
                    'Add Routers (optional)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (availableRouters.isEmpty)
                    Text(
                      'No routers available',
                      style:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableRouters.length,
                        itemBuilder: (context, index) {
                          final router = availableRouters[index];
                          final isSelected =
                              _selectedRouterIds.contains(router.id);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedRouterIds.add(router.id);
                                } else {
                                  _selectedRouterIds.remove(router.id);
                                }
                              });
                            },
                            title: Text(router.title),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSave(
                              _titleController.text.trim(),
                              _notesController.text.trim(),
                              _selectedColor.value,
                              _selectedRouterIds,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorDark,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Edit Packet Dialog
class EditPacketDialog extends StatefulWidget {
  const EditPacketDialog({
    super.key,
    required this.packet,
    required this.onSave,
  });

  final PacketData packet;
  final Function(
          String title, String description, int color, List<String> routerIds)
      onSave;

  @override
  State<EditPacketDialog> createState() => _EditPacketDialogState();
}

class _EditPacketDialogState extends State<EditPacketDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late Color _selectedColor;
  late List<String> _selectedRouterIds;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.redAccent,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.packet.title);
    _notesController = TextEditingController(text: widget.packet.notes);
    _selectedColor = Color(widget.packet.color);
    _selectedRouterIds = List.from(widget.packet.routerIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableRouters =
        RouterManager.routers.where((r) => r.dateArchived.isEmpty).toList();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.25),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit Job Packet',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Packet Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableColors.map((color) {
                          final isSelected = color == _selectedColor;
                          return InkWell(
                            onTap: () => setState(() => _selectedColor = color),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Routers in Packet',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (availableRouters.isEmpty)
                        Text(
                          'No routers available',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableRouters.length,
                            itemBuilder: (context, index) {
                              final router = availableRouters[index];
                              final isSelected =
                                  _selectedRouterIds.contains(router.id);

                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedRouterIds.add(router.id);
                                    } else {
                                      _selectedRouterIds.remove(router.id);
                                    }
                                  });
                                },
                                title: Text(router.title),
                                secondary: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color(router.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                widget.onSave(
                                  _titleController.text.trim(),
                                  _notesController.text.trim(),
                                  _selectedColor.value,
                                  _selectedRouterIds,
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Update Packet'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateOrderReceiptDialog extends StatefulWidget {
  const CreateOrderReceiptDialog({
    super.key,
    required this.availablePackets,
    required this.createdBy,
  });

  final List<PacketData> availablePackets;
  final String createdBy;

  @override
  State<CreateOrderReceiptDialog> createState() =>
      _CreateOrderReceiptDialogState();
}

class _CreateOrderReceiptDialogState extends State<CreateOrderReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newItemNameController = TextEditingController();
  final _newItemQtyController = TextEditingController();
  final _newItemNotesController = TextEditingController();

  List<String> _selectedPacketIds = [];
  List<OrderItem> _items = [];

  @override
  void dispose() {
    _newItemNameController.dispose();
    _newItemQtyController.dispose();
    _newItemNotesController.dispose();
    super.dispose();
  }

  void _addItem() {
    final itemName = _newItemNameController.text.trim();
    final qty = int.tryParse(_newItemQtyController.text.trim());

    setState(() {
      _items.add(OrderItem(
        id: Uuid().v4(),
        name: itemName,
        quantity: qty ?? 0,
        notes: _newItemNotesController.text.trim(),
      ));
      _newItemNameController.clear();
      _newItemQtyController.clear();
      _newItemNotesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateCreated = DateTime.now().toIso8601String();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.25),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create Order',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Packets in Order',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      widget.availablePackets.isEmpty
                          ? Text('No packets available',
                              style: theme.textTheme.bodyMedium)
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 180),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.colorScheme.outline),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.availablePackets.length,
                                itemBuilder: (context, index) {
                                  final packet = widget.availablePackets[index];
                                  final isSelected =
                                      _selectedPacketIds.contains(packet.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(packet.title),
                                    subtitle: packet.notes.isNotEmpty
                                        ? Text(packet.notes)
                                        : null,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedPacketIds.add(packet.id);
                                        } else {
                                          _selectedPacketIds.remove(packet.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 24),

                      // Items Section
                      Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._items.map((item) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text('${item.name} (x${item.quantity})'),
                              subtitle: Text(item.notes.isNotEmpty
                                  ? item.notes
                                  : 'No notes'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() => _items.remove(item));
                                },
                              ),
                              tileColor: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(0.1),
                            ),
                          )),

                      SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Item',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _newItemNameController,
                              decoration: InputDecoration(
                                hintText: 'Enter item name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newItemQtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Quantity',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _newItemNotesController,
                                    decoration: InputDecoration(
                                      hintText: 'Notes (optional)',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _addItem,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColorDark,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Add Item'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;

                              final receipt = OrderReceipt(
                                id: Uuid().v4(),
                                dateCreated: dateCreated,
                                createdBy: widget.createdBy,
                                packetIds: List.from(_selectedPacketIds),
                                status: 'Draft',
                                approvedBy: '',
                                approvedOn: '',
                                shippedBy: '',
                                shippedOn: '',
                                items: {for (var item in _items) item.id: item},
                              );

                              Navigator.pop(context, receipt);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).primaryColorDark,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
