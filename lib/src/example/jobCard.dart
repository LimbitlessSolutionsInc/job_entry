import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../styles/globals.dart';
import '../data/jobData.dart';
import '../../../../styles/savedWidgets.dart';
import 'package:css/css.dart' as css;

class JobTimelineCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // First job is lit (active), others are dimmed
    final isActive = isFirst;
    final opacity = isActive ? 1.0 : 0.4;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Job card
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 200,
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circle with number
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? css.CSS.lsiTheme.secondaryHeaderColor : Colors.grey[300],
                      border: Border.all(
                        color: isActive ? css.CSS.lsiTheme.secondaryHeaderColor : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        jobNumber.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Job title
                  SizedBox(
                    width: 80,
                    child: Text(
                      job.title ?? 'Untitled',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Connecting line (except for last job)
        if (!isLast)
          Opacity(
            opacity: opacity,
            child: Container(
              width: 40,
              height: 2,
              margin: const EdgeInsets.only(top: 24),
              color: isActive ? css.CSS.lsiTheme.secondaryHeaderColor : Colors.grey[300],
            ),
          ),
      ],
    );
  }
}