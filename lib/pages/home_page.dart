import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/models/task_model.dart';
import '../widgets/task_item_widget.dart';
import 'package:todo_app/pages/pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? selectedCategoryId;
  bool? completedFilter;
  String? successMessage;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().fetchTasks();
        context.read<CategoryProvider>().fetchCategories();
      }
    });

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addTaskToList(TaskModel task, int index) {
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 300),
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    if (searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    final filteredTasks = _getFilteredTasks(taskProvider.tasks);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && taskProvider.tasks.isNotEmpty) {
        final currentListLength =
            _listKey.currentState?.widget.initialItemCount ?? 0;
        if (filteredTasks.length > currentListLength) {
          for (int i = currentListLength; i < filteredTasks.length; i++) {
            _addTaskToList(filteredTasks[i], i);
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: ColorConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: ColorConstants.themeColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My To-Do List',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
            ),
            Lottie.asset(
              'assets/animations/home.json',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.category,
              color: ColorConstants.primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCategoryPage(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                color: ColorConstants.primaryColor,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: GoogleFonts.poppins(
                  color: ColorConstants.greyColor,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: ColorConstants.greyColor2,
                prefixIcon: const Icon(
                  Icons.search,
                  color: ColorConstants.primaryColor,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: ColorConstants.primaryColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text(
                    'All',
                    style: GoogleFonts.poppins(
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  selected:
                      selectedCategoryId == null && completedFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedCategoryId = null;
                        completedFilter = null;
                      });
                      taskProvider.fetchTasks();
                    }
                  },
                  selectedColor: ColorConstants.accentColor,
                ),
                FilterChip(
                  label: Text(
                    'Completed',
                    style: GoogleFonts.poppins(
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  selected: completedFilter == true,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        completedFilter = true;
                        selectedCategoryId = null;
                      });
                      taskProvider.fetchTasks(completedFilter: true);
                    }
                  },
                  selectedColor: ColorConstants.accentColor,
                ),
                FilterChip(
                  label: Text(
                    'Incomplete',
                    style: GoogleFonts.poppins(
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  selected: completedFilter == false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        completedFilter = false;
                        selectedCategoryId = null;
                      });
                      taskProvider.fetchTasks(completedFilter: false);
                    }
                  },
                  selectedColor: ColorConstants.accentColor,
                ),
                ...categoryProvider.categories.map(
                  (category) => FilterChip(
                    label: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    selected: selectedCategoryId == category.id,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedCategoryId = category.id;
                          completedFilter = null;
                        });
                        taskProvider.fetchTasks(categoryId: category.id);
                      }
                    },
                    selectedColor: Color(
                      int.parse(category.color.replaceFirst('#', '0xFF')),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: DropdownButton<String>(
              value: taskProvider.sortBy,
              items: [
                DropdownMenuItem(
                  value: 'reminderTime',
                  child: Text(
                    'Sort by Reminder Time',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                DropdownMenuItem(
                  value: 'createdAt',
                  child: Text(
                    'Sort by Created At',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  taskProvider.setSortBy(value);
                }
              },
            ),
          ),

          if (successMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                successMessage!,
                style: GoogleFonts.poppins(
                  color: ColorConstants.successColor,
                  fontSize: 14,
                ),
              ),
            ),
          if (taskProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                taskProvider.errorMessage!,
                style: GoogleFonts.poppins(
                  color: ColorConstants.errorColor,
                  fontSize: 14,
                ),
              ),
            ),

          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      taskProvider.errorMessage != null
                          ? 'Failed to load tasks'
                          : 'No tasks found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: ColorConstants.greyColor,
                      ),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: filteredTasks.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    itemBuilder: (context, index, animation) {
                      if (index >= filteredTasks.length) {
                        return const SizedBox.shrink();
                      }
                      final task = filteredTasks[index];
                      return SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: TaskItemWidget(
                            task: task,
                            categoryProvider: categoryProvider,
                            onDelete: (taskId) async {
                              final removedIndex = filteredTasks.indexWhere(
                                (t) => t.id == taskId,
                              );
                              if (removedIndex >= 0) {
                                final removedTask = filteredTasks[removedIndex];
                                _listKey.currentState?.removeItem(
                                  removedIndex,
                                  (context, animation) => SlideTransition(
                                    position: animation.drive(
                                      Tween<Offset>(
                                        begin: Offset.zero,
                                        end: const Offset(1.0, 0.0),
                                      ).chain(
                                        CurveTween(curve: Curves.easeInOut),
                                      ),
                                    ),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: TaskItemWidget(
                                        task: removedTask,
                                        categoryProvider: categoryProvider,
                                        onDelete: (_) {},
                                        onToggleComplete: (_, __) {},
                                      ),
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                );
                                await taskProvider.deleteTask(taskId);
                                if (mounted) {
                                  setState(() {
                                    successMessage =
                                        'Task deleted successfully';
                                  });
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) {
                                        setState(() {
                                          successMessage = null;
                                        });
                                      }
                                    },
                                  );
                                }
                              }
                            },
                            onToggleComplete: (taskId, completed) async {
                              await taskProvider.updateTask(
                                taskId,
                                completed: completed,
                              );
                              if (mounted) {
                                setState(() {
                                  successMessage = completed
                                      ? 'Task marked as completed'
                                      : 'Task marked as incomplete';
                                });
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    setState(() {
                                      successMessage = null;
                                    });
                                  }
                                });
                              }
                            },
                          ).animate().fadeIn(duration: 300.ms),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: ColorConstants.primaryColor,
                  ),
                  onPressed: () async {
                    await authProvider.handleSignOut();

                    if (!context.mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskPage()),
          );
          if (result == true && mounted) {
            setState(() {
              successMessage = 'Task added successfully';
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  successMessage = null;
                });
              }
            });
            await taskProvider.fetchTasks();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
