import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/category_model.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  CollectionReference todosCollection = FirebaseFirestore.instance.collection("Todo");
  
  

  Future<DocumentReference> createNewTodo({
    required String title,
    required String description,
    required String endDate,
    required String photoPath,
    required String categoryID,
    required String? userID,
    required String startDate,
    List<String> participants = const [],
  }) async {
    // Upload de la photo et récupération de son URL

    // Création d'une nouvelle tâche avec la catégorie associée
    return await todosCollection.add({
      "title": title,
      "description": description,
      "endDate": endDate,
      "photoUrl": photoPath,
      "status": TodoStatus.pending.toString().split('.').last,
      "participants": participants,
      "categoryID": categoryID,
      "userID": userID,
      "StartDate": startDate,
    });
  }

  Future<void> completeTask(String uid) async {
    await todosCollection.doc(uid).update({"status": TodoStatus.completed.toString().split('.').last});
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
      endDate: data["endDate"],
      photoUrl: data["photoUrl"],
      status: _getStatusFromString(data["status"]),
      participants: List<String>.from(data["participants"]),
      categoryID: data["categoryID"],
      userID: data["userID"], 
      startDate: data["StartDate"],// Utilise la valeur de "categoryID" provenant de la base de données
    );
  }).toList();
}

String getCurrentUserID() {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    return currentUser.email!;
  } else {
    throw Exception("No user is currently logged in.");
  }
}

  Stream<List<Todo>> listUserTodos() {
  String currentUserID = getCurrentUserID();

  return todosCollection
      .where('userID', isEqualTo: currentUserID)
      .snapshots()
      .map(todoFromFirestore);
}

  TodoStatus _getStatusFromString(String status) {
    switch (status) {
      case "pending":
        return TodoStatus.pending;
      case "inProgress":
        return TodoStatus.inProgress;
      case "completed":
        return TodoStatus.completed;
      default:
        return TodoStatus.pending;
    }
  }

Future<void> updateTodoStatus(String todoID, String newStatus) async {
    // Implémentation pour mettre à jour le statut de la tâche dans la base de données
    // ou dans toute autre source de données
    // Par exemple, si vous utilisez Firestore :
    await FirebaseFirestore.instance
        .collection('Todo')
        .doc(todoID)
        .update({'status': newStatus});
  }


Future<Category?> getCategoryById(String categoryID) async {
  // Récupération de la référence à l'utilisateur connecté
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception("No user is currently logged in.");
  }

  // Implémentation pour récupérer la catégorie à partir de la base de données
  DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.email)
      .collection('categories')
      .doc(categoryID)
      .get();

  if (categorySnapshot.exists) {
    Map<String, dynamic> categoryData = categorySnapshot.data() as Map<String, dynamic>;
    return Category(
      categoryID: categorySnapshot.id,
      title: categoryData['title'],
      description: categoryData['description'],
    );
  }

  return null; // Retourne null si la catégorie n'est pas trouvée
}






// Categorie Implementation


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


  Future<void> updateCategory({required String userId,required String categoryID, required String name, required String description}) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('categories').doc(categoryID).update({
      "name": name,
      "description": description,
    });
  }

  Future<void> deleteCategory(String categoryID) async {
   await FirebaseFirestore.instance
      .collection('users')
      .doc(getCurrentUserID())
      .collection('categories').doc(categoryID).delete();
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
    return FirebaseFirestore.instance
      .collection('users')
      .doc(getCurrentUserID())
      .collection('categories').snapshots().map(categoriesFromFirestore);
  }
 
Future<void> createDefaultCategories(String userId) async {
  List<Map<String, dynamic>> defaultCategories = [
    {
      "title": "Ecole",
      "description": "Catégorie pour les tâches liées aux études",
    },
    {
      "title": "Travail",
      "description": "Catégorie pour les tâches liées au travail",
    },
    {
      "title": "Loisir",
      "description": "Catégorie pour les tâches de loisir",
    },
  ];

  for (var categoryData in defaultCategories) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .add(categoryData);
  }
}


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

  // Ajouter les catégories par défaut si la liste est vide
  if (categories.isEmpty) {
    await createDefaultCategories(userId);
    categories = await getCategories(userId);
  }

  return categories;
}

}

