import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../styles/globals.dart';
import '../managers/jobManager.dart';
import '../data/jobData.dart';
import '../../../../styles/savedWidgets.dart';
import 'package:css/css.dart' as css;

class JobTimelineCard extends StatefulWidget {
  const JobTimelineCard({
    super.key,
    required this.job,
    required this.jobNumber,
    required this.onTap,
  });

  final JobData job;
  final int jobNumber;
  final VoidCallback onTap;

  @override
  State<JobTimelineCard> createState() => _JobTimelineCardState();
}

class _JobTimelineCardState extends State<JobTimelineCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isActive = widget.job.status == JobStatus.inProgress;
    final isCompleted = widget.job.status == JobStatus.completed;

    Color accentColor;
    if (isCompleted) {
      accentColor = Colors.green;
    } else if (isActive) {
      accentColor = theme.colorScheme.primary;
    } else if (widget.job.status == JobStatus.partsReceived) {
      accentColor = Colors.orange.shade400;
    } else {
      accentColor = theme.colorScheme.outline;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(14),
          height: 210,
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor,
              width: _isHovering ? 2.4 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(_isHovering ? 0.6 : 0.3),
                blurRadius: _isHovering ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title + priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildPriorityIndicator(),
                  const Spacer(),
                  Icon(
                    Icons.drag_indicator,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // date/status information (only show if nonempty)
              if (_dateInfo().isNotEmpty) ...[
                Text(
                  _dateInfo(),
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              // Text(
              //   'Created by ${widget.job.createdBy} on ${formatDate(widget.job.dateCreated)}',
              //   style: TextStyle(
              //     color: Colors.white,
              //   ),
              // ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    _statusLabel(widget.job.status),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  _buildWorkerAvatars(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(JobStatus status) {
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

  /// Returns a widget showing 1/2/3 exclamation marks based on priority string.
  Widget _buildPriorityIndicator() {
    final p = widget.job.priority.toLowerCase();
    int count = 0;
    if (p == 'low') count = 1;
    if (p == 'medium') count = 2;
    if (p == 'high') count = 3;
    if (p == 'not set') count = 0;
    if (count == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (_) {
        return const Padding(
          padding: EdgeInsets.only(right: 2),
          child: Text(
            '!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        );
      }),
    );
  }

  /// Builds date info
  String _dateInfo() {
    final start = widget.job.startDate;
    final due = widget.job.dueDate;
    final complete = widget.job.completeDate;

    if (widget.job.status == JobStatus.completed && (due.isEmpty || due == '')) {
      return '${formatDate(start)} - ${formatDate(complete)}';
    }

    if (start.isNotEmpty && start != '') {
      final buf = StringBuffer('Started on ${formatDate(start)}');
      if (due.isNotEmpty && due != '') {
        buf.write(' • Due ${formatDate(due)}');
      }
      return buf.toString();
    }

    return '';
  }

  Widget _buildWorkerAvatars() {
    final workers = widget.job.workers;
    if (workers.isEmpty) return const SizedBox.shrink();

    // stack avatars with a slight overlap
    return SizedBox(
      width: workers.length * 26.0,
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < workers.length; i++)
            Positioned(
              left: i * 16.0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.grey.shade800,
                child: Text(
                  _initialsFromName(workers[i]),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // extracts initials from worker's name
  String _initialsFromName(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
