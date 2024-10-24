import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import 'add_edit_reminder.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({super.key, required this.reminderId});

  final int reminderId;

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DbHelper.getRemindersById(widget.reminderId),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),
          );
        }

        final Map<String, dynamic> reminder = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.teal),
            title: const Text(
              'Reminder Details',
              style: TextStyle(color: Colors.teal),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetailCard(
                  label: 'Title',
                  icon: Icons.title,
                  content: reminder['title'].toString(),
                ),
                const SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Description',
                  icon: Icons.description,
                  content: reminder['description'].toString(),
                ),
                const SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Category',
                  icon: Icons.category,
                  content: reminder['category'].toString(),
                ),
                const SizedBox(height: 20),
                _buildDetailCard(
                  label: 'Reminder Time',
                  icon: Icons.access_time,
                  content: DateFormat('yyyy-MM-dd hh:mm a').format(
                    DateTime.parse(reminder['reminderTime'].toString()),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                  context,
                  // ignore: inference_failure_on_instance_creation, always_specify_types
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        AddEditReminderScreen(reminderId: widget.reminderId),
                  ));
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  ///
  Widget _buildDetailCard(
      {required String label,
      required IconData icon,
      required String content}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
