import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../constants/color_constants.dart';
import '../providers/category_provider.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  Color selectedColor = ColorConstants.accentColor;
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;
  bool isDeleting = false;

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a Color', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(CategoryProvider categoryProvider) async {
    if (isLoading) return;
    if (nameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Category name is required';
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
      await categoryProvider.addCategory(
        nameController.text.trim(),
        '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      );
      setState(() {
        nameController.clear();
        selectedColor = ColorConstants.accentColor;
        successMessage = 'Category added successfully';
        isLoading = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to add category: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory(
    CategoryProvider categoryProvider,
    String categoryId,
  ) async {
    if (isDeleting) return;
    setState(() {
      isDeleting = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      await categoryProvider.deleteCategory(categoryId);
      setState(() {
        successMessage = 'Category deleted successfully';
        isDeleting = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to delete category: $e';
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: ColorConstants.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryColor,
          ),
        ),
        backgroundColor: ColorConstants.themeColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
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
                  style: GoogleFonts.poppins(
                    color: ColorConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: Text(
                    'Select Color',
                    style: GoogleFonts.poppins(color: ColorConstants.greyColor),
                  ),
                  trailing: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      border: Border.all(color: ColorConstants.softBorder),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onTap: () => _showColorPicker(context),
                ),
                const SizedBox(height: 20),
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
                    onPressed: isLoading
                        ? null
                        : () => _addCategory(categoryProvider),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Add Category',
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
          Expanded(
            child: categoryProvider.categories.isEmpty
                ? Center(
                    child: Text(
                      'No categories yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: ColorConstants.greyColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return Card(
                        elevation: 2,
                        color: ColorConstants.greyColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            category.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                          leading: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  category.color.replaceFirst('#', '0xFF'),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: ColorConstants.greyColor,
                                ),
                                onPressed: () {
                                  nameController.text = category.name;
                                  setState(() {
                                    selectedColor = Color(
                                      int.parse(
                                        category.color.replaceFirst(
                                          '#',
                                          '0xFF',
                                        ),
                                      ),
                                    );
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        'Edit Category',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              labelText: 'Category Name',
                                              labelStyle: GoogleFonts.poppins(
                                                color: ColorConstants.greyColor,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      ColorConstants.softBorder,
                                                ),
                                              ),
                                            ),
                                            style: GoogleFonts.poppins(
                                              color:
                                                  ColorConstants.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ListTile(
                                            title: Text(
                                              'Select Color',
                                              style: GoogleFonts.poppins(
                                                color: ColorConstants.greyColor,
                                              ),
                                            ),
                                            trailing: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: selectedColor,
                                                border: Border.all(
                                                  color:
                                                      ColorConstants.softBorder,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            onTap: () =>
                                                _showColorPicker(context),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (nameController.text.isEmpty) {
                                              setState(() {
                                                errorMessage =
                                                    'Category name is required';
                                              });
                                              return;
                                            }
                                            await categoryProvider.updateCategory(
                                              category.id,
                                              name: nameController.text.trim(),
                                              color:
                                                  '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                            );
                                            setState(() {
                                              successMessage =
                                                  'Category updated successfully';
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
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Update',
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: isDeleting
                                    ? const CircularProgressIndicator(
                                        color: ColorConstants.errorColor,
                                      )
                                    : const Icon(
                                        Icons.delete,
                                        color: ColorConstants.errorColor,
                                      ),
                                onPressed: isDeleting
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Delete Category',
                                              style: GoogleFonts.poppins(),
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete "${category.name}"? This will remove the category from all associated tasks.',
                                              style: GoogleFonts.poppins(),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'Cancel',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await _deleteCategory(
                                                    categoryProvider,
                                                    category.id,
                                                  );
                                                },
                                                child: Text(
                                                  'Delete',
                                                  style: GoogleFonts.poppins(
                                                    color: ColorConstants
                                                        .errorColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
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
