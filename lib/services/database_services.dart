// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:todo/models/task_model.dart';


// class DatabaseService {
//   CollectionReference todosCollection =
//       FirebaseFirestore.instance.collection("Todos");

//   Future<DocumentReference> createNewTodo({
//     required String title,
//     required String description,
//     required DateTime startDate,
//     required DateTime endDate,
 
//   }) async {
//     return await todosCollection.add({
//       "title": title,
//       "description": description,
//       "startDate": startDate,
//       "endDate": endDate,
//       "isComplete": false,
//     });
//   }

//   Future<void> completeTask(String uid) async {
//     await todosCollection.doc(uid).update({"isComplete": true});
//   }

//   Future<void> removeTodo(String uid) async {
//     await todosCollection.doc(uid).delete();
//   }

//   List<Todo> todoFromFirestore(QuerySnapshot snapshot) {
//     return snapshot.docs.map((e) {
//       Map<String, dynamic> data = e.data() as Map<String, dynamic>;
//       return Todo(
//         uid: e.id,
//         title: data["title"],
//         description: data["description"],
//         startDate: (data["startDate"] as Timestamp).toDate(),
//         endDate: (data["endDate"] as Timestamp).toDate(),
//         isComplete: data["isComplete"],
//       );
//     }).toList();
//   }

//   Stream<List<Todo>> listTodos() {
//     return todosCollection.snapshots().map(todoFromFirestore);
//   }
// }
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:todo/models/task_model.dart';

class DatabaseService {
  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("Todos");

  Future<DocumentReference> createNewTodo({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String photoPath, // Chemin de la photo
  }) async {
   
   // Upload de la photo et récupération de son URL
    return await todosCollection.add({
      "title": title,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "photoUrl": photoPath, // Ajout de l'URL de la photo dans la base de données
      "isComplete": false,
    });
  }

  Future<void> completeTask(String uid) async {
    await todosCollection.doc(uid).update({"isComplete": true});
  }

  Future<void> removeTodo(String uid) async {
    await todosCollection.doc(uid).delete();
  }

  List<Todo> todoFromFirestore(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      return Todo(
        uid: e.id,
        title: data["title"],
        description: data["description"],
        startDate: data["startDate"],
        endDate: data["endDate"],
        photoUrl: data["photoUrl"], // Récupération de l'URL de la photo depuis la base de données
        isComplete: data["isComplete"],
      );
    }).toList();
  }

  Stream<List<Todo>> listTodos() {
    return todosCollection.snapshots().map(todoFromFirestore);
  }
}
