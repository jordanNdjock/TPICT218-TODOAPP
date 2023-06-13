class Todo {
  String uid;
  String title;
  String description;
 String startDate;
  String endDate;
  bool isComplete;
  String photoUrl;

  Todo({
    required this.uid,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isComplete,
    required this.photoUrl, required categoryID,
  });
}
