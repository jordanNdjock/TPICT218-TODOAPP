
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:todo/pages/edit_profile_page.dart';
// import 'package:todo/widget/appbar_widget.dart';
// import 'package:todo/widget/button_widget.dart';
import 'package:todo/widget/numbers_widget.dart';
import 'package:todo/services/database_services.dart';

import 'log_in_page.dart';
// import 'package:todo/widget/profile_widget.dart';

final authProvider = Provider((_) => FirebaseAuth.instance.currentUser);

class ProfilePage extends ConsumerWidget {

 final TextEditingController _nameController = TextEditingController();
 final TextEditingController _passwordController = TextEditingController();

Future<void> updateUser(String? uid, String name, String password ) async {

  DocumentReference userRef = DatabaseService().usersCollection.doc(uid);

  // Créer un map contenant les données à mettre à jour
  Map<String, dynamic> updatedData = {};
  if (name.isNotEmpty) {
    updatedData['nom'] = name;
  }
  if (password.isNotEmpty) {
    updatedData['password'] = password;
  }

  await userRef.update(updatedData);
}




  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;

    return Scaffold(
      appBar: buildAppBar(context, user),
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          SizedBox(height: 24),
          buildProfileAvatar(context, user),
          SizedBox(height: 34),
          buildEmailTextField(userEmail),
          SizedBox(height: 12),
          buildNameTextField(user),
          SizedBox(height: 12),
          buildPasswordTextField(),
          SizedBox(height: 24),
          buildUpdateButton(userEmail,_nameController.text,_passwordController.text),
          SizedBox(height: 48),
          NumbersWidget(),
          SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget buildProfileAvatar(BuildContext context, User? user) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: CircleAvatar(
        radius: 50,
        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
        child: user?.photoURL == null ? Icon(Icons.person, size: 50, color: Colors.grey) : null,
      ),
    );
  }

 Future<void> _pickImage(BuildContext context) async {
  final picker = ImagePicker();
  final pickedImage = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Choose Image Source'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
          child: Text('Gallery'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ImageSource.camera),
          child: Text('Camera'),
        ),
      ],
    ),
  );

  if (pickedImage != null) {
    final pickedFile = await picker.getImage(source: pickedImage);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      
      // Implement the logic to upload the selected image
    }
  }
}


  Widget buildEmailTextField(String? userEmail) {
    return TextFormField(
                    readOnly: true,
                    initialValue: userEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: "Entrez l'email de la tâche",
                    ),
                  );
  }

  Widget buildNameTextField(User? user) {
    return TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      hintText: 'Entrez le nom de la tâche',
                    ),
                  );
  }

  Widget buildPasswordTextField() {
    return TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      hintText: 'Entrez le nom de la tâche',
                    ),
                  );
  }

  Widget buildUpdateButton(String? userEmail, String name, String password) {
    return ElevatedButton(
      onPressed: () async {
        // Implement the logic to update the user's profile
        await updateUser(userEmail, name, password);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Update'),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, User? user) {
    return AppBar(
      title: Text('Profile'),
      actions: [
        IconButton(
          onPressed: () {
            // Implement the logic to navigate to the user list page
          },
          icon: Icon(Icons.people),
        ),
        IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  LogInPage()),
                    );
            // Implement the logic to sign out the user
          },
          icon: Icon(Icons.logout),
        ),
      ],
    );

  }
}
