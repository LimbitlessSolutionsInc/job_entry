// Router Manager Screen - Displays list of routers and allows for CRUD operations
import 'package:flutter/material.dart';
import 'package:job_entry/styles/globals.dart';
import '../data/routerData.dart';
import '../data/jobData.dart';
import '../data/processTemplates.dart';
import '../example/routerCard.dart';
import 'package:css/css.dart' as css;
import '../models/router_model.dart';
import '../data/processData.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class RouterManager extends StatefulWidget {
  const RouterManager({
    super.key,
    this.onRouterSelected,
  });

  static List<RouterData> get routers => RouterManagerState.routers;

  final Function(String routerId, List<RouterData> routers)? onRouterSelected;

  static get routerJobs => RouterManagerState.routerJobs;

  static get processIdToType => RouterManagerState.processIdToType;

  @override
  State<RouterManager> createState() => RouterManagerState();
}

class RouterManagerState extends State<RouterManager> {
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
    
    // Sample router data, can delete when testing is done
    routers = [
      RouterData(
        id: router1Id,
        title: 'Router 1',
        color: 0xFFFF5252,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process1Id,
        processType: 'Core Parts',
      ),
      RouterData(
        id: router2Id,
        title: 'Router 2',
        color: 0xFF2196F3,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process2Id,
        processType: 'Cosmetic Sleeves',
      ),
      RouterData(
        id: router3Id,
        title: 'Archived Router',
        color: 0xFF4CAF50,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process3Id,
        processType: 'Magnets/Magnet Holders',
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
        processType: 'Core Parts',
      ),
      RouterData(
        id: router5Id,
        title: 'Archived Router 2',
        color: 0xFF9C27B0,
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: process5Id,
        processType: 'Cosmetic Sleeves',
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
        partsReceivedDate: '',
        notes: {},
        good: 0,
        bad: 0,
        status: JobStatus.notStarted,
        priority: 'Not set',
        workers: [],
        partsReceivedBy: [],
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
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
          processType: result.process, // Store the actual process name
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
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
          processType: result.process, // Update process type
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
        processType: currentRouter.processType,
        connectedRouters: currentRouter.connectedRouters,
        dateArchived: '',
        archivedBy: '',
      );
      debugPrint('Unarchived router: ${currentRouter.title}');
    });
  }

  // Show router details in a dialog
  static void showRouterDetails(BuildContext context, RouterData router) {
    // Get process type from the router first, fall back to map lookup
    final processType = router.processType.isNotEmpty 
        ? router.processType 
        : (RouterManagerState.processIdToType[router.processId] ?? 'Unknown');
    final isArchived = router.dateArchived.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface),
                          tooltip: 'Export to PDF',
                          onPressed: () => _exportRouterToPdf(context, router),
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
                        _buildDetailRow('Router Name:', router.title, context),
                        _buildDetailRow('Process Type:', processType, context),
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
                        _buildDetailRow('Created By:', router.createdBy, context),
                        _buildDetailRow('Date Created:', _formatDate(router.dateCreated), context),
                        if (isArchived) ...[
                          _buildDetailRow('Archived By:', router.archivedBy, context),
                          _buildDetailRow('Date Archived:', _formatDate(router.dateArchived), context),
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
                                final connectedRouter = RouterManagerState.routers.firstWhere(
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
                                      ? () => RouterManagerState.showRouterDetails(
                                          context, connectedRouter)
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

  static Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
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

  static String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  static Future<void> _exportRouterToPdf(BuildContext context, RouterData router) async {
    final processType = router.processType.isNotEmpty 
        ? router.processType 
        : (RouterManagerState.processIdToType[router.processId] ?? 'Unknown');
    final isArchived = router.dateArchived.isNotEmpty;
    final jobs = RouterManagerState.routerJobs[router.id] ?? [];
    
    // Get connected router details
    final connectedRouterDetails = router.connectedRouters.map((routerId) {
      return RouterManagerState.routers.firstWhere(
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
    }).toList();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Router Details',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    router.title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: isArchived ? PdfColors.grey : PdfColors.green,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      isArchived ? 'Archived' : 'Active',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Router Information
            pw.Text(
              'Router Information',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            _buildPdfDetailRow('Router Name:', router.title),
            _buildPdfDetailRow('Process Type:', processType),
            pw.SizedBox(height: 16),

            pw.Text(
              'Timeline',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            _buildPdfDetailRow('Created By:', router.createdBy),
            _buildPdfDetailRow('Created On:', _formatDate(router.dateCreated)),
            if (isArchived) ...[
              _buildPdfDetailRow('Archived By:', router.archivedBy),
              _buildPdfDetailRow('Archived On:', _formatDate(router.dateArchived)),
            ],
            pw.SizedBox(height: 16),

            // Connected Routers
            pw.Text(
              'Connected Routers',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (connectedRouterDetails.isEmpty)
              pw.Text('No connected routers', style: const pw.TextStyle(fontSize: 12))
            else
              ...connectedRouterDetails.map((connectedRouter) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('- ', style: const pw.TextStyle(fontSize: 12)),
                      pw.Expanded(
                        child: pw.Text(
                          '${connectedRouter.title} (Created by: ${connectedRouter.createdBy})',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            pw.SizedBox(height: 16),

            // Jobs List
            pw.Text(
              'Jobs',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (jobs.isEmpty)
              pw.Text('No jobs in this router', style: const pw.TextStyle(fontSize: 12))
            else
              ...jobs.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;
                final statusText = _formatJobStatus(job.status);
                
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Job title with status
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              '${index + 1}. ${job.title}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: _getStatusPdfColor(job.status),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Text(
                              statusText,
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 10,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      // Job details split into two columns
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Table(
                              border: pw.TableBorder.all(color: PdfColors.grey400),
                              columnWidths: {
                                0: const pw.FlexColumnWidth(1),
                                1: const pw.FlexColumnWidth(2),
                              },
                              children: [
                                _buildJobTableRow('Workers:', job.workers.isEmpty ? 'None' : job.workers.join(', ')),
                                _buildJobTableRow('Completion Verified By:', job.approvers.isEmpty ? 'None' : job.approvers.join(', ')),
                                _buildJobTableRow('Number of Good Parts:', '${job.good}'),
                                _buildJobTableRow('Number of Bad Parts:', '${job.bad}'),
                                _buildJobTableRow('Notes:', job.notes.isEmpty
                                    ? 'None'
                                    : job.notes.entries.map((e) => '${e.key}: ${e.value}').join('; ')),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Table(
                              border: pw.TableBorder.all(color: PdfColors.grey400),
                              columnWidths: {
                                0: const pw.FlexColumnWidth(1),
                                1: const pw.FlexColumnWidth(2),
                              },
                              children: [
                                _buildJobTableRow('Start Date:', _formatDate(job.startDate)),
                                _buildJobTableRow('Completion Date:', _formatDate(job.completeDate)),
                                _buildJobTableRow('Due Date:', _formatDate(job.dueDate)),
                                _buildJobTableRow('Received On:', _formatDate(job.partsReceivedDate)),
                                _buildJobTableRow('Received By:', job.partsReceivedBy.isEmpty ? 'None' : job.partsReceivedBy.join(', ')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ];
        },
      ),
    );

    // generating file name
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = '${router.title}_$dateStr.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  static pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildJobTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  static String _formatJobStatus(JobStatus status) {
    switch (status) {
      case JobStatus.notStarted:
        return 'Not Started';
      case JobStatus.partsReceived:
        return 'Parts Received';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.skipped:
        return 'Skipped';
    }
  }

  static PdfColor _getStatusPdfColor(JobStatus status) {
    switch (status) {
      case JobStatus.notStarted:
        return PdfColors.grey;
      case JobStatus.partsReceived:
        return PdfColors.blue;
      case JobStatus.inProgress:
        return PdfColors.orange;
      case JobStatus.completed:
        return PdfColors.green;
      case JobStatus.skipped:
        return PdfColors.red;
    }
  }

  void _showRouterDetailsInstance(BuildContext context, RouterData router) {
    RouterManagerState.showRouterDetails(context, router);
  }

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
                        createdBy: router.createdBy,
                        createdDate: router.dateCreated.split('T')[0], // format date
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
                          _showRouterDetailsInstance(context, router);
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
                backgroundColor: Theme.of(context).primaryColorDark,
                elevation: 2,
              ),
              onPressed: _addRouter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Router',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
    'Magnetic EMG',
    'Boa Assembly',
    'Finger Assembly',
    'Hand Assembly',
    'Board',
    'Battery Assembly',
    'Battery Core Assembly',
    'Arm Assembly',
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

  // Helper method to build grouped router checkboxes by process type
  List<Widget> _buildGroupedRouterCheckboxes(List<RouterData> routers, String? excludeRouterId) {
    // Group routers by process type
    final Map<String, List<RouterData>> groupedRouters = {};
    
    for (final router in routers) {
      final processType = RouterManagerState.processIdToType[router.processId] ?? 'Unknown Process';
      if (!groupedRouters.containsKey(processType)) {
        groupedRouters[processType] = [];
      }
      groupedRouters[processType]!.add(router);
    }

    // Sort process types alphabetically
    final sortedProcessTypes = groupedRouters.keys.toList()..sort();

    // Build widgets
    final List<Widget> widgets = [];
    
    for (int i = 0; i < sortedProcessTypes.length; i++) {
      final processType = sortedProcessTypes[i];
      final routersInProcess = groupedRouters[processType]!;

      // Add divider before each section except the first
      if (i > 0) {
        widgets.add(const Divider(height: 1, thickness: 1));
      }

      // Add section header
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: Colors.grey.withOpacity(0.2),
          child: Text(
            processType,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.25,
            ),
          ),
        ),
      );

      // Add routers in this process
      for (final router in routersInProcess) {
        final isSelected = _selectedConnectedRouters.contains(router.id);
        widgets.add(
          CheckboxListTile(
            title: Text(
              router.title,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
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
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Router Name*",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w200,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 1.25,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter router name',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                Text(
                  "Process*",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w200,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 1.25,
                  ),
                ),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  dropdownColor: Theme.of(context).cardColor,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15, 
                  ),
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

                // Display "Jobs in this process:" and list template jobs if existing process selected and jobs list isnt empty?

                CheckboxListTile(
                  title: Text(
                    'New process',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.onSurface,
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
                  Text(
                    'New Process Name*',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _newProcessController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter new process name',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
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
                          _processId = RouterManagerState.createProcessInstance(value);
                        }
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16.0),
                Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w200,
                    color: Theme.of(context).colorScheme.onSurface,
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
                                ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16.0),
                Text(
                  "Connected Routers (Optional)",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w200,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RouterManagerState.routers.where((r) => r.dateArchived.isEmpty).isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'No available routers to connect',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildGroupedRouterCheckboxes(
                              RouterManagerState.routers
                                  .where((r) => r.dateArchived.isEmpty)
                                  .toList(),
                              null,
                            ),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: Text(
                    'Start with empty job list',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(context).colorScheme.onSurface,
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
                      backgroundColor: Theme.of(context).primaryColorDark,
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
                            process: newProcess ?? _processId,
                            color: _routerColor,
                            isArchived: _isArchived,
                            clearJobs: _clearJobs,
                            connectedRouters: _selectedConnectedRouters,
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Add Router",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  // Helper method to build grouped router checkboxes by process type
  List<Widget> _buildGroupedRouterCheckboxes(List<RouterData> routers, String? excludeRouterId) {
    // Group routers by process type
    final Map<String, List<RouterData>> groupedRouters = {};
    
    for (final router in routers) {
      final processType = RouterManagerState.processIdToType[router.processId] ?? 'Unknown Process';
      if (!groupedRouters.containsKey(processType)) {
        groupedRouters[processType] = [];
      }
      groupedRouters[processType]!.add(router);
    }

    // Sort process types alphabetically
    final sortedProcessTypes = groupedRouters.keys.toList()..sort();

    // Build widgets
    final List<Widget> widgets = [];
    
    for (int i = 0; i < sortedProcessTypes.length; i++) {
      final processType = sortedProcessTypes[i];
      final routersInProcess = groupedRouters[processType]!;

      // Add divider before each section except the first
      if (i > 0) {
        widgets.add(const Divider(height: 1, thickness: 1));
      }

      // Add section header
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: Colors.grey.withOpacity(0.2),
          child: Text(
            processType,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      );

      // Add routers in this process
      for (final router in routersInProcess) {
        final isSelected = _selectedConnectedRouters.contains(router.id);
        widgets.add(
          CheckboxListTile(
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
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      color: Theme.of(context).textTheme.headlineMedium!.color,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),
                Text(
                  "Router Name",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ]),
          
                const SizedBox(height: 16.0),
                Text(
                  "Router Color",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
                                ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3.0)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16.0),
                Text(
                  "Connected Routers (Optional)",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RouterManagerState.routers
                          .where((r) => r.dateArchived.isEmpty && r.id != widget.currentRouterId)
                          .isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'No available routers to connect',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildGroupedRouterCheckboxes(
                              RouterManagerState.routers
                                  .where((r) => r.dateArchived.isEmpty && r.id != widget.currentRouterId)
                                  .toList(),
                              widget.currentRouterId,
                            ),
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
                      backgroundColor: Theme.of(context).primaryColorDark,
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
                    child: Text(
                      "Update Router",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
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
