import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/planner_provider.dart';
import '../../../core/models/models.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskSheet(context),
          ),
        ],
      ),
      body: Consumer<PlannerProvider>(
        builder: (context, provider, child) {
          final tasks = provider.todayTasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 16),
                  Text('No tasks for today', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAddTaskSheet(context),
                    child: const Text('Add your first task'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTimelineTask(context, task, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimelineTask(BuildContext context, Task task, PlannerProvider provider) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 72,
            child: Column(
              children: [
                Text(
                  DateFormat('h:mm').format(task.scheduledTime),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateFormat('a').format(task.scheduledTime),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 4,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                  ),
                ),
                child: InkWell(
                  onTap: () => provider.toggleTaskCompletion(task.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              task.subject,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (task.isCompleted)
                              Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Theme.of(context).disabledColor : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              '${task.durationMinutes} min',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  int _duration = 25;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PlannerProvider>(context, listen: false);
    final now = DateTime.now();

    // Auto-schedule after the last task today, or next hour if empty
    DateTime scheduledTime;
    final todayTasks = provider.todayTasks;
    if (todayTasks.isNotEmpty) {
      final lastTask = todayTasks.last;
      scheduledTime = lastTask.scheduledTime.add(Duration(minutes: lastTask.durationMinutes + 10)); // 10 min buffer
    } else {
      scheduledTime = DateTime(now.year, now.month, now.day, now.hour + 1);
    }

    provider.addTask(
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        subject: _subjectController.text,
        scheduledTime: scheduledTime,
        durationMinutes: _duration,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Task', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
          Text('Duration: $_duration minutes', style: Theme.of(context).textTheme.bodyLarge),
          Slider(
            value: _duration.toDouble(),
            min: 10,
            max: 120,
            divisions: 11,
            label: '$_duration min',
            onChanged: (val) {
              setState(() => _duration = val.toInt());
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Add to Plan'),
            ),
          ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
