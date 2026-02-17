import 'package:flutter/material.dart';
import 'package:css/css.dart' as css;
import 'package:job_entry/src/router_master.dart';

class RouterCard extends StatelessWidget {
  const RouterCard({
    super.key,
    required this.title,
    this.color,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onInfo,
    this.onArchive,
    this.onUnarchive,
  });

  final String title;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onInfo;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Router'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) {
                  onDelete!();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    
    return Card(
      color: css.chartNameGrey,
      clipBehavior: Clip.hardEdge,
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: cardColor,
          width: 8,
        ),
      ),
      child: InkWell(
        hoverColor: cardColor.withOpacity(0.2),
        splashColor: cardColor.withAlpha(30),
        onTap: onTap,
        child: Container(
          color: isSelected ? cardColor.withOpacity(0.1) : null,
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: css.chartGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                          tooltip: 'Edit',
                          iconSize: 18,
                          color: css.chartGrey,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteConfirmation(context),
                          tooltip: 'Delete',
                          iconSize: 18,
                          color: css.chartGrey,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),

                      if (onInfo != null)
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: onInfo,
                          tooltip: 'View Details',
                          iconSize: 18,
                          color: css.chartGrey,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),
                      if (onUnarchive != null)
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: onUnarchive,
                          tooltip: 'Unarchive',
                          iconSize: 12,
                          color: css.chartGrey,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
