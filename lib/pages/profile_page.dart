import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:todo/model/user.dart';
import 'package:todo/pages/edit_profile_page.dart';
// import 'package:todo/utils/user_preferences.dart';
import 'package:todo/widget/appbar_widget.dart';
import 'package:todo/widget/button_widget.dart';
import 'package:todo/widget/numbers_widget.dart';
import 'package:todo/widget/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
     User? user = FirebaseAuth.instance.currentUser;
  String ? useremail = user!.email;

    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          // ProfileWidget(
          //   imagePath: user.email!,
          //   onClicked: () async {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (context) =>EditProfilePage()),
          //     );
          //   },
          // ),
          const SizedBox(height: 24),
          buildName(user),
          const SizedBox(height: 24),
          // Center(child: buildUpgradeButton()),
          const SizedBox(height: 24),
          NumbersWidget(),
          const SizedBox(height: 48),
          
        ],
      ),
    );
  }
 
  Widget buildName(User user) => Column(
        children: [
          Text(
            user.email!,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.uid,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  // Widget buildUpgradeButton() => ButtonWidget(
  //       text: ' ',
  //       onClicked: () {},
  //     );

  // Widget buildAbout(User user) => Container(
  //       padding: EdgeInsets.symmetric(horizontal: 48),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'About',
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             user.about,
  //             style: TextStyle(fontSize: 16, height: 1.4),
  //           ),
  //         ],
  //       ),
  //     );
}
