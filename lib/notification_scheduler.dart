import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:new_oppsfarm/notification_settings/notification_service.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/notification_settings/notification_settings.dart';

class NotificationScheduler {
  static Future<void> scheduleAllProjectNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final projectIds = prefs.getStringList('project_ids') ?? [];

    for (String id in projectIds) {
      final projectData = await _loadProjectData(id);
      if (projectData != null) {
        await scheduleProjectNotifications(projectData);
      }
    }
  }

  static Future<Map<String, dynamic>?> _loadProjectData(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final projectJson = prefs.getString('project_$id');
    if (projectJson != null) {
      return jsonDecode(projectJson);
    }
    return null;
  }

  static Future<void> scheduleProjectNotifications(Map<String, dynamic> projectData) async {
    final id = projectData['id'] as int;
    final nom = projectData['nom'] as String;
    final startDate = DateTime.parse(projectData['startDate'] as String);
    final endDate = DateTime.parse(projectData['endDate'] as String);
    final cropVarietyData = projectData['cropVariety'] as Map<String, dynamic>?;
    final cropVariety = cropVarietyData != null ? CropVariety.fromJson(cropVarietyData) : null;
    final daysToMaturity = cropVariety?.days_to_maturity ?? 0;
    final isListedOnMarketplace = projectData['isListedOnMarketplace'] as bool? ?? false;

    final notificationsPlugin = NotificationService.flutterLocalNotificationsPlugin;

    final notifyStart = await NotificationSettings.getStartNotification();
    final notifyProgress50 = await NotificationSettings.getProgress50Notification();
    final notifyProgress80 = await NotificationSettings.getProgress80Notification();
    final notifyHarvest = await NotificationSettings.getHarvestNotification();
    final harvestDays = await NotificationSettings.getHarvestDays();

    // Payload dynamique basé sur l'ID du projet
    final String payload = '/ProjectDetails?id=$id';

    if (notifyStart) {
      await notificationsPlugin.zonedSchedule(
        id * 1000 + 1,
        'Début du projet',
        'Votre projet $nom démarre aujourd\'hui !',
        tz.TZDateTime.from(startDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'crop_channel',
            'Crop Notifications',
            channelDescription: 'Notifications pour le suivi des cultures',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'open_app',
                'Ouvrir l\'app',
                showsUserInterface: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload, // Ajouter le payload ici
      );
    }

    if (notifyProgress50 && daysToMaturity > 0) {
      final progress50Date = startDate.add(Duration(days: (daysToMaturity * 0.5).round()));
      await notificationsPlugin.zonedSchedule(
        id * 1000 + 2,
        'Progression à 50%',
        'Votre projet $nom atteint 50% aujourd\'hui !',
        tz.TZDateTime.from(progress50Date, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'crop_channel',
            'Crop Notifications',
            channelDescription: 'Notifications pour le suivi des cultures',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'open_app',
                'Ouvrir l\'app',
                showsUserInterface: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }

    if (notifyProgress80 && !isListedOnMarketplace && daysToMaturity > 0) {
      final progress80Date = startDate.add(Duration(days: (daysToMaturity * 0.8).round()));
      await notificationsPlugin.zonedSchedule(
        id * 1000 + 3,
        'Progression à 80%',
        'Votre projet $nom atteint 80% aujourd\'hui ! Publiez-le sur la marketplace.',
        tz.TZDateTime.from(progress80Date, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'crop_channel',
            'Crop Notifications',
            channelDescription: 'Notifications pour le suivi des cultures',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'open_app',
                'Ouvrir l\'app',
                showsUserInterface: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }

    if (notifyHarvest && daysToMaturity > 0) {
      final harvestNotificationDate = endDate.subtract(Duration(days: harvestDays));
      await notificationsPlugin.zonedSchedule(
        id * 1000 + 4,
        'Récolte imminente',
        'Il reste $harvestDays jours avant la récolte de votre projet $nom !',
        tz.TZDateTime.from(harvestNotificationDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'crop_channel',
            'Crop Notifications',
            channelDescription: 'Notifications pour le suivi des cultures',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'open_app',
                'Ouvrir l\'app',
                showsUserInterface: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  static Future<void> updateProjectNotifications(int projectId) async {
    final projectData = await _loadProjectData(projectId.toString());
    if (projectData != null) {
      final notificationsPlugin = NotificationService.flutterLocalNotificationsPlugin;
      await notificationsPlugin.cancel(projectId * 1000 + 1);
      await notificationsPlugin.cancel(projectId * 1000 + 2);
      await notificationsPlugin.cancel(projectId * 1000 + 3);
      await notificationsPlugin.cancel(projectId * 1000 + 4);
      await scheduleProjectNotifications(projectData);
    }
  }
}