import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';

import 'package:new_oppsfarm/notification_settings/notification_settings_page.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocales.getTranslation('settings', locale),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocales.getTranslation('settings_options', locale),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            // Bouton pour les notifications
            ListTile(
              leading: Icon(Icons.notifications, color: green),
              title: Text(
                AppLocales.getTranslation('notifications', locale),
                style: TextStyle(color: textColor),
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: green),
              title: Text(
                AppLocales.getTranslation('messagerie', locale),
                style: TextStyle(color: textColor),
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const ChatSettingsPage(userId:'user_id')),
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: green),
              title: Text(
                AppLocales.getTranslation('friendship', locale),
                style: TextStyle(color: textColor),
              ),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const FriendshipSettingsPage(userId: 'user_id')),
                // );
              },
            ),
            // Exemples de futurs boutons (optionnels)
            // ListTile(
            //   leading: Icon(Icons.language, color: green),
            //   title: Text(
            //     AppLocales.getTranslation('language', locale),
            //     style: TextStyle(color: textColor),
            //   ),
            //   trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            //   onTap: () {
            //     // TODO: Implémenter la page pour la langue
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.palette, color: green),
            //   title: Text(
            //     AppLocales.getTranslation('theme', locale),
            //     style: TextStyle(color: textColor),
            //   ),
            //   trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
            //   onTap: () {
            //     // TODO: Implémenter la page pour le thème
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
