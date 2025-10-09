import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/pages/projets/project_group_message/service/project-chat.service.dart';

class GroupMessage extends StatefulWidget {
  final int userId;
  final int projectId;
  final String token;

  const GroupMessage({
    Key? key,
    required this.userId,
    required this.projectId,
    required this.token,
  }) : super(key: key);

  @override
  State<GroupMessage> createState() => _GroupMessageState();
}

class _GroupMessageState extends State<GroupMessage> {
  final ProjectChatService _chatService = ProjectChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // JSON cru
  final ScrollController _scrollController = ScrollController();
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      setState(() => _isLoading = true);

      await _chatService.initSocket(widget.userId, widget.projectId,
          (jsonMessage) {
        // Vérifie duplication par ID
        if (!_messages
            .any((m) => (m['id'] as int?) == (jsonMessage['id'] as int?))) {
          setState(() {
            _messages.add(jsonMessage);
            _scrollToBottom();
          });
        }
      });

      final messages = await _chatService.getProjectMessages(widget.projectId);
      setState(() {
        _messages.clear();
        _messages.addAll(messages); // Déjà filtré dans le service
        _isLoading = false;
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'initialisation du chat : $e';
        _isLoading = false;
      });
      print('Erreur lors de l\'initialisation du chat : $e');
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      setState(() => _errorMessage = null);
      final jsonMessage = await _chatService.sendMessageHttp(
          widget.userId, widget.projectId, content);
      // Vérifie duplication par ID
      if (!_messages
          .any((m) => (m['id'] as int?) == (jsonMessage['id'] as int?))) {
        setState(() {
          _messages.add(jsonMessage);
          _scrollToBottom();
        });
      }
      _chatService.sendMessage(widget.userId, widget.projectId, content);
      _messageController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Échec de l\'envoi du message : $e';
      });
      print('Erreur lors de l\'envoi du message : $e');
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Projet ${widget.projectId}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Aucun message pour l\'instant'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.only(bottom: 10),
                        itemBuilder: (context, index) {
                          final jsonMessage = _messages[index];
                          final senderId = jsonMessage['senderId'] as int?;
                          final isMe = senderId == widget.userId;
                          final content =
                              (jsonMessage['content'] as String?)?.trim() ?? '';
                          if (content.isEmpty)
                            return const SizedBox.shrink(); // Double filtre

                          final senderName =
                              jsonMessage['senderName'] as String? ??
                                  'Utilisateur $senderId';
                          final createdAtStr =
                              jsonMessage['created_at'] as String?;
                          final createdAt = createdAtStr != null
                              ? DateTime.tryParse(createdAtStr)
                              : null;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe
                                          ? Colors.blue[800]
                                          : Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    content,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    createdAt != null
                                        ? DateFormat('dd/MM/yyyy HH:mm')
                                            .format(createdAt.toLocal())
                                        : 'Date inconnue',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
                      hintText: 'Tapez un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
