import 'package:flutter/material.dart';
import 'package:todo/services/database_services.dart';
import 'package:todo/models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categories = []; // Liste des catégories
  final TextEditingController _nameController = TextEditingController();
   final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<Category> loadedCategories = await DatabaseService().getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _createCategory() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty) {
      await DatabaseService().createCategory(name:name, description:description);
      _nameController.clear();
      _descriptionController.clear();
      _loadCategories();
      Navigator.pop(context);
    }
  }

  Future<void> _updateCategory(Category category) async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty) {
      await DatabaseService().updateCategory(categoryID: category.categoryID, name: name, description: description);
      _nameController.clear();
      _descriptionController.clear();
      _loadCategories();
      Navigator.pop(context);
    }
  }

  Future<void> _deleteCategory(Category category) async {
    await DatabaseService().deleteCategory(category.categoryID);
    _loadCategories();
  }

  void _showCategoryDialog({Category? category}) {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 134, 134, 8), // Modifier la couleur du bouton
            ),
            onPressed: () {
              if (category != null) {
                _updateCategory(category);
              } else {
                _createCategory();
              }
            },
            child: Text(category != null ? 'Modifier' : 'Créer'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 134, 134, 8), // Modifier la couleur du texte du bouton
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      );
    },
  );
}

void _showDeleteConfirmationDialog(Category category) {
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
              _deleteCategory(category);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catégories'),
        backgroundColor: Color.fromARGB(255, 134, 134, 8),
       
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          Category category = categories[index];
          return ListTile(
            title: Text(category.title),
            subtitle: Text(category.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showCategoryDialog(category: category),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(category),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Color.fromARGB(255, 134, 134, 8),
        child: Icon(Icons.add),
      ),
    );
  }
}
