import 'package:flutter/material.dart';
import '../src/organization/organization.dart';
import '../styles/globals.dart';
import 'package:css/css.dart' as css;
import 'src/data/routerData.dart';
import 'src/data/packetData.dart';
import 'src/managers/routerManager.dart';
import 'src/managers/packetManager.dart';
import 'src/example/routerCard.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String? selectedRouterId;
  String? selectedPacketId;

  // Public method to refresh data when tab is switched
  void refreshData() {
    if (mounted) {
      setState(() {
        debugPrint('Archive page refreshed via refreshData()');
      });
    }
  }

  // Get archived routers from the shared static list
  List<RouterData> get archivedRouters {
    return RouterManager.routers
        .where((router) => router.dateArchived.isNotEmpty)
        .toList();
  }

  // Get archived packets from the shared static list
  List<PacketData> get archivedPackets {
    final allPackets = PacketManager.packets;
    debugPrint('Total packets in PacketManager: ${allPackets.length}');
    for (var packet in allPackets) {
      debugPrint('Packet: ${packet.title}, dateArchived: "${packet.dateArchived}", isArchived: ${packet.isArchived}');
    }
    final archived = allPackets.where((packet) => packet.isArchived).toList();
    debugPrint('Filtered archived packets: ${archived.length}');
    return archived;
  }

  // Delete a router permanently from the list
  void _deleteRouter(int index) {
    final archivedList = archivedRouters;
    final routerToDelete = archivedList[index];
    
    setState(() {
      RouterManager.routers.removeWhere((r) => r.id == routerToDelete.id);
      if (selectedRouterId == routerToDelete.id) {
        selectedRouterId = null;
      }
    });
    
    debugPrint('Permanently deleted router: ${routerToDelete.title}');
  }

  // Unarchive a router (clears archive date)
  void _unarchiveRouter(int index) {
    final archivedList = archivedRouters;
    final routerToUnarchive = archivedList[index];
    final actualIndex = RouterManager.routers.indexOf(routerToUnarchive);
    
    setState(() {
      RouterManager.routers[actualIndex] = RouterData(
        id: routerToUnarchive.id,
        title: routerToUnarchive.title,
        color: routerToUnarchive.color,
        dateCreated: routerToUnarchive.dateCreated,
        createdBy: routerToUnarchive.createdBy,
        processId: routerToUnarchive.processId,
        processType: routerToUnarchive.processType,
        connectedRouters: routerToUnarchive.connectedRouters,
        dateArchived: '',
        archivedBy: '',
      );
      if (selectedRouterId == routerToUnarchive.id) {
        selectedRouterId = null;
      }
    });
    
    debugPrint('Unarchived router: ${routerToUnarchive.title}');
  }

  // Delete a packet permanently from the list
  void _deletePacket(int index) {
    final archivedList = archivedPackets;
    final packetToDelete = archivedList[index];
    
    setState(() {
      PacketManager.packets.removeWhere((p) => p.id == packetToDelete.id);
      if (selectedPacketId == packetToDelete.id) {
        selectedPacketId = null;
      }
    });
    
    debugPrint('Permanently deleted packet: ${packetToDelete.title}');
  }

  // Unarchive a packet (clears archive date)
  void _unarchivePacket(int index) {
    final archivedList = archivedPackets;
    final packetToUnarchive = archivedList[index];
    final actualIndex = PacketManager.packets.indexOf(packetToUnarchive);
    
    setState(() {
      PacketManager.packets[actualIndex].dateArchived = '';
      PacketManager.packets[actualIndex].archivedBy = '';
      if (selectedPacketId == packetToUnarchive.id) {
        selectedPacketId = null;
      }
    });
    
    debugPrint('Unarchived packet: ${packetToUnarchive.title}');
  }

  // Show packet details in a dialog
  void _showPacketDetails(BuildContext context, PacketData packet) {
    String formatDate(String isoDate) {
      if (isoDate.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(isoDate);
        return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return isoDate;
      }
    }

    Widget buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w200,
                  color: css.darkGrey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isArchived = packet.dateArchived.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                packet.title,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isArchived ? Colors.grey : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isArchived ? 'Archived' : 'Active',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CloseButton(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        Text(
                          'Packet Info',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildDetailRow('Packet Name:', packet.title),
                        if (packet.notes.isNotEmpty)
                          buildDetailRow('Notes:', packet.notes),
                        const Divider(height: 32),

                        // Timeline Section
                        Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildDetailRow('Created By:', packet.createdBy),
                        buildDetailRow('Date Created:', formatDate(packet.dateCreated)),
                        if (isArchived) ...[
                          buildDetailRow('Archived By:', packet.archivedBy),
                          buildDetailRow('Date Archived:', formatDate(packet.dateArchived)),
                        ],
                        const Divider(height: 32),

                        // Routers Section
                        Text(
                          'Routers (${packet.routerIds.length})',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (packet.routerIds.isEmpty)
                          Text(
                            'No routers in this packet',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: packet.routerIds.map((routerId) {
                                final router = RouterManager.routers.firstWhere(
                                  (r) => r.id == routerId,
                                  orElse: () => RouterData(
                                    id: '',
                                    title: 'Unknown Router',
                                    color: 0,
                                    dateCreated: '',
                                    createdBy: '',
                                    processId: '',
                                    processType: 'Unknown',
                                  ),
                                );
                                return InkWell(
                                  onTap: router.id.isNotEmpty
                                      ? () => _showRouterDetails(context, router)
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Color(router.color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Color(router.color),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          router.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        if (router.id.isNotEmpty) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
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

  // Show router details in a dialog
  void _showRouterDetails(BuildContext context, RouterData router) {
    String formatDate(String isoDate) {
      if (isoDate.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(isoDate);
        return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return isoDate;
      }
    }

    Widget buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w200,
                  color: css.darkGrey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Get process type from the router first, fall back to map lookup
    final processType = router.processType.isNotEmpty 
        ? router.processType 
        : (RouterManager.processIdToType[router.processId] ?? 'Unknown');
    final isArchived = router.dateArchived.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                router.title,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isArchived ? Colors.grey : Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isArchived ? 'Archived' : 'Active',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CloseButton(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        Text(
                          'Router Info',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildDetailRow('Router Name:', router.title),
                        buildDetailRow('Process Type:', processType),
                        const Divider(height: 32),

                        // Timeline Section
                        Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildDetailRow('Created By:', router.createdBy),
                        buildDetailRow('Date Created:', formatDate(router.dateCreated)),
                        if (isArchived) ...[
                          buildDetailRow('Archived By:', router.archivedBy),
                          buildDetailRow('Date Archived:', formatDate(router.dateArchived)),
                        ],
                        const Divider(height: 32),

                        // Connected Routers Section
                        Text(
                          'Connected Routers',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (router.connectedRouters.isEmpty)
                          Text(
                            'No connected routers',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: router.connectedRouters.map((routerId) {
                                final connectedRouter = RouterManager.routers.firstWhere(
                                  (r) => r.id == routerId,
                                  orElse: () => RouterData(
                                    id: '',
                                    title: 'Unknown Router',
                                    color: 0,
                                    dateCreated: '',
                                    createdBy: '',
                                    processId: '',
                                    processType: 'Unknown',
                                  ),
                                );
                                return InkWell(
                                  onTap: connectedRouter.id.isNotEmpty
                                      ? () => _showRouterDetails(context, connectedRouter)
                                      : null,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Color(connectedRouter.color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Color(connectedRouter.color),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          connectedRouter.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        if (connectedRouter.id.isNotEmpty) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final archivedRoutersList = archivedRouters;
    final archivedPacketsList = archivedPackets;
    final hasAnyArchived = archivedRoutersList.isNotEmpty || archivedPacketsList.isNotEmpty;
    
    // Debug print to check if packets are being detected
    debugPrint('Archive Page - Routers: ${archivedRoutersList.length}, Packets: ${archivedPacketsList.length}');
    if (archivedPacketsList.isNotEmpty) {
      debugPrint('Archived packets: ${archivedPacketsList.map((p) => p.title).join(', ')}');
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: !hasAnyArchived
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'No archived items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Archived routers and packets will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Archived Routers Section
                      if (archivedRoutersList.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                'Archived Routers (${archivedRoutersList.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: archivedRoutersList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final router = archivedRoutersList[index];
                            final isSelected = router.id == selectedRouterId;
                            return RouterCard(
                              title: router.title,
                              createdBy: router.createdBy,
                              createdDate: router.dateCreated.split('T')[0],
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  selectedRouterId = router.id;
                                  selectedPacketId = null;
                                });
                                debugPrint('Archived router selected: ${router.title}');
                              },
                              color: Color(router.color),
                              onInfo: () {
                                _showRouterDetails(context, router);
                              },
                              onUnarchive: () {
                                _unarchiveRouter(index);
                              },
                              onDelete: () {
                                _deleteRouter(index);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Archived Packets Section
                      if (archivedPacketsList.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                'Archived Packets (${archivedPacketsList.length})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: archivedPacketsList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final packet = archivedPacketsList[index];
                            final isSelected = packet.id == selectedPacketId;
                            final theme = Theme.of(context);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Color(packet.color),
                                  width: isSelected ? 3 : 2,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPacketId = packet.id;
                                    selectedRouterId = null;
                                  });
                                  debugPrint('Archived packet selected: ${packet.title}');
                                },
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
                                      // Action buttons
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.info_outline),
                                            iconSize: 20,
                                            tooltip: 'View Details',
                                            onPressed: () => _showPacketDetails(context, packet),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.unarchive),
                                            iconSize: 20,
                                            tooltip: 'Unarchive',
                                            onPressed: () => _unarchivePacket(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_forever),
                                            iconSize: 20,
                                            tooltip: 'Delete Permanently',
                                            color: Colors.red,
                                            onPressed: () => _deletePacket(index),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

