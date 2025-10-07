import 'package:flutter/material.dart';

class TaskForm extends StatefulWidget {
  final void Function({
    required String title,
    String? description,
    required DateTime dueDate,
    TimeOfDay? reminderTime,
  })
  onSubmit;

  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDueDate;
  final TimeOfDay? initialReminderTime;
  final String submitLabel;

  const TaskForm({
    super.key,
    required this.onSubmit,
    this.initialTitle,
    this.initialDescription,
    this.initialDueDate,
    this.initialReminderTime,
    this.submitLabel = 'Save Task',
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _dueDate = widget.initialDueDate;
    _reminderTime = widget.initialReminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _dueDate ?? now,
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? now,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _dueDate == null) {
      return;
    }
    widget.onSubmit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate!,
      reminderTime: _reminderTime,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No date selected'
                          : 'Due: ${_dueDate!.toLocal().toString().split(' ').first}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick date'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _reminderTime == null
                          ? 'No reminder time'
                          : 'Reminder: ${_reminderTime!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Pick time'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
