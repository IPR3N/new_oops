import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';
import 'package:new_oppsfarm/pages/view/settings_page.dart';
import 'package:new_oppsfarm/profile/profile_page.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class CustomDrawer extends ConsumerWidget {
  final dynamic connectedUser;
  final Color backgroundColor;
  final Color textColor;
  final bool isDarkMode;
  final VoidCallback onLogout;
  final Function(BuildContext) onShowThemeBottomSheet;
  final Function(BuildContext) onShowLanguageBottomSheet;

  const CustomDrawer({
    super.key,
    required this.connectedUser,
    required this.backgroundColor,
    required this.textColor,
    required this.isDarkMode,
    required this.onLogout,
    required this.onShowThemeBottomSheet,
    required this.onShowLanguageBottomSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    "${connectedUser?['nom']} ${connectedUser?['prenom']}"
                        .trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(connectedUser?['email'] ?? ''),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            connectedUser: {
                              ...connectedUser,
                              "profile": connectedUser["profile"] ?? {},
                            },
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        connectedUser?['profile']?['photoProfile']
                                    ?.isNotEmpty ==
                                true
                            ? connectedUser['profile']['photoProfile']
                            : 'https://picsum.photos/id/1015/500/300',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://picsum.photos/id/1015/500/300',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : green,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocales.getTranslation('profile', locale)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          connectedUser: {
                            ...connectedUser,
                            "profile": connectedUser["profile"] ?? {},
                          },
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(AppLocales.getTranslation('settings', locale)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app,
                      color: Colors.red, size: 20),
                  title: Text(AppLocales.getTranslation('logout', locale)),
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onShowThemeBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.color_lens, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        AppLocales.getTranslation('theme', locale),
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onShowLanguageBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        AppLocales.getTranslation('language', locale),
                        style: TextStyle(color: textColor),
                      ),
                    ],
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
