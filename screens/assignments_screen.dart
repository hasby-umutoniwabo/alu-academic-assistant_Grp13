import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../utils/constants.dart';

class AssignmentsScreen extends StatelessWidget {
  // The list of all assignments (shared with main.dart)
  final List<Assignment> assignments;

  // Callback function to notify main.dart when data changes
  final VoidCallback onDataChanged;

  const AssignmentsScreen({
    super.key,
    required this.assignments,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Sort assignments: incomplete first (by due date), then completed
    final sortedAssignments = List<Assignment>.from(assignments);
    sortedAssignments.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return Scaffold(
      body: sortedAssignments.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedAssignments.length,
              itemBuilder: (context, index) {
                return _buildAssignmentCard(
                    context, sortedAssignments[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ALUColors.gold,
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add, color: ALUColors.navy),
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: ALUColors.lightGrey),
          SizedBox(height: 16),
          Text('No assignments yet',
              style: TextStyle(fontSize: 18, color: ALUColors.lightGrey)),
          SizedBox(height: 8),
          Text('Tap + to add your first assignment',
              style: TextStyle(color: ALUColors.lightGrey)),
        ],
      ),
    );
  }

  // ===== ASSIGNMENT CARD =====
  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    final daysLeft = assignment.isCompleted
        ? 0
        : assignment.dueDate.difference(DateTime.now()).inDays;
    
    final urgencyColor = assignment.isCompleted
        ? ALUColors.lightGrey
        : (daysLeft < 0
            ? ALUColors.red
            : daysLeft <= 1
                ? ALUColors.red
                : daysLeft <= 3
                    ? Colors.orange
                    : ALUColors.green);

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dueDateStr =
        '${monthNames[assignment.dueDate.month - 1]} ${assignment.dueDate.day}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: assignment.isCompleted
          ? ALUColors.darkBlue.withAlpha(128)
          : ALUColors.darkBlue,
      child: ListTile(
        // Make entire card tappable to edit
        onTap: () => _showAddEditDialog(context, assignment: assignment),
        
        // CHECKBOX: toggle completion
        leading: Checkbox(
          value: assignment.isCompleted,
          activeColor: ALUColors.gold,
          semanticLabel: assignment.isCompleted
              ? 'Mark as incomplete'
              : 'Mark as complete',
          onChanged: (value) {
            assignment.isCompleted = value ?? false;
            onDataChanged();
          },
        ),

        // TITLE (strikethrough if completed)
        title: Text(
          assignment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: assignment.isCompleted
                ? ALUColors.lightGrey
                : ALUColors.white,
            decoration: assignment.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        // SUBTITLE: course, due date, priority
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(assignment.course,
                style: const TextStyle(color: ALUColors.lightGrey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: urgencyColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Due $dueDateStr',
                      style: TextStyle(fontSize: 12, color: urgencyColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(assignment.priority).withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(assignment.priority,
                      style: TextStyle(
                          fontSize: 12,
                          color: _getPriorityColor(assignment.priority))),
                ),
              ],
            ),
          ],
        ),

        // MENU: edit and delete
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: ALUColors.lightGrey),
          onSelected: (value) {
            if (value == 'edit') {
              _showAddEditDialog(context, assignment: assignment);
            } else if (value == 'delete') {
              _confirmDelete(context, assignment);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, size: 18, color: ALUColors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: ALUColors.red))
                ])),
          ],
        ),
      ),
    );
  }

  // ===== INPUT VALIDATION HELPERS =====
  /// Checks if a string contains only letters, numbers, spaces, and basic punctuation
  /// Returns null if valid, or an error message if invalid
  String? _validateName(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return '$fieldName must be less than 100 characters';
    }
    
    // Allow letters, numbers, spaces, and common punctuation
    final validPattern = RegExp(r"^[a-zA-Z0-9\s\-\.\'\:\,\(\)\&\#\/\@\!\?]+$");
    if (!validPattern.hasMatch(value.trim())) {
      return '$fieldName contains invalid characters';
    }
    
    // Must contain at least one letter (no pure numbers like "123")
    if (!RegExp(r'[a-zA-Z]').hasMatch(value.trim())) {
      return '$fieldName must contain at least one letter';
    }
    
    return null; // Valid
  }

  // ===== ADD/EDIT DIALOG =====
  void _showAddEditDialog(BuildContext context, {Assignment? assignment}) {
    final titleController =
        TextEditingController(text: assignment?.title ?? '');
    final courseController =
        TextEditingController(text: assignment?.course ?? '');
    DateTime selectedDate = assignment?.dueDate ?? DateTime.now();
    String selectedPriority = assignment?.priority ?? 'Medium';
    final isEditing = assignment != null;

    // Track validation error messages
    String? titleError;
    String? courseError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ALUColors.darkBlue,
              title: Text(
                isEditing ? 'Edit Assignment' : 'New Assignment',
                style: const TextStyle(color: ALUColors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TITLE FIELD with validation
                    TextField(
                      controller: titleController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: 'Assignment Title *',
                        hintText: 'e.g. Assignment 2',
                        errorText: titleError,
                        counterText: '',
                      ),
                      style: const TextStyle(color: ALUColors.white),
                      onChanged: (_) {
                        // Clear error when user types
                        if (titleError != null) {
                          setDialogState(() => titleError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // COURSE FIELD with validation
                    TextField(
                      controller: courseController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: 'Course Name *',
                        hintText: 'e.g. Introduction to Flutter',
                        errorText: courseError,
                        counterText: '',
                      ),
                      style: const TextStyle(color: ALUColors.white),
                      onChanged: (_) {
                        if (courseError != null) {
                          setDialogState(() => courseError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // DUE DATE PICKER
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due Date',
                          style: TextStyle(color: ALUColors.lightGrey)),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                            color: ALUColors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_today,
                          color: ALUColors.gold),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          // Allow editing past dates when editing existing assignments
                          firstDate: isEditing
                              ? DateTime.now()
                                  .subtract(const Duration(days: 365))
                              : DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // PRIORITY DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority Level'),
                      dropdownColor: ALUColors.darkBlue,
                      items: ['High', 'Medium', 'Low'].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority,
                              style: const TextStyle(color: ALUColors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(
                            () => selectedPriority = value ?? 'Medium');
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ===== VALIDATE ALL FIELDS =====
                    final tError = _validateName(titleController.text, 'Title');
                    final cError =
                        _validateName(courseController.text, 'Course name');

                    if (tError != null || cError != null) {
                      setDialogState(() {
                        titleError = tError;
                        courseError = cError;
                      });
                      return;
                    }

                    // Check for duplicate assignments
                    final isDuplicate = assignments.any((a) =>
                        a.title.toLowerCase() ==
                            titleController.text.trim().toLowerCase() &&
                        a.course.toLowerCase() ==
                            courseController.text.trim().toLowerCase() &&
                        (!isEditing || a.id != assignment?.id));

                    if (isDuplicate) {
                      setDialogState(() {
                        titleError =
                            'Assignment with this title already exists for this course';
                      });
                      return;
                    }

                    // Save changes
                    if (isEditing && assignment != null) {
                      assignment.title = titleController.text.trim();
                      assignment.course = courseController.text.trim();
                      assignment.dueDate = selectedDate;
                      assignment.priority = selectedPriority;
                    } else {
                      assignments.add(Assignment(
                        title: titleController.text.trim(),
                        course: courseController.text.trim(),
                        dueDate: selectedDate,
                        priority: selectedPriority,
                      ));
                    }

                    onDataChanged();
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===== DELETE CONFIRMATION =====
  void _confirmDelete(BuildContext context, Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ALUColors.darkBlue,
          title: const Text('Delete Assignment',
              style: TextStyle(color: ALUColors.white)),
          content: Text(
            'Are you sure you want to delete "${assignment.title}"?',
            style: const TextStyle(color: ALUColors.lightGrey),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ALUColors.red),
              onPressed: () {
                assignments.removeWhere((a) => a.id == assignment.id);
                onDataChanged();
                Navigator.pop(context);
              },
              child: const Text('Delete',
                  style: TextStyle(color: ALUColors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return ALUColors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return ALUColors.green;
      default:
        return ALUColors.lightGrey;
    }
  }
}
