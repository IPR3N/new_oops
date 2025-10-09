import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/profile/service/profile_Http_service.dart';
import 'package:new_oppsfarm/profile/userProfile_image_page.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();
  final ProfileHttpService _profileFreiendshipProfile = ProfileHttpService();
  dynamic connectedUser;
  Map<int, bool> _friendRequestSent = {};
  List<Map<String, dynamic>> _users = [];
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> connectUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
        print("Utilisateur connecté : $connectedUser");
      } else {
        print("Aucun token trouvé !");
      }
    } catch (e) {
      print("Erreur lors de la connexion de l'utilisateur : $e");
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Erreur de connexion : $e")),
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

  Future<void> getUserForMembership() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usersData = await _projectService.getUser();
      List<Map<String, dynamic>> users =
          List<Map<String, dynamic>>.from(usersData);

      // Filtrer les utilisateurs :
      // 1. Exclure l'utilisateur connecté
      // 2. Exclure les utilisateurs qui ont une demande reçue de l'utilisateur connecté
      users = users.where((user) {
        final userId = user['id'];
        if (userId == connectedUser?['id'])
          return false; // Exclure l'utilisateur connecté

        final receivedRequests =
            List<Map<String, dynamic>>.from(user['receivedRequests'] ?? []);
        // Vérifier si une demande reçue vient de l'utilisateur connecté
        final hasPendingRequestFromConnectedUser = receivedRequests.any(
            (request) =>
                request['requester']?['id'] == connectedUser['id'] &&
                request['status'] == 'pending');
        return !hasPendingRequestFromConnectedUser; // Garder uniquement ceux sans demande en attente
      }).toList();

      print("Utilisateurs filtrés : $users");
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    } catch (error) {
      print("Erreur lors de la récupération des utilisateurs : $error");
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Erreur de récupération : $error")),
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
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    connectUser().then((_) => getUserForMembership());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    // final cardColor = isDarkMode ? Colors.grey[900] : white;
    // final borderColor = isDarkMode ? Colors.grey[700]! : green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Connections"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: textColor,
          indicatorColor: green,
          tabs: const [
            Tab(text: "Suggestions"),
            Tab(text: "Potential connections"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? const Center(child: Text("Aucune suggestion disponible"))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        final userId = user['id'] as int?;
                        if (userId == null) return const SizedBox.shrink();

                        bool isRequestSent =
                            _friendRequestSent[userId] ?? false;

                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const UserprofileImagePage(),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                user["profile"]?["photoProfile"] ??
                                    "https://picsum.photos/id/1011/100/100",
                                height: 26,
                                width: 26,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    "https://picsum.photos/id/1011/100/100",
                                    height: 26,
                                    width: 26,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            '${user['nom'] ?? 'Nom indisponible'} ${user['prenom'] ?? 'Prénom indisponible'}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user['profile']?['username'] ??
                                'Username indisponible',
                          ),
                          trailing: ElevatedButton(
                            onPressed: isRequestSent || _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      await _profileFreiendshipProfile
                                          .sendFriendRequest(
                                        requesterId: int.parse(
                                            connectedUser['id'].toString()),
                                        receiverId:
                                            int.parse(userId.toString()),
                                      );
                                      if (mounted) {
                                        setState(() {
                                          _friendRequestSent[userId] = true;
                                          // Retirer l'utilisateur de la liste après envoi
                                          _users.removeWhere(
                                              (u) => u['id'] == userId);
                                        });
                                        _scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Demande d'amitié envoyée")),
                                        );
                                      }
                                    } catch (e) {
                                      print('Erreur envoi demande : $e');
                                      if (mounted) {
                                        _scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                              content: Text("Erreur : $e")),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isRequestSent ? Colors.grey : green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              isRequestSent ? "Demande envoyée" : "Suivre",
                              style: TextStyle(color: white),
                            ),
                          ),
                        );
                      },
                    ),
          const Center(child: Text("Potential connections")),
        ],
      ),
    );
  }
}
