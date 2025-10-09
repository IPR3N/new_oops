// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importez Riverpod
// // import 'package:intl/intl.dart';
// // import 'package:new_oppsfarm/core/color.dart';
// // import 'package:new_oppsfarm/locales.dart';
// // import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
// // import 'package:new_oppsfarm/providers/locale_provider.dart';

// // class MarketPlace extends ConsumerStatefulWidget {
// //   final String nom;
// //   final String description;
// //   final String startDate;
// //   final String endDate;
// //   final int estimatedQuantityProduced;
// //   final int? basePrice;
// //   final Crop crop;
// //   final CropVariety? cropVariety;
// //   final String imageUrl;
// //   final String? owner;

// //   const MarketPlace({
// //     super.key,
// //     required this.nom,
// //     required this.description,
// //     required this.startDate,
// //     required this.endDate,
// //     required this.estimatedQuantityProduced,
// //     this.basePrice,
// //     required this.crop,
// //     this.cropVariety,
// //     required this.imageUrl,
// //     this.owner,
// //     required List memberships,
// //     required String maturytiLevel,
// //   });

// //   @override
// //   ConsumerState<MarketPlace> createState() => _MarketPlaceState();
// // }

// // class _MarketPlaceState extends ConsumerState<MarketPlace> {
// //   // Liste des acheteurs potentiels
// //   final List<Map<String, dynamic>> potentialBuyers = [
// //     {'name': 'John Doe', 'distance': 10, 'quantity': 50},
// //     {'name': 'Jane Smith', 'distance': 25, 'quantity': 20},
// //     {'name': 'Alice Johnson', 'distance': 5, 'quantity': 70},
// //   ];

// //   String _formatDate(String date) {
// //     final DateTime parsedDate = DateTime.parse(date);
// //     final DateFormat formatter = DateFormat('dd/MM/yyyy');
// //     return formatter.format(parsedDate);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //     final backgroundColor = isDarkMode ? Colors.black : white;
// //     final textColor = isDarkMode ? Colors.white : black;
// //     final cardColor = isDarkMode ? Colors.grey[900] : white;
// //     final borderColor = isDarkMode ? Colors.grey[700]! : green;
// //     final iconColor = isDarkMode ? Colors.white : black;
// //     final locale = ref.read(localeProvider).languageCode;

// //     return Scaffold(
// //       backgroundColor: backgroundColor,
// //       appBar: AppBar(
// //         backgroundColor: backgroundColor,
// //         title: Text(
// //           AppLocales.getTranslation('marketplace_view', locale),
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             color: textColor,
// //           ),
// //         ),
// //         elevation: 1,
// //         centerTitle: true,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Section informations sur la culture
// //             _buildCropInfo(context),
// //             const SizedBox(height: 20),
// //             // Liste déroulante des acheteurs potentiels
// //             _buildPotentialBuyersDropdown(context),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // Carte des informations sur la culture
// //   Widget _buildCropInfo(BuildContext context) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //     final backgroundColor = isDarkMode ? Colors.black : white;
// //     final textColor = isDarkMode ? Colors.white : black;
// //     final cardColor = isDarkMode ? Colors.grey[900] : white;
// //     final borderColor = isDarkMode ? Colors.grey[700]! : green;
// //     final iconColor = isDarkMode ? Colors.white : black;
// //     final locale = ref.read(localeProvider).languageCode;

// //     return SizedBox(
// //       width: double.infinity,
// //       child: Card(
// //         color: cardColor,
// //         elevation: 2,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 widget.nom,
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                   color: textColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(AppLocales.getTranslation('crop', locale)),
// //                   Text(widget.crop.nom),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(AppLocales.getTranslation('variety', locale)),
// //                   Text(widget.cropVariety?.nom ?? 'N/A'),
// //                 ],
// //               ),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(AppLocales.getTranslation('end_date', locale)),
// //                   Text(_formatDate(widget.endDate)),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // Liste déroulante pour les acheteurs potentiels
// //   Widget _buildPotentialBuyersDropdown(BuildContext context) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// //     final backgroundColor = isDarkMode ? Colors.black : white;
// //     final textColor = isDarkMode ? Colors.white : black;
// //     final cardColor = isDarkMode ? Colors.grey[900] : white;
// //     final borderColor = isDarkMode ? Colors.grey[700]! : green;
// //     final iconColor = isDarkMode ? Colors.white : black;
// //     final locale = ref.read(localeProvider).languageCode;

// //     return ExpansionTile(
// //       title: Text(
// //         AppLocales.getTranslation('potential_buyers', locale),
// //         style: TextStyle(
// //           fontSize: 18,
// //           fontWeight: FontWeight.bold,
// //           color: textColor,
// //         ),
// //       ),
// //       children: potentialBuyers.map((buyer) {
// //         return Card(
// //           elevation: 1,
// //           color: cardColor,
// //           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //           child: ListTile(
// //             title: Text(
// //               buyer['name'],
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: textColor,
// //               ),
// //             ),
// //             subtitle: Text(
// //               '${AppLocales.getTranslation('quantity', locale)}: ${buyer['quantity']} kg\n${AppLocales.getTranslation('distance', locale)}: ${buyer['distance']} km',
// //               style: TextStyle(color: textColor),
// //             ),
// //             trailing: Icon(Icons.message, color: green),
// //             onTap: () {
// //               // Action : mettre en relation avec l'acheteur
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 SnackBar(
// //                   content: Text('${AppLocales.getTranslation('contacting', locale)} ${buyer['name']}...'),
// //                 ),
// //               );
// //             },
// //           ),
// //         );
// //       }).toList(),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';
// import 'package:equatable/equatable.dart';

// // Modèle d'état pour les acheteurs potentiels
// class MarketPlaceState with EquatableMixin {
//   final List<Map<String, dynamic>> potentialBuyers;

//   const MarketPlaceState({
//     required this.potentialBuyers,
//   });

//   factory MarketPlaceState.initial() => const MarketPlaceState(
//         potentialBuyers: [
//           {'name': 'John Doe', 'distance': 10, 'quantity': 50},
//           {'name': 'Jane Smith', 'distance': 25, 'quantity': 20},
//           {'name': 'Alice Johnson', 'distance': 5, 'quantity': 70},
//         ],
//       );

//   MarketPlaceState copyWith({
//     List<Map<String, dynamic>>? potentialBuyers,
//   }) {
//     return MarketPlaceState(
//       potentialBuyers: potentialBuyers ?? this.potentialBuyers,
//     );
//   }

//   @override
//   List<Object?> get props => [potentialBuyers];
// }

// // Notifier pour gérer l'état
// class MarketPlaceNotifier extends StateNotifier<MarketPlaceState> {
//   MarketPlaceNotifier() : super(MarketPlaceState.initial());

//   void addPotentialBuyer(Map<String, dynamic> buyer) {
//     state = state.copyWith(
//       potentialBuyers: [...state.potentialBuyers, buyer],
//     );
//   }
// }

// // Provider
// final marketPlaceProvider =
//     StateNotifierProvider<MarketPlaceNotifier, MarketPlaceState>((ref) {
//   return MarketPlaceNotifier();
// });

// // Widget principal
// class MarketPlace extends ConsumerWidget { // Changé en ConsumerWidget
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
//   final List memberships; // Corrigé pour être facultatif
//   final String? maturityLevel; // Corrigé 'maturytiLevel' en 'maturityLevel'

//   const MarketPlace({
//     super.key,
//     required this.nom,
//     required this.description,
//     required this.startDate,
//     required this.endDate,
//     required this.estimatedQuantityProduced,
//     this.basePrice,
//     required this.crop,
//     this.cropVariety,
//     required this.imageUrl,
//     this.owner,
//     this.memberships = const [], // Valeur par défaut
//     this.maturityLevel, // Rendu facultatif
//   });

//   String _formatDate(String date) {
//     final DateTime parsedDate = DateTime.parse(date);
//     final DateFormat formatter = DateFormat('dd/MM/yyyy');
//     return formatter.format(parsedDate);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final marketPlaceState = ref.watch(marketPlaceProvider);
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     final iconColor = isDarkMode ? Colors.white : black;
//     final locale = ref.read(localeProvider).languageCode;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         title: Text(
//           AppLocales.getTranslation('marketplace_view', locale),
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//         ),
//         elevation: 1,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildCropInfo(context, locale),
//             const SizedBox(height: 20),
//             _buildPotentialBuyersDropdown(context, marketPlaceState.potentialBuyers, locale),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCropInfo(BuildContext context, String locale) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDarkMode ? Colors.white : black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;

//     return SizedBox(
//       width: double.infinity,
//       child: Card(
//         color: cardColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 nom, // Changé de widget.nom à nom
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(AppLocales.getTranslation('crop', locale)),
//                   Text(crop.nom), // Changé de widget.crop.nom
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(AppLocales.getTranslation('variety', locale)),
//                   Text(cropVariety?.nom ?? 'N/A'), // Changé de widget.cropVariety
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(AppLocales.getTranslation('end_date', locale)),
//                   Text(_formatDate(endDate)), // Changé de widget.endDate
//                 ],
//               ),
//               if (maturityLevel != null) // Ajout de maturityLevel
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(AppLocales.getTranslation('maturity_level', locale)),
//                     Text(maturityLevel!),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPotentialBuyersDropdown(
//       BuildContext context, List<Map<String, dynamic>> potentialBuyers, String locale) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDarkMode ? Colors.white : black;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;

//     return ExpansionTile(
//       title: Text(
//         AppLocales.getTranslation('potential_buyers', locale),
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//       children: potentialBuyers.map((buyer) {
//         return Card(
//           elevation: 1,
//           color: cardColor,
//           margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           child: ListTile(
//             title: Text(
//               buyer['name'],
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//             ),
//             subtitle: Text(
//               '${AppLocales.getTranslation('quantity', locale)}: ${buyer['quantity']} kg\n${AppLocales.getTranslation('distance', locale)}: ${buyer['distance']} km',
//               style: TextStyle(color: textColor),
//             ),
//             trailing: Icon(Icons.message, color: green),
//             onTap: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${AppLocales.getTranslation('contacting', locale)} ${buyer['name']}...'),
//                 ),
//               );
//             },
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/projets/services/models/marketplace_listing.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class MarketPlace extends ConsumerWidget {
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
  final List memberships;
  final String? maturityLevel;
  final List<MarketplaceListing> marketplaceListings;

  const MarketPlace({
    super.key,
    required this.nom,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.estimatedQuantityProduced,
    this.basePrice,
    required this.crop,
    this.cropVariety,
    required this.imageUrl,
    this.owner,
    this.memberships = const [],
    this.maturityLevel,
    required this.marketplaceListings,
  });

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.black
        : Colors.white; // Fond noir pur en mode sombre
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final iconColor =
        isDarkMode ? Colors.white : Colors.black87; // Corrigé pour les icônes
    final locale = ref.read(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('marketplace_view', locale),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme:
            IconThemeData(color: iconColor), // Couleur des icônes d'AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: iconColor),
            onPressed: () {
              _showFilterDialog(context, locale);
            },
            tooltip: AppLocales.getTranslation('filter', locale),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCropInfo(context, locale, textColor, cardColor),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:
                  _buildMarketplaceStats(context, locale, textColor, cardColor),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMarketplaceListings(
                  context, locale, textColor, cardColor),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: marketplaceListings.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocales.getTranslation(
                        'contact_all_buyers', locale)),
                  ),
                );
              },
              backgroundColor: green,
              child: const Icon(Icons.message),
              tooltip: AppLocales.getTranslation('contact_all', locale),
            )
          : null,
    );
  }

  Widget _buildCropInfo(
      BuildContext context, String locale, Color textColor, Color cardColor) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black, // Fond noir pur pour la section d'en-tête
        image: DecorationImage(
          image: imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/projectDefaultimg.jpg')
                  as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2), BlendMode.dstATop),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    crop.nom,
                    textAlign: TextAlign.center,
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
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    label: AppLocales.getTranslation('crop', locale),
                    value: crop.nom,
                    locale: locale,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    context,
                    label: AppLocales.getTranslation('variety', locale),
                    value: cropVariety?.nom ?? 'N/A',
                    locale: locale,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    context,
                    label: AppLocales.getTranslation('end_date', locale),
                    value: _formatDate(endDate),
                    locale: locale,
                  ),
                  if (maturityLevel != null) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      context,
                      label:
                          AppLocales.getTranslation('maturity_level', locale),
                      value: maturityLevel!,
                      locale: locale,
                      isHighlighted: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required String locale,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? Colors.yellow[100] : Colors.white,
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceStats(
      BuildContext context, String locale, Color textColor, Color cardColor) {
    final publishedQuantity =
        marketplaceListings.fold(0, (sum, listing) => sum + listing.quantity);
    final percentage = (publishedQuantity / estimatedQuantityProduced * 100)
        .toStringAsFixed(1);

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocales.getTranslation('marketplace_stats', locale),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocales.getTranslation('publications', locale)}: ${marketplaceListings.length}/5',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: marketplaceListings.length >= 5
                        ? Colors.redAccent
                        : green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    marketplaceListings.length >= 5 ? 'Complet' : 'Disponible',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocales.getTranslation('quantity_published', locale)}: $publishedQuantity/$estimatedQuantityProduced',
              style: TextStyle(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: publishedQuantity / estimatedQuantityProduced,
                    backgroundColor: Colors.grey[300],
                    color: green,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 10),
                Text('$percentage%',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceListings(
      BuildContext context, String locale, Color textColor, Color cardColor) {
    final List<Map<String, dynamic>> potentialBuyers = [
      {
        'name': 'John Doe',
        'distance': 10,
        'quantity': 50,
        'avatar': 'assets/images/avatar1.png'
      },
      {
        'name': 'Jane Smith',
        'distance': 25,
        'quantity': 20,
        'avatar': 'assets/images/avatar2.png'
      },
      {
        'name': 'Alice Johnson',
        'distance': 5,
        'quantity': 70,
        'avatar': 'assets/images/avatar3.png'
      },
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ExpansionTile(
        title: Text(
          AppLocales.getTranslation('marketplace_listings', locale),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        collapsedBackgroundColor: cardColor,
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: marketplaceListings.isNotEmpty
            ? marketplaceListings.map((listing) {
                final daysLeft = listing.listingDate
                    .add(const Duration(days: 7))
                    .difference(DateTime.now())
                    .inDays;
                return Card(
                  color: cardColor,
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${listing.quantity} unités',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: listing.status == 'Active'
                                ? green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            listing.status,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Listé le: ${DateFormat('dd/MM/yyyy').format(listing.listingDate)}',
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                        Text(
                          daysLeft > 0
                              ? 'Expire dans $daysLeft jours'
                              : 'Expiré',
                          style: TextStyle(
                            color: daysLeft > 0
                                ? textColor.withOpacity(0.7)
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocales.getTranslation(
                                  'potential_buyers', locale),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...potentialBuyers.map((buyer) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(buyer['avatar']),
                                  radius: 20,
                                ),
                                title: Text(
                                  buyer['name'],
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${AppLocales.getTranslation('quantity', locale)}: ${buyer['quantity']} kg\n${AppLocales.getTranslation('distance', locale)}: ${buyer['distance']} km',
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.message, color: green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${AppLocales.getTranslation('contacting', locale)} ${buyer['name']}...',
                                        ),
                                        action: SnackBarAction(
                                            label: 'OK', onPressed: () {}),
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {},
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
            : [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      AppLocales.getTranslation('no_listings', locale),
                      style: TextStyle(
                          color: textColor.withOpacity(0.7), fontSize: 14),
                    ),
                  ),
                ),
              ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, String locale) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: Text(
          AppLocales.getTranslation('filter_options', locale),
          style: TextStyle(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocales.getTranslation('sort_by_quantity', locale),
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                AppLocales.getTranslation('sort_by_date', locale),
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                AppLocales.getTranslation('sort_by_distance', locale),
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocales.getTranslation('cancel', locale),
              style: TextStyle(color: green),
            ),
          ),
        ],
      ),
    );
  }
}
