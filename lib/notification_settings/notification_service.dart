import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _alarmPlatform = MethodChannel('com.example/alarm');

  // Clé globale pour la navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'crop_channel',
      'Crop Notifications',
      description: 'Notifications pour le suivi des cultures et projets',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 1000, 500]),
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final bool? notificationGranted = await androidPlugin?.requestNotificationsPermission();
      print('Permission de notification accordée : $notificationGranted');

      final bool canScheduleExact = await _canScheduleExactAlarms();
      if (!canScheduleExact) {
        print('Permission pour alarmes exactes non accordée. Demande en cours...');
        await _requestExactAlarmPermission();
        final bool recheck = await _canScheduleExactAlarms();
        print('Permission pour alarmes exactes après demande : $recheck');
      }
    }

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification sélectionnée avec payload : ${response.payload}');
        _handleNotificationResponse(response);
      },
    );
  }

  // Gérer la réponse à la notification
  static void _handleNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null && navigatorKey.currentState != null) {
      print('Navigating to route from payload: $payload');
      navigatorKey.currentState!.pushNamed(payload);
    } else {
      print('Navigator non disponible ou payload vide');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    String? payload,
    String summaryText = 'Action requise',
    List<AndroidNotificationAction>? actions,
  }) async {
    final String? imagePath = await _downloadAndSaveImage(imageUrl, id);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'crop_channel',
      'Crop Notifications',
      channelDescription: 'Notifications pour le suivi des cultures et projets',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.green,
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/icon'),
      styleInformation: imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              largeIcon: const DrawableResourceAndroidBitmap('@drawable/icon'),
              contentTitle: '<b>$title</b>',
              summaryText: body,
              htmlFormatContentTitle: true,
            )
          : BigTextStyleInformation(
              body,
              contentTitle: '<b>$title</b>',
              summaryText: summaryText,
              htmlFormatContentTitle: true,
            ),
      actions: actions ??
          [
            AndroidNotificationAction(
              'open_app',
              'Ouvrir l\'app',
              showsUserInterface: true,
            ),
          ],
      ticker: 'Mise à jour de projet',
    );

    final DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload ?? '/Home',
      );
    } catch (e) {
      print('Erreur lors de l\'affichage de la notification : $e');
    }
  }

  static Future<void> scheduleNotification({
    required BuildContext context,
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? imageUrl,
    String? payload,
    String summaryText = 'Action requise',
    List<AndroidNotificationAction>? actions,
  }) async {
    final String? imagePath = await _downloadAndSaveImage(imageUrl, id);

    final bool canScheduleExact = await _canScheduleExactAlarms();
    if (Platform.isAndroid && !canScheduleExact) {
      print('Permission pour alarmes exactes non accordée au moment de programmer.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Les notifications précises nécessitent une autorisation. Activez les alarmes exactes dans les paramètres.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Paramètres',
            textColor: Colors.white,
            onPressed: () async {
              await _requestExactAlarmPermission();
            },
          ),
        ),
      );
      await _scheduleWithMode(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        imagePath: imagePath,
        payload: payload,
        summaryText: summaryText,
        actions: actions,
        mode: AndroidScheduleMode.inexact,
      );
      return;
    }

    await _scheduleWithMode(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      imagePath: imagePath,
      payload: payload,
      summaryText: summaryText,
      actions: actions,
      mode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> _scheduleWithMode({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String? imagePath,
    required String? payload,
    required String summaryText,
    required List<AndroidNotificationAction>? actions,
    required AndroidScheduleMode mode,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'crop_channel',
      'Crop Notifications',
      channelDescription: 'Notifications pour le suivi des cultures et projets',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.green,
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/icon'),
      styleInformation: imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath),
              largeIcon: const DrawableResourceAndroidBitmap('@drawable/icon'),
              contentTitle: '<b>$title</b>',
              summaryText: body,
              htmlFormatContentTitle: true,
            )
          : BigTextStyleInformation(
              body,
              contentTitle: '<b>$title</b>',
              summaryText: summaryText,
              htmlFormatContentTitle: true,
            ),
      actions: actions ??
          [
            AndroidNotificationAction(
              'open_app',
              'Ouvrir l\'app',
              showsUserInterface: true,
            ),
          ],
      ticker: 'Mise à jour de projet',
    );

    final DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload, // Payload passé directement
      );
    } catch (e) {
      print('Erreur lors de la programmation de la notification : $e');
    }
  }

  static Future<bool> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool canSchedule = await _alarmPlatform.invokeMethod('canScheduleExactAlarms');
      return canSchedule;
    } catch (e) {
      print('Erreur lors de la vérification des alarmes exactes : $e');
      return false;
    }
  }

  static Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _alarmPlatform.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      print('Erreur lors de la demande de permission d\'alarme : $e');
    }
  }

  static Future<String?> _downloadAndSaveImage(String? url, int id) async {
    if (url == null) return null;
    try {
      final response = await http.get(Uri.parse(url));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/notification_image_$id.png');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return null;
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      print('Notification $id annulée');
    } catch (e) {
      print('Erreur lors de l\'annulation de la notification : $e');
    }
  }
}