// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/add_projet.dart';
// import 'package:new_oppsfarm/pages/projets/projet_details.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';

// class Projet extends StatefulWidget {
//   const Projet({super.key});

//   @override
//   State<Projet> createState() => _ProjetState();
// }

// class _ProjetState extends State<Projet> with SingleTickerProviderStateMixin {
//   final HttpService _projectService = HttpService();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   dynamic connectedUser;
//   late TabController _tabController;
//   List<ProjectModel> _projects = [];

//   Future<void> connectUser() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String? token = await _authService.readToken();
//       if (token != null) {
//         connectedUser = JwtDecoder.decode(token);
//         // print("Utilisateur connecté : $connectedUser");
//       } else {
//         print("Aucun token trouvé !");
//       }
//     } catch (e) {
//       print("Erreur lors de la connexion de l'utilisateur : $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _getUserConnectedProject() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       if (connectedUser != null) {
//         var userId = connectedUser['id']; // Vérifiez que l'ID est valide
//         if (userId != null) {
//           int? parsedUserId = int.tryParse(userId.toString());
//           if (parsedUserId != null && parsedUserId > 0) {
//             var response = await _projectService.getUserProject(parsedUserId);
//             // ignore: unnecessary_type_check
//             if (response is List) {
//               List<ProjectModel> projects = response
//                   .map((project) => ProjectModel.fromJson(project))
//                   .toList();

//               setState(() {
//                 _projects = projects;
//               });
//             } else {
//               print("La réponse n'est pas une liste de projets : $response");
//             }
//           } else {
//             print("ID utilisateur invalide : $parsedUserId");
//           }
//         } else {
//           print("ID utilisateur est null");
//         }
//       } else {
//         print("Aucun utilisateur connecté");
//       }
//     } catch (e) {
//       print(
//           "Erreur lors de la récupération des projets de l'utilisateur connecté : $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> deleteProject(int id) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       var response = await _projectService.deleteProject(id);
//       if (response.contains('Projet supprimé avec succès')) {
//         print('Projet supprimé avec succès');
//         // Mettez à jour la liste des projets après la suppression
//         _getUserConnectedProject();
//       } else {
//         throw Exception('Échec de la suppression du projet: $response');
//       }
//     } catch (e) {
//       print('Erreur réseau ou interne: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     connectUser().then((_) {
//       _getUserConnectedProject();
//     });
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose(); // Dispose
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text('Projets', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           GestureDetector(
//             onTap: () async {
//               final result = await Navigator.push(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       const AddProject(),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const offsetBegin = Offset(0, 1);
//                     const offsetEnd = Offset.zero;

//                     var tween = Tween(begin: offsetBegin, end: offsetEnd);
//                     var offsetAnimation = animation.drive(tween);

//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );

//               if (result == true) {
//                 // Si un nouveau projet a été ajouté, mettez à jour la liste des projets
//                 _getUserConnectedProject();
//               }
//             },
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Container(
//                 width: 50,
//                 height: 35,
//                 decoration: BoxDecoration(
//                   color: green,
//                   borderRadius: BorderRadius.circular(
//                     5,
//                   ),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add,
//                       color: white,
//                     ),
//                     SizedBox(width: 2),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: const Drawer(),
//       body: Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             indicatorColor: green,
//             labelColor: green,
//             unselectedLabelColor: Colors.grey,
//             tabs: const [
//               Tab(text: 'Mes Projets'),
//               Tab(text: 'Collaboration'),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: _projects.length,
//                               itemBuilder: (context, index) {
//                                 return ProjectTile(
//                                   id: _projects[index].id,
//                                   nom: _projects[index].nom,
//                                   description: _projects[index].description,
//                                   crop: _projects[index].crop,
//                                   imageUrl: _projects[index].imageUrl ?? '',
//                                   status: _projects[index].status,
//                                   startDate: _projects[index]
//                                       .startDate
//                                       .toIso8601String(),
//                                   endDate: _projects[index]
//                                       .endDate
//                                       .toIso8601String(),
//                                   estimatedQuantityProduced: _projects[index]
//                                       .estimatedQuantityProduced,
//                                   basePrice: _projects[index].basePrice,
//                                   owner: _projects[index].owner.nom,
//                                   isListedOnMarketplace:
//                                       _projects[index].isListedOnMarketplace,
//                                   onDelete: () {
//                                     final projectId = _projects[index]
//                                         .id; // Sauvegarde de l'ID avant suppression
//                                     setState(() {
//                                       _projects.removeAt(index);
//                                     });
//                                     deleteProject(
//                                         projectId); // Utiliser l'ID sauvegardé
//                                   },
//                                   // onDelete: () {
//                                   //   setState(() {
//                                   //     _projects.removeAt(index);
//                                   //   });
//                                   //   deleteProject(_projects[index].id);
//                                   // },
//                                 );
//                               },
//                             )
//                           ],
//                         ),
//                       ),

//                 // Onglet "Collaboration"
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Text(
//                                 'Collaborations en cours',
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount:
//                                   4, // Remplace par la longueur réelle si nécessaire
//                               itemBuilder: (context, index) {
//                                 return Container(
//                                   height: 150,
//                                   color: Colors.grey.shade200,
//                                   margin: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 8,
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       'Aucune collaboration disponible.',
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void _showProjectTypeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: white,
//           title: const Text('Choisissez le type de projet'),
//           content: const Text('Que voulez-vous ajouter ?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) =>
//                         const AddProject(),
//                     transitionsBuilder:
//                         (context, animation, secondaryAnimation, child) {
//                       const offsetBegin = Offset(0, 1); // Départ du bas
//                       const offsetEnd = Offset.zero; // Fin au centre

//                       var tween = Tween(begin: offsetBegin, end: offsetEnd);
//                       var offsetAnimation = animation.drive(tween);

//                       return SlideTransition(
//                           position: offsetAnimation, child: child);
//                     },
//                   ),
//                 );
//               },
//               child: const Center(
//                 child: Text(
//                   'Projet Agricole',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: green,
//                   ),
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();

//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) =>
//                         const AddProject(), // Remplacez par la page appropriée
//                     transitionsBuilder:
//                         (context, animation, secondaryAnimation, child) {
//                       const offsetBegin = Offset(0, 1); // Départ du bas
//                       const offsetEnd = Offset.zero; // Fin au centre

//                       var tween = Tween(begin: offsetBegin, end: offsetEnd);
//                       var offsetAnimation = animation.drive(tween);

//                       return SlideTransition(
//                           position: offsetAnimation, child: child);
//                     },
//                   ),
//                 );
//               },
//               child: const Center(
//                 child: Text(
//                   'Projet de Transformation Agricole',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: green,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class ProjectTile extends StatelessWidget {
//   final int id;
//   final String nom;
//   final String description;
//   final String status;
//   final String startDate;
//   final String endDate;
//   final int estimatedQuantityProduced;
//   final int? basePrice;
//   final Crop crop;
//   final String imageUrl;
//   final String? owner;
//   final bool? isListedOnMarketplace;
//   final VoidCallback onDelete;

//   const ProjectTile({
//     super.key,
//     required this.id,
//     required this.nom,
//     required this.description,
//     required this.crop,
//     required this.imageUrl,
//     required this.status,
//     required this.startDate,
//     required this.endDate,
//     required this.estimatedQuantityProduced,
//     required this.basePrice,
//     required this.owner,
//     required this.isListedOnMarketplace,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Dismissible(
//       key: Key(nom),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         onDelete();
//       },
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       child: GestureDetector(
//         onTap: () {
//           // Naviguer vers la page ProjectDetail
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProjetctDetails(
//                 nom: nom,
//                 description: description,
//                 crop: crop,
//                 status: status,
//                 imageUrl: imageUrl,
//                 startDate: startDate,
//                 endDate: endDate,
//                 estimatedQuantityProduced: estimatedQuantityProduced,
//                 basePrice: basePrice,
//                 owner: owner,
//                 isListedOnMarketplace: isListedOnMarketplace,
//                 memberships: [], // Add the required memberships argument
//               ),
//             ),
//           );
//         },
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(
//               color: green,
//             ),
//             borderRadius: BorderRadius.circular(
//               15.0,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.teal.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Material(
//               borderRadius: BorderRadius.circular(15),
//               color: white,
//               child: Container(
//                 height: 185,
//                 width: size.height - 50,
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         left: 10,
//                         top: 10,
//                         bottom: 10,
//                         right: 5,
//                       ),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           color: const Color(
//                             0xffe8f6ee,
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: imageUrl.isNotEmpty
//                               ? Image.network(
//                                   imageUrl,
//                                   fit: BoxFit.cover,
//                                 )
//                               : Image.asset(
//                                   'assets/images/image1.jpg',
//                                   fit: BoxFit.cover,
//                                 ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(9.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 50,
//                             width: size.width / 2.3,
//                             child: Text(
//                               nom,
//                               softWrap: true,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 19,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 2,
//                           ),
//                           SizedBox(
//                             width: size.width / 2.3,
//                             // height: 50,
//                             child: Text(
//                               description,
//                               softWrap: true,
//                               maxLines: 3,
//                               style: const TextStyle(
//                                 // fontWeight: FontWeight.bold,
//                                 fontSize: 17,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           SizedBox(
//                             child: Row(
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Crop: ',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       crop.nom,
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   width: 12,
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Status: ',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       status, // Vous pouvez ajouter un champ de progression si nécessaire
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }