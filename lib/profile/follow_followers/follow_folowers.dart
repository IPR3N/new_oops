import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/profile/follow_followers/connexion.dart';
import 'package:new_oppsfarm/profile/service/profile_Http_service.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class FollowFolowers extends StatefulWidget {
  final int initialTabIndex;
  final int userId;
  final String userNom;
  const FollowFolowers({
    super.key,
    this.initialTabIndex = 0,
    required this.userNom,
    required this.userId,
  });

  @override
  State<FollowFolowers> createState() => _FollowFolowersState();
}

class _FollowFolowersState extends State<FollowFolowers>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> friends = [];
  bool _isLoading = false;
  final ProfileHttpService _profileHttpService = ProfileHttpService();
  List<Map<String, dynamic>> _outgoingRequests = [];
  List<Map<String, dynamic>> _incomingRequests = [];

  List<int> _incomingSenderIds = [];

  Future<void> getOutgoingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileHttpService
          .getOutgoingFriendRequests(int.parse(widget.userId.toString()));
      if (mounted) {
        setState(() {
          _outgoingRequests = List<Map<String, dynamic>>.from(data['requests']);
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

  Future<void> getIncomingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileHttpService
          .getIncomingFriendRequests(int.parse(widget.userId.toString()));
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

  Future<void> acceptFriendRequest(int requesterId) async {
    if (!_incomingSenderIds.contains(requesterId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cette demande n'existe pas")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Corrected: requesterId is the sender, receiverId is the current user
      await _profileHttpService.acceptFriendRequest(
        requesterId: requesterId, // The user who sent the request
        receiverId: widget.userId, // The current user accepting the request
      );
      if (mounted) {
        setState(() {
          _incomingRequests.removeWhere(
              (request) => request['requester']['id'] == requesterId);
          _incomingSenderIds.remove(requesterId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Demande acceptée avec succès")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Future<void> acceptFriendRequest(int requesterId) async {
  //   if (!_incomingSenderIds.contains(requesterId)) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Cette demande n'existe pas")),
  //     );
  //     return;
  //   }
  //   setState(() {
  //     _isLoading = true;
  //     // print("isLoading mis à true");
  //   });
  //   try {
  //     await _profileHttpService.acceptFriendRequest(
  //         requesterId: widget.userId, receiverId: requesterId);
  //     if (mounted) {
  //       setState(() {
  //         _incomingRequests.removeWhere(
  //             (request) => request['requester']['id'] == requesterId);
  //         _incomingSenderIds.remove(requesterId);
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Demande acceptée avec succès")),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Erreur : $e")),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         // print("isLoading mis à false");
  //       });
  //     }
  //   }
  // }

  Future<void> cancelFriendRequest(int receiverId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _profileHttpService.cancelFriendRequest(widget.userId, receiverId);
      if (mounted) {
        setState(() {
          _outgoingRequests.removeWhere(
              (request) => request['receiver']['id'] == receiverId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Demande annulée avec succès")),
        );
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

  void getFirenship() {
    try {
      final response = _profileHttpService.getFriends(userId: widget.userId);
      response.then((friendsData) {
        if (friendsData != null && friendsData.isNotEmpty) {
          final friendsList = jsonDecode(friendsData);
          print(friendsList);
          setState(() {
            friends = friendsList;

            print("Liste d'amis : $friends");
          });
        }
      }).catchError((error) {
        print('Error fetching friends: $error');
      });
    } catch (e) {
      print('Synchronous error in getFirenship: $e');
    }
  }

  Future<void> removeFriend({
    required int friendId,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _profileHttpService.removeFriend(
        userId: widget.userId,
        friendId: friendId,
      );
      if (mounted) {
        setState(() {
          friends.removeWhere((friend) => friend['id'] == friendId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ami supprimé avec succès")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> unfollow({
    required int followedId,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _profileHttpService.unfollow(
        userId: widget.userId,
        followedId: followedId,
      );
      if (mounted) {
        setState(() {
          friends.removeWhere((friend) => friend['id'] == followedId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous ne suivez plus cette personne")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    getFirenship();
    getOutgoingFriendRequests();
    getIncomingFriendRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[900] : white;
    // final borderColor = isDarkMode ? Colors.grey[700]! : green;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        title: Text(widget.userNom),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Connexion();
              }));
            },
            icon: const Icon(Icons.person_add_alt),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Amis"),
            Tab(text: "Abonnements"),
            Tab(text: "Abonnements"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : friends.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun ami pour le moment",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final friendPrenom =
                            friend['prenom']?.toString() ?? 'N/A';
                        final friendNom = friend['nom']?.toString() ?? 'N/A';

                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          shadowColor: Colors.lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 4.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 2),
                              Expanded(
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        friendPrenom.isNotEmpty
                                            ? friendPrenom[0]
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        '$friendNom $friendPrenom',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    '0 amis en commun',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    color: white,
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey[600],
                                    ),
                                    onSelected: (String result) {
                                      switch (result) {
                                        case 'message':
                                          break;

                                        case 'arhiver':
                                          break;

                                        case 'unfollow':
                                          unfollow(followedId: friend);
                                          break;

                                        case 'remove':
                                          unfollow(followedId: friend);
                                          break;
                                        case 'block':
                                          // Logique pour bloquer l'ami
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'message',
                                        child: Row(
                                          children: [
                                            Icon(Icons.message,
                                                size: 20, color: green),
                                            SizedBox(width: 8),
                                            Text('Envoyez un message'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'arhiver',
                                        child: Row(
                                          children: [
                                            Icon(Icons.archive,
                                                size: 20, color: green),
                                            SizedBox(width: 8),
                                            Text('Ne plus suivre'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_remove,
                                                size: 20, color: green),
                                            SizedBox(width: 8),
                                            Text('Retirer des amis'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'block',
                                        child: Row(
                                          children: [
                                            Icon(Icons.block,
                                                size: 20, color: green),
                                            SizedBox(width: 8),
                                            Text('Bloquer'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _incomingRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune demande reçue",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _incomingRequests.length,
                      itemBuilder: (context, index) {
                        final request = _incomingRequests[index];
                        print("Requête #$index: $request");
                        final sender =
                            request['requester'] ?? {}; // Changement ici
                        final senderId = sender['id']; // ID de l'expéditeur
                        final senderPrenom =
                            sender['prenom']?.toString() ?? 'N/A';
                        final senderNom = sender['nom']?.toString() ?? 'N/A';

                        return Card(
                          color: white,
                          elevation: 1,
                          shadowColor: lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                        8), // Coins arrondis
                                  ),
                                  child: Center(
                                    child: Text(
                                      senderPrenom.isNotEmpty
                                          ? senderPrenom[0]
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 35),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$senderNom $senderPrenom',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Text(
                                    //   'Statut : ${request['status'] ?? 'Inconnu'}',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     color: Colors.grey[600],
                                    //   ),
                                    // ),
                                    const SizedBox(
                                        height:
                                            8), // Espacement avant les boutons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (senderId != null) {
                                                    acceptFriendRequest(
                                                        senderId);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "ID de l'expéditeur manquant",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors
                                                .green, // Couleur du texte
                                            backgroundColor: Colors
                                                .transparent, // Fond transparent
                                            shadowColor: Colors
                                                .transparent, // Pas d'ombre
                                            side: const BorderSide(
                                                color: Colors.green,
                                                width: 2), // Bordure verte
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                          ),
                                          child: const Text(
                                            "Accepter",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  print(
                                                      "Bouton Refuser cliqué pour requête #$index");
                                                  if (senderId != null) {
                                                    // rejectFriendRequest(senderId);
                                                    cancelFriendRequest(
                                                        senderId);
                                                    print(
                                                        "Refuser senderId: $senderId");
                                                  } else {
                                                    print(
                                                        "Aucun senderId pour Refuser: $request");
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors
                                                .redAccent, // Couleur du texte
                                            backgroundColor: Colors
                                                .transparent, // Fond transparent
                                            shadowColor: Colors
                                                .transparent, // Pas d'ombre
                                            side: const BorderSide(
                                                color: Colors.redAccent,
                                                width: 2), // Bordure rouge
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                          ),
                                          child: const Text(
                                            "Refuser",
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _outgoingRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune demande envoyée",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _incomingRequests.length,
                      itemBuilder: (context, index) {
                        final request = _incomingRequests[index];
                        print("Requête #$index: $request");
                        final sender = request['requester'] ?? {};
                        final senderId = sender['id']; // ID de l'expéditeur
                        final requestId = request['id']; // ID de la demande
                        final senderPrenom =
                            sender['prenom']?.toString() ?? 'N/A';
                        final senderNom = sender['nom']?.toString() ?? 'N/A';

                        return Card(
                          color: white,
                          elevation: 1,
                          shadowColor: lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Text(
                                    senderPrenom.isNotEmpty
                                        ? senderPrenom[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$senderNom $senderPrenom',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Statut : ${request['status'] ?? 'Inconnu'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              print(
                                                  "Bouton Accepter cliqué pour requête #$index");
                                              print(
                                                  "requestId trouvé: $requestId");
                                              if (requestId != null) {
                                                acceptFriendRequest(
                                                    requestId); // Utilise requestId
                                              } else {
                                                print(
                                                    "Aucun requestId trouvé dans la requête: $request");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "ID de la demande manquant")),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        "Accepter",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              print(
                                                  "Bouton Refuser cliqué pour requête #$index");
                                              if (requestId != null) {
                                                // rejectFriendRequest(requestId);
                                                print(
                                                    "Refuser requestId: $requestId");
                                              } else {
                                                print(
                                                    "Aucun requestId pour Refuser: $request");
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        "Refuser",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
