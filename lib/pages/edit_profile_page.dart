import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/model/user.dart';
import 'package:todo/utils/user_preferences.dart';
import 'package:todo/widget/appbar_widget.dart';
import 'package:todo/widget/profile_widget.dart';
import 'package:todo/widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {

  @override
  _EditProfilePageState createState() =>  _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage> {
  User user = UserPreferences.myUser;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: user.imagePath,
              isEdit: true,
              onClicked: () async {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label : 'Full Name',
              text:user.name,
              onChanged: (name) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
                label: 'Email',
                text: user.email,
                onChanged: (email) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'About',
              text: user.about,
              maxLines: 5,
              onChanged: (about) {},
            ),
          ],
        ),
  );
}

