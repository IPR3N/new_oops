import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/notification_settings/notification_service.dart';
import 'package:new_oppsfarm/notification_settings/notification_settings.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/marketPlace/marketService/marketHttpService.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/ai_alert.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/collaboration-tool.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/crop_progress.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/market_place.dart';
import 'package:new_oppsfarm/pages/projets/project_group_message/group_message.dart';
import 'package:new_oppsfarm/pages/projets/services/models/marketplace_listing.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ProjectDetails extends ConsumerStatefulWidget {
  final int id;
  final String nom;
  final String description;
  final String startDate;
  final String endDate;
  final int estimatedQuantityProduced;
  final int? basePrice;
  final Crop crop;
  final CropVariety? cropVariety;
  final String imageUrl;
  final String? owner;
  final bool? isListedOnMarketplace;
  final List<Membership> memberships;
  final List<Task> tasks;
  final List<MarketplaceListing> marketplaceListings;

  const ProjectDetails({
    super.key,
    required this.id,
    required this.nom,
    required this.description,
    required this.crop,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.estimatedQuantityProduced,
    this.basePrice,
    this.owner,
    this.isListedOnMarketplace,
    this.cropVariety,
    required this.memberships,
    required this.tasks,
    required this.marketplaceListings,
  });

  @override
  ConsumerState<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends ConsumerState<ProjectDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  late int _daysDifference;
  late String _maturationLevel;
  late double _progressPercentage;
  final AuthService _authService = AuthService();
  final MarketHttpService _marketService = MarketHttpService();
  dynamic connectedUser;
  String? _token;
  bool _isLoading = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> mediaList = [];
  List<Map<String, dynamic>> newsFeed = [];

  Future<void> _addProjectToMarket() async {
    if (widget.marketplaceListings.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('marketplace_limit_reached',
              ref.read(localeProvider).languageCode)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? quantityToList;
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        title: Text(
          AppLocales.getTranslation(
              'add_to_marketplace', ref.read(localeProvider).languageCode),
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocales.getTranslation(
                  'select_quantity', ref.read(localeProvider).languageCode),
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54),
            ),
            Text(
              AppLocales.getTranslation('remaining_quantity_with_units',
                      ref.read(localeProvider).languageCode)
                  .replaceAll('{quantity}', remainingQuantity.toString()),
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54),
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87),
              decoration: InputDecoration(
                labelText: AppLocales.getTranslation(
                    'quantity', ref.read(localeProvider).languageCode),
                hintText: 'Max $remainingQuantity',
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54),
                hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black38),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black38)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: green)),
              ),
              onChanged: (value) => quantityToList = int.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                AppLocales.getTranslation(
                    'cancel', ref.read(localeProvider).languageCode),
                style: TextStyle(color: green)),
          ),
          TextButton(
            onPressed: () {
              if (quantityToList != null &&
                  quantityToList! > 0 &&
                  quantityToList! <= remainingQuantity) {
                Navigator.pop(context, quantityToList);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocales.getTranslation('invalid_quantity',
                        ref.read(localeProvider).languageCode)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
                AppLocales.getTranslation(
                    'confirm', ref.read(localeProvider).languageCode),
                style: TextStyle(color: green)),
          ),
        ],
      ),
    );

    if (quantityToList == null) return;

    setState(() => _isLoading = true);

    try {
      await _marketService.addMarketItem(widget.id, quantity: quantityToList);
      setState(() {
        widget.marketplaceListings.add(MarketplaceListing(
          id: widget.marketplaceListings.length + 1,
          projectId: widget.id,
          quantity: quantityToList!,
          listingDate: DateTime.now(),
          status: 'Active',
        ));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('add_to_marketplace_success',
              ref.read(localeProvider).languageCode)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation(
              'add_to_marketplace_error', ref.read(localeProvider).languageCode,
              placeholders: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> connectUser() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _authService.readToken();
      if (token != null) {
        _token = token;
        connectedUser = JwtDecoder.decode(token);
      } else {
        print("Aucun token trouvé !");
      }
    } catch (e) {
      print("Erreur lors de la connexion de l'utilisateur : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateDaysDifference() =>
      DateTime.now().difference(DateTime.parse(widget.startDate)).inDays;

  double _calculateProgressPercentage() {
    if (widget.cropVariety != null) {
      final int totalDays = widget.cropVariety!.days_to_germinate +
          widget.cropVariety!.days_to_croissant +
          widget.cropVariety!.days_to_maturity;
      return (_daysDifference / totalDays).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  String _maturityLevel() {
    final DateTime today = DateTime.now();
    final DateTime startDate = DateTime.parse(widget.startDate);
    final int daysDifference = today.difference(startDate).inDays;

    if (widget.cropVariety != null) {
      final int daysToGerminate = widget.cropVariety!.days_to_germinate;
      final int daysToCroissant = widget.cropVariety!.days_to_croissant;
      final int daysToMaturity = widget.cropVariety!.days_to_maturity;

      if (daysDifference >= 0 && daysDifference <= daysToGerminate)
        return 'Germination';
      if (daysDifference > daysToGerminate && daysDifference <= daysToCroissant)
        return 'Croissance';
      if (daysDifference > daysToCroissant && daysDifference <= daysToMaturity)
        return 'Maturation';
      if (daysDifference > daysToMaturity) return 'Récolte';
      return 'Non commencé';
    }
    return 'Informations sur la variété de culture non disponibles';
  }

  Map<String, dynamic> _calculateVisibilityStatus() {
    final DateTime now = DateTime.now();
    final DateTime endDate = DateTime.parse(widget.endDate);
    final int daysToGerminate = widget.cropVariety?.days_to_germinate ?? 0;
    final int daysToCroissant = widget.cropVariety?.days_to_croissant ?? 0;
    final int daysToMaturity = widget.cropVariety?.days_to_maturity ?? 0;
    final totalDaysToMaturity =
        daysToGerminate + daysToCroissant + daysToMaturity;

    final int daysSinceMaturity = now.difference(endDate).inDays;
    final int gracePeriodDays = (totalDaysToMaturity * 0.1).ceil();

    return {
      'isVisible': daysSinceMaturity <= gracePeriodDays,
      'daysSinceMaturity': daysSinceMaturity,
      'gracePeriodDays': gracePeriodDays,
    };
  }

  int get remainingQuantity =>
      widget.estimatedQuantityProduced -
      widget.marketplaceListings
          .fold(0, (sum, listing) => sum + listing.quantity);

  MethodChannel alarmPlatform = const MethodChannel('com.example/alarm');

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      return await alarmPlatform.invokeMethod('canScheduleExactAlarms');
    } catch (e) {
      print('Erreur lors de la vérification des alarmes exactes : $e');
      return false;
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await alarmPlatform.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      print('Erreur lors de la demande de permission d\'alarme : $e');
    }
  }

  Future<void> _scheduleOrShowNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String prefsKey,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await _notificationsPlugin.cancel(id);

    final bool alreadyScheduled = prefs.getBool(prefsKey) ?? false;
    if (!alreadyScheduled) {
      if (scheduledDate.isBefore(now)) {
        await NotificationService.showNotification(
          id: id,
          title: title,
          body: body,
          imageUrl: widget.imageUrl,
          payload: payload ?? prefsKey,
        );
      } else {
        final bool canScheduleExact = await canScheduleExactAlarms();
        if (!canScheduleExact) {
          await requestExactAlarmPermission();
          final bool recheck = await canScheduleExactAlarms();
          if (!recheck) {
            await _notificationsPlugin.zonedSchedule(
              id,
              title,
              body,
              tz.TZDateTime.from(scheduledDate, tz.local),
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'crop_channel',
                  'Crop Notifications',
                  channelDescription:
                      'Notifications pour le suivi des cultures',
                  importance: Importance.max,
                  priority: Priority.high,
                  largeIcon: DrawableResourceAndroidBitmap('@drawable/icon'),
                ),
                iOS: DarwinNotificationDetails(),
              ),
              androidScheduleMode: AndroidScheduleMode.inexact,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            await prefs.setBool(prefsKey, true);
            return;
          }
        }
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'crop_channel',
              'Crop Notifications',
              channelDescription: 'Notifications pour le suivi des cultures',
              importance: Importance.max,
              priority: Priority.high,
              largeIcon: DrawableResourceAndroidBitmap('@drawable/icon'),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      await prefs.setBool(prefsKey, true);
    }
  }

  void _checkProgressAndNotify() async {
    if (widget.cropVariety == null) return;

    final int daysToMaturity = widget.cropVariety!.days_to_maturity;
    final DateTime startDate = DateTime.parse(widget.startDate);
    final DateTime endDate = DateTime.parse(widget.endDate);

    final String startKey = 'start_notification_${widget.id}';
    final String progress50Key = 'progress_50_notification_${widget.id}';
    final String progress80Key = 'progress_80_notification_${widget.id}';
    final String harvestKey = 'harvest_notification_${widget.id}';
    final String listingExpiryKey = 'listing_expiry_${widget.id}';

    final bool notifyStart = await NotificationSettings.getStartNotification();
    final bool notifyProgress50 =
        await NotificationSettings.getProgress50Notification();
    final bool notifyProgress80 =
        await NotificationSettings.getProgress80Notification();
    final bool notifyHarvest =
        await NotificationSettings.getHarvestNotification();
    final int harvestDays = await NotificationSettings.getHarvestDays();

    String _getContextualMessage({
      required String todayMessage,
      required String futureMessage,
      required String yesterdayMessage,
      required String daysAgoMessage,
      required String pastDateMessage,
      required DateTime scheduledDate,
    }) {
      final now = DateTime.now();
      final differencePast = now.difference(scheduledDate).inDays;
      final differenceFuture = scheduledDate.difference(now).inDays;
      final formatter = DateFormat('dd/MM/yyyy');

      final today = DateTime(now.year, now.month, now.day);
      final scheduled =
          DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);

      if (scheduled.isAtSameMomentAs(today)) return todayMessage;
      if (scheduled.isAfter(today)) {
        return differenceFuture == 1
            ? futureMessage.replaceFirst('{days}', 'demain')
            : futureMessage.replaceFirst(
                '{days}', 'dans $differenceFuture jours');
      }
      if (scheduled.isBefore(today)) {
        if (differencePast == 1) return yesterdayMessage;
        if (differencePast == 2)
          return daysAgoMessage.replaceFirst('{days}', '2');
        return pastDateMessage.replaceFirst(
            '{date}', formatter.format(scheduledDate));
      }
      return todayMessage;
    }

    if (notifyStart) {
      final String body = _getContextualMessage(
        todayMessage:
            "Aujourd'hui, votre projet ${widget.nom} démarre ! Bonne chance !",
        futureMessage:
            "Votre projet ${widget.nom} démarrera {days} ! Bonne chance !",
        yesterdayMessage:
            "Votre projet ${widget.nom} a démarré hier. Bonne chance !",
        daysAgoMessage:
            "Votre projet ${widget.nom} a démarré il y a {days} jours. Bonne chance !",
        pastDateMessage:
            "Votre projet ${widget.nom} a démarré depuis le {date}. Bonne chance !",
        scheduledDate: startDate,
      );
      await _scheduleOrShowNotification(
        id: widget.id * 1000 + 1,
        title: "Début du projet",
        body: body,
        scheduledDate: startDate,
        prefsKey: startKey,
        payload: 'project_start_${widget.id}',
      );
    }

    if (notifyProgress50) {
      final DateTime progress50Date =
          startDate.add(Duration(days: (daysToMaturity * 0.5).round()));
      final String body = _getContextualMessage(
        todayMessage:
            "Aujourd'hui, votre projet ${widget.nom} atteint 50% et entre en phase de maturation !",
        futureMessage:
            "Votre projet ${widget.nom} atteindra 50% {days} et entrera en phase de maturation !",
        yesterdayMessage:
            "Votre projet ${widget.nom} a atteint la phase de maturation hier.",
        daysAgoMessage:
            "Votre projet ${widget.nom} a atteint la phase de maturation il y a {days} jours.",
        pastDateMessage:
            "Votre projet ${widget.nom} a atteint la phase de maturation depuis le {date}.",
        scheduledDate: progress50Date,
      );
      await _scheduleOrShowNotification(
        id: widget.id * 1000 + 2,
        title: "Progression à 50%",
        body: body,
        scheduledDate: progress50Date,
        prefsKey: progress50Key,
        payload: 'progress_50_${widget.id}',
      );
    }

    if (notifyProgress80 && widget.marketplaceListings.isEmpty) {
      final DateTime progress80Date =
          startDate.add(Duration(days: (daysToMaturity * 0.8).round()));
      final String body = _getContextualMessage(
        todayMessage:
            "Aujourd'hui, votre projet ${widget.nom} atteint 80% ! Prêt à être publié sur la marketplace ?",
        futureMessage:
            "Votre projet ${widget.nom} atteindra 80% {days} ! Prêt à le publier sur la marketplace ?",
        yesterdayMessage:
            "Votre projet ${widget.nom} a atteint 80% hier ! Vous pouvez maintenant le publier sur la marketplace.",
        daysAgoMessage:
            "Votre projet ${widget.nom} a atteint 80% il y a {days} jours ! Pensez à le publier sur la marketplace.",
        pastDateMessage:
            "Depuis le {date}, votre projet ${widget.nom} a atteint 80%. Publiez-le sur la marketplace !",
        scheduledDate: progress80Date,
      );
      await _scheduleOrShowNotification(
        id: widget.id * 1000 + 3,
        title: "Progression à 80%",
        body: body,
        scheduledDate: progress80Date,
        prefsKey: progress80Key,
        payload: 'project_details_${widget.id}',
      );
    }

    if (notifyHarvest) {
      final DateTime notificationDate =
          endDate.subtract(Duration(days: harvestDays));
      final String body = _getContextualMessage(
        todayMessage:
            "Aujourd'hui, il reste $harvestDays jours avant la récolte de ${widget.crop.nom} dans ${widget.nom} !",
        futureMessage:
            "{days}, il faudra penser à la récolte de ${widget.crop.nom} dans ${widget.nom} !",
        yesterdayMessage:
            "Depuis hier, il reste $harvestDays jours pour la récolte de ${widget.crop.nom} dans ${widget.nom}.",
        daysAgoMessage:
            "Depuis {days} jours, il reste $harvestDays jours pour la récolte de ${widget.crop.nom} dans ${widget.nom}.",
        pastDateMessage:
            "Depuis le {date}, il restait $harvestDays jours pour la récolte de ${widget.crop.nom} dans ${widget.nom}.",
        scheduledDate: notificationDate,
      );
      await _scheduleOrShowNotification(
        id: widget.id * 1000 + 4,
        title: "Récolte imminente",
        body: body,
        scheduledDate: notificationDate,
        prefsKey: harvestKey,
        payload: 'harvest_${widget.id}',
      );
    }

    if (widget.marketplaceListings.isNotEmpty) {
      final DateTime expiryDate = widget.marketplaceListings.last.listingDate
          .add(const Duration(days: 7));
      final String body = _getContextualMessage(
        todayMessage: "Votre annonce sur ${widget.nom} expire aujourd'hui !",
        futureMessage: "Votre annonce sur ${widget.nom} expirera {days} !",
        yesterdayMessage: "Votre annonce sur ${widget.nom} a expiré hier.",
        daysAgoMessage:
            "Votre annonce sur ${widget.nom} a expiré il y a {days} jours.",
        pastDateMessage: "Votre annonce sur ${widget.nom} a expiré le {date}.",
        scheduledDate: expiryDate,
      );
      await _scheduleOrShowNotification(
        id: widget.id * 1000 + 5,
        title: "Expiration de l'annonce",
        body: body,
        scheduledDate: expiryDate,
        prefsKey: listingExpiryKey,
      );
    }

    if (widget.marketplaceListings.length == 4) {
      await NotificationService.showNotification(
        id: widget.id * 1000 + 6,
        title: "Limite presque atteinte",
        body:
            "Vous avez atteint 4/5 publications pour ${widget.nom}. Une seule publication restante !",
      );
    }
  }

  Future<void> _takeMedia() async {
    if (!mounted) return;

    try {
      print('🔵 Début _takeMedia');
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final locale = ref.read(localeProvider).languageCode;

      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          title: Text(
            AppLocales.getTranslation('add_media_action', locale),
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('📷 Camera sélectionnée');
                Navigator.pop(context, ImageSource.camera);
              },
              child: Text(AppLocales.getTranslation('open_camera', locale),
                  style: TextStyle(color: green)),
            ),
            TextButton(
              onPressed: () {
                print('🖼️ Gallery sélectionnée');
                Navigator.pop(context, ImageSource.gallery);
              },
              child: Text(AppLocales.getTranslation('open_gallery', locale),
                  style: TextStyle(color: green)),
            ),
          ],
        ),
      );

      print('✅ Source sélectionnée: $source');

      if (source == null || !mounted) {
        print('⚠️ Source null ou widget démonté');
        return;
      }

      print('📸 Tentative pickImage...');
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      print('✅ Fichier sélectionné: ${file?.path}');

      if (file == null || !mounted) {
        print('⚠️ Fichier null ou widget démonté');
        return;
      }

      print('💾 Ajout du media à la liste');
      setState(() {
        mediaList
            .add({'type': 'photo', 'path': file.path, 'date': DateTime.now()});
      });

      print('✅ Media ajouté avec succès');

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content:
              Text(AppLocales.getTranslation('media_added_success', locale)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      print('❌ ERREUR: $e');
      print('📚 StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Future<void> _takeMedia() async {
  //   final source = await showDialog<ImageSource>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Theme.of(context).brightness == Brightness.dark
  //           ? Colors.grey[900]
  //           : Colors.white,
  //       title: Text(
  //         AppLocales.getTranslation(
  //             'add_media_action', ref.read(localeProvider).languageCode),
  //         style: TextStyle(
  //             color: Theme.of(context).brightness == Brightness.dark
  //                 ? Colors.white
  //                 : Colors.black87,
  //             fontSize: 16),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, ImageSource.camera),
  //           child: Text(
  //               AppLocales.getTranslation(
  //                   'open_camera', ref.read(localeProvider).languageCode),
  //               style: TextStyle(color: green)),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, ImageSource.gallery),
  //           child: Text(
  //               AppLocales.getTranslation(
  //                   'open_gallery', ref.read(localeProvider).languageCode),
  //               style: TextStyle(color: green)),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (source != null) {
  //     final XFile? file = await _picker.pickImage(source: source);
  //     if (file != null) {
  //       setState(() {
  //         mediaList.add(
  //             {'type': 'photo', 'path': file.path, 'date': DateTime.now()});
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(AppLocales.getTranslation(
  //               'media_added_success', ref.read(localeProvider).languageCode)),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   }
  // }

  void _showMediaOptions(BuildContext context, Map<String, dynamic> media) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (context) {
        final locale = ref.read(localeProvider).languageCode;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.publish, color: green),
                title: Text(
                    AppLocales.getTranslation('publish_to_news', locale),
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  _publishToNewsFeed(media);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: green),
                title: Text(AppLocales.getTranslation('annotate', locale),
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Annotation non implémentée')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocales.getTranslation('delete', locale),
                    style: TextStyle(color: textColor)),
                onTap: () {
                  setState(() => mediaList.remove(media));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocales.getTranslation(
                            'media_deleted', locale))),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: green),
                title: Text(AppLocales.getTranslation('share', locale),
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partage non implémenté')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: green),
                title: Text(AppLocales.getTranslation('details', locale),
                    style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor:
                          isDarkMode ? Colors.grey[900] : Colors.white,
                      title: Text(
                          AppLocales.getTranslation('media_details', locale),
                          style: TextStyle(color: textColor)),
                      content: Text(
                        'Type: ${media['type']}\nDate: ${DateFormat('dd/MM/yyyy HH:mm').format(media['date'])}',
                        style: TextStyle(color: textColor.withOpacity(0.85)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK', style: TextStyle(color: green)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _publishToNewsFeed(Map<String, dynamic> media) async {
    String comment = '';
    String selectedEmoji = '';
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          AppLocales.getTranslation('publish_to_news', locale),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (media['type'] == 'photo')
                  Image.file(File(media['path']),
                      height: 150, fit: BoxFit.cover, width: double.infinity),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocales.getTranslation('add_comment', locale),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                isDarkMode ? Colors.white54 : Colors.black38)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: green)),
                  ),
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87),
                  maxLines: 3,
                  onChanged: (value) => comment = value,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ['👍', '❤️', '🌱', '😂', '👏']
                      .map((emoji) => GestureDetector(
                            onTap: () => setState(() => selectedEmoji = emoji),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedEmoji == emoji
                                    ? green.withOpacity(0.2)
                                    : null,
                              ),
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Text('Projet: ${widget.nom}',
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                Text('Culture: ${widget.crop.nom}',
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                Text('Maturité: $_maturationLevel',
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocales.getTranslation('cancel', locale),
                style: TextStyle(color: green)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                newsFeed.add({
                  'media': media,
                  'comment': comment,
                  'emoji': selectedEmoji,
                  'projectInfo': {
                    'name': widget.nom,
                    'crop': widget.crop.nom,
                    'startDate': widget.startDate,
                    'maturity': _maturationLevel,
                  },
                  'timestamp': DateTime.now(),
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocales.getTranslation('published_to_news', locale)),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(AppLocales.getTranslation('publish', locale),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _daysDifference = _calculateDaysDifference();
    _maturationLevel = _maturityLevel();
    _progressPercentage = _calculateProgressPercentage();
    connectUser();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(
        () => setState(() => _selectedIndex = _tabController.index));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationSettings.initializeDefaults();
      _checkProgressAndNotify();
    });
  }

  @override
  void didUpdateWidget(ProjectDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.estimatedQuantityProduced !=
            widget.estimatedQuantityProduced ||
        oldWidget.cropVariety?.days_to_maturity !=
            widget.cropVariety?.days_to_maturity) {
      _daysDifference = _calculateDaysDifference();
      _maturationLevel = _maturityLevel();
      _progressPercentage = _calculateProgressPercentage();
      _updateNotifications();
    }
  }

  Future<void> _updateNotifications() async {
    await _notificationsPlugin.cancel(widget.id * 1000 + 1);
    await _notificationsPlugin.cancel(widget.id * 1000 + 2);
    await _notificationsPlugin.cancel(widget.id * 1000 + 3);
    await _notificationsPlugin.cancel(widget.id * 1000 + 4);
    await _notificationsPlugin.cancel(widget.id * 1000 + 5);
    await _notificationsPlugin.cancel(widget.id * 1000 + 6);
    _checkProgressAndNotify();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String date) =>
      DateFormat('dd/MM/yyyy').format(DateTime.parse(date));

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Définition des couleurs cohérentes
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    final iconColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? Colors.black : Colors.white;
    final disabledColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.nom,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: green),
            tooltip: AppLocales.getTranslation('add_media', locale),
            onPressed: _takeMedia,
          ),
          // const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.message_rounded, color: green),
            tooltip: AppLocales.getTranslation('group_message', locale),
            onPressed: () {
              if (_token == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No token available. Please log in.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupMessage(
                    projectId: 1, // Replace with widget.id
                    userId: connectedUser[
                        'id'], // or connectedUser['sub'] if that's the key
                    token: _token!,
                  ),
                ),
              );
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.message_rounded, color: green),
          //   tooltip: AppLocales.getTranslation('add_media', locale),
          //   onPressed: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => GroupMessage()));
          //   },
          // ),
          // const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black54
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: green,
                labelColor: green,
                unselectedLabelColor: textColor.withOpacity(0.6),
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: [
                  Tab(text: AppLocales.getTranslation('dashboard', locale)),
                  Tab(text: AppLocales.getTranslation('details', locale)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              widget.crop.nom,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _cardMenu(
                              title: AppLocales.getTranslation(
                                  'crop_progress', locale),
                              icon: Icons.grass,
                              color: cardColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CropProgress(
                                    crop: widget.crop,
                                    nom: widget.nom,
                                    description: widget.description,
                                    cropVariety: widget.cropVariety,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                    estimatedQuantityProduced:
                                        widget.estimatedQuantityProduced,
                                    imageUrl: widget.imageUrl,
                                    memberships: widget.memberships,
                                  ),
                                ),
                              ),
                            ),
                            _cardMenu(
                              title: AppLocales.getTranslation(
                                  'collaboration_tools', locale),
                              icon: Icons.people_outline,
                              color: cardColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ColloborationTool(
                                    id: widget.id,
                                    nom: widget.nom,
                                    crop: widget.crop,
                                    description: widget.description,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                    estimatedQuantityProduced:
                                        widget.estimatedQuantityProduced,
                                    imageUrl: widget.imageUrl,
                                    memberships: widget.memberships,
                                    tasks: widget.tasks,
                                  ),
                                ),
                              ),
                            ),
                            _cardMenu(
                              title: AppLocales.getTranslation(
                                  'ai_alerts', locale),
                              icon: Icons.lightbulb_outline,
                              color: cardColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AiAlertScreen(
                                    crop: widget.crop,
                                    nom: widget.nom,
                                    description: widget.description,
                                    estimatedQuantityProduced:
                                        widget.estimatedQuantityProduced,
                                    imageUrl: widget.imageUrl,
                                    owner: widget.owner,
                                    basePrice: widget.basePrice,
                                  ),
                                ),
                              ),
                            ),
                            _cardMenu(
                              title: AppLocales.getTranslation(
                                  'market_place', locale),
                              icon: Icons.shopping_cart_outlined,
                              color: widget.marketplaceListings.isNotEmpty
                                  ? cardColor
                                  : disabledColor,
                              onTap: widget.marketplaceListings.isNotEmpty
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MarketPlace(
                                            crop: widget.crop,
                                            nom: widget.nom,
                                            description: widget.description,
                                            cropVariety: widget.cropVariety,
                                            startDate: widget.startDate,
                                            endDate: widget.endDate,
                                            estimatedQuantityProduced: widget
                                                .estimatedQuantityProduced,
                                            imageUrl: widget.imageUrl,
                                            memberships: widget.memberships,
                                            maturityLevel: _maturationLevel,
                                            marketplaceListings:
                                                widget.marketplaceListings,
                                          ),
                                        ),
                                      )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.grey[800]!.withOpacity(0.8),
                                      Colors.grey[900]!.withOpacity(0.4)
                                    ]
                                  : [
                                      green.withOpacity(0.8),
                                      green.withOpacity(0.4)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            image: DecorationImage(
                              image: widget.imageUrl.isNotEmpty
                                  ? NetworkImage(widget.imageUrl)
                                  : const AssetImage(
                                          'assets/images/projectDefaultimg.jpg')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.2),
                                  BlendMode.dstATop),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.crop.nom,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 14,
                                        color: iconColor.withOpacity(0.9)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.startDate),
                                      style: TextStyle(
                                          color: iconColor.withOpacity(0.9),
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.event,
                                        size: 14,
                                        color: iconColor.withOpacity(0.9)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.endDate),
                                      style: TextStyle(
                                          color: iconColor.withOpacity(0.9),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor.withOpacity(0.85),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTile(
                                AppLocales.getTranslation(
                                    'project_media', locale),
                                Icons.photo,
                                [
                                  SizedBox(
                                    height: 150,
                                    child: mediaList.isEmpty
                                        ? Center(
                                            child: Text(
                                              AppLocales.getTranslation(
                                                  'no_media', locale),
                                              style: TextStyle(
                                                  color: secondaryTextColor),
                                            ),
                                          )
                                        : ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: mediaList.length,
                                            itemBuilder: (context, index) {
                                              final media = mediaList[index];
                                              return GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreenMediaView(
                                                      media: media,
                                                      onShowOptions: () =>
                                                          _showMediaOptions(
                                                              context, media),
                                                    ),
                                                  ),
                                                ),
                                                onDoubleTap: () =>
                                                    _showMediaOptions(
                                                        context, media),
                                                onLongPress: () =>
                                                    _showMediaOptions(
                                                        context, media),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: media['type'] ==
                                                            'photo'
                                                        ? Image.file(
                                                            File(media['path']),
                                                            width: 150,
                                                            height: 150,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            width: 150,
                                                            height: 150,
                                                            color:
                                                                disabledColor,
                                                            child: Center(
                                                              child: Text(
                                                                'Video Placeholder',
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTile(
                                AppLocales.getTranslation(
                                    'team_members', locale),
                                Icons.group,
                                widget.memberships.isNotEmpty
                                    ? widget.memberships
                                        .map(
                                          (member) => ListTile(
                                            leading: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                image: const DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/profil.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            title: Text(
                                              member.user?.nom ?? 'Nom inconnu',
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              member.role ?? 'Rôle inconnu',
                                              style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 12),
                                            ),
                                            trailing: PopupMenuButton<String>(
                                              onSelected: (value) {},
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'View Profile',
                                                  child: Text(
                                                    AppLocales.getTranslation(
                                                        'details', locale),
                                                    style: TextStyle(
                                                        color: textColor),
                                                  ),
                                                ),
                                              ],
                                              color: cardColor,
                                            ),
                                          ),
                                        )
                                        .toList()
                                    : [
                                        ListTile(
                                          title: Center(
                                            child: Text(
                                              AppLocales.getTranslation(
                                                  'no_members', locale),
                                              style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTile(
                                AppLocales.getTranslation(
                                    'marketplace_listings', locale),
                                Icons.shopping_cart,
                                widget.marketplaceListings.isNotEmpty
                                    ? widget.marketplaceListings
                                        .map(
                                          (listing) => ListTile(
                                            title: Text(
                                              '${listing.quantity} unités - ${DateFormat('dd/MM/yyyy').format(listing.listingDate)}',
                                              style:
                                                  TextStyle(color: textColor),
                                            ),
                                            subtitle: Text(
                                              'Statut: ${listing.status}',
                                              style: TextStyle(
                                                  color: secondaryTextColor),
                                            ),
                                            trailing: PopupMenuButton<String>(
                                              onSelected: (value) async {
                                                if (value == 'Edit') {
                                                  // TODO: Logique pour modifier
                                                } else if (value == 'Delete') {
                                                  setState(() => widget
                                                      .marketplaceListings
                                                      .remove(listing));
                                                  try {
                                                    await _marketService
                                                        .deleteMarketItem(
                                                            listing.id);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(AppLocales
                                                            .getTranslation(
                                                                'remove_from_marketplace_error',
                                                                ref
                                                                    .read(
                                                                        localeProvider)
                                                                    .languageCode)),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                    setState(() => widget
                                                        .marketplaceListings
                                                        .add(listing));
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'Edit',
                                                  child: Text(
                                                    AppLocales.getTranslation(
                                                        'edit', locale),
                                                    style: TextStyle(
                                                        color: textColor),
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'Delete',
                                                  child: Text(
                                                    AppLocales.getTranslation(
                                                        'delete', locale),
                                                    style: TextStyle(
                                                        color: textColor),
                                                  ),
                                                ),
                                              ],
                                              color: cardColor,
                                            ),
                                          ),
                                        )
                                        .toList()
                                    : [
                                        ListTile(
                                          title: Center(
                                            child: Text(
                                              AppLocales.getTranslation(
                                                  'no_listings', locale),
                                              style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                              ),
                              if (newsFeed.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildSectionTile(
                                  AppLocales.getTranslation(
                                      'news_feed', locale),
                                  Icons.feed,
                                  newsFeed
                                      .map(
                                        (post) => Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          color: cardColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (post['media']['type'] ==
                                                    'photo')
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.file(
                                                      File(post['media']
                                                          ['path']),
                                                      fit: BoxFit.cover,
                                                      height: 150,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  post['comment'].isNotEmpty
                                                      ? post['comment']
                                                      : AppLocales
                                                          .getTranslation(
                                                              'no_comment',
                                                              locale),
                                                  style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 14),
                                                ),
                                                if (post['emoji'].isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Text(post['emoji'],
                                                        style: const TextStyle(
                                                            fontSize: 20)),
                                                  ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Projet: ${post['projectInfo']['name']}\nCulture: ${post['projectInfo']['crop']}\nMaturité: ${post['projectInfo']['maturity']}',
                                                  style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  DateFormat('dd/MM/yyyy HH:mm')
                                                      .format(
                                                          post['timestamp']),
                                                  style: TextStyle(
                                                      color: textColor
                                                          .withOpacity(0.4),
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 1 &&
              widget.marketplaceListings.length < 5 &&
              remainingQuantity > 0
          ? FloatingActionButton.extended(
              onPressed: (_maturationLevel == 'Maturation' ||
                      _maturationLevel == 'Récolte')
                  ? _addProjectToMarket
                  : null,
              label: Text(
                (_maturationLevel == 'Maturation' ||
                        _maturationLevel == 'Récolte')
                    ? AppLocales.getTranslation('add_to_marketplace', locale)
                    : AppLocales.getTranslation('project_not_mature', locale),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              backgroundColor: (_maturationLevel == 'Maturation' ||
                      _maturationLevel == 'Récolte')
                  ? green
                  : green,
              elevation: 2,
            )
          : null,
    );
  }

  Widget _cardMenu({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: green.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: green),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile(String title, IconData icon, List<Widget> children) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      ),
      leading: Icon(icon, color: green),
      collapsedBackgroundColor: backgroundColor,
      backgroundColor: backgroundColor,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: children,
    );
  }
}

class FullScreenMediaView extends StatelessWidget {
  final Map<String, dynamic> media;
  final VoidCallback onShowOptions;

  const FullScreenMediaView(
      {super.key, required this.media, required this.onShowOptions});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        title: Text(
          'Vue détaillée',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: GestureDetector(
          onLongPress: onShowOptions,
          onDoubleTap: onShowOptions,
          child: media['type'] == 'photo'
              ? InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(File(media['path']), fit: BoxFit.contain),
                )
              : Text(
                  'Video Player Placeholder',
                  style: TextStyle(color: textColor),
                ),
        ),
      ),
    );
  }
}
