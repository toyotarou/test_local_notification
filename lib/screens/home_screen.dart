import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../extensions/extensions.dart';
import '../services/notification_helper.dart';
import '../services/permission_handler.dart';
import 'add_edit_reminder.dart';
import 'reminder_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = <Map<String, dynamic>>[];

  ///
  @override
  void initState() {
    super.initState();

    requestNotificationPermissions();

    _loadReminders();
  }

  ///
  Future<void> _loadReminders() async {
    final List<Map<String, dynamic>> reminders = await DbHelper.getReminders();

    setState(() => _reminders = reminders);
  }

  ///
  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);

    if (isActive) {
      final Map<String, dynamic> reminder =
          _reminders.firstWhere((Map<String, dynamic> rem) => rem['id'] == id);

      NotificationHelper.scheduleNotification(
        id,
        reminder['title'].toString(),
        reminder['category'].toString(),
        DateTime.parse(reminder['reminderTime'].toString()),
      );
    } else {
      NotificationHelper.cancelNotification(id);
    }

    _loadReminders();
  }

  ///
  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);

    NotificationHelper.cancelNotification(id);

    _loadReminders();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Reminders',
            style: TextStyle(color: Colors.teal),
          ),
          iconTheme: const IconThemeData(color: Colors.teal),
        ),
        body: _reminders.isEmpty
            ? const Center(
                child: Text(
                  'No Reminders Found',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              )
            : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> reminder = _reminders[index];

                  return Dismissible(
                    key: Key(reminder['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return _showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (DismissDirection direction) {
                      _deleteReminder(reminder['id'].toString().toInt());

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder Deleted')),
                      );
                    },
                    child: Card(
                      color: Colors.teal.shade50,
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            // ignore: inference_failure_on_instance_creation, always_specify_types
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ReminderDetailScreen(
                                reminderId: reminder['id'].toString().toInt(),
                              ),
                            ),
                          );
                        },
                        leading: const Icon(Icons.notifications, color: Colors.teal),
                        title: Text(
                          reminder['title'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          "Category: ${reminder['category']}",
                          style: const TextStyle(),
                        ),
                        trailing: Switch(
                          value: reminder['isActive'] == 1,
                          activeColor: Colors.teal,
                          inactiveTrackColor: Colors.white,
                          inactiveThumbColor: Colors.black54,
                          onChanged: (bool value) {
                            _toggleReminder(
                                reminder['id'].toString().toInt(), value);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              // ignore: inference_failure_on_instance_creation, always_specify_types
              MaterialPageRoute(
                builder: (BuildContext context) => const AddEditReminderScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  ///
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext content) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Reminder'),
          content: const Text('Are your sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // don't delete
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // confirm delete
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
