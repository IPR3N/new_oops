// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/projets/agriculture/capteur/fertilizer_application_screen.dart';
// import 'package:new_oppsfarm/pages/projets/agriculture/crop_association_screen.dart';
// import 'package:new_oppsfarm/pages/projets/agriculture/capteur/fertilizer_screen.dart';
// import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
// import 'package:new_oppsfarm/pages/projets/diseases_prevention/disease_prediction_screen.dart';
// import 'package:new_oppsfarm/pages/projets/pest_prediction/pest_prediction_screen.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';

// class AiAlertScreen extends ConsumerStatefulWidget {
//   final String nom;
//   final String description;
//   final int estimatedQuantityProduced;
//   final int? basePrice;
//   final Crop crop;
//   final CropVariety? cropVariety;
//   final String imageUrl;
//   final String? owner;

//   const AiAlertScreen({
//     super.key,
//     required this.nom,
//     required this.description,
//     required this.estimatedQuantityProduced,
//     this.basePrice,
//     required this.crop,
//     this.cropVariety,
//     required this.imageUrl,
//     this.owner,
//   });

//   @override
//   _AiAlertState createState() => _AiAlertState();
// }

// class _AiAlertState extends ConsumerState<AiAlertScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : green;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     final iconColor = isDarkMode ? Colors.white : black;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           AppLocales.getTranslation('projects', locale),
//           style: TextStyle(color: textColor),
//         ),
//         backgroundColor: backgroundColor,
//         iconTheme: IconThemeData(color: iconColor),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               "${AppLocales.getTranslation('crop_label', locale)}${widget.crop.nom}",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               AppLocales.getTranslation('what_to_do', locale),
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 20),
//             GridView.count(
//               shrinkWrap: true,
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               physics: const NeverScrollableScrollPhysics(),
//               children: [
//                 _cardMenu(
//                   context: context,
//                   title: AppLocales.getTranslation('diseases', locale),
//                   icon: Icons.health_and_safety,
//                   color: backgroundColor,
//                   textColor: textColor,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DiseasePredictionScreen(
//                           project: ProjectModel(
//             id: 0, // ID par défaut, ajustez si vous avez une source
//             nom: widget.nom,
//             description: widget.description,
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 30)),
//             isListedOnMarketplace: false,
//             imageUrl: widget.imageUrl,
//             estimatedQuantityProduced: widget.estimatedQuantityProduced,
//             basePrice: widget.basePrice ?? 0,
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//             owner: widget.owner != null
//                 ? Owner(
//                     id: 0, // Valeur par défaut pour id
//                     nom: widget.owner!, // Nom fourni par widget.owner
//                     prenom: "", // Valeur par défaut pour prenom
//                     email: "unknown@example.com", // Valeur par défaut pour email
//                     password: "default", // Valeur par défaut pour password
//                   )
//                 : null,
//             crop: widget.crop,
//             cropVariety: widget.cropVariety,
//             memberships: [],
//             tasks: [],
//           ),
//         ),
//       ),
//     );
//   },
// ),

//                 _cardMenu(
//   context: context,
//   title: AppLocales.getTranslation('pests', locale),
//   icon: Icons.pest_control,
//   color: backgroundColor,
//   textColor: textColor,
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PestPredictionScreen(
//           product: ProjectModel(
//             id: 0, // ID par défaut, ajustez si vous avez une source
//             nom: widget.nom,
//             description: widget.description,
//             startDate: DateTime.now(),
//             endDate: DateTime.now().add(const Duration(days: 30)),
//             isListedOnMarketplace: false,
//             imageUrl: widget.imageUrl,
//             estimatedQuantityProduced: widget.estimatedQuantityProduced,
//             basePrice: widget.basePrice ?? 0,
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//             owner: widget.owner != null
//                 ? Owner(
//                     id: 0, // Valeur par défaut pour id
//                     nom: widget.owner!, // Nom fourni par widget.owner
//                     prenom: "", // Valeur par défaut pour prenom
//                     email: "unknown@example.com", // Valeur par défaut pour email
//                     password: "default", // Valeur par défaut pour password
//                   )
//                 : null,
//             crop: widget.crop,
//             cropVariety: widget.cropVariety,
//             memberships: [],
//             tasks: [],
//           ),
//         ),
//       ),
//     );
//   },
// ),
//                 _cardMenu(
//                   context: context,
//                   title: AppLocales.getTranslation('fertilizers', locale),
//                   icon: Icons.eco,
//                   color: backgroundColor,
//                   textColor: textColor,
//                   onTap: () {
//                     Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => FertilizerApplicationScreen(project: widget.project), // Remplacez "crop" par "project"
//   ),
// );
//                   },
//                 ),
//                 _cardMenu(
//                   context: context,
//                   title: AppLocales.getTranslation('friends_enemies', locale),
//                   icon: Icons.agriculture,
//                   color: backgroundColor,
//                   textColor: textColor,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CropAssociationScreen(crop: widget.crop),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _cardMenu({
//     required BuildContext context,
//     required String title,
//     required IconData icon,
//     required VoidCallback? onTap,
//     required Color color,
//     required Color textColor,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2.4,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: Colors.green.withOpacity(0.3),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 100),
//                 child: Icon(
//                   icon,
//                   size: 45,
//                   color: Colors.green,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                   fontSize: 14,
//                   letterSpacing: 1.1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/capteur/fertilizer_application_screen.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/crop_association_screen.dart';
import 'package:new_oppsfarm/pages/projets/diseases_prevention/disease_prediction_screen.dart';
import 'package:new_oppsfarm/pages/projets/pest_prediction/pest_prediction_screen.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class AiAlertScreen extends ConsumerStatefulWidget {
  final String nom;
  final String description;
  final int estimatedQuantityProduced;
  final int? basePrice;
  final Crop crop;
  final CropVariety? cropVariety;
  final String imageUrl;
  final String? owner;

  const AiAlertScreen({
    super.key,
    required this.nom,
    required this.description,
    required this.estimatedQuantityProduced,
    this.basePrice,
    required this.crop,
    this.cropVariety,
    required this.imageUrl,
    this.owner,
  });

  @override
  _AiAlertState createState() => _AiAlertState();
}

class _AiAlertState extends ConsumerState<AiAlertScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final iconColor = isDarkMode ? Colors.white : black;

    // Création d'une instance de ProjectModel à partir des données de widget
    final project = ProjectModel(
      id: 0, // ID par défaut
      nom: widget.nom,
      description: widget.description,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      isListedOnMarketplace: false,
      imageUrl: widget.imageUrl,
      estimatedQuantityProduced: widget.estimatedQuantityProduced,
      basePrice: widget.basePrice ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      owner: widget.owner != null
          ? Owner(
              id: 0,
              nom: widget.owner!,
              prenom: "",
              email: "unknown@example.com",
              password: "default",
            )
          : null,
      crop: widget.crop,
      cropVariety: widget.cropVariety,
      memberships: [],
      tasks: [],
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('projects', locale),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${AppLocales.getTranslation('crop_label', locale)}${widget.crop.nom}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocales.getTranslation('what_to_do', locale),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.2,
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
                  context: context,
                  title: AppLocales.getTranslation('diseases', locale),
                  icon: Icons.health_and_safety,
                  color: backgroundColor,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseasePredictionScreen(project: project),
                      ),
                    );
                  },
                ),
                _cardMenu(
                  context: context,
                  title: AppLocales.getTranslation('pests', locale),
                  icon: Icons.pest_control,
                  color: backgroundColor,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PestPredictionScreen(product: project), // "product" au lieu de "project" ici, vérifier si c'est une erreur
                      ),
                    );
                  },
                ),
                _cardMenu(
                  context: context,
                  title: AppLocales.getTranslation('fertilizers', locale),
                  icon: Icons.eco,
                  color: backgroundColor,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FertilizerApplicationScreen(project: project), // Utilisation de l'instance project construite
                      ),
                    );
                  },
                ),
                _cardMenu(
                  context: context,
                  title: AppLocales.getTranslation('friends_enemies', locale),
                  icon: Icons.agriculture,
                  color: backgroundColor,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropAssociationScreen(crop: widget.crop),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardMenu({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2.4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  icon,
                  size: 45,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}