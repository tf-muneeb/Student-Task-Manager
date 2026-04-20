import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case 'High':
        return Colors.red;
      case 'Low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData get _priorityIcon {
    switch (task.priority) {
      case 'High':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'Low':
        return Icons.keyboard_double_arrow_down_rounded;
      default:
        return Icons.drag_handle_rounded;
    }
  }

  Color _getIndexColor(int index) {
    final colors = [
      const Color(0xFF4A90D9),
      const Color(0xFF27AE60),
      const Color(0xFFE67E22),
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
      const Color(0xFF1ABC9C),
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(taskDay).inDays;
    if (diff == 0) return 'Today • ${DateFormat('hh:mm a').format(date)}';
    if (diff == 1) return 'Yesterday • ${DateFormat('hh:mm a').format(date)}';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getIndexColor(index);
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade500, size: 26),
              const SizedBox(width: 10),
              const Text('Delete Task',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
            content: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                      text: '"${task.taskTitle}"',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: '? This cannot be undone.'),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx, true),
                        icon: const Icon(Icons.delete_rounded, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await FirestoreService.deleteTask(task.id);
          return true;
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.taskTitle,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    task.taskDescription,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildPriorityBadge(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 13, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatDate(task.createdAt),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildStatusBadge(),
                            const Spacer(),
                            _buildActionButton(
                              icon: Icons.edit_outlined,
                              color: const Color(0xFF4A90D9),
                              label: 'Edit',
                              onTap: onEdit,
                            ),
                            const SizedBox(width: 8),
                            _buildCompleteButton(),
                          ],
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            task.isCompleted
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            size: 12,
            color: task.isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            task.isCompleted ? 'Completed' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return GestureDetector(
      onTap: () => FirestoreService.updateTaskCompletion(
        taskId: task.id,
        isCompleted: !task.isCompleted,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? Colors.orange.withOpacity(0.10)
              : Colors.green.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              task.isCompleted
                  ? Icons.replay_rounded
                  : Icons.check_rounded,
              size: 15,
              color: task.isCompleted ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              task.isCompleted ? 'Undo' : 'Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: task.isCompleted ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _priorityColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _priorityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_priorityIcon, size: 12, color: _priorityColor),
          const SizedBox(width: 3),
          Text(task.priority,
              style: TextStyle(
                  fontSize: 11,
                  color: _priorityColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}