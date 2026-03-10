import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../src/organization/organization.dart';
import '../src/managers/routerManager.dart';
import '../src/managers/jobManager.dart';
import '../src/data/routerData.dart';
import '../src/data/jobData.dart';
import '../src/data/processTemplates.dart';
import '../styles/globals.dart';
import 'package:css/css.dart' as css;
import '../src/example/jobCard.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  // final Size size;

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  bool showRouterList = true;
  String? selectedRouterId;
  RouterData? selectedRouter;

  final List<RouterData> routers = [
    // Sample data can be added here for demo
  ];

  @override
  void initState() {
    super.initState();
    selectedRouterId = routers.isNotEmpty ? routers[0].id : null;

    currentUser = UsersProfile(
      uid: 'testUser',
      displayName: 'Test User',
      status: OrgStatus.admin,
      imageUrl: null,
      canRemoteWork: true,
    );

    // deviceWidth = widget.size.width;
    // deviceHeight = widget.size.height;
  }

  void _togglePane() {
    setState(() => showRouterList = !showRouterList);
  }

  void _onRouterSelected(String routerId, List<RouterData> routersList) {
    setState(() {
      selectedRouterId = routerId;
      selectedRouter = routersList.firstWhere(
        (r) => r.id == routerId,
        orElse: () => routersList.first,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isWide = width >= 900;

        final leftPane = RouterManager(
          onRouterSelected: _onRouterSelected,
        );
        final rightPane = RouterWorkspace(selectedRouter: selectedRouter);

        const SizedBox(width: 12);
        Alignment.centerLeft;
        Text(
          'Current User: ${currentUser.displayName}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: css.darkBlue,
          ),
        );

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Card(
              child: Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: RouterSidebarFrame(
                      child: RouterManager(
                        onRouterSelected: _onRouterSelected,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: RouterProcessFrame(
                      child: RouterWorkspace(selectedRouter: selectedRouter),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // show one pane at a time, with a toggle
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Card(
                child: showRouterList
                    ? RouterSidebarFrame(
                        child: RouterManager(
                          onRouterSelected: _onRouterSelected,
                        ),
                      )
                    : RouterProcessFrame(
                        child: RouterWorkspace(selectedRouter: selectedRouter),
                      ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: FloatingActionButton(
                onPressed: _togglePane,
                child: Icon(
                  showRouterList
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A thin wrapper for sidebar
class RouterSidebarFrame extends StatelessWidget {
  const RouterSidebarFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

/// A thin wrapper for process timeline
class RouterProcessFrame extends StatelessWidget {
  const RouterProcessFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

/// Process timeline area
class RouterWorkspace extends StatelessWidget {
  const RouterWorkspace({super.key, this.selectedRouter});

  final RouterData? selectedRouter;

  @override
  Widget build(BuildContext context) {
    if (selectedRouter == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'No router selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a router from the list to view details',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ProcessTimelineView(
        routerId: selectedRouter!.id,
        processId: selectedRouter!.processId,
        selectedRouter: selectedRouter);
  }
}

/// Process Timeline View - Shows horizontal timeline of jobs for a router
class ProcessTimelineView extends StatefulWidget {
  const ProcessTimelineView({
    super.key,
    required this.routerId,
    required this.processId,
    required this.selectedRouter,
  });

  final String routerId;
  final String processId;
  final RouterData? selectedRouter;

  @override
  State<ProcessTimelineView> createState() => _ProcessTimelineViewState();
}

class _ProcessTimelineViewState extends State<ProcessTimelineView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to first in-progress job after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstInProgressJob();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstInProgressJob() {
    final jobs = RouterManager.routerJobs[widget.routerId] ?? [];
    final firstInProgressIndex =
        jobs.indexWhere((job) => job.status == JobStatus.inProgress);

    if (firstInProgressIndex != -1 && _scrollController.hasClients) {
      final scrollPosition = firstInProgressIndex * 300.0;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handle editing a job
  Future<void> _handleEdit(JobData job) async {
    final updatedJob = await showEditJobDialog(context, job);
    if (updatedJob != null) {
      setState(() {
        final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
        final jobIndex = jobList.indexWhere((j) => j.id == job.id);
        if (jobIndex != -1) {
          jobList[jobIndex] = updatedJob;
        }
      });

      // Reopen the details dialog to show updated data
      showJobDetailsDialog(
        context,
        updatedJob,
        onEdit: () => _handleEdit(updatedJob),
        onDelete: () => _handleDelete(updatedJob),
        onStatusChange: (updatedJobFromStatus) =>
            _handleStatusChange(updatedJobFromStatus),
      );
    }
  }

  /// Handle status change from job details dialog
  void _handleStatusChange(JobData updatedJob) {
    setState(() {
      final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
      final jobIndex = jobList.indexWhere((j) => j.id == updatedJob.id);
      if (jobIndex != -1) {
        jobList[jobIndex] = updatedJob;
      }
    });
  }

  /// Handle deleting a job with confirmation
  Future<void> _handleDelete(JobData job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text(
            'Are you sure you want to delete "${job.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
        jobList.removeWhere((j) => j.id == job.id);
      });
    }
  }

  /// Handle adding a new job at the end of timeline
  Future<void> _handleAdd() async {
    final newJob = await showCreateJobDialog(
      context,
      routerId: widget.routerId,
      processId: widget.processId,
    );
    if (newJob != null) {
      setState(() {
        final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
        jobList.add(newJob);
      });
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final moved = jobList.removeAt(oldIndex);
      jobList.insert(newIndex, moved);
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!_scrollController.hasClients) return;
    if (event is PointerScrollEvent) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final nextOffset = (_scrollController.offset + event.scrollDelta.dy)
          .clamp(0.0, maxExtent)
          .toDouble();
      _scrollController.jumpTo(nextOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get jobs for this router
    final jobs = RouterManager.routerJobs[widget.routerId] ?? [];

    // Get process type from process ID
    final processType = RouterManager.processIdToType[widget.processId];

    // Text(
    //   'Process: $processType',
    //   textAlign: TextAlign.center,
    //   style: const TextStyle(
    //     fontSize: 20,
    //   ),
    // );

    // if (jobs.isEmpty || processType == null) {
    //   return SizedBox(
    //     height: 100,
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(
    //             'Create a job to get started!',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //               fontSize: 28,
    //               color: Colors.grey[600],
    //             ),
    //           ),
    //           IconButton(
    //             onPressed: () {
    //               _handleAdd(0);
    //             },
    //             icon: Icon(
    //               Icons.add_circle_outline,
    //               size: 70,
    //               color: Colors.grey[400],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 2000),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 20),
          // Column(
          //   children: [
          //     Text(
          //       'Router Name: ${widget.selectedRouter?.title ?? 'Unknown Router'}',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         fontSize: 18,
          //         color: Colors.grey,
          //       ),
          //     ),
          //     const SizedBox(height: 8),
          //   ],
          // ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Tooltip(
              message:
                  '${widget.selectedRouter?.title ?? 'Unknown Router'}',
              waitDuration: const Duration(milliseconds: 250),
              child: Material(
                color: Colors.transparent,
                child: Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.9),
                ),
              ),
            ),
          ]),
          Expanded(
            child: SizedBox(
              child: Stack(
                children: [
                  Listener(
                    onPointerSignal: _handlePointerSignal,
                    child: (jobs.isEmpty || processType == null)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No jobs yet in this router',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Click the + button to create the first job!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ReorderableListView.builder(
                            key: ValueKey(widget.routerId),
                            scrollDirection: Axis.horizontal,
                            scrollController: _scrollController,
                            buildDefaultDragHandles: false,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: jobs.length,
                            onReorder: _handleReorder,
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                elevation: 8,
                                borderRadius: BorderRadius.circular(14),
                                child: child,
                              );
                            },
                            itemBuilder: (context, i) {
                              return SizedBox(
                                key: ValueKey(jobs[i].id),
                                width: 280,
                                child: ReorderableDragStartListener(
                                  index: i,
                                  child: JobTimelineCard(
                                    job: jobs[i],
                                    jobNumber: i + 1,
                                    onTap: () {
                                      showJobDetailsDialog(
                                        context,
                                        jobs[i],
                                        onEdit: () => _handleEdit(jobs[i]),
                                        onDelete: () => _handleDelete(jobs[i]),
                                        onStatusChange: (updatedJob) =>
                                            _handleStatusChange(updatedJob),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      heroTag: 'add-job-${widget.routerId}',
                      onPressed: _handleAdd,
                      backgroundColor: css.darkBlue,
                      foregroundColor: Colors.white,
                      tooltip: 'Add Job',
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Job extends StatelessWidget {
  const _Job();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Text('Process and jobs', textAlign: TextAlign.center),
      ),
    );
  }
}
