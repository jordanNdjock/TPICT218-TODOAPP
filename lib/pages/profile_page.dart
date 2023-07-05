// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:todo/pages/edit_profile_page.dart';
// import 'package:todo/widget/appbar_widget.dart';
// import 'package:todo/widget/button_widget.dart';
// import 'package:todo/widget/numbers_widget.dart';
// import 'package:todo/widget/profile_widget.dart';

// class ProfilePage extends StatefulWidget {
//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   @override
//   Widget build(BuildContext context) {
//      User? user = FirebaseAuth.instance.currentUser;
//   String ? useremail = user!.email;

//     return Scaffold(
//       appBar: buildAppBar(context),
//       body: ListView(
//         physics: BouncingScrollPhysics(),
//         children: [
//           const SizedBox(height: 24),
//           buildName(user),
//           const SizedBox(height: 24),
//           // Center(child: buildUpgradeButton()),
//           const SizedBox(height: 24),
//           NumbersWidget(),
//           const SizedBox(height: 48),
          
//         ],
//       ),
//     );
//   }
 
//   Widget buildName(User user) => Column(
//         children: [
//           Text(
//             user.email!,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             user.uid,
//             style: TextStyle(color: Colors.grey),
//           )
//         ],
//       );

 
// }

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/pages/edit_profile_page.dart';
import 'package:todo/widget/appbar_widget.dart';
import 'package:todo/widget/button_widget.dart';
import 'package:todo/widget/numbers_widget.dart';
import 'package:todo/widget/profile_widget.dart';

final authProvider = Provider((_) => FirebaseAuth.instance.currentUser);

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
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
          buildUpdateButton(),
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      // Implement the logic to upload the selected image
    }
  }

  Widget buildEmailTextField(String? userEmail) {
    return TextFormField(
      initialValue: userEmail,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildNameTextField(User? user) {
    return TextFormField(
      initialValue: user?.displayName,
      decoration: InputDecoration(
        labelText: 'Name',
        hintText: 'Enter your name',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildUpdateButton() {
    return ElevatedButton(
      onPressed: () {
        // Implement the logic to update the user's profile
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
          onPressed: () {
            // Implement the logic to sign out the user
          },
          icon: Icon(Icons.logout),
        ),
      ],
    );
  }
}
