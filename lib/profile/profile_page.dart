// import 'package:flutter/material.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';

// class ProfilePage extends StatefulWidget {
//   final dynamic connectedUser;

//   const ProfilePage({super.key, required this.connectedUser});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   late final userProfile;
//   late final int userId;
//   late final String userNom;
//   //  final AuthService _authService = AuthService();
//   final HttpService _httpService = HttpService();

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];

//   void getUserConnectedPost() async {
//     setState(() {
//       _isLoading = true;
//     });
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Nom inconnu";
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//       print(_oopsPosts.length);
//     } on Exception catch (e) {
//       print('Error fetching Opps: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     userProfile = widget.connectedUser["profile"];
//     // userId = widget.connectedUser["id"];
//     // userNom = widget.connectedUser["profile"]["username"];
//     getUserConnectedPost();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                     bottom: -50,
//                     child: buildProfileImage(isDarkMode: isDarkMode)),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(isDarkMode: isDarkMode),
//             const SizedBox(height: 20),
//             buildStats(),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo({required bool isDarkMode}) => Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 // Ajout de Expanded ici
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                             "Nom inconnu",
//                         style: TextStyle(
//                           color: isDarkMode ? Colors.white : Colors.black,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                         style: TextStyle(
//                           color: isDarkMode ? Colors.white : Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       if (widget.connectedUser["profile"] != null &&
//                           widget.connectedUser["profile"]?["bio"] != null &&
//                           widget.connectedUser["profile"]?["bio"] != "")
//                         Container(
//                           width: double.infinity, // Ajustement
//                           child: Text(
//                             widget.connectedUser["profile"]["bio"] ??
//                                 "Bio inconnue",
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white : Colors.black,
//                               fontSize: 16,
//                             ),
//                             softWrap: true,
//                             overflow: TextOverflow.visible,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => EditProfilePage(
//                           userId: userId, userProfile: userProfile)));
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[900],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text("Éditer le profil",
//                 style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       );

//   Widget buildStats() => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               const Text(
//                 "100",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text("Abonnements"),
//               ),
//             ],
//           ),
//           const SizedBox(width: 20),
//           Column(
//             children: [
//               const Text(
//                 "500",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text("Abonnés"),
//               ),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required isDarkMode}) => DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             const TabBar(
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: Colors.green,
//               tabs: [
//                 Tab(text: "Publications"),
//                 Tab(text: "Médias"),
//                 Tab(text: "Likes"),
//               ],
//             ),
//             Container(
//               height: 300, // Contenu des onglets (temporaire)
//               child: TabBarView(
//                 children: [
//                   buildPostsList(),
//                   Center(child: Text("Aucun média")),
//                   Center(child: Text("Aucun like")),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList() {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text("Aucune publication"));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(widget.connectedUser["avatarUrl"] ??
//                 "https://picsum.photos/100"),
//           ),
//           title: Text(widget.connectedUser["nom"] ?? "Nom inconnu"),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(post.content ?? "Contenu indisponible"),
//               // if (post.image != null)
//               //   Padding(
//               //     padding: const EdgeInsets.only(top: 8.0),
//               //     child: Image.network(post.image!,
//               //         height: 150, fit: BoxFit.cover),
//               //   ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:intl/intl.dart';

// class ProfilePage extends ConsumerStatefulWidget {
//   final dynamic connectedUser; // User data for the profile being viewed
//   final int?
//       visitorId; // Optional: ID of the visitor (null if it's the connected user)

//   const ProfilePage({super.key, required this.connectedUser, this.visitorId});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   final HttpService _httpService = HttpService();
//   final AuthService _authService = AuthService();

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];
//   late final int userId;
//   late final String userNom;
//   bool _isFollowing = false; // For visitor view
//   int _followersCount = 500; // Example data (fetch from API in real app)
//   int _followingCount = 100; // Example data

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
//     _fetchUserPosts();
//     _checkFollowingStatus(); // For visitor view
//   }

//   void _fetchUserPosts() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//     } catch (e) {
//       print('Error fetching posts: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _checkFollowingStatus() async {
//     if (widget.visitorId != null) {
//       // Simulate API call to check if visitor follows this user
//       // Replace with actual API call
//       setState(() {
//         _isFollowing = false; // Example: assume not following initially
//       });
//     }
//   }

//   Future<void> _toggleFollow() async {
//     setState(() {
//       _isFollowing = !_isFollowing;
//       _followersCount += _isFollowing ? 1 : -1;
//     });
//     // TODO: Call API to follow/unfollow
//     try {
//       // await _httpService.toggleFollow(widget.visitorId!, userId, _isFollowing);
//     } catch (e) {
//       print('Error toggling follow: $e');
//       setState(() {
//         _isFollowing = !_isFollowing;
//         _followersCount += _isFollowing ? 1 : -1;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;

//     final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                   bottom: -50,
//                   child: buildProfileImage(isDarkMode: isDarkMode),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(
//                 isDarkMode: isDarkMode,
//                 isOwnProfile: isOwnProfile,
//                 locale: locale),
//             const SizedBox(height: 20),
//             buildStats(isOwnProfile: isOwnProfile, locale: locale),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode, locale: locale),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo(
//           {required bool isDarkMode,
//           required bool isOwnProfile,
//           required String locale}) =>
//       Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                       "Unknown",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Colors.black,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 if (widget.connectedUser["profile"]?["bio"] != null &&
//                     widget.connectedUser["profile"]?["bio"] != "")
//                   Text(
//                     widget.connectedUser["profile"]["bio"],
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Colors.black,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           isOwnProfile
//               ? ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditProfilePage(
//                           userId: userId,
//                           userProfile: widget.connectedUser["profile"],
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[900],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     AppLocales.getTranslation('edit_profile', locale),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _toggleFollow,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isFollowing ? Colors.grey : green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         _isFollowing
//                             ? AppLocales.getTranslation('unfollow', locale)
//                             : AppLocales.getTranslation('follow', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         // TODO: Implement messaging
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(AppLocales.getTranslation(
//                                   'message_sent', locale))),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         AppLocales.getTranslation('message', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//           if (!isOwnProfile) ...[
//             const SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 // TODO: Implement share profile
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text(
//                           AppLocales.getTranslation('profile_shared', locale))),
//                 );
//               },
//               icon: const Icon(Icons.share, color: Colors.green),
//               label: Text(
//                 AppLocales.getTranslation('share_profile', locale),
//                 style: TextStyle(color: Colors.green),
//               ),
//             ),
//           ],
//         ],
//       );

//   Widget buildStats({required bool isOwnProfile, required String locale}) =>
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               Text(
//                 "$_followingCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('following', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "$_followersCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('followers', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "${_oopsPosts.length}",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text(AppLocales.getTranslation('posts', locale)),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required bool isDarkMode, required String locale}) =>
//       DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             TabBar(
//               labelColor: isDarkMode ? Colors.white : green,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: green,
//               tabs: [
//                 Tab(text: AppLocales.getTranslation('posts', locale)),
//                 Tab(text: AppLocales.getTranslation('media', locale)),
//                 Tab(text: AppLocales.getTranslation('likes', locale)),
//               ],
//             ),
//             Container(
//               height: 300,
//               child: TabBarView(
//                 children: [
//                   buildPostsList(locale: locale),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_media', locale))),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_likes', locale))),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList({required String locale}) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             leading: Container(
//               width: 40, // Largeur du carré
//               height: 40, // Hauteur du carré
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8), // Bords arrondis
//                 color: Colors.grey[200], // Couleur de fond par défaut
//               ),
//               child: ClipRRect(
//                 borderRadius:
//                     BorderRadius.circular(8), // Bords arrondis pour l'image
//                 child:
//                     widget.connectedUser["profile"]["photoProfile"] != null &&
//                             widget.connectedUser["profile"]["photoProfile"]
//                                 .isNotEmpty
//                         ? Image.network(
//                             widget.connectedUser["profile"]["photoProfile"],
//                             fit: BoxFit.cover, // L'image remplit le conteneur
//                             width: 40,
//                             height: 40,
//                             errorBuilder: (context, error, stackTrace) {
//                               // En cas d'erreur de chargement de l'image, affichez un avatar par défaut
//                               return Icon(Icons.person,
//                                   color: Colors.white,
//                                   size: 24); // Icône par défaut
//                             },
//                           )
//                         : Icon(Icons.person,
//                             color: Colors.white, size: 24), // Avatar par défaut
//               ),
//             ),
//             title: Text(
//                 "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(post.content ??
//                     AppLocales.getTranslation('no_content', locale)),
//                 if (post.image != null && post.image!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.network(
//                       post.image!,
//                       height: 150,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
// import 'package:new_oppsfarm/profile/service/profile_Http_service.dart'; // Add this import
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:intl/intl.dart';

// enum FollowStatus { notFollowing, following, pending, rejected }

// class ProfilePage extends ConsumerStatefulWidget {
//   final dynamic connectedUser; // User data for the profile being viewed
//   final int? visitorId; // Optional: ID of the visitor (null if it's the connected user)

//   const ProfilePage({super.key, required this.connectedUser, this.visitorId});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   final HttpService _httpService = HttpService();
//   final AuthService _authService = AuthService();
//   final ProfileHttpService _profileService = ProfileHttpService(); // Add ProfileHttpService

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];
//   late final int userId;
//   late final String userNom;
//   FollowStatus _followStatus = FollowStatus.notFollowing; // Enhanced follow state
//   bool _isFollowActionLoading = false; // Loading state for follow actions
//   int _followersCount = 500; // Will be updated from API
//   int _followingCount = 100; // Example data

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
//     _fetchUserPosts();
//     _checkFollowStatus(); // Enhanced follow status check
//   }

//   void _fetchUserPosts() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//     } catch (e) {
//       print('Error fetching posts: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _checkFollowStatus() async {
//     if (widget.visitorId != null && widget.visitorId != userId) {
//       setState(() => _isLoading = true);
//       try {
//         final outgoingRequests = await _profileService.getOutgoingFriendRequests(widget.visitorId!);
//         final friends = jsonDecode(await _profileService.getFriends(userId: userId));

//         final request = outgoingRequests['requests']?.firstWhere(
//           (req) => req['receiver']['id'] == userId,
//           orElse: () => null,
//         );

//         if (mounted) {
//           setState(() {
//             if (request != null) {
//               switch (request['status'].toLowerCase()) {
//                 case 'pending':
//                   _followStatus = FollowStatus.pending;
//                   break;
//                 case 'rejected':
//                   _followStatus = FollowStatus.rejected;
//                   break;
//                 case 'accepted':
//                   _followStatus = FollowStatus.following;
//                   break;
//                 default:
//                   _followStatus = FollowStatus.notFollowing;
//               }
//             } else {
//               final isFriend = friends.any((friend) => friend['id'] == widget.visitorId);
//               _followStatus = isFriend ? FollowStatus.following : FollowStatus.notFollowing;
//             }
//             _followersCount = friends.length; // Update followers count
//           });
//         }
//       } catch (e) {
//         print('Error checking follow status: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error loading follow status: $e')),
//           );
//         }
//       } finally {
//         if (mounted) setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _toggleFollow() async {
//     if (widget.visitorId == null || _isFollowActionLoading) return;

//     setState(() => _isFollowActionLoading = true);
//     try {
//       switch (_followStatus) {
//         case FollowStatus.notFollowing:
//         case FollowStatus.rejected:
//           await _profileService.sendFriendRequest(
//             requesterId: widget.visitorId!,
//             receiverId: userId,
//           );
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.pending;
//               _followersCount++;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Follow request sent')),
//             );
//           }
//           break;
//         case FollowStatus.following:
//           await _profileService.cancelFriendRequest(widget.visitorId!, userId);
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.notFollowing;
//               _followersCount--;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Unfollowed successfully')),
//             );
//           }
//           break;
//         case FollowStatus.pending:
//           await _profileService.cancelFriendRequest(widget.visitorId!, userId);
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.notFollowing;
//               _followersCount--;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Request cancelled')),
//             );
//           }
//           break;
//       }
//     } catch (e) {
//       print('Error toggling follow: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//         setState(() {
//           if (_followStatus == FollowStatus.pending) {
//             _followStatus = FollowStatus.notFollowing;
//             _followersCount--;
//           } else if (_followStatus == FollowStatus.notFollowing) {
//             _followStatus = FollowStatus.following;
//             _followersCount++;
//           }
//         });
//       }
//     } finally {
//       if (mounted) setState(() => _isFollowActionLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;

//     final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                   bottom: -50,
//                   child: buildProfileImage(isDarkMode: isDarkMode),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(
//                 isDarkMode: isDarkMode,
//                 isOwnProfile: isOwnProfile,
//                 locale: locale),
//             const SizedBox(height: 20),
//             buildStats(isOwnProfile: isOwnProfile, locale: locale),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode, locale: locale),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo({
//     required bool isDarkMode,
//     required bool isOwnProfile,
//     required String locale,
//   }) =>
//       Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                       "Unknown",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Colors.black,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 if (widget.connectedUser["profile"]?["bio"] != null &&
//                     widget.connectedUser["profile"]?["bio"] != "")
//                   Text(
//                     widget.connectedUser["profile"]["bio"],
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Colors.black,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           isOwnProfile
//               ? ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditProfilePage(
//                           userId: userId,
//                           userProfile: widget.connectedUser["profile"],
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[900],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     AppLocales.getTranslation('edit_profile', locale),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _isFollowActionLoading ? null : _toggleFollow,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _getFollowButtonColor(),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         elevation: 2,
//                       ),
//                       child: _isFollowActionLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               _getFollowButtonText(locale),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(AppLocales.getTranslation(
//                                   'message_sent', locale))),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         AppLocales.getTranslation('message', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//           if (!isOwnProfile) ...[
//             const SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text(
//                           AppLocales.getTranslation('profile_shared', locale))),
//                 );
//               },
//               icon: const Icon(Icons.share, color: Colors.green),
//               label: Text(
//                 AppLocales.getTranslation('share_profile', locale),
//                 style: const TextStyle(color: Colors.green),
//               ),
//             ),
//           ],
//         ],
//       );

//   Color _getFollowButtonColor() {
//     switch (_followStatus) {
//       case FollowStatus.following:
//         return Colors.grey[700]!;
//       case FollowStatus.pending:
//         return Colors.orange[600]!;
//       case FollowStatus.rejected:
//       case FollowStatus.notFollowing:
//         return green;
//     }
//   }

//   String _getFollowButtonText(String locale) {
//     switch (_followStatus) {
//       case FollowStatus.following:
//         return AppLocales.getTranslation('unfollow', locale);
//       case FollowStatus.pending:
//         return AppLocales.getTranslation('pending', locale);
//       case FollowStatus.rejected:
//       case FollowStatus.notFollowing:
//         return AppLocales.getTranslation('follow', locale);
//     }
//   }

//   Widget buildStats({required bool isOwnProfile, required String locale}) =>
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               Text(
//                 "$_followingCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('following', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "$_followersCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('followers', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "${_oopsPosts.length}",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text(AppLocales.getTranslation('posts', locale)),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required bool isDarkMode, required String locale}) =>
//       DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             TabBar(
//               labelColor: isDarkMode ? Colors.white : green,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: green,
//               tabs: [
//                 Tab(text: AppLocales.getTranslation('posts', locale)),
//                 Tab(text: AppLocales.getTranslation('media', locale)),
//                 Tab(text: AppLocales.getTranslation('likes', locale)),
//               ],
//             ),
//             Container(
//               height: 300,
//               child: TabBarView(
//                 children: [
//                   buildPostsList(locale: locale),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_media', locale))),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_likes', locale))),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList({required String locale}) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             leading: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.grey[200],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child:
//                     widget.connectedUser["profile"]["photoProfile"] != null &&
//                             widget.connectedUser["profile"]["photoProfile"]
//                                 .isNotEmpty
//                         ? Image.network(
//                             widget.connectedUser["profile"]["photoProfile"],
//                             fit: BoxFit.cover,
//                             width: 40,
//                             height: 40,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Icon(Icons.person,
//                                   color: Colors.white, size: 24);
//                             },
//                           )
//                         : Icon(Icons.person, color: Colors.white, size: 24),
//               ),
//             ),
//             title: Text(
//                 "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(post.content ??
//                     AppLocales.getTranslation('no_content', locale)),
//                 if (post.image != null && post.image!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.network(
//                       post.image!,
//                       height: 150,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';

// class ProfilePage extends StatefulWidget {
//   final dynamic connectedUser;

//   const ProfilePage({super.key, required this.connectedUser});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   late final userProfile;
//   late final int userId;
//   late final String userNom;
//   //  final AuthService _authService = AuthService();
//   final HttpService _httpService = HttpService();

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];

//   void getUserConnectedPost() async {
//     setState(() {
//       _isLoading = true;
//     });
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Nom inconnu";
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//       print(_oopsPosts.length);
//     } on Exception catch (e) {
//       print('Error fetching Opps: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     userProfile = widget.connectedUser["profile"];
//     // userId = widget.connectedUser["id"];
//     // userNom = widget.connectedUser["profile"]["username"];
//     getUserConnectedPost();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                     bottom: -50,
//                     child: buildProfileImage(isDarkMode: isDarkMode)),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(isDarkMode: isDarkMode),
//             const SizedBox(height: 20),
//             buildStats(),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo({required bool isDarkMode}) => Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 // Ajout de Expanded ici
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                             "Nom inconnu",
//                         style: TextStyle(
//                           color: isDarkMode ? Colors.white : Colors.black,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                         style: TextStyle(
//                           color: isDarkMode ? Colors.white : Colors.black,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       if (widget.connectedUser["profile"] != null &&
//                           widget.connectedUser["profile"]?["bio"] != null &&
//                           widget.connectedUser["profile"]?["bio"] != "")
//                         Container(
//                           width: double.infinity, // Ajustement
//                           child: Text(
//                             widget.connectedUser["profile"]["bio"] ??
//                                 "Bio inconnue",
//                             style: TextStyle(
//                               color: isDarkMode ? Colors.white : Colors.black,
//                               fontSize: 16,
//                             ),
//                             softWrap: true,
//                             overflow: TextOverflow.visible,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => EditProfilePage(
//                           userId: userId, userProfile: userProfile)));
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[900],
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text("Éditer le profil",
//                 style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       );

//   Widget buildStats() => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               const Text(
//                 "100",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text("Abonnements"),
//               ),
//             ],
//           ),
//           const SizedBox(width: 20),
//           Column(
//             children: [
//               const Text(
//                 "500",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text("Abonnés"),
//               ),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required isDarkMode}) => DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             const TabBar(
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: Colors.green,
//               tabs: [
//                 Tab(text: "Publications"),
//                 Tab(text: "Médias"),
//                 Tab(text: "Likes"),
//               ],
//             ),
//             Container(
//               height: 300, // Contenu des onglets (temporaire)
//               child: TabBarView(
//                 children: [
//                   buildPostsList(),
//                   Center(child: Text("Aucun média")),
//                   Center(child: Text("Aucun like")),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList() {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text("Aucune publication"));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(widget.connectedUser["avatarUrl"] ??
//                 "https://picsum.photos/100"),
//           ),
//           title: Text(widget.connectedUser["nom"] ?? "Nom inconnu"),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(post.content ?? "Contenu indisponible"),
//               // if (post.image != null)
//               //   Padding(
//               //     padding: const EdgeInsets.only(top: 8.0),
//               //     child: Image.network(post.image!,
//               //         height: 150, fit: BoxFit.cover),
//               //   ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:intl/intl.dart';

// class ProfilePage extends ConsumerStatefulWidget {
//   final dynamic connectedUser; // User data for the profile being viewed
//   final int?
//       visitorId; // Optional: ID of the visitor (null if it's the connected user)

//   const ProfilePage({super.key, required this.connectedUser, this.visitorId});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   final HttpService _httpService = HttpService();
//   final AuthService _authService = AuthService();

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];
//   late final int userId;
//   late final String userNom;
//   bool _isFollowing = false; // For visitor view
//   int _followersCount = 500; // Example data (fetch from API in real app)
//   int _followingCount = 100; // Example data

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
//     _fetchUserPosts();
//     _checkFollowingStatus(); // For visitor view
//   }

//   void _fetchUserPosts() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//     } catch (e) {
//       print('Error fetching posts: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _checkFollowingStatus() async {
//     if (widget.visitorId != null) {
//       // Simulate API call to check if visitor follows this user
//       // Replace with actual API call
//       setState(() {
//         _isFollowing = false; // Example: assume not following initially
//       });
//     }
//   }

//   Future<void> _toggleFollow() async {
//     setState(() {
//       _isFollowing = !_isFollowing;
//       _followersCount += _isFollowing ? 1 : -1;
//     });
//     // TODO: Call API to follow/unfollow
//     try {
//       // await _httpService.toggleFollow(widget.visitorId!, userId, _isFollowing);
//     } catch (e) {
//       print('Error toggling follow: $e');
//       setState(() {
//         _isFollowing = !_isFollowing;
//         _followersCount += _isFollowing ? 1 : -1;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;

//     final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                   bottom: -50,
//                   child: buildProfileImage(isDarkMode: isDarkMode),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(
//                 isDarkMode: isDarkMode,
//                 isOwnProfile: isOwnProfile,
//                 locale: locale),
//             const SizedBox(height: 20),
//             buildStats(isOwnProfile: isOwnProfile, locale: locale),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode, locale: locale),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo(
//           {required bool isDarkMode,
//           required bool isOwnProfile,
//           required String locale}) =>
//       Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                       "Unknown",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Colors.black,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 if (widget.connectedUser["profile"]?["bio"] != null &&
//                     widget.connectedUser["profile"]?["bio"] != "")
//                   Text(
//                     widget.connectedUser["profile"]["bio"],
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Colors.black,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           isOwnProfile
//               ? ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditProfilePage(
//                           userId: userId,
//                           userProfile: widget.connectedUser["profile"],
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[900],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     AppLocales.getTranslation('edit_profile', locale),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _toggleFollow,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isFollowing ? Colors.grey : green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         _isFollowing
//                             ? AppLocales.getTranslation('unfollow', locale)
//                             : AppLocales.getTranslation('follow', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         // TODO: Implement messaging
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(AppLocales.getTranslation(
//                                   'message_sent', locale))),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         AppLocales.getTranslation('message', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//           if (!isOwnProfile) ...[
//             const SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 // TODO: Implement share profile
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text(
//                           AppLocales.getTranslation('profile_shared', locale))),
//                 );
//               },
//               icon: const Icon(Icons.share, color: Colors.green),
//               label: Text(
//                 AppLocales.getTranslation('share_profile', locale),
//                 style: TextStyle(color: Colors.green),
//               ),
//             ),
//           ],
//         ],
//       );

//   Widget buildStats({required bool isOwnProfile, required String locale}) =>
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               Text(
//                 "$_followingCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('following', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "$_followersCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('followers', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "${_oopsPosts.length}",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text(AppLocales.getTranslation('posts', locale)),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required bool isDarkMode, required String locale}) =>
//       DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             TabBar(
//               labelColor: isDarkMode ? Colors.white : green,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: green,
//               tabs: [
//                 Tab(text: AppLocales.getTranslation('posts', locale)),
//                 Tab(text: AppLocales.getTranslation('media', locale)),
//                 Tab(text: AppLocales.getTranslation('likes', locale)),
//               ],
//             ),
//             Container(
//               height: 300,
//               child: TabBarView(
//                 children: [
//                   buildPostsList(locale: locale),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_media', locale))),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_likes', locale))),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList({required String locale}) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             leading: Container(
//               width: 40, // Largeur du carré
//               height: 40, // Hauteur du carré
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8), // Bords arrondis
//                 color: Colors.grey[200], // Couleur de fond par défaut
//               ),
//               child: ClipRRect(
//                 borderRadius:
//                     BorderRadius.circular(8), // Bords arrondis pour l'image
//                 child:
//                     widget.connectedUser["profile"]["photoProfile"] != null &&
//                             widget.connectedUser["profile"]["photoProfile"]
//                                 .isNotEmpty
//                         ? Image.network(
//                             widget.connectedUser["profile"]["photoProfile"],
//                             fit: BoxFit.cover, // L'image remplit le conteneur
//                             width: 40,
//                             height: 40,
//                             errorBuilder: (context, error, stackTrace) {
//                               // En cas d'erreur de chargement de l'image, affichez un avatar par défaut
//                               return Icon(Icons.person,
//                                   color: Colors.white,
//                                   size: 24); // Icône par défaut
//                             },
//                           )
//                         : Icon(Icons.person,
//                             color: Colors.white, size: 24), // Avatar par défaut
//               ),
//             ),
//             title: Text(
//                 "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(post.content ??
//                     AppLocales.getTranslation('no_content', locale)),
//                 if (post.image != null && post.image!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.network(
//                       post.image!,
//                       height: 150,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/edit-profile_page.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
// import 'package:new_oppsfarm/profile/service/profile_Http_service.dart'; // Add this import
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:intl/intl.dart';

// enum FollowStatus { notFollowing, following, pending, rejected }

// class ProfilePage extends ConsumerStatefulWidget {
//   final dynamic connectedUser; // User data for the profile being viewed
//   final int? visitorId; // Optional: ID of the visitor (null if it's the connected user)

//   const ProfilePage({super.key, required this.connectedUser, this.visitorId});

//   @override
//   _ProfilePageState createState() => _ProfilePageState();
// }

// class _ProfilePageState extends ConsumerState<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   final HttpService _httpService = HttpService();
//   final AuthService _authService = AuthService();
//   final ProfileHttpService _profileService = ProfileHttpService(); // Add ProfileHttpService

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];
//   late final int userId;
//   late final String userNom;
//   FollowStatus _followStatus = FollowStatus.notFollowing; // Enhanced follow state
//   bool _isFollowActionLoading = false; // Loading state for follow actions
//   int _followersCount = 500; // Will be updated from API
//   int _followingCount = 100; // Example data

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
//     _fetchUserPosts();
//     _checkFollowStatus(); // Enhanced follow status check
//   }

//   void _fetchUserPosts() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
//           await _httpService.getPostByConnectUser(userId));
//       _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
//     } catch (e) {
//       print('Error fetching posts: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _checkFollowStatus() async {
//     if (widget.visitorId != null && widget.visitorId != userId) {
//       setState(() => _isLoading = true);
//       try {
//         final outgoingRequests = await _profileService.getOutgoingFriendRequests(widget.visitorId!);
//         final friends = jsonDecode(await _profileService.getFriends(userId: userId));

//         final request = outgoingRequests['requests']?.firstWhere(
//           (req) => req['receiver']['id'] == userId,
//           orElse: () => null,
//         );

//         if (mounted) {
//           setState(() {
//             if (request != null) {
//               switch (request['status'].toLowerCase()) {
//                 case 'pending':
//                   _followStatus = FollowStatus.pending;
//                   break;
//                 case 'rejected':
//                   _followStatus = FollowStatus.rejected;
//                   break;
//                 case 'accepted':
//                   _followStatus = FollowStatus.following;
//                   break;
//                 default:
//                   _followStatus = FollowStatus.notFollowing;
//               }
//             } else {
//               final isFriend = friends.any((friend) => friend['id'] == widget.visitorId);
//               _followStatus = isFriend ? FollowStatus.following : FollowStatus.notFollowing;
//             }
//             _followersCount = friends.length; // Update followers count
//           });
//         }
//       } catch (e) {
//         print('Error checking follow status: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error loading follow status: $e')),
//           );
//         }
//       } finally {
//         if (mounted) setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _toggleFollow() async {
//     if (widget.visitorId == null || _isFollowActionLoading) return;

//     setState(() => _isFollowActionLoading = true);
//     try {
//       switch (_followStatus) {
//         case FollowStatus.notFollowing:
//         case FollowStatus.rejected:
//           await _profileService.sendFriendRequest(
//             requesterId: widget.visitorId!,
//             receiverId: userId,
//           );
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.pending;
//               _followersCount++;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Follow request sent')),
//             );
//           }
//           break;
//         case FollowStatus.following:
//           await _profileService.cancelFriendRequest(widget.visitorId!, userId);
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.notFollowing;
//               _followersCount--;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Unfollowed successfully')),
//             );
//           }
//           break;
//         case FollowStatus.pending:
//           await _profileService.cancelFriendRequest(widget.visitorId!, userId);
//           if (mounted) {
//             setState(() {
//               _followStatus = FollowStatus.notFollowing;
//               _followersCount--;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Request cancelled')),
//             );
//           }
//           break;
//       }
//     } catch (e) {
//       print('Error toggling follow: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//         setState(() {
//           if (_followStatus == FollowStatus.pending) {
//             _followStatus = FollowStatus.notFollowing;
//             _followersCount--;
//           } else if (_followStatus == FollowStatus.notFollowing) {
//             _followStatus = FollowStatus.following;
//             _followersCount++;
//           }
//         });
//       }
//     } finally {
//       if (mounted) setState(() => _isFollowActionLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;

//     final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: [
//                 buildCoverImage(isDarkMode: isDarkMode),
//                 Positioned(
//                   bottom: -50,
//                   child: buildProfileImage(isDarkMode: isDarkMode),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 60),
//             buildUserInfo(
//                 isDarkMode: isDarkMode,
//                 isOwnProfile: isOwnProfile,
//                 locale: locale),
//             const SizedBox(height: 20),
//             buildStats(isOwnProfile: isOwnProfile, locale: locale),
//             const SizedBox(height: 20),
//             buildTabs(isDarkMode: isDarkMode, locale: locale),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCoverImage({required bool isDarkMode}) => Container(
//         height: coverHeight,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage(
//               widget.connectedUser["profile"]["photoCouverture"] ??
//                   "https://picsum.photos/id/1015/500/300",
//             ),
//             fit: BoxFit.cover,
//             onError: (exception, stackTrace) {},
//           ),
//         ),
//       );

//   Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Image.network(
//           widget.connectedUser["profile"]["photoProfile"] ??
//               "https://picsum.photos/id/1011/100/100",
//           height: 80,
//           width: 80,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return Image.network(
//               "https://picsum.photos/id/1011/100/100",
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             );
//           },
//         ),
//       );

//   Widget buildUserInfo({
//     required bool isDarkMode,
//     required bool isOwnProfile,
//     required String locale,
//   }) =>
//       Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
//                       "Unknown",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Colors.black,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 if (widget.connectedUser["profile"]?["bio"] != null &&
//                     widget.connectedUser["profile"]?["bio"] != "")
//                   Text(
//                     widget.connectedUser["profile"]["bio"],
//                     style: TextStyle(
//                       color: isDarkMode ? Colors.white : Colors.black,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           isOwnProfile
//               ? ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditProfilePage(
//                           userId: userId,
//                           userProfile: widget.connectedUser["profile"],
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[900],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     AppLocales.getTranslation('edit_profile', locale),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _isFollowActionLoading ? null : _toggleFollow,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _getFollowButtonColor(),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         elevation: 2,
//                       ),
//                       child: _isFollowActionLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               _getFollowButtonText(locale),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(AppLocales.getTranslation(
//                                   'message_sent', locale))),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       child: Text(
//                         AppLocales.getTranslation('message', locale),
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//           if (!isOwnProfile) ...[
//             const SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content: Text(
//                           AppLocales.getTranslation('profile_shared', locale))),
//                 );
//               },
//               icon: const Icon(Icons.share, color: Colors.green),
//               label: Text(
//                 AppLocales.getTranslation('share_profile', locale),
//                 style: const TextStyle(color: Colors.green),
//               ),
//             ),
//           ],
//         ],
//       );

//   Color _getFollowButtonColor() {
//     switch (_followStatus) {
//       case FollowStatus.following:
//         return Colors.grey[700]!;
//       case FollowStatus.pending:
//         return Colors.orange[600]!;
//       case FollowStatus.rejected:
//       case FollowStatus.notFollowing:
//         return green;
//     }
//   }

//   String _getFollowButtonText(String locale) {
//     switch (_followStatus) {
//       case FollowStatus.following:
//         return AppLocales.getTranslation('unfollow', locale);
//       case FollowStatus.pending:
//         return AppLocales.getTranslation('pending', locale);
//       case FollowStatus.rejected:
//       case FollowStatus.notFollowing:
//         return AppLocales.getTranslation('follow', locale);
//     }
//   }

//   Widget buildStats({required bool isOwnProfile, required String locale}) =>
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           Column(
//             children: [
//               Text(
//                 "$_followingCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('following', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "$_followersCount",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FollowFolowers(
//                         userId: userId,
//                         userNom: userNom,
//                         initialTabIndex: 0,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(AppLocales.getTranslation('followers', locale)),
//               ),
//             ],
//           ),
//           Column(
//             children: [
//               Text(
//                 "${_oopsPosts.length}",
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               Text(AppLocales.getTranslation('posts', locale)),
//             ],
//           ),
//         ],
//       );

//   Widget buildTabs({required bool isDarkMode, required String locale}) =>
//       DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             TabBar(
//               labelColor: isDarkMode ? Colors.white : green,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: green,
//               tabs: [
//                 Tab(text: AppLocales.getTranslation('posts', locale)),
//                 Tab(text: AppLocales.getTranslation('media', locale)),
//                 Tab(text: AppLocales.getTranslation('likes', locale)),
//               ],
//             ),
//             Container(
//               height: 300,
//               child: TabBarView(
//                 children: [
//                   buildPostsList(locale: locale),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_media', locale))),
//                   Center(
//                       child:
//                           Text(AppLocales.getTranslation('no_likes', locale))),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList({required String locale}) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
//     }
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             leading: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.grey[200],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child:
//                     widget.connectedUser["profile"]["photoProfile"] != null &&
//                             widget.connectedUser["profile"]["photoProfile"]
//                                 .isNotEmpty
//                         ? Image.network(
//                             widget.connectedUser["profile"]["photoProfile"],
//                             fit: BoxFit.cover,
//                             width: 40,
//                             height: 40,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Icon(Icons.person,
//                                   color: Colors.white, size: 24);
//                             },
//                           )
//                         : Icon(Icons.person, color: Colors.white, size: 24),
//               ),
//             ),
//             title: Text(
//                 "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(post.content ??
//                     AppLocales.getTranslation('no_content', locale)),
//                 if (post.image != null && post.image!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.network(
//                       post.image!,
//                       height: 150,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/view/actuality_details.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/profile/edit-profile_page.dart';
import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
import 'package:new_oppsfarm/profile/service/profile_Http_service.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:new_oppsfarm/socket/socket-service.dart';

enum FollowStatus { notFollowing, following, pending, rejected }

class ProfilePage extends ConsumerStatefulWidget {
  final dynamic connectedUser;
  final int? visitorId;

  const ProfilePage({super.key, required this.connectedUser, this.visitorId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final double coverHeight = 200;
  final double profileHeight = 100;
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();
  final ProfileHttpService _profileService = ProfileHttpService();

  List<Map<String, dynamic>> _outgoingRequests = [];
  List<Map<String, dynamic>> _incomingRequests = [];
  List<int> _incomingSenderIds = [];

  bool _isLoading = false;
  List<OppsModel> _oopsPosts = [];
  late final int userId;
  late final String userNom;
  FollowStatus _followStatus = FollowStatus.notFollowing;
  bool _isFollowActionLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<dynamic> _friends = [];

  @override
  void initState() {
    super.initState();
    userId = widget.connectedUser["id"];
    userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
    _fetchUserPosts();
    _checkFollowStatus();
    _fetchFriendsAndUpdateCounts();
  }

  Future<void> _fetchFriendsAndUpdateCounts() async {
    setState(() => _isLoading = true);
    try {
      final friendsData = await _profileService.getFriends(userId: userId);
      final friendsList = jsonDecode(friendsData);
      if (mounted) {
        setState(() {
          _friends = friendsList;
          _followersCount = _friends.length;
          _followingCount = _friends.length;
        });
      }
      await getOutgoingFriendRequests();
      await getIncomingFriendRequests();
    } catch (e) {
      print('Error fetching friends: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement des amis: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> getOutgoingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileService.getOutgoingFriendRequests(userId);
      if (mounted) {
        setState(() {
          _outgoingRequests = List<Map<String, dynamic>>.from(data['requests']);
        });
      }
    } catch (e) {
      // print("Erreur lors de la récupération des demandes envoyées : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getIncomingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileService.getIncomingFriendRequests(userId);
      if (mounted) {
        setState(() {
          _incomingRequests =
              List<Map<String, dynamic>>.from(data['requests'] ?? []);
          _incomingSenderIds = _incomingRequests
              .map((request) => request['requester']?['id'] as int?)
              .where((id) => id != null)
              .cast<int>()
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fetchUserPosts() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
          await _httpService.getPostByConnectUser(userId));
      _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkFollowStatus() async {
    if (widget.visitorId == null || widget.visitorId == userId) return;

    setState(() => _isLoading = true);
    try {
      final outgoingRequests =
          await _profileService.getOutgoingFriendRequests(widget.visitorId!);
      final friends =
          jsonDecode(await _profileService.getFriends(userId: userId));

      final request = outgoingRequests['requests']?.firstWhere(
        (req) => req['receiver']['id'] == userId,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _friends = friends;
          _followersCount = _friends.length;
          _followingCount = _friends.length;

          if (request != null) {
            switch (request['status'].toLowerCase()) {
              case 'pending':
                _followStatus = FollowStatus.pending;
                break;
              case 'rejected':
                _followStatus = FollowStatus.rejected;
                break;
              case 'accepted':
                _followStatus = FollowStatus.following;
                break;
              default:
                _followStatus = FollowStatus.notFollowing;
            }
          } else {
            _followStatus =
                friends.any((friend) => friend['id'] == widget.visitorId)
                    ? FollowStatus.following
                    : FollowStatus.notFollowing;
          }
          _followersCount = friends.length;
          _followingCount =
              friends.length; // À ajuster selon votre logique réelle
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.visitorId == null || _isFollowActionLoading) return;

    setState(() => _isFollowActionLoading = true);
    try {
      switch (_followStatus) {
        case FollowStatus.notFollowing:
        case FollowStatus.rejected:
          await _profileService.sendFriendRequest(
            requesterId: widget.visitorId!,
            receiverId: userId,
          );
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.pending;
              _followersCount++;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Follow request sent')));
          }
          break;
        case FollowStatus.following:
          await _profileService.cancelFriendRequest(widget.visitorId!, userId);
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.notFollowing;
              _followersCount--;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Unfollowed')));
          }
          break;
        case FollowStatus.pending:
          await _profileService.cancelFriendRequest(widget.visitorId!, userId);
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.notFollowing;
              _followersCount--;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request cancelled')));
          }
          break;
      }
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isFollowActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                buildCoverImage(isDarkMode: isDarkMode),
                Positioned(
                    bottom: -50,
                    child: buildProfileImage(isDarkMode: isDarkMode)),
              ],
            ),
            const SizedBox(height: 60),
            buildUserInfo(
                isDarkMode: isDarkMode,
                isOwnProfile: isOwnProfile,
                locale: locale,
                textColor: textColor),
            const SizedBox(height: 20),
            buildStats(isOwnProfile: isOwnProfile, locale: locale),
            const SizedBox(height: 20),
            buildTabs(isDarkMode: isDarkMode, locale: locale),
          ],
        ),
      ),
    );
  }

  Widget buildCoverImage({required bool isDarkMode}) => Container(
        height: coverHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.connectedUser["profile"]
                    ["photoCouverture"] ??
                "https://picsum.photos/id/1015/500/300"),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
      );

  Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          widget.connectedUser["profile"]["photoProfile"] ??
              "https://picsum.photos/id/1011/100/100",
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.network(
              "https://picsum.photos/id/1011/100/100",
              height: 80,
              width: 80,
              fit: BoxFit.cover),
        ),
      );

  Widget buildUserInfo(
          {required bool isDarkMode,
          required Color textColor,
          required bool isOwnProfile,
          required String locale}) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
                      "Unknown",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
                  style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (widget.connectedUser["profile"]?["bio"]?.isNotEmpty ??
                    false)
                  Text(
                    widget.connectedUser["profile"]["bio"],
                    style: TextStyle(color: textColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          isOwnProfile
              ? ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                              userId: userId,
                              userProfile: widget.connectedUser["profile"]))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: Text(AppLocales.getTranslation('edit_profile', locale),
                      style: const TextStyle(color: Colors.white)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isFollowActionLoading ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getFollowButtonColor(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: _isFollowActionLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_getFollowButtonText(locale),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.visitorId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Vous devez être connecté pour envoyer un message')));
                          return;
                        }
                        // Navigator.push(
                        //   context,
                        //   // MaterialPageRoute(
                        //   //   builder: (_) =>
                        //   //   ChatScreen(

                        //   //       ),
                        //   // ),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text(AppLocales.getTranslation('message', locale),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
        ],
      );

  Color _getFollowButtonColor() {
    switch (_followStatus) {
      case FollowStatus.following:
        return Colors.grey[700]!;
      case FollowStatus.pending:
        return Colors.orange[600]!;
      case FollowStatus.rejected:
      case FollowStatus.notFollowing:
        return green;
    }
  }

  String _getFollowButtonText(String locale) {
    switch (_followStatus) {
      case FollowStatus.following:
        return AppLocales.getTranslation('unfollow', locale);
      case FollowStatus.pending:
        return AppLocales.getTranslation('pending', locale);
      case FollowStatus.rejected:
      case FollowStatus.notFollowing:
        return AppLocales.getTranslation('follow', locale);
    }
  }

  Widget buildStats({required bool isOwnProfile, required String locale}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text("$_followingCount",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FollowFolowers(
                              userId: userId,
                              userNom: userNom,
                              initialTabIndex: 1))),
                  child: Text(AppLocales.getTranslation('following', locale))),
            ],
          ),
          Column(
            children: [
              Text("$_followersCount",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FollowFolowers(
                              userId: userId, userNom: userNom))),
                  child: Text(AppLocales.getTranslation('followers', locale))),
            ],
          ),
          Column(
            children: [
              Text(
                "${_oopsPosts.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                AppLocales.getTranslation(
                  'posts',
                  locale,
                ),
              ),
            ],
          ),
        ],
      );

  Widget buildTabs({required bool isDarkMode, required String locale}) =>
      DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: isDarkMode ? Colors.white : green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: green,
              tabs: [
                Tab(text: AppLocales.getTranslation('posts', locale)),
                Tab(text: AppLocales.getTranslation('media', locale)),
                Tab(text: AppLocales.getTranslation('likes', locale)),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  buildPostsList(locale: locale),
                  Center(
                      child:
                          Text(AppLocales.getTranslation('no_media', locale))),
                  Center(
                      child:
                          Text(AppLocales.getTranslation('no_likes', locale))),
                ],
              ),
            ),
          ],
        ),
      );

  Widget buildPostsList({required String locale}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_oopsPosts.isEmpty)
      return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _oopsPosts.length,
      itemBuilder: (context, index) {
        final post = _oopsPosts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.connectedUser["profile"]["photoProfile"]
                            ?.isNotEmpty ??
                        false
                    ? Image.network(
                        widget.connectedUser["profile"]["photoProfile"],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: Colors.white))
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
            title: Text(
                "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content ??
                    AppLocales.getTranslation('no_content', locale)),
                if (post.image?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(post.image!,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//    Widget buildPostsList({required String locale}) {
//   if (_isLoading) return const Center(child: CircularProgressIndicator());
//   if (_oopsPosts.isEmpty) return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
//   return ListView.builder(
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     itemCount: _oopsPosts.length,
//     itemBuilder: (context, index) {
//       final post = _oopsPosts[index];

//   return GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ActualityDetails(
//             id: post.id,
//             image: post.image ?? '', // Fallback for nullable String
//             createdAt: DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt), // Optional, formatted
//             content: post.content ?? '', // Fallback for nullable String
//             user: post.user,
//             likedBy: post.likedBy,
//             comments: post.comments,
//             likes: post.likes,
//             likesCount: post.likesCount.value,
//             onLike: () {
//               setState(() { // Update state in ProfilePage
//                 if (post.isLiked.value) {
//                   post.isLiked.value = false;
//                   post.likesCount.value--;
//                   post.likedBy.remove(widget.connectedUser["id"]);
//                 } else {
//                   post.isLiked.value = true;
//                   post.likesCount.value++;
//                   post.likedBy.add(widget.connectedUser["id"]);
//                 }
//               });
//               // Add API call here if needed
//             },
//             onComment: () {
//               // Trigger the comment logic in ActualityDetails
//               // The actual comment text is handled within ActualityDetails
//             },
//             isLiked: post.isLiked.value,
//             commentsCount: post.comments.length, // Required parameter
//           ),
//         ),
//       );
//     },
//     child: Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: widget.connectedUser["profile"]["photoProfile"]?.isNotEmpty ?? false
//                 ? Image.network(
//                     widget.connectedUser["profile"]["photoProfile"],
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
//                   )
//                 : const Icon(Icons.person, color: Colors.white),
//           ),
//         ),
//         title: Text("${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(post.content ?? AppLocales.getTranslation('no_content', locale)),
//             if (post.image?.isNotEmpty ?? false)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Image.network(
//                   post.image!,
//                   height: 150,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     ),
//   );
// },

//   );
// }
