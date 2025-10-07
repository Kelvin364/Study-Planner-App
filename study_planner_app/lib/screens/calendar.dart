import 'package:flutter/material.dart';
import '../widgets/task_form.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storage = StorageService();
  List<Task> _tasks = <Task>[];
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<Task> all = await _storage.loadTasks();
    setState(() => _tasks = all);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  bool _hasTasksOn(DateTime date) {
    return _tasks.any(
      (Task t) =>
          t.dueDate.year == date.year &&
          t.dueDate.month == date.month &&
          t.dueDate.day == date.day,
    );
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final DateTime first = DateTime(month.year, month.month, 1);
    final DateTime last = DateTime(month.year, month.month + 1, 0);
    final List<DateTime> days = <DateTime>[];
    for (int i = 0; i < first.weekday - 1; i++) {
      days.add(first.subtract(Duration(days: first.weekday - 1 - i)));
    }
    for (int d = 0; d < last.day; d++) {
      days.add(DateTime(month.year, month.month, d + 1));
    }
    while (days.length % 7 != 0) {
      days.add(days.last.add(const Duration(days: 1)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> days = _daysInMonth(_focusedMonth);
    final List<Task> selectedTasks = _tasks
        .where(
          (Task t) =>
              t.dueDate.year == _selectedDate.year &&
              t.dueDate.month == _selectedDate.month &&
              t.dueDate.day == _selectedDate.day,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Center(
            child: Text(
              '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: days.length,
            itemBuilder: (BuildContext context, int index) {
              final DateTime day = days[index];
              final bool isCurrentMonth = day.month == _focusedMonth.month;
              final bool isSelected =
                  day.year == _selectedDate.year &&
                  day.month == _selectedDate.month &&
                  day.day == _selectedDate.day;
              final bool hasTasks = _hasTasksOn(day);
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isCurrentMonth ? null : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      if (hasTasks)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          Expanded(
            child: selectedTasks.isEmpty
                ? const Center(child: Text('No tasks on selected date'))
                : ListView.builder(
                    itemCount: selectedTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Task t = selectedTasks[index];
                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.description ?? ''),
                        trailing: Wrap(
                          spacing: 8,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext ctx) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(
                                          ctx,
                                        ).viewInsets.bottom,
                                      ),
                                      child: TaskForm(
                                        initialTitle: t.title,
                                        initialDescription: t.description,
                                        initialDueDate: t.dueDate,
                                        initialReminderTime: t.reminderTime,
                                        submitLabel: 'Update Task',
                                        onSubmit:
                                            ({
                                              required String title,
                                              String? description,
                                              required DateTime dueDate,
                                              TimeOfDay? reminderTime,
                                            }) async {
                                              final Task updated = t.copyWith(
                                                title: title,
                                                description: description,
                                                dueDate: dueDate,
                                                reminderTime: reminderTime,
                                              );
                                              await _storage.updateTask(
                                                updated,
                                              );
                                              await _load();
                                            },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    return AlertDialog(
                                      title: const Text('Delete task?'),
                                      content: const Text(
                                        'This action cannot be undone.',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  await _storage.deleteTask(t.id);
                                  await _load();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
