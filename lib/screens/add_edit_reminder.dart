import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import '../services/notification_helper.dart';
import 'home_screen.dart';

class AddEditReminderScreen extends StatefulWidget {
  const AddEditReminderScreen({super.key, this.reminderId});

  final int? reminderId;

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _category = 'Work';

  DateTime _reminderTime = DateTime.now();

  ///
  @override
  void initState() {
    super.initState();

    if (widget.reminderId != null) {
      fetchReminder();
    }
  }

  ///
  Future<void> fetchReminder() async {
    try {
      final Map<String, dynamic>? data =
          await DbHelper.getRemindersById(widget.reminderId!);

      if (data != null) {
        _titleController.text = data['title'].toString();

        _descriptionController.text = data['description'].toString();

        _category = data['category'].toString();

        _reminderTime = DateTime.parse(data['reminderTime'].toString());
      }
    // ignore: empty_catches
    } catch (e) {}
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.teal),
        backgroundColor: Colors.white,
        title: Text(
          widget.reminderId == null ? 'Add Reminder' : 'Edit Reminder',
          style: const TextStyle(color: Colors.teal),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInputCard(
                  label: 'Title',
                  icon: Icons.title,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        hintText: 'Enter Title', border: InputBorder.none),
                    validator: (String? value) {
                      // ignore: unnecessary_statements
                      value!.isEmpty ? 'Please enter a title' : null;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  label: 'Description',
                  icon: Icons.description,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter Description',
                      border: InputBorder.none,
                    ),
                    validator: (String? value) {
                      // ignore: unnecessary_statements
                      value!.isEmpty ? 'Please description' : null;
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  label: 'Category',
                  icon: Icons.category,
                  // ignore: always_specify_types
                  child: DropdownButtonFormField(
                    value: _category,
                    dropdownColor: Colors.teal.shade50,
                    decoration: const InputDecoration.collapsed(hintText: ''),
                    items: <String>['Work', 'Personal', 'Health', 'Others']
                        .map((String category) => DropdownMenuItem<String>(
                            value: category, child: Text(category)))
                        .toList(),
                    onChanged: (String? value) =>
                        setState(() => _category = value!),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDateTimerPicker(
                  label: 'Date',
                  icon: Icons.calendar_today,
                  displayValue: DateFormat('yyyy-MM-dd').format(_reminderTime),
                  onPressed: _selectDate,
                ),
                const SizedBox(height: 10),
                _buildDateTimerPicker(
                  label: 'Time',
                  icon: Icons.access_time,
                  displayValue: DateFormat('hh:mm a').format(_reminderTime),
                  onPressed: _selectTime,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveReminder,
                    child: const Text('Save Reminder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildInputCard(
      {required String label, required IconData icon, required Widget child}) {
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildDateTimerPicker(
      {required String label,
      required IconData icon,
      required String displayValue,
      // ignore: inference_failure_on_function_return_type
      required Function() onPressed}) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.teal),
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _reminderTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(picked.year, picked.month, picked.day,
            _reminderTime.hour, _reminderTime.minute);
      });
    }
  }

  ///
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _reminderTime.hour, minute: _reminderTime.minute),
    );

    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(_reminderTime.year, _reminderTime.month,
            _reminderTime.day, picked.hour, picked.minute);
      });
    }
  }

  ///
  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, Object> newReminder = <String, Object>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isActive': 1,
        'reminderTime': _reminderTime.toIso8601String(),
        'category': _category,
      };

      if (widget.reminderId == null) {
        final int reminderId = await DbHelper.addReminder(newReminder);

        NotificationHelper.scheduleNotification(
            reminderId, _titleController.text, _category, _reminderTime);
      } else {
        await DbHelper.updateReminder(widget.reminderId!, newReminder);

        NotificationHelper.scheduleNotification(widget.reminderId!,
            _titleController.text, _category, _reminderTime);
      }

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        // ignore: inference_failure_on_instance_creation, always_specify_types
        MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()),
      );
    }
  }
}
