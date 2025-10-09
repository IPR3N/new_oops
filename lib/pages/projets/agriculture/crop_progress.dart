// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importez Riverpod
// import 'package:intl/intl.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';

// class CropProgress extends ConsumerStatefulWidget {
//   final String nom;
//   final String description;
//   final String startDate;
//   final String endDate;
//   final int estimatedQuantityProduced;
//   final int? basePrice;
//   final Crop crop;
//   final CropVariety? cropVariety;
//   final String imageUrl;
//   final String? owner;
//   final bool? isListedOnMarketplace;
//   final List<dynamic> memberships;

//   const CropProgress({
//     super.key,
//     required this.crop,
//     required this.description,
//     this.cropVariety,
//     required this.startDate,
//     required this.endDate,
//     required this.estimatedQuantityProduced,
//     this.basePrice,
//     required this.imageUrl,
//     this.owner,
//     this.isListedOnMarketplace,
//     required this.memberships,
//     required this.nom,
//   });

//   @override
//   ConsumerState<CropProgress> createState() => _CropProgressState();
// }

// class _CropProgressState extends ConsumerState<CropProgress> {
//   late String _maturationLevel;
//   late int _daysDifference;
//   late double _progressPercentage;

//   @override
//   void initState() {
//     super.initState();
//     _maturationLevel = _maturityLevel();
//     _daysDifference = _calculateDaysDifference();
//     _progressPercentage = _calculateProgressPercentage();
//   }

//   int _calculateDaysDifference() {
//     final DateTime today = DateTime.now();
//     final DateTime startDate = DateTime.parse(widget.startDate);
//     return today.difference(startDate).inDays;
//   }

//   double _calculateProgressPercentage() {
//     if (widget.cropVariety != null) {
//       final int totalDays = widget.cropVariety!.days_to_germinate +
//           widget.cropVariety!.days_to_croissant +
//           widget.cropVariety!.days_to_maturity;
//       return (_daysDifference / totalDays).clamp(0.0, 1.0);
//     } else {
//       return 0.0;
//     }
//   }

//   String _formatDate(DateTime date) {
//     final DateFormat formatter = DateFormat('dd/MM/yyyy');
//     return formatter.format(date);
//   }

//   String _maturityLevel() {
//     final DateTime today = DateTime.now();
//     final DateTime startDate = DateTime.parse(widget.startDate);
//     final int daysDifference = today.difference(startDate).inDays;

//     if (widget.cropVariety != null) {
//       final int daysToGerminate = widget.cropVariety!.days_to_germinate;
//       final int daysToCroissant = widget.cropVariety!.days_to_croissant;
//       final int daysToMaturity = widget.cropVariety!.days_to_maturity;

//       if (daysDifference >= 0 && daysDifference <= daysToGerminate) {
//         return AppLocales.getTranslation('germination', ref.read(localeProvider).languageCode);
//       } else if (daysDifference > daysToGerminate && daysDifference <= daysToCroissant) {
//         return AppLocales.getTranslation('growth', ref.read(localeProvider).languageCode);
//       } else if (daysDifference > daysToCroissant && daysDifference <= daysToMaturity) {
//         return AppLocales.getTranslation('maturation', ref.read(localeProvider).languageCode);
//       } else if (daysDifference > daysToMaturity) {
//         return AppLocales.getTranslation('harvest', ref.read(localeProvider).languageCode);
//       } else {
//         return AppLocales.getTranslation('not_started', ref.read(localeProvider).languageCode);
//       }
//     } else {
//       return AppLocales.getTranslation('crop_variety_unavailable', ref.read(localeProvider).languageCode);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : green;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     final iconColor = isDarkMode ? Colors.white : black;
//     final locale = ref.read(localeProvider).languageCode;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         title: Text(
//           AppLocales.getTranslation('crop_progress', locale),
//           style: TextStyle(color: textColor),
//         ),
//         iconTheme: IconThemeData(color: iconColor),
//       ),
//       body: SizedBox(
//         width: double.infinity,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 CircularPercentIndicator(
//                   radius: 75.0,
//                   lineWidth: 5.0,
//                   percent: _progressPercentage,
//                   center: Text(
//                     '${(_progressPercentage * 100).toStringAsFixed(1)}%',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   progressColor: green,
//                   backgroundColor: lightGreen,
//                   circularStrokeCap: CircularStrokeCap.round,
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   widget.nom,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           AppLocales.getTranslation('days_count', locale),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         Text(
//                           _daysDifference.toString(),
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           AppLocales.getTranslation('maturity_level', locale),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         Text(
//                           _maturationLevel,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           AppLocales.getTranslation('end_date', locale),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           _formatDate(DateTime.parse(widget.endDate)),
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/notification_settings/notification_service.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CropProgress extends ConsumerStatefulWidget {
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
  final List<dynamic> memberships;

  const CropProgress({
    super.key,
    required this.crop,
    required this.description,
    this.cropVariety,
    required this.startDate,
    required this.endDate,
    required this.estimatedQuantityProduced,
    this.basePrice,
    required this.imageUrl,
    this.owner,
    this.isListedOnMarketplace,
    required this.memberships,
    required this.nom,
  });

  @override
  ConsumerState<CropProgress> createState() => _CropProgressState();
}

class _CropProgressState extends ConsumerState<CropProgress> {
  late String _maturationLevel;
  late int _daysDifference;
  late double _progressPercentage;
  String? _previousMaturationLevel;

  @override
  void initState() {
    super.initState();
    _maturationLevel = _maturityLevel();
    _daysDifference = _calculateDaysDifference();
    _progressPercentage = _calculateProgressPercentage();
    _checkMaturationChange();
  }

  @override
  void didUpdateWidget(CropProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMaturationLevel = _maturityLevel();
    if (newMaturationLevel != _maturationLevel) {
      _maturationLevel = newMaturationLevel;
      _daysDifference = _calculateDaysDifference();
      _progressPercentage = _calculateProgressPercentage();
      _checkMaturationChange();
    }
  }

  int _calculateDaysDifference() {
    final DateTime today = DateTime.now();
    final DateTime startDate = DateTime.parse(widget.startDate);
    return today.difference(startDate).inDays;
  }

  double _calculateProgressPercentage() {
    if (widget.cropVariety != null) {
      final int totalDays = widget.cropVariety!.days_to_germinate +
          widget.cropVariety!.days_to_croissant +
          widget.cropVariety!.days_to_maturity;
      return (_daysDifference / totalDays).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  String _maturityLevel() {
    final DateTime today = DateTime.now();
    final DateTime startDate = DateTime.parse(widget.startDate);
    final int daysDifference = today.difference(startDate).inDays;

    if (widget.cropVariety != null) {
      final int daysToGerminate = widget.cropVariety!.days_to_germinate;
      final int daysToCroissant = widget.cropVariety!.days_to_croissant;
      final int daysToMaturity = widget.cropVariety!.days_to_maturity;

      if (daysDifference >= 0 && daysDifference <= daysToGerminate) {
        return AppLocales.getTranslation(
            'germination', ref.read(localeProvider).languageCode);
      } else if (daysDifference > daysToGerminate &&
          daysDifference <= daysToCroissant) {
        return AppLocales.getTranslation(
            'growth', ref.read(localeProvider).languageCode);
      } else if (daysDifference > daysToCroissant &&
          daysDifference <= daysToMaturity) {
        return AppLocales.getTranslation(
            'maturation', ref.read(localeProvider).languageCode);
      } else if (daysDifference > daysToMaturity) {
        return AppLocales.getTranslation(
            'harvest', ref.read(localeProvider).languageCode);
      }
    }
    return AppLocales.getTranslation(
        'not_started', ref.read(localeProvider).languageCode);
  }

  void _checkMaturationChange() {
    if (_previousMaturationLevel != null &&
        _previousMaturationLevel != _maturationLevel) {
      _sendNotification();
    }
    _previousMaturationLevel = _maturationLevel;
  }

  void _sendNotification() {
    final advice = _getMaturationAdvice();
    final title = "Monsieur ${widget.owner ?? 'Utilisateur'}";
    final body =
        "Votre culture de ${widget.crop.nom} du projet ${widget.nom} est en phase de $_maturationLevel.\nConseil : $advice";
    NotificationService.showNotification(
      id: widget.nom.hashCode,
      title: title,
      body: body,
      imageUrl: widget.imageUrl,
      payload: 'crop_progress',
    );
  }

  String _getMaturationAdvice() {
    final cropName = widget.crop.nom.toLowerCase();
    switch (_maturationLevel) {
      case 'Germination':
        if (cropName == 'wheat') {
          return 'Maintenez un sol humide et surveillez les températures entre 15-20°C.';
        } else if (cropName == 'corn') {
          return 'Assurez un arrosage régulier et un sol bien drainé.';
        }
        return 'Arrosez modérément et vérifiez l’exposition au soleil.';
      case 'Croissance':
        if (cropName == 'wheat') {
          return 'Ajoutez un engrais riche en azote et éliminez les mauvaises herbes.';
        } else if (cropName == 'corn') {
          return 'Surveillez les besoins en eau et protégez des insectes.';
        }
        return 'Vérifiez les nutriments et protégez des nuisibles.';
      case 'Maturation':
        if (cropName == 'wheat') {
          return 'Réduisez l’arrosage et préparez la récolte.';
        } else if (cropName == 'corn') {
          return 'Vérifiez la couleur des épis et préparez les outils.';
        }
        return 'Préparez-vous à récolter et surveillez la météo.';
      case 'Récolte':
        if (cropName == 'wheat') {
          return 'Récoltez dès que les grains sont secs et dorés.';
        } else if (cropName == 'corn') {
          return 'Récoltez les épis mûrs avant les pluies.';
        }
        return 'Récoltez rapidement pour éviter les pertes.';
      default:
        return 'Aucune action spécifique pour le moment.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final locale = ref.read(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('crop_progress', locale),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircularPercentIndicator(
                  radius: 90.0,
                  lineWidth: 10.0,
                  percent: _progressPercentage,
                  center: Text(
                    '${(_progressPercentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  progressColor: green,
                  backgroundColor: lightGreen.withOpacity(0.3),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                widget.nom,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        AppLocales.getTranslation('days_count', locale),
                        _daysDifference.toString(),
                        textColor,
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        AppLocales.getTranslation('maturity_level', locale),
                        _maturationLevel,
                        textColor,
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        AppLocales.getTranslation('end_date', locale),
                        _formatDate(DateTime.parse(widget.endDate)),
                        textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: textColor.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
