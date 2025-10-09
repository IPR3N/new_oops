import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/maessages/chat_page.dart';
import 'package:new_oppsfarm/maessages/services/model.dart';
import 'package:new_oppsfarm/notification_page/notification_page.dart';
import 'package:new_oppsfarm/notification_page/services/notification_manger.dart';
import 'package:new_oppsfarm/notification_page/services/notification_sse_model.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/marketPlace/market_home.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/market_place.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/tasks/chatPage.dart';
import 'package:new_oppsfarm/pages/view/actuality.dart';
import 'package:new_oppsfarm/pages/projets/projet.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

import 'dart:async';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  StreamSubscription<NotificationModel>? _notificationSubscription;

  final ScrollController _scrollController = ScrollController();
  final bool _isVisible = true;
  dynamic connectedUser;
  late int _userId;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> connectUser() async {
    setState(() {});

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
        _userId = connectedUser['id'];
        print("Utilisateur connecté : $connectedUser");
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

  final List<Widget> _pages = [
    const Actuality(),
    const Projet(),
    const NotificationPage(),
    const ECommerceHomePage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    connectUser();
  }

  Future<void> _initializeNotifications() async {
    _notificationSubscription = await NotificationManager.initialize(ref);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final bottomNavBarColor =
        isDarkMode ? Colors.grey[850] : Colors.black.withOpacity(0.9);
    final locale = ref.watch(localeProvider).languageCode;
    final unreadCount = ref.watch(unreadNotificationsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              NotificationManager.resetUnreadCount(ref);
            }
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(25),
          ),
          color: bottomNavBarColor,
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 9),
          backgroundColor: Colors.transparent,
          selectedItemColor: green,
          unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 2) {
                NotificationManager.resetUnreadCount(ref);
              }
            });
            _pageController.jumpToPage(index);
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppLocales.getTranslation('actuality', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business_center),
              label: AppLocales.getTranslation('project', locale),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: AppLocales.getTranslation('notifications', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: AppLocales.getTranslation('shop', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.forum),
              label: AppLocales.getTranslation('messages', locale),
            ),
          ],
        ),
      ),
    );
  }
}
