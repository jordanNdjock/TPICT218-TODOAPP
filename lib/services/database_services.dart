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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  CollectionReference todosCollection = FirebaseFirestore.instance.collection("Todos");
  CollectionReference categoriesCollection = FirebaseFirestore.instance.collection("Categories");

  Future<DocumentReference> createNewTodo({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    required String photoPath,
    required String categoryID,
  }) async {
    // Upload de la photo et récupération de son URL

    // Création d'une nouvelle tâche avec la catégorie associée
    return await todosCollection.add({
      "title": title,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "photoUrl": photoPath,
      "isComplete": false,
      "categoryID": categoryID,
    });
  }

  Future<void> completeTask(String uid) async {
    await todosCollection.doc(uid).update({"isComplete": true});
  }

  Future<void> removeTodo(String uid) async {
    await todosCollection.doc(uid).delete();
  }

Future<void> updateTodo(String uid, {String? name, String? description}) async {
  DocumentReference todoRef = todosCollection.doc(uid);

  // Créer un map contenant les données à mettre à jour
  Map<String, dynamic> updatedData = {};
  if (name != null) {
    updatedData['title'] = name;
  }
  if (description != null) {
    updatedData['description'] = description;
  }

  await todoRef.update(updatedData);
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
        photoUrl: data["photoUrl"],
        isComplete: data["isComplete"],
        categoryID: data["categoryID"],
      );
    }).toList();
  }

  Stream<List<Todo>> listTodos() {
    return todosCollection.snapshots().map(todoFromFirestore);
  }


Future<void> createCategory({required String userId, required String name, required String description}) async {
  DocumentReference categoryRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('categories')
      .doc();

  await categoryRef.set({
    'title': name,
    'description': description,
  });
}


  Future<void> updateCategory({required String categoryID, required String name, required String description}) async {
    await categoriesCollection.doc(categoryID).update({
      "name": name,
      "description": description,
    });
  }

  Future<void> deleteCategory(String categoryID) async {
    await categoriesCollection.doc(categoryID).delete();
  }

  List<Category> categoriesFromFirestore(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;
      return Category(
        categoryID: e.id,
        title: data["name"],
        description: data["description"],
      );
    }).toList();
  }

  Stream<List<Category>> listCategories() {
    return categoriesCollection.snapshots().map(categoriesFromFirestore);
  }
  // Future<List<Category>> getCategories() async {
  //   QuerySnapshot snapshot = await categoriesCollection.get();
  //   return categoriesFromFirestore(snapshot);
  // }
  Future<List<Category>> getCategories(String userId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('categories')
      .get();

  List<Category> categories = snapshot.docs.map((doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      categoryID: doc.id,
      title: data['title'],
      description: data['description'],
    );
  }).toList();

  return categories;
}

}

