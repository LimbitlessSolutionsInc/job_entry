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
import '../src/managers/processManager.dart';

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

  // void selectRouter(String routerId) {
  //   setState(() {
  //     selectedRouterId = routerId;
  //     showRouterList = false;
  //   });
  // }

  // void addRouter(RouterData router) {
  //   setState(() {
  //     routers.add(router);
  //     selectedRouterId = router.id;
  //     showRouterList = false;
  //   });
  // }

  // void editRouter(RouterData updatedRouter) {
  //   setState(() {
  //     final index = routers.indexWhere((r) => r.id == updatedRouter.id);
  //     if (index != -1) {
  //       routers[index] = updatedRouter;
  //     }
  //   });
  // }

  // void deleteRouter(String routerId) {
  //   setState(() {
  //     routers.removeWhere((r) => r.id == routerId);
  //     if (selectedRouterId == routerId) {
  //       selectedRouterId = routers.isNotEmpty ? routers[0].id : null;
  //       showRouterList = true;
  //     }
  //   });
  // }

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
        routerId: selectedRouter!.id, processId: selectedRouter!.processId);
  }
}

/// Process Timeline View - Shows horizontal timeline of jobs for a router
class ProcessTimelineView extends StatefulWidget {
  const ProcessTimelineView({
    super.key,
    required this.routerId,
    required this.processId,
  });

  final String routerId;
  final String processId;

  @override
  State<ProcessTimelineView> createState() => _ProcessTimelineViewState();
}

class _ProcessTimelineViewState extends State<ProcessTimelineView> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    // Auto-scroll to first in-progress job after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstInProgressJob();
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (_scrollController.hasClients) {
      setState(() {
        _canScrollLeft = _scrollController.offset > 0;
        _canScrollRight = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    }
  }

  void _scrollToFirstInProgressJob() {
    final jobs = RouterManager.routerJobs[widget.routerId] ?? [];
    final firstInProgressIndex =
        jobs.indexWhere((job) => job.status == JobStatus.inProgress);

    if (firstInProgressIndex != -1 && _scrollController.hasClients) {
      // Calculate approximate position (card width + hover button width)
      // Each card is ~300px, hover button ~40-80px, so approximately 350px per item
      final scrollPosition = firstInProgressIndex * 350.0;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 350,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 350,
        duration: const Duration(milliseconds: 300),
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
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateScrollButtons());
    }
  }

  /// Handle adding a new job in specific part of timeline
  Future<void> _handleAdd(int position) async {
    final newJob = await showCreateJobDialog(
      context,
      routerId: widget.routerId,
      processId: widget.processId,
    );
    if (newJob != null) {
      setState(() {
        final jobList = RouterManager.routerJobs[widget.routerId] ?? [];
        jobList.insert(position, newJob);
      });
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateScrollButtons());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get jobs for this router
    final jobs = RouterManager.routerJobs[widget.routerId] ?? [];

    // Get process type from process ID
    final processType = RouterManager.processIdToType[widget.processId];

    Text(
      'Process: $processType',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    if (jobs.isEmpty || processType == null) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create a job to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              IconButton(
                onPressed: () {
                  _handleAdd(0);
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 100,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 2000),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 40),
          Expanded(
            child: SizedBox(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add button at the beginning
                        _HoverAddButton(
                          onAdd: () => _handleAdd(0),
                        ),
                        // Interleave cards and add buttons
                        for (int i = 0; i < jobs.length; i++) ...[
                          JobTimelineCard(
                            job: jobs[i],
                            jobNumber: i + 1,
                            isFirst: i == 0,
                            isLast: i == jobs.length - 1,
                            onTap: () {
                              showJobDetailsDialog(
                                context,
                                jobs[i],
                                onEdit: () => _handleEdit(jobs[i]),
                                onDelete: () => _handleDelete(jobs[i]),
                                onStatusChange: (updatedJob) => _handleStatusChange(updatedJob),
                              );
                            },
                          ),
                          // Add button after each card
                          _HoverAddButton(
                            onAdd: () => _handleAdd(i + 1),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Left navigation arrow
                  if (_canScrollLeft)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, size: 32),
                            onPressed: _scrollLeft,
                            tooltip: 'Scroll left',
                            color: css.darkBlue,
                          ),
                        ),
                      ),
                    ),
                  // Right navigation arrow
                  if (_canScrollRight)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, size: 32),
                            onPressed: _scrollRight,
                            tooltip: 'Scroll right',
                            color: css.darkBlue,
                          ),
                        ),
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

/// Shows '+' button on hover between job cards
class _HoverAddButton extends StatefulWidget {
  const _HoverAddButton({required this.onAdd});

  final VoidCallback onAdd;

  @override
  State<_HoverAddButton> createState() => _HoverAddButtonState();
}

class _HoverAddButtonState extends State<_HoverAddButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isHovering ? 80 : 40,
        height: 400,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isHovering ? 1.0 : 0.3,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _isHovering
                    ? css.CSS.lsiTheme.secondaryHeaderColor
                    : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: _isHovering
                    ? [
                        BoxShadow(
                          color: css.CSS.lsiTheme.secondaryHeaderColor
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onAdd,
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.add,
                    color: _isHovering ? Colors.white : Colors.grey[600],
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
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
