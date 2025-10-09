// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/notification_page/services/NotificationClient_services.dart';
// import 'package:new_oppsfarm/notification_page/services/notification_sse_model.dart';
// import 'dart:async';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

// class NotificationPage extends StatefulWidget {
//   const NotificationPage({super.key});

//   @override
//   _NotificationPageState createState() => _NotificationPageState();
// }

// class _NotificationPageState extends State<NotificationPage> {
//   final NotificationClient _notificationClient = NotificationClient();
//   List<NotificationModel> notifications = [];
//   StreamSubscription<NotificationModel>? _subscription;
//   final AuthService _authService = AuthService();
//   Map<String, dynamic>? connectedUser;
//   bool _isLoading = false;

//   late ScaffoldMessengerState _scaffoldMessenger;
//   int? userId;

//   @override
//   void initState() {
//     super.initState();
//     _initUserAndLoad();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _scaffoldMessenger = ScaffoldMessenger.of(context);
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }

//   Future<void> _initUserAndLoad() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String? token = await _authService.readToken();
//       if (token != null) {
//         connectedUser = JwtDecoder.decode(token);
//         userId = connectedUser?['id'] as int?;
//         print("Utilisateur connecté : $connectedUser");
//         if (userId != null) {
//           await _loadNotifications();
//           _listenToNotifications();
//         } else {
//           print("ID utilisateur non trouvé dans le token");
//         }
//       } else {
//         print("Aucun token trouvé !");
//       }
//     } catch (e) {
//       print("Erreur lors de la connexion de l'utilisateur : $e");
//       if (mounted) {
//         _scaffoldMessenger.showSnackBar(
//           SnackBar(content: Text("Erreur de connexion : $e")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadNotifications() async {
//     if (userId == null) return; // Sécurité si userId n’est pas encore défini

//     try {
//       final fetchedNotifications =
//           await _notificationClient.fetchNotifications(userId!);
//       if (mounted) {
//         setState(() {
//           notifications = fetchedNotifications;
//         });
//       }
//     } catch (e) {
//       print('Erreur lors du chargement: $e');
//     }
//   }

//   void _listenToNotifications() {
//     if (userId == null) return; // Sécurité si userId n’est pas encore défini

//     _subscription = _notificationClient.streamNotifications(userId!).listen(
//       (notification) {
//         if (mounted) {
//           setState(() {
//             notifications.insert(0, notification);
//           });
//         }
//       },
//       onError: (error) {
//         print('Erreur SSE: $error');
//       },
//       onDone: () {
//         print('Stream SSE terminé');
//       },
//     );
//   }

//   Future<void> _markAsRead(int notificationId) async {
//     if (userId == null) return; // Sécurité si userId n’est pas encore défini

//     try {
//       await _notificationClient.markAsRead(notificationId, userId!);
//       if (mounted) {
//         setState(() {
//           notifications = notifications
//               .map((n) => n.id == notificationId
//                   ? NotificationModel(
//                       id: n.id,
//                       message: n.message,
//                       createdAt: n.createdAt,
//                       isRead: true)
//                   : n)
//               .toList();
//         });
//       }
//     } catch (e) {
//       print('Erreur lors de la mise à jour: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: AppBar(
//         backgroundColor: white,
//         title: const Text('Notifications'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : notifications.isEmpty
//               ? const Center(child: Text('Aucune notification'))
//               : ListView.builder(
//                   itemCount: notifications.length,
//                   itemBuilder: (context, index) {
//                     final notification = notifications[index];
//                     return ListTile(
//                       title: Text(notification.message),
//                       subtitle: Text(notification.createdAt.toString()),
//                       trailing: notification.isRead
//                           ? null
//                           : const Icon(Icons.circle,
//                               color: Colors.red, size: 10),
//                       onTap: () {
//                         if (notification.id != null) {
//                           _markAsRead(notification.id!);
//                         }
//                       },
//                     );
//                   },
//                 ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/notification_page/services/NotificationClient_services.dart';
import 'package:new_oppsfarm/notification_page/services/notification_sse_model.dart';
import 'dart:async';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:new_oppsfarm/providers/locale_provider.dart'; // Assuming this exists

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final NotificationClient _notificationClient = NotificationClient();
  List<NotificationModel> notifications = [];
  StreamSubscription<NotificationModel>? _subscription;
  final AuthService _authService = AuthService();
  Map<String, dynamic>? connectedUser;
  bool _isLoading = false;

  late ScaffoldMessengerState _scaffoldMessenger;
  int? userId;

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initUserAndLoad() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
        userId = connectedUser?['id'] as int?;
        print("Utilisateur connecté : $connectedUser");
        if (userId != null) {
          await _loadNotifications();
          _listenToNotifications();
        } else {
          print("ID utilisateur non trouvé dans le token");
        }
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

  Future<void> _loadNotifications() async {
    if (userId == null) return;

    try {
      final fetchedNotifications =
          await _notificationClient.fetchNotifications(userId!);
      if (mounted) {
        setState(() {
          notifications = fetchedNotifications;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement: $e');
    }
  }

  void _listenToNotifications() {
    if (userId == null) return;

    _subscription = _notificationClient.streamNotifications(userId!).listen(
      (notification) {
        if (mounted) {
          setState(() {
            notifications.insert(0, notification);
          });
        }
      },
      onError: (error) {
        print('Erreur SSE: $error');
      },
      onDone: () {
        print('Stream SSE terminé');
      },
    );
  }

  Future<void> _markAsRead(int notificationId) async {
    if (userId == null) return;

    try {
      await _notificationClient.markAsRead(notificationId, userId!);
      if (mounted) {
        setState(() {
          notifications = notifications
              .map((n) => n.id == notificationId
                  ? NotificationModel(
                      id: n.id,
                      message: n.message,
                      createdAt: n.createdAt,
                      isRead: true,
                    )
                  : n)
              .toList();
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final locale = ref.read(localeProvider).languageCode;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return AppLocales.getTranslation('just_now', locale);
    } else if (difference.inHours < 24) {
      return AppLocales.getTranslation('hours_ago', locale,
          placeholders: {'hours': difference.inHours.toString()});
    } else if (difference.inDays == 1) {
      return AppLocales.getTranslation('yesterday', locale);
    } else if (difference.inDays < 7) {
      return AppLocales.getTranslation('days_ago', locale,
          placeholders: {'days': difference.inDays.toString()});
    } else if (difference.inDays < 30) {
      return AppLocales.getTranslation('weeks_ago', locale,
          placeholders: {'weeks': (difference.inDays ~/ 7).toString()});
    } else {
      return DateFormat(locale == 'en' ? 'MM/dd/yyyy' : 'dd/MM/yyyy', locale)
          .format(dateTime);
    }
  }

  RichText _buildNotificationText(String message, bool isUnread, Color textColor) {
    final parts = message.split(' ');
    final actionWords = [
      'liked',
      'commented',
      'followed',
      'shared',
      'posted',
      'by',
      'on',
      'your'
    ];

    int nameEndIndex = parts.length;
    for (int i = 0; i < parts.length; i++) {
      if (actionWords.contains(parts[i].toLowerCase())) {
        nameEndIndex = i;
        break;
      }
    }

    if (nameEndIndex <= 1) {
      return RichText(
        text: TextSpan(
          text: message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      );
    }

    final name = parts.sublist(0, nameEndIndex).join(' ');
    final rest = parts.sublist(nameEndIndex).join(' ');

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          TextSpan(
            text: rest.isNotEmpty ? ' $rest' : '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode; // Watch locale changes
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('notifications', locale), // Localized title
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    AppLocales.getTranslation('no_notifications', locale),
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isUnread = !notification.isRead;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isUnread
                            ? const BorderSide(color: Colors.red, width: 2)
                            : BorderSide.none,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isUnread ? Colors.red[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: isUnread ? Colors.red : Colors.grey,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNotificationText(
                                      notification.message, isUnread, textColor),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRelativeTime(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnread)
                              GestureDetector(
                                onTap: () {
                                  if (notification.id != null) {
                                    _markAsRead(notification.id!);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppLocales.getTranslation('new', locale),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}