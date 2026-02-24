import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' hide VoidCallback;
import '../data/jobData.dart';
import 'package:css/css.dart' as css;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../styles/globals.dart';

class JobManager extends StatefulWidget {
  const JobManager({super.key});

  @override
  State<JobManager> createState() => JobManagerState();
}

class JobManagerState extends State<JobManager> {
  // UUID generator for creating unique job IDs
  static const _uuid = Uuid();

  static List<JobData> jobs = [];

  String? selectedJobId;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Shows job details in a dialog with options to edit or delete
void showJobDetailsDialog(
  BuildContext context,
  JobData job, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  Function(JobData)? onStatusChange,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return JobDetailsDialog(
        job: job,
        onEdit: onEdit,
        onDelete: onDelete,
        onStatusChange: onStatusChange,
      );
    },
  );
}

/// Shows dialog to create a new job
Future<JobData?> showCreateJobDialog(
  BuildContext context, {
  required String processId,
  required String routerId,
}) async {
  return await showDialog<JobData>(
    context: context,
    builder: (BuildContext context) {
      return CreateJobDialog(
        processId: processId,
        routerId: routerId,
      );
    },
  );
}

/// Shows dialog to edit an existing job
Future<JobData?> showEditJobDialog(
  BuildContext context,
  JobData job,
) async {
  return await showDialog<JobData>(
    context: context,
    builder: (BuildContext context) {
      return EditJobDialog(job: job);
    },
  );
}

/// Dialog to view job details with edit/delete options
class JobDetailsDialog extends StatefulWidget {
  const JobDetailsDialog({
    super.key,
    required this.job,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  final JobData job;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(JobData)? onStatusChange;

  @override
  State<JobDetailsDialog> createState() => _JobDetailsDialogState();
}

class _JobDetailsDialogState extends State<JobDetailsDialog> {
  late JobStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.job.status;
  }

  Future<bool> _confirmStatusChange(
      BuildContext context, JobStatus newStatus) async {
    String title;
    String message;

    switch (newStatus) {
      case JobStatus.partsReceived:
        title = 'Confirm Parts Received';
        message = 'Have the parts for this job been received and verified?';
        break;
      case JobStatus.completed:
        title = 'Confirm Job Completion';
        message =
            'Have you reviewed the parts and confirmed they are ready for handoff?';
        break;
      default:
        return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: css.CSS.lsiTheme.secondaryHeaderColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _handleStatusChange(JobStatus newStatus) async {
    if (newStatus == _currentStatus) return;

    final confirmed = await _confirmStatusChange(context, newStatus);

    if (confirmed) {
      setState(() {
        _currentStatus = newStatus;
      });

      // Add current user to approvals list if marking as completed
      List<String> updatedApprovals = List.from(widget.job.approvers);
      if (newStatus == JobStatus.completed &&
          !updatedApprovals.contains(currentUser.uid)) {
        updatedApprovals.add(currentUser.uid);
      }

      // Add current user to partsReceivedBy list if marking as partsReceived
      List<String> updatedPartsReceivedBy = List.from(widget.job.partsReceivedBy);
      if (newStatus == JobStatus.partsReceived &&
          !updatedPartsReceivedBy.contains(currentUser.displayName)) {
        updatedPartsReceivedBy.add(currentUser.displayName);
      }

      if (newStatus == JobStatus.partsReceived &&
          widget.job.partsReceivedDate.isEmpty) {
        widget.job.partsReceivedDate = DateTime.now().toIso8601String();
      }

      if (newStatus == JobStatus.inProgress && widget.job.startDate.isEmpty) {
        widget.job.startDate = DateTime.now().toIso8601String();
      }

      if (newStatus == JobStatus.completed && widget.job.completeDate.isEmpty) {
        widget.job.completeDate = DateTime.now().toIso8601String();
      }

      final updatedJob = JobData(
        id: widget.job.id,
        title: widget.job.title,
        dateCreated: widget.job.dateCreated,
        createdBy: widget.job.createdBy,
        processId: widget.job.processId,
        priority: widget.job.priority,
        dueDate: widget.job.dueDate,
        startDate: widget.job.startDate,
        completeDate: widget.job.completeDate,
        partsReceivedDate: widget.job.partsReceivedDate,
        notes: widget.job.notes,
        status: newStatus,
        good: widget.job.good,
        bad: widget.job.bad,
        workers: widget.job.workers,
        partsReceivedBy: updatedPartsReceivedBy,
        approvers: updatedApprovals,
        numApprovals: widget.job.numApprovals,
      );

      widget.onStatusChange?.call(updatedJob);
    }
  }

  Widget _buildStatusDropdown() {
    final statusColor = _getStatusColor(_currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<JobStatus>(
          value: _currentStatus,
          dropdownColor: Theme.of(context).cardColor,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: statusColor, size: 20),
          selectedItemBuilder: (BuildContext context) {
            return JobStatus.values.map((status) {
              return Center(
                child: Text(
                  _formatStatusText(status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList();
          },
          items: JobStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                _formatStatusText(status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (JobStatus? newStatus) {
            if (newStatus != null) {
              _handleStatusChange(newStatus);
            }
          },
        ),
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.notStarted:
        return Colors.grey;
      case JobStatus.partsReceived:
        return Colors.purple;
      case JobStatus.inProgress:
        return Colors.blue;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.skipped:
        return Colors.orange;
    }
  }

  String _formatStatusText(JobStatus status) {
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

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
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
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  color: css.CSS.lsiTheme.primaryColor.withOpacity(0.1),
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
                            widget.job.title,
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: css.CSS.lsiTheme.primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusDropdown(),
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
                      'Job Info',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: css.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    //_buildDetailRow('Job ID:', widget.job.id),
                    //_buildDetailRow('Process ID:', widget.job.processId),
                    _buildDetailRow('Job Name:', widget.job.title),
                    _buildDetailRow('Priority:', widget.job.priority),
                    const Divider(height: 32),

                    // Timeline Section
                    Text(
                      'Timeline',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: css.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Created On:', formatDate(widget.job.dateCreated)),
                    _buildDetailRow('Created By:', widget.job.createdBy),
                    _buildDetailRow('Parts Received On:',
                        formatDate(widget.job.partsReceivedDate)),
                    _buildDetailRow(
                        'Start Date:', formatDate(widget.job.startDate)),
                    _buildDetailRow(
                        'Due Date:', formatDate(widget.job.dueDate)),
                    _buildDetailRow(
                        'Completed On:', formatDate(widget.job.completeDate)),
                    const Divider(height: 32),

                    // Team Section
                    Text(
                      'Team',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: css.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Workers:',
                      widget.job.workers.isEmpty
                          ? 'None assigned'
                          : widget.job.workers.join(', '),
                    ),
                    _buildDetailRow(
                      'Parts Received By:',
                      widget.job.partsReceivedBy.isEmpty
                          ? 'None assigned'
                          : widget.job.partsReceivedBy.join(', '),
                    ),
                    _buildDetailRow(
                      'Job Completion Verified By:',
                      widget.job.approvers.isEmpty
                          ? 'None assigned'
                          : widget.job.approvers.join(', '),
                    ),
                    const Divider(height: 32),

                    // Good, Bad, Notes
                    Text(
                      'Quality Metrics',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: css.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.green.shade100.withOpacity(0.2)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.job.good}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Good Parts',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.red.shade100.withOpacity(0.2)
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.job.bad}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Bad Parts',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Notes Section
                    if (widget.job.notes.isNotEmpty) ...[
                      const Divider(height: 32),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.5)),
                        ),
                        child: Text(
                          widget.job.notes.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join('\n'),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (widget.onDelete != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onDelete?.call();
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Job'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (widget.onEdit != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onEdit?.call();
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Job'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  css.CSS.lsiTheme.secondaryHeaderColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
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
}

/// Dialog to create a new job
class CreateJobDialog extends StatefulWidget {
  const CreateJobDialog({
    super.key,
    required this.processId,
    required this.routerId,
  });

  final String processId;
  final String routerId;

  @override
  State<CreateJobDialog> createState() => _CreateJobDialogState();
}

class _CreateJobDialogState extends State<CreateJobDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _partsReceivedDate;
  // Form field values
  String _priority = 'Medium';
  JobStatus _status = JobStatus.notStarted;
  DateTime? _startDate;
  DateTime? _dueDate;
  DateTime? _completeDate;
  List<String> _workers = [];
  List<String> _approvers = [];
  int _good = 0;
  int _bad = 0;
  String? _selectedWorker;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: css.CSS.lsiTheme.secondaryHeaderColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case 'partsReceived':
            _partsReceivedDate = picked;
            break;
          case 'start':
            _startDate = picked;
            break;
          case 'due':
            _dueDate = picked;
            break;
          case 'complete':
            _completeDate = picked;
            break;
        }
      });
    }
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      // Auto-set dates based on status if not manually set
      DateTime? finalPartsReceivedDate = _partsReceivedDate;
      if (_status == JobStatus.partsReceived && _partsReceivedDate == null) {
        finalPartsReceivedDate = DateTime.now();
      }

      DateTime? finalStartDate = _startDate;
      if (_status == JobStatus.inProgress && _startDate == null) {
        finalStartDate = DateTime.now();
      }

      DateTime? finalCompleteDate = _completeDate;
      if (_status == JobStatus.completed && _completeDate == null) {
        finalCompleteDate = DateTime.now();
      }

      // Set partsReceivedBy if status is partsReceived
      List<String> finalPartsReceivedBy = [];
      if (_status == JobStatus.partsReceived) {
        finalPartsReceivedBy = [currentUser.displayName];
      }

      final newJob = JobData(
        id: JobManagerState._uuid.v4(), // Generate unique job ID
        title: _titleController.text.trim(),
        dateCreated: DateTime.now().toIso8601String(),
        createdBy: 'testUser',
        processId: widget.processId,
        priority: _priority,
        dueDate: _dueDate?.toIso8601String() ?? '',
        startDate: finalStartDate?.toIso8601String() ?? '',
        completeDate: finalCompleteDate?.toIso8601String() ?? '',
        partsReceivedDate: finalPartsReceivedDate?.toIso8601String() ?? '',
        notes: {},
        status: _status,
        good: _good,
        bad: _bad,
        workers: _workers,
        partsReceivedBy: finalPartsReceivedBy,
        approvers: _approvers,
      );

      Navigator.pop(context, newJob);
    }
  }

  Widget _buildDateButton(String label, DateTime? date, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: css.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, field),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Select date'
                        : DateFormat('MMM dd, yyyy').format(date),
                    style: TextStyle(
                      fontSize: 15,
                      color: date == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (date != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        switch (field) {
                          case 'start':
                            _startDate = null;
                            break;
                          case 'due':
                            _dueDate = null;
                            break;
                          case 'complete':
                            _completeDate = null;
                            break;
                          case 'partsReceived':
                            _partsReceivedDate = null;
                            break;
                        }
                      });
                    },
                    child: Icon(Icons.clear,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color:
                        css.CSS.lsiTheme.secondaryHeaderColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        'Create New Job',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const CloseButton(),
                    ],
                  ),
                ),

                // Form Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Title
                      Text(
                        'Job Title *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter job title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Priority & Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _priority,
                                  dropdownColor: Theme.of(context).cardColor,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  items: ['Low', 'Medium', 'High']
                                      .map((level) => DropdownMenuItem(
                                            value: level,
                                            child: Text(level),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<JobStatus>(
                                  value: _status,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                  dropdownColor: Theme.of(context).cardColor,
                                  items: JobStatus.values
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              _formatStatusText(status),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _status = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Workers Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assign Workers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: css.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedWorker,
                            decoration: InputDecoration(
                              hintText: 'Select a worker', 
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            dropdownColor: Theme.of(context).cardColor,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            items: ['Test User', 'John Doe', 'Jane Smith', 'None']
                                .map((worker) => DropdownMenuItem(
                                      value: worker,
                                      child: Text(worker),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null && value != 'None' &&
                                  !_workers.contains(value)) {
                                setState(() {
                                  _workers.add(value);
                                  _selectedWorker = null; // Reset dropdown
                                });
                              }
                            },
                          ),
                          if (_workers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _workers.map((worker) {
                                return Chip(
                                  label: Text(worker),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _workers.remove(worker);
                                    });
                                  },
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Dates Section
                      Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDateButton('Start Date', _startDate, 'start'),
                      const SizedBox(height: 16),
                      _buildDateButton('Due Date', _dueDate, 'due'),
                      const SizedBox(height: 16),
                      _buildDateButton(
                          'Complete Date', _completeDate, 'complete'),
                      const SizedBox(height: 20),

                      // Quality Metrics
                      Text(
                        'Quality Metrics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Count',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: '0',
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _good = int.tryParse(value) ?? 0;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bad Count',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: '0',
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _bad = int.tryParse(value) ?? 0;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _handleCreate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  css.CSS.lsiTheme.secondaryHeaderColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Create Job',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    letterSpacing: 1.25,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  String _formatStatusText(JobStatus status) {
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
}

/// Dialog to edit an existing job
class EditJobDialog extends StatefulWidget {
  const EditJobDialog({
    super.key,
    required this.job,
  });

  final JobData job;

  @override
  State<EditJobDialog> createState() => _EditJobDialogState();
}

class _EditJobDialogState extends State<EditJobDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _goodController;
  late final TextEditingController _badController;
  late final TextEditingController _notesController;

  // Form field values
  late String _priority;
  late JobStatus _status;
  DateTime? _startDate;
  DateTime? _dueDate;
  DateTime? _completeDate;
  DateTime? _partsReceivedDate;
  late List<String> _workers;
  late List<String> _approvers;
  Map<String, String> _notes = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate form with existing job data
    _titleController = TextEditingController(text: widget.job.title);
    _goodController = TextEditingController(text: widget.job.good.toString());
    _badController = TextEditingController(text: widget.job.bad.toString());

    _priority = widget.job.priority;
    _status = widget.job.status;
    _workers = List.from(widget.job.workers);
    _approvers = List.from(widget.job.approvers);
    _notes = Map.from(widget.job.notes);

    // Initialize notes controller with empty text (existing notes will be preserved)
    _notesController = TextEditingController(text: '');

    // Parse dates
    _startDate = _parseDate(widget.job.startDate);
    _dueDate = _parseDate(widget.job.dueDate);
    _completeDate = _parseDate(widget.job.completeDate);
    _partsReceivedDate = _parseDate(widget.job.partsReceivedDate);
  }

  DateTime? _parseDate(String isoDate) {
    if (isoDate.isEmpty) return null;
    try {
      return DateTime.parse(isoDate);
    } catch (e) {
      return null;
    }
  }

  Future<bool> _confirmStatusChange(
      BuildContext context, JobStatus newStatus) async {
    String title;
    String message;

    switch (newStatus) {
      case JobStatus.partsReceived:
        title = 'Confirm Parts Received';
        message = 'Have the parts for this job been received and verified?';
        break;
      case JobStatus.completed:
        title = 'Confirm Job Completion';
        message =
            'Have you reviewed the parts and confirmed they are ready for handoff?';
        break;
      default:
        return true; // No confirmation needed for other statuses
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: css.CSS.lsiTheme.secondaryHeaderColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goodController.dispose();
    _badController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: css.CSS.lsiTheme.secondaryHeaderColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case 'start':
            _startDate = picked;
            break;
          case 'due':
            _dueDate = picked;
            break;
          case 'complete':
            _completeDate = picked;
            break;
        }
      });
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      // Add current user to approvals list if marking as completed
      List<String> updatedApprovals = List.from(widget.job.approvers);
      if (_status == JobStatus.completed &&
          widget.job.status != JobStatus.completed &&
          !updatedApprovals.contains(currentUser.uid)) {
        updatedApprovals.add(currentUser.uid);
      }

      // Add current user to partsReceivedBy list if marking as partsReceived
      List<String> updatedPartsReceivedBy = List.from(widget.job.partsReceivedBy);
      if (_status == JobStatus.partsReceived &&
          widget.job.status != JobStatus.partsReceived &&
          !updatedPartsReceivedBy.contains(currentUser.displayName)) {
        updatedPartsReceivedBy.add(currentUser.displayName);
      }

      // Auto-set dates based on status if not manually set
      DateTime? finalPartsReceivedDate = _partsReceivedDate;
      if (_status == JobStatus.partsReceived &&
          _partsReceivedDate == null &&
          widget.job.partsReceivedDate.isEmpty) {
        finalPartsReceivedDate = DateTime.now();
      }

      DateTime? finalStartDate = _startDate;
      if (_status == JobStatus.inProgress &&
          _startDate == null &&
          widget.job.startDate.isEmpty) {
        finalStartDate = DateTime.now();
      }

      DateTime? finalCompleteDate = _completeDate;
      if (_status == JobStatus.completed &&
          _completeDate == null &&
          widget.job.completeDate.isEmpty) {
        finalCompleteDate = DateTime.now();
      }

      // Parse new notes from controller text and ADD to existing notes
      // Start with existing notes from widget.job
      Map<String, String> allNotes = Map.from(widget.job.notes);
      
      // Only process if there's new text in the controller
      if (_notesController.text.trim().isNotEmpty) {
        var lines = _notesController.text.split('\n');
        Map<String, int> keyCounts = {}; // Track duplicate keys
        
        for (int i = 0; i < lines.length; i++) {
          var line = lines[i].trim();
          if (line.isEmpty) continue;
          
          var colonIndex = line.indexOf(':');
          if (colonIndex > 0) {
            // Has colon: split on first colon only
            var key = line.substring(0, colonIndex).trim();
            var val = line.substring(colonIndex + 1).trim();
            if (key.isNotEmpty) {
              // Handle duplicate keys
              var finalKey = key;
              if (allNotes.containsKey(key)) {
                keyCounts[key] = (keyCounts[key] ?? 1) + 1;
                finalKey = '$key (${keyCounts[key]})';
              }
              allNotes[finalKey] = val;
            }
          } else {
            // No colon: use current user's name as key with counter
            var baseKey = currentUser.displayName;
            var finalKey = baseKey;
            if (allNotes.containsKey(baseKey)) {
              keyCounts[baseKey] = (keyCounts[baseKey] ?? 1) + 1;
              finalKey = '$baseKey (${keyCounts[baseKey]})';
            }
            allNotes[finalKey] = line;
          }
        }
      }
      
      _notes = allNotes;

      final updatedJob = JobData(
        id: widget.job.id,
        title: _titleController.text.trim(),
        dateCreated: widget.job.dateCreated,
        createdBy: widget.job.createdBy,
        processId: widget.job.processId,
        priority: _priority,
        dueDate: _dueDate?.toIso8601String() ?? '',
        startDate: finalStartDate?.toIso8601String() ?? '',
        completeDate: finalCompleteDate?.toIso8601String() ?? '',
        partsReceivedDate: finalPartsReceivedDate?.toIso8601String() ?? '',
        notes: _notes,  
        status: _status,
        good: int.tryParse(_goodController.text) ?? 0,
        bad: int.tryParse(_badController.text) ?? 0,
        workers: _workers,
        partsReceivedBy: updatedPartsReceivedBy,
        approvers: updatedApprovals,
        numApprovals: widget.job.numApprovals,
      );

      debugPrint('Widget Job Notes: ${widget.job.notes}');

      Navigator.pop(context, updatedJob);
    }
  }

  Widget _buildDateButton(String label, DateTime? date, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: css.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, field),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Select date'
                        : DateFormat('MMM dd, yyyy').format(date),
                    style: TextStyle(
                      fontSize: 15,
                      color: date == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (date != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        switch (field) {
                          case 'start':
                            _startDate = null;
                            break;
                          case 'due':
                            _dueDate = null;
                            break;
                          case 'complete':
                            _completeDate = null;
                            break;
                          case 'partsReceived':
                            _partsReceivedDate = null;
                            break;
                        }
                      });
                    },
                    child: Icon(Icons.clear,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color:
                        css.CSS.lsiTheme.secondaryHeaderColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Job',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Title
                      Text(
                        'Job Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter job title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Priority & Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _priority,
                                  dropdownColor: Theme.of(context).cardColor,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  items: ['Low', 'Medium', 'High']
                                      .map((level) => DropdownMenuItem(
                                            value: level,
                                            child: Text(level),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _priority = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<JobStatus>(
                                  value: _status,
                                  dropdownColor: Theme.of(context).cardColor,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                  items: JobStatus.values
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              _formatStatusText(status),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) async {
                                    if (value != null && value != _status) {
                                      final confirmed =
                                          await _confirmStatusChange(
                                              context, value);
                                      if (confirmed) {
                                        setState(() {
                                          _status = value;
                                        });
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dates Section
                      Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDateButton('Start Date', _startDate, 'start'),
                      const SizedBox(height: 16),
                      _buildDateButton('Due Date', _dueDate, 'due'),
                      const SizedBox(height: 16),
                      _buildDateButton(
                          'Complete Date', _completeDate, 'complete'),
                      const SizedBox(height: 20),

                      // Quality Metrics
                      Text(
                        'Quality Metrics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Count',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _goodController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bad Count',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: css.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _badController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: css.darkGrey,
                        ),
                      ),

                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Enter any notes or comments about this job',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _handleUpdate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    css.CSS.lsiTheme.secondaryHeaderColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Update Job'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatStatusText(JobStatus status) {
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
}

/// Formats ISO date string to readable format
String formatDate(String isoDate) {
  if (isoDate.isEmpty) return 'Not set';
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  } catch (e) {
    return isoDate;
  }
}

// Legacy function - priority is now stored as String directly
String parsePriority(dynamic priority) {
  if (priority is String) return priority;
  // For backwards compatibility with old int values
  if (priority is int) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
      case 3:
        return 'Medium';
      case 4:
      case 5:
        return 'High';
      default:
        return 'Medium';
    }
  }
  return 'Medium';
}

/// Status badge widget
Widget buildStatusBadge(JobStatus status) {
  Color badgeColor;
  String statusText;

  switch (status) {
    case JobStatus.notStarted:
      badgeColor = Colors.grey;
      statusText = 'Not Started';
      break;
    case JobStatus.partsReceived:
      badgeColor = Colors.purple;
      statusText = 'Parts Received';
      break;
    case JobStatus.inProgress:
      badgeColor = Colors.blue;
      statusText = 'In Progress';
      break;
    case JobStatus.completed:
      badgeColor = Colors.green;
      statusText = 'Completed';
      break;
    case JobStatus.skipped:
      badgeColor = Colors.orange;
      statusText = 'Skipped';
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: badgeColor),
    ),
    child: Text(
      statusText,
      style: TextStyle(
        color: badgeColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  );
}
