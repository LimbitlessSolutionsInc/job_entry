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
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final JobData job;
  final int jobNumber;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<JobTimelineCard> createState() => _JobTimelineCardState();
}

class _JobTimelineCardState extends State<JobTimelineCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Get theme for adaptive colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine visual state based on job status
    final isActive = widget.job.status == JobStatus.inProgress;
    final isCompleted = widget.job.status == JobStatus.completed;
    final isStarted = widget.job.status != JobStatus.notStarted && widget.job.status != JobStatus.skipped;
    
    // Brighter opacity for all cards to make them stand out
    final opacity = 1.0; // Can adjust this value for fading out jobs

    // Determine circle color based on status - theme aware
    Color circleColor;
    Color borderColor;
    Color textColor;
    
    if (isCompleted) {
      circleColor = Colors.green;
      borderColor = Colors.green.shade700;
      textColor = Colors.white;
    } else if (isActive) {
      circleColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
      textColor = css.darkBlue;
    } else if (widget.job.status == JobStatus.partsReceived) {
      circleColor = isDark ? Colors.orange.shade700 : Colors.orange.shade100;
      borderColor = Colors.orange.shade400;
      textColor = isDark ? Colors.orange.shade100 : Colors.orange.shade900;
    } else {
      circleColor = theme.colorScheme.surfaceVariant;
      borderColor = theme.colorScheme.outline;
      textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Job card with background and elevation
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 200,
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circle with number and hover animation
                    AnimatedScale(
                      scale: _isHovering ? 1.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.jobNumber.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Job title
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.job.title ?? 'Untitled',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: (isActive || isCompleted) ? FontWeight.w600 : FontWeight.w500,
                            color: (isActive || isCompleted) 
                                ? theme.colorScheme.onSurface 
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Connecting line (except for last job)
        if (!widget.isLast)
          Opacity(
            opacity: opacity,
            child: Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(top: 24),
              color: (isCompleted) 
                  ? Colors.green 
                  : (isActive) 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }
}