import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../constants/color_constants.dart';
import 'package:todo_app/models/models.dart';
import '../providers/category_provider.dart';
import '../pages/edit_task_page.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
  final CategoryProvider categoryProvider;
  final Function(String) onDelete;
  final Function(String, bool) onToggleComplete;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.categoryProvider,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final category = categoryProvider.categories.firstWhere(
      (cat) => cat.id == task.categoryId,
      orElse: () => CategoryModel(id: '', name: '', color: '', userId: ''),
    );

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(task.id),
      background: Container(
        color: ColorConstants.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        color: task.completed
            ? ColorConstants.completedTaskColor
            : ColorConstants.incompleteTaskColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Checkbox(
            value: task.completed,
            onChanged: (value) => onToggleComplete(task.id, value ?? false),
            activeColor: ColorConstants.accentColor,
          ),
          title: Row(
            children: [
              Icon(
                task.completed ? Icons.check_circle : Icons.cancel,
                color: task.completed
                    ? ColorConstants.successColor
                    : ColorConstants.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.primaryColor,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: ColorConstants.greyColor,
                  ),
                ),
              if (category.name.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(category.color.replaceFirst('#', '0xFF')),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.completed)
                Lottie.asset(
                  'assets/animations/home.json',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              IconButton(
                icon: const Icon(Icons.edit, color: ColorConstants.greyColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskPage(task: task),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: ColorConstants.errorColor,
                ),
                onPressed: () => onDelete(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
