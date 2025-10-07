import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _remindersKey = 'reminders_enabled_v1';
  bool _reminders = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _reminders = prefs.getBool(_remindersKey) ?? false);
  }

  Future<void> _toggle(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
    setState(() => _reminders = value);
    if (value && mounted) {
      // Simple reminder simulation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder simulation enabled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable reminders (simulation)'),
            value: _reminders,
            onChanged: _toggle,
          ),
          const ListTile(
            title: Text('Storage method'),
            subtitle: Text('SharedPreferences (local JSON)'),
          ),
          const ListTile(title: Text('App version'), subtitle: Text('1.0.0')),
        ],
      ),
    );
  }
}
