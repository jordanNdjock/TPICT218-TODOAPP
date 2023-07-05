import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/services/database_services.dart';
import 'package:todo/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return DatabaseService().streamCategories(DatabaseService().getCurrentUserID());
});


class CategoriesPage extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _createCategory(BuildContext context, String userId) async {
  String name = _nameController.text.trim();
  String description = _descriptionController.text.trim();

  if (name.isNotEmpty && description.isNotEmpty) {
    await DatabaseService().createCategory(
      userId: userId,
      name: name,
      description: description,
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
  final categoriesStream = ref.watch(categoriesProvider);

  return Scaffold(
    appBar: AppBar(
      title: Text('Catégories'),
      backgroundColor: Color.fromARGB(255, 134, 134, 8),
    ),
    body: categoriesStream.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text('Aucune catégorie trouvée.'));
        }
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            Category category = categories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 6.0),
              child: Container(
                color: Color.fromARGB(255, 74, 147, 184), // Remplacez cette couleur par celle souhaitée
              
                child: ListTile(
                  title: Text(
                    category.title,
                    style: TextStyle(color: Colors.white), // Couleur du texte en blanc
                  ),
                  subtitle: Text(
                    category.description,
                    style: TextStyle(color: Colors.white70), // Couleur du texte en blanc
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.white70, // Couleur de l'icône de modification en bleu
                        onPressed: () => _showCategoryDialog(context, category: category),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Color.fromARGB(255, 248, 18, 18), // Couleur de l'icône de suppression en rouge
                        onPressed: () => _showDeleteConfirmationDialog(context, category),
                      ),
                    ],
                  ),
                ),
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
