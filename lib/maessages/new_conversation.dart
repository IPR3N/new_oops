import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/maessages/services/auth.provider.dart';
import 'package:new_oppsfarm/maessages/services/model.dart';
import 'package:new_oppsfarm/maessages/services/service.dart';
import '../../core/color.dart';

class ConversationPage extends ConsumerStatefulWidget {
  final int otherUserId;
  final String otherUserName;

  const ConversationPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  List<Message> _messages = [];
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  int? _currentUserId;
  late ScrollController _scrollController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
      }
      return;
    }
    try {
      _currentUserId = authState.userId;
    } catch (e) {
      print('Erreur lors de la conversion de userId : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID utilisateur invalide')),
        );
      }
      return;
    }
    await _loadMessages();
    _initSocket();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final messages = await _chatService.getConversation(
        _currentUserId!,
        widget.otherUserId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (error) {
      print('Erreur lors du chargement des messages : $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des messages : $error')),
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

  void _initSocket() {
    if (_currentUserId == null) return;

    _chatService.initSocket(_currentUserId!, (Message message) {
      if (message.senderId == widget.otherUserId ||
          message.receiverId == widget.otherUserId) {
        setState(() {
          _messages.add(message);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty || _currentUserId == null) return;

    final content = _messageController.text.trim();
    try {
      final response = await _chatService.sendMessageHttp(
        _currentUserId!,
        widget.otherUserId,
        content,
      );
      if (mounted) {
        setState(() {
          _messages.add(response);
          _messageController.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (error) {
      print('Erreur lors de l\'envoi du message : $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'envoi du message : $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          widget.otherUserName,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun message pour le moment',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByUser =
                              message.senderId == _currentUserId;
                          final formattedTime =
                              DateFormat('HH:mm').format(message.createdAt);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Align(
                              alignment: isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                margin: EdgeInsets.only(
                                  top: 4,
                                  bottom: 4,
                                  left: isSentByUser ? 48 : 8,
                                  right: isSentByUser ? 8 : 48,
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByUser
                                      ? green
                                      : (isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200]),
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(isSentByUser ? 12 : 0),
                                    topRight:
                                        Radius.circular(isSentByUser ? 0 : 12),
                                    bottomLeft: const Radius.circular(12),
                                    bottomRight: const Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isSentByUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isSentByUser
                                            ? Colors.white
                                            : textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        color: isSentByUser
                                            ? Colors.white70
                                            : Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez un message...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: green, width: 2),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    style: TextStyle(color: textColor, fontSize: 15),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: green,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
