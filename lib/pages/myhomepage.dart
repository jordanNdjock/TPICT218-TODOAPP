// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:todo/pages/home_page.dart';
// import 'package:provider/provider.dart';

// // Définition du fournisseur d'index sélectionné
// final selectedIndexProvider = StateProvider<int>((ref) => 0);

// // Création de la page d'accueil
// class MyHomePage extends ConsumerWidget {
//   // Liste des pages de l'application
//   final List<Widget> _pages = [
//     HomePage(),
//     CategoryPage(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Récupération de l'index sélectionné depuis le fournisseur
//     final  currentIndex = ref.watch(selectedIndexProvider);

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Bottom Navigation Bar'),
//       // ),

//       // Affichage de la page correspondant à l'index sélectionné
//       body: _pages[currentIndex],

//       // Affichage de la barre de navigation en bas de l'écran
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,

//         // Modification de l'index sélectionné lorsqu'on tappe sur une icône
//         onTap: (index) {
//           context.read().state = index;
//         },

//         // Icônes de chaque page avec leur texte
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Accueil',
//             backgroundColor: Colors.blueGrey,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category),
//             label: 'Catégorie',
//             backgroundColor: Colors.yellowAccent,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profil',
//             backgroundColor: Colors.redAccent,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Création de la page de catégorie
// class CategoryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Catégorie'),
//     );
//   }
// }

// // Création de la page de profil
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text('Profil'),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:todo/pages/home_page.dart';
import 'package:todo/pages/profile_page.dart';
import 'package:todo/pages/categories_page.dart';
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  // Liste des pages de l'application
  final List<Widget> _pages = [
    const HomePage(),
    CategoriesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Bottom Navigation Bar'),
      // ),

      // Affichage de la page correspondant à l'index sélectionné
      body: SafeArea(child: _pages[currentIndex]),

      // Affichage de la barre de navigation en bas de l'écran
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        // Modification de l'index sélectionné lorsqu'on tappe sur une icône
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        // Icônes de chaque page avec leur texte
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: const Color(0xff3B999B),),
            label: 'Accueil',          
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category, color:Color.fromARGB(255, 134, 134, 8)),
            label: 'Catégorie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color:Color.fromARGB(255, 150, 144, 144) ,),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Création de la page de catégorie


// Création de la page de profil

