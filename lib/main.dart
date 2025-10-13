import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_oppsfarm/notification_scheduler.dart';
import 'package:new_oppsfarm/notification_settings/notification_service.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';
import 'package:new_oppsfarm/pages/auth/sign_up.dart';
import 'package:new_oppsfarm/pages/screen/splash.dart';
import 'package:new_oppsfarm/pages/view/home.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class ProjectDetails extends StatelessWidget {
  final String? projectId;

  const ProjectDetails({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Projet $projectId')),
      body: Center(child: Text('Détails du projet $projectId')),
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getInt('themeMode') ?? 0;
    state = ThemeMode.values[savedTheme.clamp(0, ThemeMode.values.length - 1)];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}

// Session Check Function
Future<void> checkSession(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('user_token');

  if (token != null) {
    Navigator.pushReplacementNamed(context, '/Home');
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

// Native Method Channel for Timezone
const platform = MethodChannel('com.example/timezone');

Future<String> getLocalTimezone() async {
  try {
    final String timezone = await platform.invokeMethod('getLocalTimezone');
    return timezone;
  } catch (e) {
    print('Erreur lors de la récupération du fuseau horaire natif : $e');
    return 'UTC';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr', null);
  await initializeDateFormatting('en', null);

  tz.initializeTimeZones();
  try {
    final String localTimezone = await getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));
    print('Fuseau horaire local détecté et défini : $localTimezone');
  } catch (e) {
    print('Erreur lors de la définition du fuseau horaire local : $e');
    tz.setLocalLocation(tz.getLocation('UTC'));
    print('Fuseau horaire défini sur UTC par défaut');
  }

  bool notificationInitialized = false;
  try {
    await NotificationService.initialize();
    notificationInitialized = true;
    print('Notifications initialisées avec succès');

    await NotificationScheduler.scheduleAllProjectNotifications();
    print('Toutes les notifications des projets ont été programmées');
  } catch (e) {
    print('Échec de l’initialisation des notifications ou programmation : $e');
  }

  runApp(ProviderScope(
    overrides: [
      Provider((ref) => notificationInitialized),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey, 
      title: 'Flutter Demo',
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignUpPage(),
        '/Home': (context) => const Home(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/ProjectDetails') ?? false) {
          final uri = Uri.parse(settings.name!);
          final projectId = uri.queryParameters['id'];
          return MaterialPageRoute(
            builder: (context) => ProjectDetails(projectId: projectId),
          );
        }
        return null;
      },
    );
  }
}
