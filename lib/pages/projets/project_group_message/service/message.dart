class Message {
  final int id;
  final String content;
  final int senderId;
  final String? senderName;
  final int projectId;
  final DateTime? createdAt;
  final String? fileUrl;
  final String? fileType;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    this.senderName,
    required this.projectId,
    this.createdAt,
    this.fileUrl,
    this.fileType,
  });

  factory Message.fromJson(Map<String, dynamic>? json) {
    print('Parsing message JSON: $json'); // Debug

    if (json == null) {
      print('JSON null détecté');
      throw Exception('JSON message null');
    }

    // Helper pour parser les IDs (int ou String)
    int parseId(dynamic value, String fieldName) {
      if (value == null) {
        print('$fieldName manquant dans JSON: $json');
        throw Exception('$fieldName manquant');
      }
      try {
        return value is String ? int.parse(value) : value as int;
      } catch (e) {
        print('Erreur parsing $fieldName: $value\nErreur: $e');
        throw Exception('Format invalide pour $fieldName: $value');
      }
    }

    try {
      // Extraire id
      final int id = parseId(json['id'], 'id');

      // Extraire content (accepte vide ou null)
      final String content = (json['content'] as String?)?.trim() ?? '';

      // Extraire senderId
      int senderId;
      if (json.containsKey('senderId') && json['senderId'] != null) {
        senderId = parseId(json['senderId'], 'senderId');
      } else if (json.containsKey('sender') &&
          json['sender'] is Map<String, dynamic> &&
          json['sender']['id'] != null) {
        senderId = parseId(json['sender']['id'], 'sender.id');
      } else {
        print('senderId manquant dans JSON: $json');
        throw Exception('senderId manquant');
      }

      // Extraire projectId
      int projectId;
      if (json.containsKey('projectId') && json['projectId'] != null) {
        projectId = parseId(json['projectId'], 'projectId');
      } else if (json.containsKey('project') &&
          json['project'] is Map<String, dynamic> &&
          json['project']['id'] != null) {
        projectId = parseId(json['project']['id'], 'project.id');
      } else {
        print('projectId manquant dans JSON: $json');
        throw Exception('projectId manquant');
      }

      // Extraire senderName
      String? senderName = json['senderName'] as String?;
      if (senderName == null &&
          json.containsKey('sender') &&
          json['sender'] is Map<String, dynamic>) {
        final sender = json['sender'] as Map<String, dynamic>;
        final nom = sender['nom'] as String? ?? '';
        final prenom = sender['prenom'] as String? ?? '';
        senderName = '$nom $prenom'.trim();
        if (senderName.isEmpty) senderName = null;
      }

      // Extraire createdAt
      DateTime? createdAt;
      if (json['created_at'] != null) {
        try {
          createdAt = DateTime.tryParse(json['created_at'] as String);
          if (createdAt == null) {
            print('Erreur parsing created_at: ${json['created_at']}');
          }
        } catch (e) {
          print('Erreur parsing created_at: ${json['created_at']}\nErreur: $e');
        }
      }

      return Message(
        id: id,
        content: content,
        senderId: senderId,
        senderName: senderName,
        projectId: projectId,
        createdAt: createdAt,
        fileUrl: json['fileUrl'] as String?,
        fileType: json['fileType'] as String?,
      );
    } catch (e) {
      print('Erreur générale dans Message.fromJson: $e\nJSON: $json');
      rethrow;
    }
  }

  @override
  String toString() =>
      'Message(id: $id, content: $content, senderId: $senderId, senderName: $senderName, projectId: $projectId)';
}
