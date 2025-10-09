class NotificationModel {
  final int? id; // Rendu nullable
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    this.id, // Plus besoin de required si nullable
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?, // Accepte null
      message:
          json['message'] as String? ?? 'Message inconnu', // Fallback si null
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
