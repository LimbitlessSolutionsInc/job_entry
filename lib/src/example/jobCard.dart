import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../styles/globals.dart';
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
            color: theme.cardColor.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor,
              width: _isHovering ? 2.4 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovering ? 0.14 : 0.08),
                blurRadius: _isHovering ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _statusLabel(widget.job.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
}
