import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todo/pages/log_in_page.dart';
import 'package:todo/services/database_services.dart';
import 'package:todo/models/task_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/models/category_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  @override
void initState() {
  super.initState();
  _loadCategories();
}

List<Category> categories = []; // Liste des catégories existantes



Future<void> _loadCategories() async {
   User? user = FirebaseAuth.instance.currentUser;
  List<Category> loadedCategories = await DatabaseService().getCategories(user!.email!);
  setState(() {
    categories = loadedCategories;
  });
}
  final TextEditingController _todoNameController = TextEditingController();
  final TextEditingController _todoDescController = TextEditingController();
   final TextEditingController _todoStartDateController = TextEditingController();
  final  TextEditingController _todoEndDateController =  TextEditingController();
  final TextEditingController _todoDescriptionController = TextEditingController();
  File? photoFile;
  bool isComplet = false;
  // bool _switch = false;
  bool circular = false;

  void clearText() {
    _todoNameController.clear();
     _todoDescController.clear();
     _todoStartDateController.clear();
     _todoEndDateController.clear();
  }
  Future<String> _uploadPhoto(File photoFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child("photos/$fileName");
    UploadTask uploadTask = storageReference.putFile(photoFile);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3B999B),
        elevation: 5.0,
        automaticallyImplyLeading: false,
        title: const Text(
          "ToDo App",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _sModalBottomSheet,
              icon: const Icon(
                Iconsax.setting,
                color: Colors.white,
              ))
        ],
      ),
      body: 
      
    
      
      
      Column(
        children: [
          const SizedBox(
            height: 30,
          ),

StreamBuilder<List<Todo>>(
  stream: DatabaseService().listTodos(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator(
        color: Colors.blue,
      );
    }
    List<Todo> todos = snapshot.data!;
    
    return SizedBox(
      height: 500,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[800],
        ),
        itemCount: todos.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Todo todo = todos[index];
          
          return Dismissible(
            key: Key(todo.title),
            background: Container(
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              color: Colors.red,
              child: const Icon(Icons.delete),
            ),
            onDismissed: (direction) async {
              await DatabaseService().removeTodo(todo.uid);
            },
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: todo.isComplete ? const Color(0xff3B999B) : const Color(0xffEE5873),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListTile(
                onTap: () {
                  DatabaseService().completeTask(todo.uid);
                },
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(todo.photoUrl),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Catégorie: ${todo.uid}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  todo.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Début: ${todo.startDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      'Fin: ${todo.endDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                // Bouton de modification de la tâche
                onLongPress: () {
                  // Afficher la bottom sheet de modification de la tâche
                  _showEditTodoBottomSheet(context, todo);
                },
              ),
            ),
          );
        },
      ),
    );
  },
),



/*
          StreamBuilder<List<Todo>>(
            stream: DatabaseService().listTodos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              }
              List<Todo>? todos = snapshot.data;
              return SizedBox(
                height: 500,
                width: MediaQuery.of(context).size.height,
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[800],
                  ),
                  itemCount: todos!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(todos[index].title),
                      background: Container(
                        padding: const EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        color: Colors.red,
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (direction) async {
                        await DatabaseService().removeTodo(todos[index].uid);
                      },
                      child: todos[index].isComplete
                          ? Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: const Color(0xff3B999B),
                                  borderRadius: BorderRadius.circular(5)),
                              child: ListTile(
                                onTap: () {
                                  DatabaseService()
                                      .completeTask(todos[index].uid);
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(2),
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: todos[index].isComplete
                                      ? const Icon(
                                          Iconsax.tick_circle,
                                          color: Color(0xff3B999B),
                                        )
                                      : Container(),
                                ),
                                title: Text(
                                  todos[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[200],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: const Color(0xffEE5873),
                                  borderRadius: BorderRadius.circular(5)),
                              child: ListTile(
                                onTap: () {
                                  DatabaseService()
                                      .completeTask(todos[index].uid);
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(2),
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: todos[index].isComplete
                                      ? const Icon(
                                          Iconsax.tick_circle,
                                          color: Color(0xff3B999B),
                                        )
                                      : Container(),
                                ),
                                title: Text(
                                  todos[index].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[200],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    );
                  },
                ),
              );
            },
          ),*/
        ],
      ),


      
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color(0xff3B999B)),
        child: FloatingActionButton(
          onPressed: _fModalBottomSheet,
          tooltip: 'Increment',
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          child: const Icon(Iconsax.add, color: Colors.white,)
          // SvgPicture.asset(
          //   "assets/icons/document.svg",
          //   color: Colors.white,
          //   height: 30,
          //   width: 30,
          // ),
        ),
      ),
    ));
  }

void _showEditTodoBottomSheet(BuildContext context, Todo todo) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modifier la tâche',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _todoNameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez le nom de la tâche',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _todoDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Entrez la description de la tâche',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Appeler la méthode de mise à jour de la tâche dans DatabaseService
                DatabaseService().updateTodo(
                  todo.uid,
                  name: _todoNameController.text,
                  description: _todoDescriptionController.text,
                );
                Navigator.pop(context); // Fermer la bottom sheet
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      );
    },
  );
}


void _fModalBottomSheet() {
   DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
   // Liste des catégories existantes
  String selectedCategory = "tout"; // Catégorie sélectionnée
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0),
        topRight: Radius.circular(10.0),
      ),
    ),
    backgroundColor: const Color(0xffd9d9d9),
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      
      return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height:670,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[



                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(top: 30, left: 10),
                    child: const Text(
                      "Ajouter une tâche",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
// Déclaration de la variable photoFile

GestureDetector(
  onTap: () async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        photoFile = File(pickedImage.path);
      });
    }
  },
  child: Container(
    color: Colors.grey.shade300,
    height: 150,
    width: double.infinity,
    child: Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: photoFile != null ? FileImage(photoFile!) : null,
              child: photoFile == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    )
                  : null,
            ),
           
          ],
        ),
      ),
    ),
  ),
),





                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: _todoNameController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        hintText: "Titre de la tâche",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: const Color(0xff50C4ED).withOpacity(0),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: _todoDescController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        hintText: "Description de la tâche",
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: const Color(0xff50C4ED).withOpacity(0),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                   Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime(2023),
                lastDate: DateTime(2026),
              );

              if (selectedDate != null) {
                setState(() {
                  startDate = selectedDate;
                  _todoStartDateController.text =
                      DateFormat('yyyy-MM-dd').format(startDate);
                });
              }
            },
            child: IgnorePointer(
              child: TextField(
                controller: _todoStartDateController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: "Date de début",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: const Color(0xff50C4ED).withOpacity(0),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),

                  const SizedBox(
                    height: 20,
                  ),

                  Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: InkWell(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: endDate,
                firstDate: DateTime(2023),
                lastDate: DateTime(2026),
              );

              if (selectedDate != null) {
                setState(() {
                  endDate = selectedDate;
                  _todoEndDateController.text =
                      DateFormat('yyyy-MM-dd').format(endDate);
                });
              }
            },
            child: IgnorePointer(
              child: TextField(
                controller: _todoEndDateController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: "Date de fin",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: const Color(0xff50C4ED).withOpacity(0),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Champ pour sélectionner une photo de la galerie
                  // ElevatedButton(
                  //   onPressed: () {
                  //     _selectPhotoFromGallery();
                  //   },
                  //   child: const Text("Sélectionner une photo"),
                  // style:ElevatedButton.styleFrom(
                  //   backgroundColor: const Color(0xff3B999B),
                  // )
                  // ),

                  Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items:  [
                      const DropdownMenuItem<String>(
                        value: 'tout',
                        child: Text('Tout'),
                      ),
                      ...categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryID,
                          child: Text(category.title),
                        );
                      }).toList(),
                    ],
                decoration: InputDecoration(
                  hintText: "Sélectionner une catégorie",
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: const Color(0xff50C4ED).withOpacity(0),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xff3B999B),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                      ),
                      onPressed: () async {
                        setState(() {
                          circular = true;
                        });
                        try {
                          if (_todoNameController.text.isNotEmpty &&
      _todoDescController.text.isNotEmpty &&
      _todoStartDateController.text.isNotEmpty &&
      _todoEndDateController.text.isNotEmpty) {
   
    
      String photoUrl = await _uploadPhoto(photoFile!);
      print(photoUrl);
      String categoryID = selectedCategory;
      await DatabaseService().createNewTodo(
        title: _todoNameController.text.trim(),
        description: _todoDescController.text.trim(),
        startDate: _todoStartDateController.text,
        endDate: _todoEndDateController.text,
        photoPath: photoUrl,
        categoryID: categoryID,
      );
      Navigator.pop(context);
      setState(() {
        photoFile = null;
      });
                        _todoNameController.clear();
                        _todoDescController.clear();
                        _todoStartDateController.clear();
                        _todoEndDateController.clear();
  }
                          setState(() {
                            circular = false;
                          });
                        } catch (e) {
                          final snackbar = SnackBar(content: Text(e.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          setState(() {
                            circular = false;
                          });
                        }
                      
                      },
                      child: const Text(
                        "Ajouter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      );
    },
  );
}

// Méthode pour sélectionner une photo de la galerie
void _selectPhotoFromGallery() async {
  final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      photoFile = File(pickedFile.path);
    });
  }
  
}

  void _sModalBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      backgroundColor: const Color(0xffd9d9d9),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 40,
                      margin: const EdgeInsets.only(top: 35, left: 10),
                      child: const Text("Paramètre",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w700)),
                    ),
                    
                    // ListTile(
                    //   title: const Text("Dark mode",
                    //       style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w700)),
                    //   trailing: CupertinoSwitch(
                    //     value: _switch,
                    //     onChanged: (bool value) {
                    //       setState(() {
                    //         _switch = value;
                    //       });
                    //     },
                    //   ),
                    //   onTap: () {
                    //     setState(() {
                    //       _switch = !_switch;
                    //     });
                    //   },
                    // ),
                    Container(
                        height: 45,
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _logOutDialog();
                          },
                          child: const Text("Se Deconnecter",
                              style: TextStyle(
                                  color: Color(0xffEE5873),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                                  
                        )
                        )
                  ]),
            ),
          ]),
        );
      },
    );
  }

  void _logOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text("Do you want to really \nlog out to the ToDo?",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text("Cancel",
                    style: TextStyle(
                        color: Color(0xffEE5873),
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(
                width: 20,
              ),
              Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffFF002E)),
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xffEE5873).withOpacity(0.5)),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, elevation: 0.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  LogInPage()),
                    );
                  },
                  child: const Text("Log out",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
