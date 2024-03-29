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
import 'package:todo/models/user_model.dart';
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
  _clearText();
}

List<Category> categories = []; // Liste des catégories existantes

Future<bool?> confirmDismiss() async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Supprimer'),
          ),
        ],
      );
    },
  );
}



Future<void> _loadCategories() async {
   User? user = FirebaseAuth.instance.currentUser;
  List<Category> loadedCategories = await DatabaseService().getCategories(user!.email!);
  setState(() {
    categories = loadedCategories;
  });
}
  final TextEditingController _todoNameController = TextEditingController();
  final TextEditingController _todoDescController = TextEditingController();
  final  TextEditingController _todoEndDateController =  TextEditingController();
  final TextEditingController _todoNameModifController = TextEditingController();
  final TextEditingController _todoDescModifController = TextEditingController();
  final  TextEditingController _todoEndDateModifController =  TextEditingController();
  final  TextEditingController _todoPartController =  TextEditingController();
 
  File? photoFile;
  bool isComplet = false;
  bool circular = false;

  void _clearText() {
    _todoNameController.clear();
     _todoDescController.clear();
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
double calculatePercentage(
      String startStr, String endStr, String currentStr) {

    DateFormat formatter = DateFormat('dd-MM-yyyy');
    DateTime start = formatter.parse(startStr);
    DateTime end = formatter.parse(endStr);
    DateTime current = DateTime.parse(currentStr);

    if (current.isBefore(start)) {
      return 0; // Si la date actuelle est avant la date de début, renvoyer 0
    } else if (current.isAfter(end)) {
      return 1; // Si la date actuelle est après la date de fin, renvoyer 100
    } else {
      // Calculer le pourcentage à l'aide de la différence entre les dates
      final totalDuration = end.difference(start).inMilliseconds;
      final elapsedDuration = current.difference(start).inMilliseconds;
      final percent = (elapsedDuration / totalDuration);
      return percent;
    }
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
      
    
      
      SingleChildScrollView(
       
      child : Column(
        children: [
          const SizedBox(
            height: 30,
          ),

StreamBuilder<List<Todo>>(
  stream: DatabaseService().listUserTodos(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child:CircularProgressIndicator(
        color: Colors.blue,
      ),);
    }
    if (!snapshot.hasData) {
      return Text('No data available');
    }
    List<Todo> todos = snapshot.data!;

    Future<bool?> confirmDismiss() async {
      return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Supprimer'),
              ),
            ],
          );
        },
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 600),

      child: SafeArea(
      child: SingleChildScrollView(
         child: Scrollbar(
          // thumbVisibility: true,
          // thickness: 6,
          // radius: const Radius.circular(3),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey[800],
          ),
          itemCount: todos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Todo todo = todos[index];
            String status = todo.status.toString();
            bool isComplete = status == TodoStatus.completed.toString();
            String now = DateTime.now().toString();
            double progress = calculatePercentage(todo.startDate, todo.endDate, now);
            Color progressColor;
             if (progress >= 0.75) {
              progressColor = Colors.red;
            } else if (progress >= 0.5) {
              progressColor = Colors.purple;
            } else if(progress == 1.0){
              progressColor = Colors.red;
            }
            else {
              progressColor = Colors.orange;
            }
            return Dismissible(
              key: Key(todo.uid),
              background: Container(
                padding: const EdgeInsets.only(left: 20),
                alignment: Alignment.centerLeft,
                color: Colors.red,
                child: const Icon(Icons.delete),
              ),
              confirmDismiss: (direction) async {
                return await confirmDismiss();
              },
              onDismissed: (direction) async {
                bool? confirmDelete = await confirmDismiss();
                if (confirmDelete != null && confirmDelete) {
                  await DatabaseService().removeTodo(todo.uid);
                }
              },
              child: GestureDetector( // Ajoutez un GestureDetector ici
     onTap: () async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: isComplete
              ? Text('Voulez-vous marquer cette tâche comme "non complétée" ?')
              : Text('Voulez-vous marquer cette tâche comme "complétée" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(isComplete ? 'Marquer comme non complétée' : 'Marquer comme complétée'),
            ),
          ],
        );
      },
    );
    if (confirmAction) {
      String newStatus = isComplete ? TodoStatus.inProgress.toString().split('.').last : TodoStatus.completed.toString().split('.').last;
      DatabaseService().updateTodoStatus(todo.uid, newStatus);
    }
  },
              child :Container(
               
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isComplete ? Colors.green : Colors.yellow,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  
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
                          color: isComplete ? Color.fromARGB(255, 243, 243, 243) : Color.fromARGB(255, 58, 58, 58),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        todo.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                     
                      FutureBuilder<Category?>(
                            future: DatabaseService().getCategoryById(todo.categoryID),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox();
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                return FutureBuilder<String?>(
                                  future: DatabaseService().getCategoryByName(todo.userID,todo.categoryID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    if (!snapshot.hasData || snapshot.data == null) {
                                      return Text(
                                        'Categorie non trouvée ou supprimée',
                                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                      );
                                    }

                                    String categoryName = snapshot.data!;
                                    return Text(
                                      'Categorie: $categoryName',
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    );
                                  },
                                );
                              }

                          Category? category = snapshot.data!;
                          return Text(
                            'Categorie: ${category.title}',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          );
                        },
                      ),


                    FutureBuilder<List<String>>(
                         future:  Future.wait(todo.participants.map((participantID) async {
                                if (participantID == DatabaseService().getCurrentUserID()) {
                                  return 'Moi';
                                } else {
                                  return await DatabaseService().getUserName(participantID);
                                }
                              })),
                          builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox();
                          }
                          if (snapshot.hasError) {
                            return Text('Erreur : ${snapshot.error}');
                          }
                          if (!snapshot.hasData) {
                            return Text('Aucun participant trouvé');
                          }
                          List<String> participantNames = snapshot.data!;
                          return Text('Participants : ${participantNames.join(', ')}',
                          style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                          );
                              },
                            ),
                      Text(
                        'Date de debut: ${todo.startDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        'Date de fin: ${todo.endDate}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height:05),
                     
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: 05,
                        width: MediaQuery.of(context).size.width * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.purple,
                              Colors.white,
                            ],
                            stops: [
                              0.0,
                              progress,
                              progress,
                            ],
                          ),
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditTodoBottomSheet(context, todo);
                    },
                  ),
                ),
              ),
            ),
            );
          },
        ),
         ),
      ),
      ),
    );
  },
),

        ],
      ),
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
        ),
      ),
    ));
  }




Future<void> _showEditTodoBottomSheet(BuildContext context, Todo todo) async {
  _todoNameModifController.text = todo.title;
  _todoDescModifController.text = todo.description;
  _todoEndDateModifController.text = todo.endDate;
  var selected = await DatabaseService().VerifgetCategoryByName(todo.userID,todo.categoryID);
  var selectedCategory= todo.categoryID;
List<String> participantNames = [];
for (String participantID in todo.participants) {
  if (participantID == DatabaseService().getCurrentUserID()) {
    participantNames.add('moi');
  } else {
    String participantName = await DatabaseService().getUserName(participantID);
    participantNames.add(participantName);
  }
}

_todoPartController.text = participantNames.join(",");

  File? newPhotoFile;

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Container(
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
                  GestureDetector(
                    onTap: () async {
                      final imagePicker = ImagePicker();
                      final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        setState(() {
                          newPhotoFile = File(pickedImage.path);
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
                                backgroundImage: (newPhotoFile != null)
                                    ? FileImage(newPhotoFile!) 
                                    : (todo.photoUrl != null)
                                            ? NetworkImage(todo.photoUrl) as ImageProvider<Object>? 
                                            : null,
                                child: (newPhotoFile == null &&
                                        todo.photoUrl == null)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              (newPhotoFile != null)
                                  ? Positioned(
                                      top: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              newPhotoFile = null;
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _todoNameModifController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      hintText: 'Entrez le nom de la tâche',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _todoDescModifController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Entrez la description de la tâche',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    controller: _todoPartController,
                    decoration: InputDecoration(
                      labelText: 'Participant',
                      hintText: 'Entrez le nom du participant',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                        controller: _todoEndDateModifController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date de fin',
                          hintText: 'Entrez la date de fin de la tâche',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          DateTime initialDate = DateTime.now();
                          if (_todoEndDateModifController.text.isNotEmpty) {
                            try {
                              initialDate = DateTime.parse(_todoEndDateModifController.text);
                            } catch (e) {
                              print(e);
                            }
                          }

                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2100),
                          );

                          if (selectedDate != null) {
                            final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                            _todoEndDateModifController.text = formattedDate;
                          }
                        },
                      ),


                  SizedBox(height: 8),
                 DropdownButtonFormField<String>(
                      value: null,
                      
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.categoryID,
                          child: Text(category.title),
                        );
                      }).toList(),
                       onChanged: (Value) {
                      setState(() {
                        selectedCategory = Value!;
                      });
                    },
                      decoration: InputDecoration(
                        labelText: selected,
                        hintText: 'Sélectionnez une catégorie',
                      ),
                    ),

                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff3B999B),
                    ),
                    onPressed: () async {
                      // Appeler la méthode de mise à jour de la tâche dans DatabaseService
                      DatabaseService().updateTodo(
                        todo.uid,
                        name: _todoNameModifController.text,
                        description: _todoDescModifController.text,
                        endDate: _todoEndDateModifController.text,
                        categoryID: selectedCategory,
                        participant: _todoPartController.text,
                        photo: (newPhotoFile == null) ? todo.photoUrl : await _uploadPhoto(newPhotoFile!),
                      );
                      Navigator.pop(context); // Fermer la bottom sheet
                    },
                    child: Text('Modifier'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}





// Modal de creation de la todo


void _fModalBottomSheet() {
  
  DateTime endDate = DateTime.now();
   // Liste des catégories existantes
  String selectedCategory = ''; // Catégorie sélectionnée

List<Users> userList = []; // Liste des utilisateurs
  List<String> selectedParticipants = []; // Participants sélectionnés

  void getUsers() async {
    userList = await DatabaseService().getUsers();
  }

  getUsers();

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
              height:690,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('veuillez remplir tous les champs (les participants sont facultatifs !)'),
                  const SizedBox(
                    height: 20,
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
                      child: DropdownButtonFormField<String>(
                        value: null,
                        onChanged: (value) {
                          setState(() {
                            selectedParticipants.add(value!);
                          });
                        },
                        items: userList.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.userID,
                            child: Text(user.username),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Sélectionner des participants",
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
                initialDate: endDate,
                firstDate: DateTime(2023),
                lastDate: DateTime(2050),
              );

              if (selectedDate != null) {
                setState(() {
                  endDate = selectedDate;
                  _todoEndDateController.text =
                      DateFormat('dd-MM-yyyy').format(endDate);
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

                  Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButtonFormField<String>(
  value: null,
  onChanged: (value) {
    setState(() {
      selectedCategory = value!;
    });
  },
  items: categories.map((category) {
    return DropdownMenuItem<String>(
      value: category.categoryID,
      child: Text(category.title),
    );
  }).toList(),
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
                          String photoUrl = await _uploadPhoto(photoFile!);
      String categoryID = selectedCategory;
      String date = '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';
      String? user = FirebaseAuth.instance.currentUser?.email;
      List<String> participants = selectedParticipants;

      if (_todoNameController.text.isNotEmpty &&
      _todoDescController.text.isNotEmpty &&
      _todoEndDateController.text.isNotEmpty && categoryID.isNotEmpty && photoUrl.isNotEmpty && date.isNotEmpty) {
   
      
      await DatabaseService().createNewTodo(
        title: _todoNameController.text.trim(),
        description: _todoDescController.text.trim(),
        endDate: _todoEndDateController.text,
        photoPath: photoUrl,
        participants: participants,
        categoryID: categoryID,
        userID: user,
        startDate: date,
      );
      _todoNameController.clear();
      _todoDescController.clear();
      _todoEndDateController.clear();
      _clearText();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      setState(() {
        photoFile = null;
      });
                        
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
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
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
