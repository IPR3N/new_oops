// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/notification/services/NotificationClient_services.dart';
// import 'package:new_oppsfarm/notification/services/notification_sse_model.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

// // Provider pour le compteur de notifications non lues
// final unreadNotificationsProvider = StateProvider<int>((ref) => 0);

// // Provider pour le service NotificationClient
// final notificationClientProvider =
//     Provider<NotificationClient>((ref) => NotificationClient());

// // Provider pour écouter les notifications en temps réel
// final notificationStreamProvider =
//     StreamProvider<NotificationModel>((ref) async* {
//   final client = ref.watch(notificationClientProvider);
//   final authService = AuthService();
//   final token = await authService.readToken();
//   if (token != null) {
//     final decoded = JwtDecoder.decode(token);
//     final userId = decoded['id'] as int?;
//     if (userId != null) {
//       yield* client.streamNotifications(userId);
//     }
//   }
// });

// // Manager pour gérer les notifications
// class NotificationManager {
//   static void initialize(WidgetRef ref) {
//     ref.listen(notificationStreamProvider, (previous, next) {
//       next.when(
//         data: (notification) {
//           if (!notification.isRead) {
//             ref.read(unreadNotificationsProvider.notifier).state++;
//           }
//         },
//         loading: () => print('Chargement des notifications...'),
//         error: (error, stack) => print('Erreur dans le stream: $error'),
//       );
//     });
//   }

//   static void resetUnreadCount(WidgetRef ref) {
//     ref.read(unreadNotificationsProvider.notifier).state = 0;
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/notification_page/services/NotificationClient_services.dart';
import 'package:new_oppsfarm/notification_page/services/notification_sse_model.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'dart:async';

// Provider pour le compteur de notifications non lues
final unreadNotificationsProvider = StateProvider<int>((ref) => 0);

// Provider pour le service NotificationClient
final notificationClientProvider =
    Provider<NotificationClient>((ref) => NotificationClient());

// Manager pour gérer les notifications
class NotificationManager {
  static Future<StreamSubscription<NotificationModel>?> initialize(
      WidgetRef ref) async {
    final client = ref.read(notificationClientProvider);
    final authService = AuthService();
    final token = await authService.readToken();

    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      final userId = decoded['id'] as int?;
      if (userId != null) {
        final stream = client.streamNotifications(userId);
        return stream.listen(
          (notification) {
            if (!notification.isRead) {
              ref.read(unreadNotificationsProvider.notifier).state++;
            }
          },
          onError: (error) {
            print('Erreur dans le stream: $error');
          },
          onDone: () {
            print('Stream SSE terminé');
          },
        );
      }
    }
    return null; // Retourne null si pas de token ou userId
  }

  static void resetUnreadCount(WidgetRef ref) {
    ref.read(unreadNotificationsProvider.notifier).state = 0;
  }
}
