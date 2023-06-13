import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

final userProvider = StreamProvider((ref) {
  var user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => User.fromMap(doc.data()));
});

class UserProfilePage extends ConsumerWidget {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var userAsyncValue = watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil'),
      ),
      body: userAsyncValue.when(
        data: (user) {
          _phoneController.text = user.phoneNumber;
          return Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                          )
                        : null,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      var imageFile = await ImagePicker().getImage(
                        source: ImageSource.gallery,
                      );
                      if (imageFile != null) {
                        var storageRef = FirebaseStorage.instance
                            .ref()
                            .child('users/${user.uid}/photo.jpg');
                        await storageRef.putFile(File(imageFile.path));
                        var photoUrl = await storageRef.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({'photoUrl': photoUrl});
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
              Text(user.displayName),
              Text(user.email),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({'phoneNumber': _phoneController.text});
                },
                child: Text('Enregistrer'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                child: Text('Se déconnecter'),
              )
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Text('Erreur: $error'),
      ),
    );
  }
}

class User {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String photoUrl;

  User(this.displayName, this.email, this.phoneNumber, this.photoUrl);

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['displayName'] as String,
      map['email'] as String,
      map['phoneNumber'] as String,
      map['photoUrl'] as String,
    );
  }
}
