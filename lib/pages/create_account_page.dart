// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// // import 'package:todo/pages/home_page.dart';
// import 'package:todo/pages/myhomepage.dart';
// import 'package:todo/pages/log_in_page.dart';


// class CreateAccountPage extends StatefulWidget {
//   const CreateAccountPage({Key? key}) : super(key: key);

//   @override
//   State<CreateAccountPage> createState() => _CreateAccountPageState();
// }

// class _CreateAccountPageState extends State<CreateAccountPage> {
//   firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _pwdController = TextEditingController();

//   bool circular = false;

//   final textFieldFocusNode = FocusNode();
//   bool _obscured = false;

//   void _toggleObscured() {
//     setState(() {
//       _obscured = !_obscured;
//       if (textFieldFocusNode.hasPrimaryFocus) {
//         return;
//       }
//       textFieldFocusNode.canRequestFocus = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0.0,
//           title: const Text(
//             "CreerCompte",
//             style: TextStyle(
//                 color: Colors.black, fontSize: 30, fontWeight: FontWeight.w700),
//           ),
//           centerTitle: true,
//           leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: SvgPicture.asset(
//               "assets/icons/left.svg",
//               color: Colors.black,
//               height: 24,
//               width: 24,
//             ),
//           )),
//       body: SingleChildScrollView(
//           child: Column(
//         children: <Widget>[
//           const SizedBox(
//             height: 70,
//           ),
//           Container(
//               height: 405,
//               margin: const EdgeInsets.only(left: 20, top: 30, right: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   const Spacer(),
//                   SizedBox(
//                     height: 100,
//                     child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           const Text(
//                             "Email",
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Container(
//                             height: 50,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: const Color(0xffd9d9d9),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: TextField(
//                               controller: _emailController,
//                               style: const TextStyle(
//                                   color: Colors.black, fontSize: 20),
//                               decoration: InputDecoration(
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.never,
//                                 filled: true,
//                                 fillColor:
//                                     const Color(0xff50C4ED).withOpacity(0),
//                                 isDense: true,
//                                 border: OutlineInputBorder(
//                                   borderSide: BorderSide.none,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ]),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     height: 100,
//                     child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           const Text(
//                             "Mot de Passe",
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Container(
//                             height: 50,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: const Color(0xffd9d9d9),
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: TextField(
//                               keyboardType: TextInputType.visiblePassword,
//                               controller: _pwdController,
//                               obscureText: _obscured,
//                               style: const TextStyle(
//                                   color: Colors.black, fontSize: 20),
//                               focusNode: textFieldFocusNode,
//                               decoration: InputDecoration(
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.never,
//                                 filled: true,
//                                 fillColor:
//                                     const Color(0xff50C4ED).withOpacity(0),
//                                 isDense: true,
//                                 border: OutlineInputBorder(
//                                   borderSide: BorderSide.none,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 suffixIcon: Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                   child: GestureDetector(
//                                     onTap: _toggleObscured,
//                                     child: Icon(
//                                       _obscured
//                                           ? Iconsax.eye
//                                           : Iconsax.eye_slash,
//                                       size: 20,
//                                       color: const Color(0xff3B999B),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ]),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     height: 40,
//                     child: Row(
//                       children: <Widget>[
//                         const Text(
//                           "Vous avez un compte?",
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => LogInPage()),
//                             );
//                           },
//                           child: const Text(
//                             "Se connecter",
//                             style: TextStyle(
//                                 color: Color(0xff3B999B),
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     height: 30,
//                     child: Row(
//                       children: const <Widget>[
                       
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     height: 55,
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                       color: const Color(0xff3B999B),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent, elevation: 0.0),
//                       onPressed: () async {
//                         setState(() {
//                           circular = true;
//                         });
//                         try {
//                           firebase_auth.UserCredential userCredential =
//                               await firebaseAuth.createUserWithEmailAndPassword(
//                                   email: _emailController.text,
//                                   password: _pwdController.text);
//                           print(userCredential.user?.email);
//                           setState(() {
//                             circular = false;
//                           });
//                           // ignore: use_build_context_synchronously
//                           Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (builder) =>  MyHomePage()),
//                               (route) => false);
//                         } catch (e) {
//                           final snackbar =
//                               SnackBar(content: Text(e.toString()));
//                           ScaffoldMessenger.of(context).showSnackBar(snackbar);
//                           setState(() {
//                             circular = false;
//                           });
//                         }
//                       },
//                       child: circular
//                           ? const CircularProgressIndicator(
//                               color: Colors.white,
//                             )
//                           : const Text(
//                               "Creer un compte",
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                     ),
//                   )
//                 ],
//               )),
//         ],
//       )),
//     ));
//   }
// }Voici le code corrigé pour résoudre le problème de débordement et ajuster la taille du bouton "Créer un compte" :

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:todo/pages/myhomepage.dart';
// import 'package:todo/pages/log_in_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:todo/services/database_services.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();

  bool circular = false;

  final textFieldFocusNode = FocusNode();
  bool _obscured = false;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: const Text(
            "Créer un compte",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              "assets/icons/left.svg",
              color: Colors.black,
              height: 24,
              width: 24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 400,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Spacer(),
                    SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Email",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: const Color(0xffd9d9d9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor:
                                    const Color(0xff50C4ED).withOpacity(0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 100,
                      child:

 Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Mot de Passe",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: const Color(0xffd9d9d9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.visiblePassword,
                              controller: _pwdController,
                              obscureText: _obscured,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              focusNode: textFieldFocusNode,
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor:
                                    const Color(0xff50C4ED).withOpacity(0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: GestureDetector(
                                    onTap: _toggleObscured,
                                    child: Icon(
                                      _obscured
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                      size: 20,
                                      color: const Color(0xff3B999B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Nom",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: const Color(0xffd9d9d9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: _nomController,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor:
                                    const Color(0xff50C4ED).withOpacity(0),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                   
                   
                    Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color(0xff3B999B),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          elevation: 0.0,
                        ),
                        onPressed: () async {
                          setState(() {
                            circular = true;
                          });
                          try {
                            final firebase_auth.UserCredential userCredential =
                                await firebaseAuth
                                    .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _pwdController.text,
                            );
                            final String uid = userCredential.user!.email!;
                            final

 String nom = _nomController.text;
                            final String password = _pwdController.text;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'email': uid,
                              'nom': nom,
                              'password': password,
                            });
                           createDefaultCategories(uid);

                            setState(() {
                              circular = false;
                            });
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => MyHomePage(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            final snackbar =
                                SnackBar(content: Text(e.toString()));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackbar);
                            setState(() {
                              circular = false;
                            });
                          }
                        },
                        child: circular
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Créer un compte",
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
      ),
    );
  }
}

createDefaultCategories(String uid)async {
   await createDefaultCategories(uid);
}
