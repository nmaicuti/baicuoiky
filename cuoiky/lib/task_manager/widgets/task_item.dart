import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/priority_utils.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.priority_high,
              color: PriorityUtils.getPriorityColor(task.priority),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(task.status),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.completed ? Icons.check_circle : Icons.circle_outlined,
                color: task.completed ? Colors.green : Colors.grey,
              ),
              onPressed: () async {
                await taskProvider.updateTask(
                  Task(
                    id: task.id,
                    title: task.title,
                    description: task.description,
                    status: task.status,
                    priority: task.priority,
                    dueDate: task.dueDate,
                    createdAt: task.createdAt,
                    updatedAt: DateTime.now(),
                    assignedTo: task.assignedTo,
                    createdBy: task.createdBy,
                    category: task.category,
                    attachments: task.attachments,
                    completed: !task.completed,
                  ),
                  authProvider.token!,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskFormScreen(task: task),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await taskProvider.deleteTask(task.id, authProvider.token!);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            ),
          );
        },
      ),
    );
  }
}