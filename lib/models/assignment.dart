class Assignment {
    String id;
    String title;
    String course;
    DateTime dueDate;
    String priority;
    bool isCompleted;

//Constructor

Assignment({
    String? id,
    required this.title,
    required this.course,
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
}) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

//Convert Assignment to Map for JSON storage

Map<String, dynamic> toMap(){
    return {
        'id' : id,
        'title' : title,
        'course': course,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority,
        'isCompleted': isCompleted,
    }
}

}