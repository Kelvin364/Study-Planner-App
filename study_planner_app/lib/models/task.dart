import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TimeOfDay? reminderTime;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? reminderTime,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminderTimeHour': reminderTime?.hour,
      'reminderTimeMinute': reminderTime?.minute,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final int? hour = json['reminderTimeHour'] as int?;
    final int? minute = json['reminderTimeMinute'] as int?;
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      reminderTime: (hour != null && minute != null)
          ? TimeOfDay(hour: hour, minute: minute)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
