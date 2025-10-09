// import 'package:flutter/material.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
// import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';

// class ProfilePage extends StatefulWidget {
//   final dynamic connectedUser; // Current logged-in user
//   final int? visitorUserId; // Optional: ID of the visitor (null if it's the owner)

//   const ProfilePage({
//     super.key,
//     required this.connectedUser,
//     this.visitorUserId,
//   });

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final double coverHeight = 200;
//   final double profileHeight = 100;
//   final HttpService _httpService = HttpService();
//   final AuthService _authService = AuthService();

//   bool _isLoading = false;
//   List<OppsModel> _oopsPosts = [];
//   bool _isFollowing = false; // Simulated follow state
//   int _followersCount = 500; // Simulated initial count
//   int _followingCount = 100; // Simulated initial count

//   late final int userId;
//   late final String userNom;

//   @override
//   void initState() {
//     super.initState();
//     userId = widget.connectedUser["id"];
//     userNom = widget.connectedUser["profile"]["username"] ?? "Nom inconnu";
//     _fetchUserPosts();
//     _checkFollowStatus(); // Simulate checking if visitor follows this user
//   }

//   Future<void> _fetchUserPosts() async {
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

//   void _checkFollowStatus() {
//     // Simulate checking if the visitor follows this user
//     // Replace with actual API call if available
//     setState(() {
//       _isFollowing = false; // Default for demo; adjust based on real data
//     });
//   }

//   Future<void> _toggleFollow() async {
//     setState(() {
//       _isFollowing = !_isFollowing;
//       _followersCount += _isFollowing ? 1 : -1;
//     });
//     // Add API call to follow/unfollow here (e.g., _httpService.followUser(userId))
//   }

//   bool get _isOwner => widget.visitorUserId == null || widget.visitorUserId == userId;

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.grey[900]! : white;
//     final textColor = isDarkMode ? Colors.white : Colors.black87;
//     final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: coverHeight,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               background: buildCoverImage(isDarkMode: isDarkMode),
//             ),
//             actions: [
//               if (!_isOwner)
//                 PopupMenuButton<String>(
//                   icon: Icon(Icons.more_vert, color: textColor),
//                   onSelected: (value) {
//                     if (value == 'report') {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Utilisateur signalé')),
//                       );
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'report',
//                       child: Text('Signaler'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 const SizedBox(height: 60),
//                 buildProfileImage(isDarkMode: isDarkMode),
//                 const SizedBox(height: 16),
//                 buildUserInfo(isDarkMode: isDarkMode, textColor: textColor),
//                 const SizedBox(height: 20),
//                 buildActionButtons(),
//                 const SizedBox(height: 20),
//                 buildStats(textColor: textColor),
//                 const SizedBox(height: 20),
//                 buildTabs(isDarkMode: isDarkMode, cardColor: cardColor),
//               ],
//             ),
//           ),
//         ],
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

//   Widget buildProfileImage({required bool isDarkMode}) => CircleAvatar(
//         radius: profileHeight / 2,
//         backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
//         child: ClipOval(
//           child: Image.network(
//             widget.connectedUser["profile"]["photoProfile"] ??
//                 "https://picsum.photos/id/1011/100/100",
//             height: profileHeight,
//             width: profileHeight,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Image.network(
//                 "https://picsum.photos/id/1011/100/100",
//                 height: profileHeight,
//                 width: profileHeight,
//                 fit: BoxFit.cover,
//               );
//             },
//           ),
//         ),
//       );

//   Widget buildUserInfo({required bool isDarkMode, required Color textColor}) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: [
//             Text(
//               "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}".trim(),
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
//               style: TextStyle(
//                 color: textColor.withOpacity(0.7),
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 12),
//             if (widget.connectedUser["profile"]?["bio"] != null &&
//                 widget.connectedUser["profile"]?["bio"] != "")
//               Text(
//                 widget.connectedUser["profile"]["bio"],
//                 style: TextStyle(color: textColor, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//           ],
//         ),
//       );

//   Widget buildActionButtons() => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (_isOwner)
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => EditProfilePage(
//                         userId: userId,
//                         userProfile: widget.connectedUser["profile"],
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text("Éditer le profil", style: TextStyle(color: Colors.white)),
//               )
//             else ...[
//               ElevatedButton(
//                 onPressed: _toggleFollow,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isFollowing ? Colors.grey : green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: Text(
//                   _isFollowing ? "Se désabonner" : "S'abonner",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               OutlinedButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Fonctionnalité de messagerie à venir")),
//                   );
//                 },
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: green),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text("Message", style: TextStyle(color: green)),
//               ),
//             ],
//           ],
//         ),
//       );

//   Widget buildStats({required Color textColor}) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildStatColumn("Publications", _oopsPosts.length.toString(), textColor),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FollowFolowers(
//                       userId: userId,
//                       userNom: userNom,
//                       initialTabIndex: 0,
//                     ),
//                   ),
//                 );
//               },
//               child: _buildStatColumn("Abonnés", _followersCount.toString(), textColor),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FollowFolowers(
//                       userId: userId,
//                       userNom: userNom,
//                       initialTabIndex: 1,
//                     ),
//                   ),
//                 );
//               },
//               child: _buildStatColumn("Abonnements", _followingCount.toString(), textColor),
//             ),
//           ],
//         ),
//       );

//   Widget _buildStatColumn(String label, String value, Color textColor) => Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: textColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(color: textColor.withOpacity(0.7)),
//           ),
//         ],
//       );

//   Widget buildTabs({required bool isDarkMode, required Color cardColor}) => DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             TabBar(
//               labelColor: green,
//               unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey,
//               indicatorColor: green,
//               tabs: const [
//                 Tab(text: "Publications"),
//                 Tab(text: "Médias"),
//                 Tab(text: "Likes"),
//               ],
//             ),
//             Container(
//               height: 400,
//               color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
//               child: TabBarView(
//                 children: [
//                   buildPostsList(cardColor: cardColor),
//                   buildMediaList(),
//                   buildLikesList(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//   Widget buildPostsList({required Color cardColor}) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (_oopsPosts.isEmpty) {
//       return const Center(child: Text("Aucune publication"));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(8.0),
//       itemCount: _oopsPosts.length,
//       itemBuilder: (context, index) {
//         final post = _oopsPosts[index];
//         return Card(
//           color: cardColor,
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundImage: NetworkImage(
//                 widget.connectedUser["profile"]["photoProfile"] ??
//                     "https://picsum.photos/100",
//               ),
//             ),
//             title: Text("${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}".trim()),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 4),
//                 Text(post.content ?? "Contenu indisponible"),
//                 if (post.image != null && post.image!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Image.network(
//                       post.image!,
//                       height: 150,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildMediaList() {
//     final mediaPosts = _oopsPosts.where((post) => post.image != null && post.image!.isNotEmpty).toList();
//     if (mediaPosts.isEmpty) {
//       return const Center(child: Text("Aucun média"));
//     }
//     return GridView.builder(
//       padding: const EdgeInsets.all(8.0),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//       ),
//       itemCount: mediaPosts.length,
//       itemBuilder: (context, index) {
//         return Image.network(
//           mediaPosts[index].image!,
//           fit: BoxFit.cover,
//         );
//       },
//     );
//   }

//   Widget buildLikesList() {
//     // Simulate liked posts (replace with actual data if available)
//     return const Center(child: Text("Aucun like visible pour les visiteurs"));
//   }
// }