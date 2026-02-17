// Router Manager Screen - Displays list of routers and allows for CRUD operations
import 'package:flutter/material.dart';
import '../data/routerData.dart';
import '../data/jobData.dart';
import '../data/processTemplates.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import '../models/router_model.dart';
import '../data/processData.dart';
import '../managers/processManager.dart';
import 'package:uuid/uuid.dart';

class RouterManager extends StatefulWidget {
  const RouterManager({
    super.key,
    this.onRouterSelected,
  });

  static List<RouterData> get routers => _RouterManagerState.routers;

  final Function(String routerId, List<RouterData> routers)? onRouterSelected;

  static get routerJobs => _RouterManagerState.routerJobs;

  static get processIdToType => _RouterManagerState.processIdToType;
  // final void Function(String title) onAdd;
  // final void Function(String id, String newTitle) onEdit;
  // final void Function(String id) onDelete;

  @override
  State<RouterManager> createState() => _RouterManagerState();
}

class _RouterManagerState extends State<RouterManager> {
  // UUID generator for creating unique IDs
  static const _uuid = Uuid();
  
  static List<RouterData> routers = [];

  static Map<String, List<JobData>> routerJobs = {};

  // Map process IDs to process types for job template
  static Map<String, String> processIdToType = {};

  // Track selected router ID
  String? selectedRouterId;

  @override
  void initState() {
    super.initState();

    // Only initialize sample data if routers list is empty (first time)
    if (routers.isEmpty) {
      _initializeSampleData();
    }

    if (routers.isNotEmpty) {
      selectedRouterId = routers[0].id;
    }
  }

  // Initialize with sample routers for testing
  void _initializeSampleData() {
    // Generate unique IDs for sample routers and processes
    final router1Id = _uuid.v4();
    final router2Id = _uuid.v4();
    final router3Id = _uuid.v4();
    final router4Id = _uuid.v4();
    final router5Id = _uuid.v4();
    
    final process1Id = _uuid.v4();
    final process2Id = _uuid.v4();
    final process3Id = _uuid.v4();
    final process4Id = _uuid.v4();
    final process5Id = _uuid.v4();
    
    routers = [
      RouterData(
        id: router1Id,
        title: 'Router 1',
        color: 0xFFFF5252,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process1Id,
      ),
      RouterData(
        id: router2Id,
        title: 'Router 2',
        color: 0xFF2196F3,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process2Id,
      ),
      RouterData(
        id: router3Id,
        title: 'Archived Router',
        color: 0xFF4CAF50,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process3Id,
        dateArchived: DateTime.now().toIso8601String(),
        archivedBy: 'testUser',
      ),
      RouterData(
        id: router4Id,
        title: 'Router 4',
        color: 0xFFFFC107,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process4Id,
      ),
      RouterData(
        id: router5Id,
        title: 'Archived Router 2',
        color: 0xFF9C27B0,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process5Id,
        dateArchived: DateTime.now().toIso8601String(),
        archivedBy: 'testUser',
      ),
    ];

    // Map process IDs to types for initial sample data
    processIdToType[process1Id] = 'Core Parts';
    processIdToType[process2Id] = 'Cosmetic Sleeves';
    processIdToType[process3Id] = 'Magnets/Magnet Holders';
    processIdToType[process4Id] = 'Core Parts';
    processIdToType[process5Id] = 'Cosmetic Sleeves';

    // Create jobs for all sample routers
    for (var router in routers) {
      final processType = processIdToType[router.processId];
      if (processType != null) {
        routerJobs[router.id] = _createJobsFromTemplate(router.processId, processType, router.id);
      }
    }
  }

  // Helper to create jobs from template using process ID and type
  static List<JobData> _createJobsFromTemplate(String processId, String processType, String routerId) {
    final template = ProcessTemplates.getTemplate(processType);
    if (template.isEmpty) {
      return []; // No template for this process
    }

    return template.map((jobTemplate) {
      return JobData(
        id: _uuid.v4(), // Generate unique job ID
        title: jobTemplate['title'] as String,
        processId: processId, // Use unique process instance ID
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        dueDate: '', // Can be set later
        startDate: '',
        completeDate: '',
        notes: {},
        good: 0,
        bad: 0,
        status: JobStatus.notStarted,
        priority: 1,
        workers: [],
        approvers: [],
      );
    }).toList();
  }

  // Helper to create a new process instance ID and map it to a process type
  static String createProcessInstance(String processType) {
    final processId = _uuid.v4(); // Generate unique process ID
    processIdToType[processId] = processType;
    return processId;
  }

  // Delete a router from the list
  void _deleteRouter(int index) {
    setState(() {
      final routerTitle = routers[index].title;
      final deletedRouterId = routers[index].id;
      final deletedProcessId = routers[index].processId;

      routers.removeAt(index);

      // Delete associated process mapping
      processIdToType.remove(deletedProcessId);

      // Delete associated jobs
      routerJobs.remove(deletedRouterId);

      // Update selection if deleted router was selected
      if (selectedRouterId == deletedRouterId) {
        selectedRouterId = routers.isNotEmpty ? routers[0].id : null;
      }

      debugPrint('Deleted router: $routerTitle');
    });
  }

  // Add a new router to the list
  Future<void> _addRouter() async {
    // Confirmation dialog before archiving during creation
    Future<bool> confirmArchive() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Archive Router'),
            content:
                const Text('Are you sure you want to archive this router?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text('Archive'),
              ),
            ],
          );
        },
      );
      return confirmed ?? false;
    }

    final result = await showDialog<RouterModel>(
      context: context,
      builder: (BuildContext context) {
        return CreateRouterFormWidget(onArchiveRequest: confirmArchive);
      },
    );

    if (result != null) {
      setState(() {
        final routerId = _uuid.v4(); // Generate unique router ID

        // Create process instance for this router
        final processId = createProcessInstance(result.process);

        final newRouter = RouterData(
          id: routerId,
          title: result.title,
          color: _colorsList[result.color]
              .value, // Convert color index to color value
          dateCreated: DateTime.now().toIso8601String(),
          createdBy: 'testUser', // Using test user for now
          processId: processId, // Reference the unique process instance ID
          dateArchived:
              result.isArchived ? DateTime.now().toIso8601String() : '',
          archivedBy: result.isArchived ? 'testUser' : '',
          connectedRouters: result.connectedRouters,
        );

        routers.add(newRouter);

        // Create template jobs for the new router (or empty list if clearJobs is true)
        if (result.clearJobs) {
          // Start with empty job palette
          routerJobs[newRouter.id] = [];
          debugPrint('Router created with empty job palette');
        } else {
          // Use template jobs
          routerJobs[newRouter.id] =
              _createJobsFromTemplate(processId, result.process, newRouter.id);
        }

        // Auto-select newly added router
        selectedRouterId = newRouter.id;
        debugPrint('Added new router: ${result.title}');
        debugPrint('Process ID: $processId (type: ${result.process})');
        debugPrint(
            'Created ${routerJobs[newRouter.id]?.length ?? 0} template jobs');
      });
    }
  }

  // Edit an existing router
  Future<void> _editRouter(int index) async {
    final currentRouter = routers[index];

    // Get current process type
    final currentProcessType = processIdToType[currentRouter.processId] ?? '';

    // Find current color index
    int currentColorIndex = 0;
    for (int i = 0; i < _colorsList.length; i++) {
      if (_colorsList[i].value == currentRouter.color) {
        currentColorIndex = i;
        break;
      }
    }

    // Confirmation dialog before archiving
    Future<bool> confirmArchive() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Archive Router'),
            content: Text(
                'Are you sure you want to archive "${currentRouter.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                child: const Text('Archive'),
              ),
            ],
          );
        },
      );
      return confirmed ?? false;
    }

    final result = await showDialog<RouterModel>(
      context: context,
      builder: (BuildContext context) {
        return EditRouterFormWidget(
          currentRouterId: currentRouter.id,
          initialTitle: currentRouter.title,
          initialProcess: currentProcessType, // Pass process type, not instance ID
          initialColorIndex: currentColorIndex,
          isCurrentlyArchived: currentRouter.dateArchived.isNotEmpty,
          initialConnectedRouters: currentRouter.connectedRouters,
          onArchiveRequest: confirmArchive,
        );
      },
    );

    if (result != null) {
      setState(() {
        routers[index] = RouterData(
          id: currentRouter.id,
          title: result.title,
          color: _colorsList[result.color].value,
          dateCreated: currentRouter.dateCreated,
          createdBy: currentRouter.createdBy,
          processId: currentRouter.processId,
          dateArchived: result.isArchived
              ? (currentRouter.dateArchived.isEmpty
                  ? DateTime.now().toIso8601String()
                  : currentRouter.dateArchived)
              : '',
          archivedBy: result.isArchived
              ? (currentRouter.archivedBy.isEmpty
                  ? 'testUser'
                  : currentRouter.archivedBy)
              : '',
          connectedRouters: result.connectedRouters,
        );
        debugPrint('Updated router: ${result.title}');
      });
    }
  }

  // Unarchive a router
  void _unarchiveRouter(int index) {
    setState(() {
      final currentRouter = routers[index];
      routers[index] = RouterData(
        id: currentRouter.id,
        title: currentRouter.title,
        color: currentRouter.color,
        dateCreated: currentRouter.dateCreated,
        createdBy: currentRouter.createdBy,
        processId: currentRouter.processId,
        connectedRouters: currentRouter.connectedRouters,
        dateArchived: '',
        archivedBy: '',
      );
      debugPrint('Unarchived router: ${currentRouter.title}');
    });
  }

  // Show router details in a dialog
  void _showRouterDetails(BuildContext context, RouterData router) {
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
                      const SizedBox(width: 40), // Balance the close button
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ViewDetailsWidget(routerData: router),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Color list matching the dialog's color picker
  final List<Color> _colorsList = [
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
  Widget build(BuildContext context) {
    // Show only non-archived (active) routers
    final filteredRouters = routers.where((router) {
      final isArchived = router.dateArchived.isNotEmpty;
      return !isArchived; // Only show active routers
    }).toList();

    return Column(
      children: [
        Expanded(
          child: filteredRouters.isEmpty
              ? _buildEmptyState(false)
              : Scrollbar(
                  thumbVisibility: true,
                  // ignore: sort_child_properties_last
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: filteredRouters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final router = filteredRouters[index];
                      final actualIndex = routers.indexOf(router);
                      final isSelected = router.id == selectedRouterId;
                      return RouterCard(
                        title: router.title,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedRouterId = router.id;
                          });
                          // Notify parent about selection
                          if (widget.onRouterSelected != null) {
                            widget.onRouterSelected!(router.id, routers);
                          }
                          debugPrint('Router selected: ${router.title}');
                        },
                        color: Color(router.color),
                        onEdit: () {
                          _editRouter(actualIndex);
                        },
                        onDelete: () {
                          _deleteRouter(actualIndex);
                        },
                        onInfo: () {
                          _showRouterDetails(context, router);
                        },
                      );
                    },
                  ),
                  controller: ScrollController(initialScrollOffset: 0.0),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: css.purple,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              onPressed: _addRouter,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Text(
                    'Add Router',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget to display when there are no routers
  Widget _buildEmptyState(bool isArchiveView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            isArchiveView ? 'No archived routers' : 'No routers yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArchiveView
                ? 'Archived routers will appear here'
                : 'Tap the + button to create your first router',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewDetailsWidget extends StatelessWidget {
  const ViewDetailsWidget({
    super.key,
    required this.routerData,
  });

  final RouterData routerData;

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildDetailRow(String label, String value) {
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

  String _getConnectedRouterNames() {
    if (routerData.connectedRouters.isEmpty) return 'None';
    
    final names = routerData.connectedRouters
        .map((id) {
          final router = _RouterManagerState.routers.firstWhere(
            (r) => r.id == id,
            orElse: () => RouterData(
              id: '',
              title: 'Unknown Router',
              color: 0,
              dateCreated: '',
              createdBy: '',
              processId: '',
            ),
          );
          return router.title;
        })
        .toList();
    
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Divider(height: 32, thickness: 1.5),
          _buildDetailRow("Router Name:", routerData.title),
          //_buildDetailRow("Router ID:", routerData.id),
          //_buildDetailRow("Process:", routerData.processId),
          _buildDetailRow("Connected Routers:", _getConnectedRouterNames()),
          _buildDetailRow("Created By:", routerData.createdBy),
          _buildDetailRow("Date Created:", _formatDate(routerData.dateCreated)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class CreateRouterFormWidget extends StatefulWidget {
  final Future<bool> Function()? onArchiveRequest;

  const CreateRouterFormWidget({super.key, this.onArchiveRequest});

  @override
  _CreateRouterFormWidgetState createState() => _CreateRouterFormWidgetState();
}

class _CreateRouterFormWidgetState extends State<CreateRouterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _newProcessController = TextEditingController();
  String _routerName = '';
  int _routerColor = 0;
  String _processId = '';
  bool _isArchived = false;
  bool _clearJobs = false;
  String? newProcess = null;
  List<String> _selectedConnectedRouters = [];

  @override
  void dispose() {
    _newProcessController.dispose();
    super.dispose();
  }
  final List<String> _processes = [
    'Core Parts',
    'Cosmetic Sleeves',
    'Magnets/Magnet Holders',
    'Game Controller',
    'Game Controller Electronics',
    'Arm Box',
    'Socket',
    'Socket Electronics',
    'Boa Assembly',
  ];

  final List<Color> _colors = [
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
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: css.CSS.lsiTheme.primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(),
                ),
                Center(
                  child: Text(
                    "Add a New Router",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: css.CSS.lsiTheme.secondaryHeaderColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Router Name",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter router name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a router name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _routerName = value!;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text(
                  "Process",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  dropdownColor: css.lightGrey,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  isExpanded: true,
                  items: _processes
                      .map(
                        (process) => DropdownMenuItem<String>(
                          value: process,
                          child: Text(process),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _processId = value!;
                      newProcess = null;
                      _newProcessController.clear();
                    });
                  },
                  validator: (value) {
                    // Skip validation if using new process
                    if (newProcess != null) {
                      return null;
                    }
                    if (value == null || value.isEmpty) {
                      return 'Please select a process';
                    }
                    return null;
                  },
                ),

                CheckboxListTile(
                  title: const Text(
                    'New process',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    )
                  ), 
                  value: newProcess != null,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        newProcess = '';
                        _processId = '';
                        _newProcessController.clear();
                      } else {
                        newProcess = null;
                        _newProcessController.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (newProcess != null) ...[
                  const SizedBox(height: 8.0),
                  const Text(
                    'New Process Name',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: css.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _newProcessController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter new process name',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    ),
                    validator: (value) {
                      if (newProcess != null && (value == null || value.trim().isEmpty)) {
                        return 'Please enter a process name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        newProcess = value;
                        if (value.trim().isNotEmpty) {
                          _processId = _RouterManagerState.createProcessInstance(value);
                        }
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16.0),
                const Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _routerColor = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _routerColor == index
                                ? Border.all(color: Colors.black, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  "Connected Routers (Optional)",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _RouterManagerState.routers.where((r) => r.dateArchived.isEmpty).isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'No available routers to connect',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _RouterManagerState.routers
                                .where((r) => r.dateArchived.isEmpty)
                                .map((router) {
                              final isSelected = _selectedConnectedRouters.contains(router.id);
                              return CheckboxListTile(
                                title: Text(router.title),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedConnectedRouters.add(router.id);
                                    } else {
                                      _selectedConnectedRouters.remove(router.id);
                                    }
                                  });
                                },
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: const Text(
                    'Start with empty process (no template jobs)',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _clearJobs,
                  onChanged: (bool? value) async {
                    if (value == true && !_clearJobs) {
                      setState(() {
                        _clearJobs = true;
                      });
                    }
                    else {
                      setState(() {
                        _clearJobs = false;
                      });
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.onArchiveRequest != null) {
                        final confirmed = await widget.onArchiveRequest!();
                        if (confirmed) {
                          setState(() {
                            _isArchived = true;
                          });
                        }
                      } else {
                        setState(() {
                          _isArchived = true;
                        });
                      }
                    },
                    child: Text('Archive Router'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: css.darkBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.of(context).pop(
                          RouterModel(
                            title: _routerName,
                            process: _processId,
                            color: _routerColor,
                            isArchived: _isArchived,
                            clearJobs: _clearJobs,
                            connectedRouters: _selectedConnectedRouters,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Add Router",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Edit Router Dialog Widget
class EditRouterFormWidget extends StatefulWidget {
  final String currentRouterId;
  final String initialTitle;
  final String initialProcess;
  final int initialColorIndex;
  final bool isCurrentlyArchived;
  final List<String> initialConnectedRouters;
  final Future<bool> Function()? onArchiveRequest;

  const EditRouterFormWidget({
    super.key,
    required this.currentRouterId,
    required this.initialTitle,
    required this.initialProcess,
    required this.initialColorIndex,
    required this.isCurrentlyArchived,
    this.initialConnectedRouters = const [],
    this.onArchiveRequest,
  });

  @override
  _EditRouterFormWidgetState createState() => _EditRouterFormWidgetState();
}

class _EditRouterFormWidgetState extends State<EditRouterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String _routerName;
  late int _routerColor;
  late String _processId;
  late bool _isArchived;
  late List<String> _selectedConnectedRouters;

  final List<String> _processes = [
    'Core Parts',
    'Cosmetic Sleeves',
    'Magnets/Magnet Holders',
    'Game Controller',
    'Game Controller Electronics',
    'Arm Box',
    'Socket',
    'Socket Electronics',
    'Boa Assembly',
  ];

  final List<Color> _colors = [
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
  void initState() {
    super.initState();
    _routerName = widget.initialTitle;
    _routerColor = widget.initialColorIndex;
    _processId = widget.initialProcess;
    _isArchived = widget.isCurrentlyArchived;
    _selectedConnectedRouters = List.from(widget.initialConnectedRouters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: css.CSS.lsiTheme.primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(),
                ),
                Center(
                  child: Text(
                    "Edit Router",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: css.CSS.lsiTheme.secondaryHeaderColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  "Router Name",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),

                const SizedBox(height: 8.0),
                TextFormField(
                  initialValue: _routerName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter router name',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a router name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _routerName = value!;
                  },
                ),

                const SizedBox(height: 16.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Process: $_processId",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: css.darkGrey,
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: css.darkGrey,
                      )
                    ]),
          
                const SizedBox(height: 16.0),
                const Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _routerColor = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _routerColor == index
                                ? Border.all(color: Colors.black, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  "Connected Routers (Optional)",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: css.darkGrey,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _RouterManagerState.routers
                          .where((r) => r.dateArchived.isEmpty && r.id != widget.currentRouterId)
                          .isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'No available routers to connect',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _RouterManagerState.routers
                                .where((r) => r.dateArchived.isEmpty && r.id != widget.currentRouterId)
                                .map((router) {
                              final isSelected = _selectedConnectedRouters.contains(router.id);
                              return CheckboxListTile(
                                title: Text(router.title),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedConnectedRouters.add(router.id);
                                    } else {
                                      _selectedConnectedRouters.remove(router.id);
                                    }
                                  });
                                },
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 16.0),
                // Archive checkbox
                CheckboxListTile(
                  title: const Text(
                    'Archive this router',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _isArchived,
                  onChanged: (bool? value) async {
                    if (value == true && !_isArchived) {
                      // Archiving - show confirmation
                      if (widget.onArchiveRequest != null) {
                        final confirmed = await widget.onArchiveRequest!();
                        if (confirmed) {
                          setState(() {
                            _isArchived = true;
                          });
                        }
                      } else {
                        setState(() {
                          _isArchived = true;
                        });
                      }
                    } else {
                      // Unarchiving - no confirmation needed
                      setState(() {
                        _isArchived = value ?? false;
                      });
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: css.darkBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.of(context).pop(
                          RouterModel(
                            title: _routerName,
                            process: _processId,
                            color: _routerColor,
                            isArchived: _isArchived,
                            connectedRouters: _selectedConnectedRouters,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Update Router",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
