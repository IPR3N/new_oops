import 'package:cached_network_image/cached_network_image.dart';
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

    // Débogage détaillé de connectedUser
    print('🔍 Structure de connectedUser: $connectedUser');

    String? profilePhoto;
    try {
      // Essayer directement proofile
      profilePhoto = connectedUser?['proofile']?['photoProfile'] as String?;
      print('🖼️ Essai proofile: photoProfile=$profilePhoto');

      // Fallback sur profile
      if (profilePhoto == null || profilePhoto.isEmpty) {
        profilePhoto = connectedUser?['profile']?['photoProfile'] as String?;
        print('🖼️ Essai profile: photoProfile=$profilePhoto');
      }

      // Fallback sur user.proofile (cas où connectedUser est imbriqué)
      if (profilePhoto == null || profilePhoto.isEmpty) {
        profilePhoto = connectedUser?['user']?['proofile']?['photoProfile'] as String?;
        print('🖼️ Essai user.proofile: photoProfile=$profilePhoto');
      }

      // Fallback sur user.profile
      if (profilePhoto == null || profilePhoto.isEmpty) {
        profilePhoto = connectedUser?['user']?['profile']?['photoProfile'] as String?;
        print('🖼️ Essai user.profile: photoProfile=$profilePhoto');
      }

      // Vérifier si connectedUser est mal formé
      if (connectedUser == null) {
        print('⚠️ connectedUser est null');
      } else if (connectedUser['proofile'] == null &&
                 connectedUser['profile'] == null &&
                 connectedUser['user']?['proofile'] == null &&
                 connectedUser['user']?['profile'] == null) {
        print('⚠️ Aucune clé proofile ou profile trouvée dans connectedUser');
      }
    } catch (e) {
      print('❌ Erreur lors de l’extraction de photoProfile: $e');
    }

    const defaultImage = 'https://picsum.photos/id/1015/500/300';
    final displayImage = (profilePhoto != null && profilePhoto.isNotEmpty)
        ? profilePhoto
        : defaultImage;
    print('🖼️ Image affichée: $displayImage');

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
                    "${connectedUser?['nom'] ?? connectedUser?['user']?['nom'] ?? 'Inconnu'} ${connectedUser?['prenom'] ?? connectedUser?['user']?['prenom'] ?? ''}"
                        .trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(connectedUser?['email'] ?? connectedUser?['user']?['email'] ?? 'Aucun email'),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            connectedUser: {
                              "id": connectedUser?['id'] ?? connectedUser?['user']?['id'] ?? 0,
                              "nom": connectedUser?['nom'] ?? connectedUser?['user']?['nom'] ?? '',
                              "prenom": connectedUser?['prenom'] ?? connectedUser?['user']?['prenom'] ?? '',
                              "email": connectedUser?['email'] ?? connectedUser?['user']?['email'] ?? '',
                              "profile": connectedUser?['proofile'] ??
                                  connectedUser?['profile'] ??
                                  connectedUser?['user']?['proofile'] ??
                                  connectedUser?['user']?['profile'] ??
                                  {},
                            },
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: displayImage,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) {
                          print('❌ Erreur chargement image: $error');
                          return CachedNetworkImage(
                            imageUrl: defaultImage,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : green, // Utilise greenColor
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
                            "id": connectedUser?['id'] ?? connectedUser?['user']?['id'] ?? 0,
                            "nom": connectedUser?['nom'] ?? connectedUser?['user']?['nom'] ?? '',
                            "prenom": connectedUser?['prenom'] ?? connectedUser?['user']?['prenom'] ?? '',
                            "email": connectedUser?['email'] ?? connectedUser?['user']?['email'] ?? '',
                            "profile": connectedUser?['proofile'] ??
                                connectedUser?['profile'] ??
                                connectedUser?['user']?['proofile'] ??
                                connectedUser?['user']?['profile'] ??
                                {},
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
                  leading: const Icon(Icons.exit_to_app, color: Colors.red, size: 20),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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