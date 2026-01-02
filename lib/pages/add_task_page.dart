import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/color_constants.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategoryId;
  DateTime? reminderTime;
  bool isReminderActive = false;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  Future<void> _selectReminderTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!context.mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (!context.mounted) return;

      if (pickedTime != null) {
        setState(() {
          reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addTask(TaskProvider taskProvider) async {
    if (isLoading) return;
    if (titleController.text.isEmpty) {
      setState(() {
        errorMessage = 'Title is required';
        successMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      await taskProvider.addTask(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: selectedCategoryId,
        reminderTime: reminderTime,
        isReminderActive: isReminderActive,
      );
      setState(() {
        successMessage = 'Task added successfully';
        isLoading = false;
        titleController.clear();
        descriptionController.clear();
        selectedCategoryId = null;
        reminderTime = null;
        isReminderActive = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to add task: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: ColorConstants.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Add Task',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        backgroundColor: ColorConstants.themeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Add New Task',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: GoogleFonts.poppins(
                  color: ColorConstants.greyColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.accentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              style: GoogleFonts.poppins(color: ColorConstants.primaryColor),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: GoogleFonts.poppins(
                  color: ColorConstants.greyColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.accentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              style: GoogleFonts.poppins(color: ColorConstants.primaryColor),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: selectedCategoryId,
              hint: Text(
                'Select Category (Optional)',
                style: GoogleFonts.poppins(),
              ),
              items: categoryProvider.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorConstants.accentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                reminderTime == null
                    ? 'Select Reminder Time (Optional)'
                    : DateFormat.yMMMd().add_jm().format(reminderTime!),
                style: GoogleFonts.poppins(color: ColorConstants.greyColor),
              ),
              trailing: const Icon(
                Icons.calendar_today,
                color: ColorConstants.greyColor,
              ),
              onTap: () => _selectReminderTime(context),
            ),
            CheckboxListTile(
              title: Text(
                'Enable Reminder',
                style: GoogleFonts.poppins(color: ColorConstants.primaryColor),
              ),
              value: isReminderActive,
              onChanged: (value) {
                setState(() {
                  isReminderActive = value ?? false;
                });
              },
              activeColor: ColorConstants.accentColor,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : () => _addTask(taskProvider),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add Task',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    color: ColorConstants.errorColor,
                    fontSize: 14,
                  ),
                ),
              ),
            if (successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  successMessage!,
                  style: GoogleFonts.poppins(
                    color: ColorConstants.successColor,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
