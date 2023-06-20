enum TodoStatus { pending, inProgress, completed }

class Todo {
  String uid;
  String title;
  String description;
  String photoUrl;
  String endDate;
  TodoStatus status;
  final String categoryID;
  List<String> participants;
  String userID;
  String startDate;

  Todo({
    required this.uid,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.endDate,
    required this.categoryID,
    required this.status,
    required this.participants, 
    required this.userID,
    required this.startDate,
  });
}
