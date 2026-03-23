// Packet Manager - Manages job packets and their routers
import 'package:flutter/material.dart';
import 'package:job_entry/styles/globals.dart';
import '../data/packetData.dart';
import '../data/routerData.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import 'package:uuid/uuid.dart';

import '../data/orderReceiptData.dart';
import 'routerManager.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt ${receipt.id} created.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePackets = packets.where((p) => !p.isArchived).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _showCreatePacketDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Packet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: css.darkBlue,
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a packet to get started',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          padding: const EdgeInsets.only(bottom: 24.0), // push button higher in the layout
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _generateOrderReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: css.darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(260, 54), // larger width and height
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                ),
                child: const Text(
                  'Generate Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                ),
              )
            ],
          ),
        )
      ],
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
                      ]
                    ),
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
                                backgroundColor: css.darkBlue,
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
                          backgroundColor: css.darkBlue,
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
        constraints: const BoxConstraints(maxWidth: 600),
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
                    'Edit Job Packet',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
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
                    style: theme.textTheme.titleMedium,
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Save'),
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

class CreateOrderReceiptDialog extends StatefulWidget {
  const CreateOrderReceiptDialog({
    super.key,
    required this.availablePackets,
    required this.createdBy,
  });

  final List<PacketData> availablePackets;
  final String createdBy;

  @override
  State<CreateOrderReceiptDialog> createState() => _CreateOrderReceiptDialogState();
}

class _CreateOrderReceiptDialogState extends State<CreateOrderReceiptDialog> {
  final _formKey = GlobalKey<FormState>();
  final _shippedByController = TextEditingController(text: 'Pending');
  final _newItemNameController = TextEditingController();
  final _newItemQtyController = TextEditingController();
  final _newItemNotesController = TextEditingController();

  List<String> _selectedPacketIds = [];
  List<OrderItem> _items = [];

  @override
  void dispose() {
    _shippedByController.dispose();
    _newItemNameController.dispose();
    _newItemQtyController.dispose();
    _newItemNotesController.dispose();
    super.dispose();
  }

  void _addItem() {
    final itemName = _newItemNameController.text.trim();
    final qty = int.tryParse(_newItemQtyController.text.trim());

    if (itemName.isEmpty || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid name and quantity')),
      );
      return;
    }

    setState(() {
      _items.add(OrderItem(
        id: Uuid().v4(),
        name: itemName,
        quantity: qty,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: css.CSS.lsiTheme.secondaryHeaderColor.withOpacity(0.1),
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
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create Order',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
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
                      // Date Created
                      // Text(
                      //   'Date Created',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //     color: css.darkGrey,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // TextFormField(
                      //   readOnly: true,
                      //   initialValue: dateCreated,
                      //   decoration: InputDecoration(
                      //     hintText: 'Date created',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 14,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),

                      // Created By

                      // Shipped By
                      // Text(
                      //   'Shipped By (admin)',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //     color: css.darkGrey,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // TextFormField(
                      //   controller: _shippedByController,
                      //   decoration: InputDecoration(
                      //     hintText: 'Enter admin name or Pending',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 14,
                      //     ),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.trim().isEmpty) {
                      //       return 'Enter admin shipped-by name or Pending';
                      //     }
                      //     return null;
                      //   },
                      // ),

                      // Included Packets Section
                      Text(
                        'Job Packets in Order',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      widget.availablePackets.isEmpty
                          ? Text('No packets available', style: theme.textTheme.bodyMedium)
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 180),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.colorScheme.outline),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.availablePackets.length,
                                itemBuilder: (context, index) {
                                  final packet = widget.availablePackets[index];
                                  final isSelected = _selectedPacketIds.contains(packet.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(packet.title),
                                    subtitle: packet.notes.isNotEmpty ? Text(packet.notes) : null,
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
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ..._items.map((item) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text('${item.quantity} x ${item.name}'),
                              subtitle: Text(item.notes.isNotEmpty ? item.notes : 'No notes'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() => _items.remove(item));
                                },
                              ),
                            ),
                          )),

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
                                color: css.darkGrey,
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
                                      contentPadding: const EdgeInsets.symmetric(
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
                                      contentPadding: const EdgeInsets.symmetric(
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
                                  backgroundColor: css.darkBlue,
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
                              if (_selectedPacketIds.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Select at least one packet')),
                                );
                                return;
                              }
                              if (_items.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Add at least one item')),
                                );
                                return;
                              }

                              final receipt = OrderReceipt(
                                id: Uuid().v4(),
                                dateCreated: dateCreated,
                                createdBy: widget.createdBy,
                                packetIds: List.from(_selectedPacketIds),
                                shippedBy: _shippedByController.text.trim(),
                                items: {for (var item in _items) item.id: item},
                              );

                              Navigator.pop(context, receipt);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: css.darkBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Receipt'),
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

