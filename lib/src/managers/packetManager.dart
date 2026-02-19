// Packet Manager - Manages job packets and their routers
import 'package:flutter/material.dart';
import '../data/packetData.dart';
import '../data/routerData.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import 'package:uuid/uuid.dart';
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

  void _addPacket(String title, String notes, int color, List<String> routerIds) {
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

  void _editPacket(String id, String title, String notes, int color, List<String> routerIds) {
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
            const SizedBox(width: 12),
            const Text('Delete Packet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to permanently delete this packet?'),
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                    Text(
                      packet.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                              subtitle: Text('Created ${_formatDate(router.dateCreated)}'),
                              trailing: TextButton.icon(
                                onPressed: () => _showRouterDetails(context, router),
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
                            OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: onArchive,
                              icon: const Icon(Icons.archive_outlined),
                              label: const Text('Archive'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
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

  final Function(String title, String notes, int color, List<String> routerIds) onSave;

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
    final availableRouters = RouterManager.routers.where((r) => r.dateArchived.isEmpty).toList();

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
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                          final isSelected = _selectedRouterIds.contains(router.id);
                          
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
  final Function(String title, String description, int color, List<String> routerIds) onSave;

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
    final availableRouters = RouterManager.routers.where((r) => r.dateArchived.isEmpty).toList();

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
                              color: isSelected ? Colors.white : Colors.transparent,
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
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
                          final isSelected = _selectedRouterIds.contains(router.id);
                          
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
