import 'package:flutter/material.dart';
import '../src/organization/organization.dart';
import '../styles/globals.dart';
import 'package:css/css.dart' as css;
import 'src/data/routerData.dart';
import 'src/managers/routerManager.dart';
import 'src/example/routerCard.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String? selectedRouterId;

  // Get archived routers from the shared static list
  List<RouterData> get archivedRouters {
    return RouterManager.routers
        .where((router) => router.dateArchived.isNotEmpty)
        .toList();
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
        dateArchived: '',
        archivedBy: '',
      );
      if (selectedRouterId == routerToUnarchive.id) {
        selectedRouterId = null;
      }
    });
    
    debugPrint('Unarchived router: ${routerToUnarchive.title}');
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
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: css.darkGrey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 32,
                              color: css.CSS.lsiTheme.secondaryHeaderColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Router Details",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: css.CSS.lsiTheme.secondaryHeaderColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1.5),
                        buildDetailRow("Router Name:", router.title),
                        buildDetailRow("Router ID:", router.id),
                        buildDetailRow("Process:", router.processId),
                        buildDetailRow("Created By:", router.createdBy),
                        buildDetailRow("Date Created:", formatDate(router.dateCreated)),
                        if (router.dateArchived.isNotEmpty)
                          buildDetailRow("Date Archived:", formatDate(router.dateArchived)),
                        if (router.archivedBy.isNotEmpty)
                          buildDetailRow("Archived By:", router.archivedBy),
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
    final archived = archivedRouters;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: archived.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'No archived routers',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Archived routers will appear here',
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
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: archived.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final router = archived[index];
                    final isSelected = router.id == selectedRouterId;
                    return RouterCard(
                      title: router.title,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedRouterId = router.id;
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
              ),
      ),
    );
  }
}

