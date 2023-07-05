import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/models/category_model.dart';
import 'package:todo/models/user_model.dart';
import 'dart:async';
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  // Partie Todo

  CollectionReference todosCollection = FirebaseFirestore.instance.collection("Todo");
  CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");
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

Future<void> updateTodo(String uid, {required String name, required String description, required String endDate, required String categoryID, required String participant, String? photo}) async {
  DocumentReference todoRef = todosCollection.doc(uid);

  // Créer un map contenant les données à mettre à jour
  Map<String, dynamic> updatedData = {};
  if (name.isNotEmpty) {
    updatedData['title'] = name;
  }
  if (description.isNotEmpty) {
    updatedData['description'] = description;
  }
  if (endDate.isNotEmpty) {
    updatedData['endDate'] = endDate;
  }
  if (categoryID.isNotEmpty) {
    updatedData['categoryID'] = categoryID;
  }
  if (participant.isNotEmpty) {
    updatedData['participant'] = participant;
  }
  // Vérifier si une nouvelle photo a été fournie
  if (photo != null) {
    String photoUrl = photo;
    updatedData['photoUrl'] = photoUrl;
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

Future<String> getUserName(String userID) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      String username = userData['nom'];
      return username;
    } else {
      return 'Utilisateur non trouvé';
    }
  } catch (e) {
    print('Erreur lors de la récupération du nom de l\'utilisateur : $e');
    return 'Erreur lors de la récupération du nom de l\'utilisateur';
  }
}



// ... Liste des todo
Stream<List<Todo>> listUserTodos() {
  String currentUserID = getCurrentUserID();

  Stream<List<Todo>> userTodosStream = todosCollection
      .where('userID', isEqualTo: currentUserID)
      .snapshots()
      .map(todoFromFirestore);

  Stream<List<Todo>> participantTodosStream = todosCollection
      .where('participants', arrayContains: currentUserID)
      .snapshots()
      .map(todoFromFirestore);

  StreamController<List<Todo>> controller = StreamController<List<Todo>>();

  List<Todo> userTodos = [];
  List<Todo> participantTodos = [];

  StreamSubscription<List<Todo>> userSubscription;
  StreamSubscription<List<Todo>>? participantSubscription;

  void updateTodos() {
    List<Todo> mergedTodos = userTodos + participantTodos;
    controller.add(mergedTodos);
  }

  userSubscription = userTodosStream.listen((todos) {
    userTodos = todos;
    updateTodos();
  }, onError: (error) {
    controller.addError(error);
  }, onDone: () {
    participantSubscription?.cancel();
    controller.close();
  });

  participantSubscription = participantTodosStream.listen((todos) {
    participantTodos = todos;
    updateTodos();
  }, onError: (error) {
    controller.addError(error);
  }, onDone: () {
    userSubscription.cancel();
    controller.close();
  });

  return controller.stream;
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
      "title": name,
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
        title: data["title"],
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
Stream<List<Category>> streamCategories(String userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('categories')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Category(
        categoryID: doc.id,
        title: data['title'],
        description: data['description'],
      );
    }).toList();
  });
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

Future<String?> VerifgetCategoryByName(String userID, String categoryID) async {
  CollectionReference userCategoriesCollection =
      usersCollection.doc(getCurrentUserID()).collection('categories');

  QuerySnapshot snapshot = await userCategoriesCollection.get();

  for (DocumentSnapshot doc in snapshot.docs) {
    Map<String, dynamic> categoryData = doc.data() as Map<String, dynamic>;
    if (doc.id == categoryID) {
      String categoryName = categoryData['title'];
      return categoryName;
    }
  }


    CollectionReference categoriesCollection =
      usersCollection.doc(userID).collection('categories');

  QuerySnapshot snapshotM = await categoriesCollection.get();

  for (DocumentSnapshot doc in snapshotM.docs) {
    Map<String, dynamic> categoryData = doc.data() as Map<String, dynamic>;
    if (doc.id == categoryID) {
      String categoryName = categoryData['title'];
      return categoryName;
    }
  }
  
  

  // Si la catégorie n'est pas trouvée dans les catégories de l'utilisateur
  // ou si l'utilisateur n'existe pas, renvoyer null
  return null;
}



Future<String?> getCategoryByName(String userID, String categoryID) async {
  CollectionReference userCategoriesCollection =
      usersCollection.doc(userID).collection('categories');

  QuerySnapshot snapshot = await userCategoriesCollection.get();

  for (DocumentSnapshot doc in snapshot.docs) {
    Map<String, dynamic> categoryData = doc.data() as Map<String, dynamic>;
    if (doc.id == categoryID) {
      String categoryName = categoryData['title'];
      return categoryName;
    }
  }

  // Si la catégorie n'est pas trouvée dans les catégories de l'utilisateur
  // ou si l'utilisateur n'existe pas, renvoyer null
  return null;
}






// Partie User

Future<List<Users>> getUsers() async {
  List<Users> userList = [];

  try {
    String currentUserID = FirebaseAuth.instance.currentUser!.email!;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = documentSnapshot.data() as  Map<String, dynamic>;
      String userID = data['email'];
      String username = data['nom'];

      // Vérifie si l'utilisateur courant est différent de l'utilisateur actuel
      if (userID != currentUserID) {
        Users user = Users(userID: userID, username: username);
        userList.add(user);
      }
    }
  } catch (e) {
    print('Error getting users: $e');
  }

  return userList;
}




}

