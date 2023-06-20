import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/services/database_services.dart';
import 'package:todo/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:ui';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  User? user = FirebaseAuth.instance.currentUser;
  String userId = user!.email!;
  return DatabaseService().getCategories(userId);
});


class CategoriesPage extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  CategoriesPage({super.key});


//   Future<void> _createCategory(BuildContext context, String userId) async {
//   String name = _nameController.text.trim();
//   String description = _descriptionController.text.trim();

//   if (name.isNotEmpty && description.isNotEmpty) {
//     await DatabaseService().createCategory(
//       userId: userId,
//       name: name,
//       description: description,
//     );
//     _nameController.clear();
//     _descriptionController.clear();
//   }
// }
List<int> categoryColors = [
  Colors.red.value,
  Colors.blue.value,
  Colors.green.value,
  Colors.yellow.value,
];

Future<void> _createCategory(BuildContext context, String userId) async {
  String name = _nameController.text.trim();
  String description = _descriptionController.text.trim();

  if (name.isNotEmpty && description.isNotEmpty) {
    int colorIndex = Random().nextInt(categoryColors.length);
    categoryColors.add(colorIndex); // Ajouter l'index de couleur à la liste
    await DatabaseService().createCategory(
      userId: userId,
      name: name,
      description: description,
      // Ne pas enregistrer l'index de couleur dans la classe Category
    );
    _nameController.clear();
    _descriptionController.clear();
  }
}


  Future<void> _updateCategory(BuildContext context, Category category,String userId) async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty) {
      await DatabaseService().updateCategory(
        userId: userId,
        categoryID: category.categoryID,
        name: name,
        description: description,
      );
      _nameController.clear();
      _descriptionController.clear();
    }
  }

  Future<void> _deleteCategory(BuildContext context, Category category) async {
    await DatabaseService().deleteCategory(category.categoryID);
  }

 void _showCategoryDialog(BuildContext context, {Category? category}) {
  String dialogTitle = category != null ? 'Modifier la catégorie' : 'Créer une catégorie';
  String name = category != null ? category.title : '';
  String description = category != null ? category.description : '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(dialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController..text = name,
              decoration: InputDecoration(
                labelText: 'Nom',
              ),
            ),
            TextField(
              controller: _descriptionController..text = description,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 134, 134, 8)),
            ),
            onPressed: () async {
              String name = _nameController.text.trim();
              String description = _descriptionController.text.trim();
              User? user = FirebaseAuth.instance.currentUser;

              if (name.isNotEmpty && description.isNotEmpty && user != null) {
                if (category != null) {
                  await _updateCategory(context, category,user.email!);
                } else {
                  await _createCategory(context,user.email!);
                }
                _nameController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(category != null ? 'Modifier' : 'Créer'),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 134, 134, 8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      );
    },
  );
}


  void _showDeleteConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer la catégorie "${category.title}" ?'),
          actions: [
            ElevatedButton(
               style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 134, 134, 8), // Modifier la couleur du texte du bouton
            ),
              onPressed: () {
                _deleteCategory(context, category);
                Navigator.pop(context);
              },
              child: Text('Supprimer'),
            ),
            TextButton(
               style: TextButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 134, 134, 8), // Modifier la couleur du texte du bouton
            ),
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Catégories'),
        backgroundColor: Color.fromARGB(255, 134, 134, 8),
      ),
      body: categoriesAsyncValue.when(
        data: (categories) {
          return ListView.builder(
  itemCount: categories.length,
  itemBuilder: (BuildContext context, int index) {
    Category category = categories[index];
    int colorIndex = categoryColors[index];
    Color categoryColor = Color(categoryColors[colorIndex]);

    return ListTile(
      title: Text(category.title),
      subtitle: Text(category.description),
      tileColor: categoryColor, // Couleur de fond du ListTile

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showCategoryDialog(context, category: category),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context, category),
          ),
        ],
      ),
    );
  },
);

        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Une erreur s\'est produite')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: Color.fromARGB(255, 134, 134, 8),
        child: Icon(Icons.add),
      ),
    );
  }
}
