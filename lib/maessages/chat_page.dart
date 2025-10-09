import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/maessages/new_conversation.dart';
import 'package:new_oppsfarm/maessages/services/auth.provider.dart';
import 'package:new_oppsfarm/maessages/services/model.dart';
import 'package:new_oppsfarm/maessages/services/service.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/profile/service/profile_http_service.dart';
import '../../core/color.dart';
import '../../locales.dart';
import '../../providers/locale_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  List<Map<String, dynamic>> _friends = [];
  final AuthService _authService = AuthService();
  final ProfileHttpService _profileHttpService = ProfileHttpService();
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  dynamic connectedUsers;
  late ScaffoldMessengerState _scaffoldMessenger;
  bool _friendsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _connectUser();
    _searchController.addListener(_filterConversations);
    _initSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> _connectUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUsers = JwtDecoder.decode(token);
        print("Utilisateur connecté : $connectedUsers");
        if (!_friendsLoaded) {
          _friendsLoaded = true;
          await _loadFriends();
        }
      } else {
        print("Aucun token trouvé !");
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scaffoldMessenger.showSnackBar(
              const SnackBar(
                  content:
                      Text("Aucun token trouvé. Veuillez vous connecter.")),
            );
          });
        }
      }
    } catch (e) {
      print("Erreur lors de la connexion de l'utilisateur : $e");
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scaffoldMessenger.showSnackBar(
            SnackBar(content: Text("Erreur de connexion : $e")),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _getUserFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement initial des amis : $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getUserFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (connectedUsers == null || connectedUsers['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID manquant');
      }
      final userId = connectedUsers['id'];
      final response = await _profileHttpService.getFriends(userId: userId);
      final List<dynamic> data = jsonDecode(response);
      print('Amis récupérés : $data');
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erreur dans _getUserFriends : $e');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Échec du chargement des amis : $e')),
          );
        });
      }
      return [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final conversations = await _chatService.getConversations();
      print('Conversations loaded: $conversations');
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _filteredConversations = conversations;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erreur lors du chargement des conversations : $error');
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scaffoldMessenger.showSnackBar(
            SnackBar(
                content:
                    Text('Échec du chargement des conversations : $error')),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConversations = _conversations.where((conversation) {
        final userName = (conversation.otherUserName ?? '').toLowerCase();
        final lastMessage = (conversation.lastMessage ?? '').toLowerCase();
        return userName.contains(query) || lastMessage.contains(query);
      }).toList();
    });
  }

  void _initSocket() {
    final authState = ref.read(authProvider);
    print('Auth state: $authState');
    if (authState.userId == null) return;

    final currentUserId = int.parse(authState.userId! as String);
    _chatService.initSocket(currentUserId, (Message message) {
      setState(() {
        final otherUserId = message.senderId == currentUserId
            ? message.receiverId
            : message.senderId;
        final otherUserName = message.senderId == currentUserId
            ? message.receiverName ?? 'Inconnu'
            : message.senderName ?? 'Inconnu';
        final existingIndex = _conversations.indexWhere(
          (conv) => conv.otherUserId == otherUserId,
        );

        final newConversation = Conversation(
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          lastMessage: message.content,
          lastMessageTime: message.createdAt,
        );

        if (existingIndex != -1) {
          _conversations[existingIndex] = newConversation;
        } else {
          _conversations.add(newConversation);
        }
        _filterConversations();
      });
    });
  }

  void _startNewConversation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FriendsList(
              scrollController: scrollController,
              friends: _friends,
              onFriendSelected: (friend) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationPage(
                      otherUserId: friend['id'],
                      otherUserName: '${friend['prenom']} ${friend['nom']}',
                    ),
                  ),
                ).then((_) => _loadConversations());
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final locale = ref.watch(localeProvider).languageCode;
    final authState = ref.watch(authProvider);

    if (authState.userId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            AppLocales.getTranslation('non_connecte', locale),
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocales.getTranslation('messages', locale),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocales.getTranslation(
                    'rechercher_conversations', locale),
                prefixIcon: Icon(Icons.search, color: green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: green, width: 2),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
              ),
              style: TextStyle(color: textColor),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? Center(
                        child: Text(
                          AppLocales.getTranslation(
                              'aucune_conversation', locale),
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          final formattedTime = DateFormat('HH:mm').format(
                            conversation.lastMessageTime is String
                                ? DateTime.parse(
                                    conversation.lastMessageTime as String)
                                : conversation.lastMessageTime,
                          );

                          return Card(
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: green,
                                child: Text(
                                  conversation.otherUserName.isNotEmpty
                                      ? conversation.otherUserName[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                conversation.otherUserName,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                conversation.lastMessage,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                formattedTime,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationPage(
                                      otherUserId:
                                          conversation.otherUserId as int,
                                      otherUserName: conversation.otherUserName,
                                    ),
                                  ),
                                ).then((_) => _loadConversations());
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class FriendsList extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> friends;
  final Function(Map<String, dynamic>) onFriendSelected;

  const FriendsList({
    Key? key,
    required this.scrollController,
    required this.friends,
    required this.onFriendSelected,
  }) : super(key: key);

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Sélectionner un ami',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          )
        else if (widget.friends.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Aucun ami disponible',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: widget.friends.length,
              itemBuilder: (context, index) {
                final friend = widget.friends[index];
                final fullName = '${friend['prenom']} ${friend['nom']}';
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: green,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    fullName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => widget.onFriendSelected(friend),
                );
              },
            ),
          ),
      ],
    );
  }
}
