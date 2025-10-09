import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/capteur/fertilizer_application_screen.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/capteur/sensor_services.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart'; // Nécessaire pour getApplicationDocumentsDirectory


part 'fertilizer_preparation_page.dart';

// Données avancées pour les fertilisants chimiques
const Map<String, Map<String, double>> chemicalFertilizers = {
  'NPK 15-15-15': {
    'nitrogen': 15.0,
    'phosphorus': 15.0,
    'potassium': 15.0,
    'bioavailability': 0.9
  },
  'NPK 20-10-10': {
    'nitrogen': 20.0,
    'phosphorus': 10.0,
    'potassium': 10.0,
    'bioavailability': 0.85
  },
  'Urea': {
    'nitrogen': 46.0,
    'phosphorus': 0.0,
    'potassium': 0.0,
    'bioavailability': 0.95
  },
  'DAP': {
    'nitrogen': 18.0,
    'phosphorus': 46.0,
    'potassium': 0.0,
    'bioavailability': 0.9
  },
  'MOP': {
    'nitrogen': 0.0,
    'phosphorus': 0.0,
    'potassium': 60.0,
    'bioavailability': 0.88
  },
};

// Page d’analyse détaillée
class FertilizerAnalysisScreen extends ConsumerWidget {
  final ProjectModel project;

  const FertilizerAnalysisScreen({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soilData = ref.watch(soilDataProvider);
    final standards = cropSoilStandards[project.crop.nom.toLowerCase()] ??
        cropSoilStandards['wheat']!;
    final double area = (project.estimatedQuantityProduced ?? 0).toDouble();

    Map<String, double> deficiencies =
        _calculateAdvancedDeficiencies(soilData, standards, area);

    return Scaffold(
      appBar: AppBar(
          title: Text("Analyse avancée",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 18))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Analyse pour ${project.crop.nom}",
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: deficiencies.entries
                      .map((e) => BarChartGroupData(
                            x: deficiencies.keys.toList().indexOf(e.key),
                            barRods: [
                              BarChartRodData(
                                toY: e.value.abs(),
                                color: e.value > 0 ? Colors.red : Colors.green,
                                width: 20,
                              ),
                            ],
                          ))
                      .toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(
                                deficiencies.keys.elementAt(value.toInt()),
                                style: GoogleFonts.roboto()))),
                    leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: deficiencies.entries
                    .map((e) =>
                        _buildNutrientTile(e.key, e.value, standards[e.key]!))
                    .toList(),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                "Comment adapter votre sol ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChemicalFertilizerScreen(
                              project: project, deficiencies: deficiencies))),
                  child: Text("Engrais chimiques",
                      style: GoogleFonts.roboto(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrganicFertilizerScreen(
                              area: area, deficiencies: deficiencies))),
                  child: Text("Engrais Bio",
                      style: GoogleFonts.roboto(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateAdvancedDeficiencies(SoilData soilData,
      Map<String, Map<String, double>> standards, double areaHa) {
    double parseValue(String value, String unit) =>
        double.tryParse(value.replaceAll(unit, '').trim()) ?? 0.0;

    double phFactor = 1 -
        (parseValue(soilData.ph, '') - standards['ph']!['optimal']!).abs() *
            0.05;
    double tempFactor = 1 -
        (parseValue(soilData.temperature, '°C') -
                    standards['temperature']!['optimal']!)
                .abs() *
            0.02;

    return {
      'nitrogen': _adjustNutrient(parseValue(soilData.nitrogen, 'mg/kg'),
          standards['nitrogen']!, areaHa, phFactor, tempFactor),
      'phosphorus': _adjustNutrient(parseValue(soilData.phosphorus, 'mg/kg'),
          standards['phosphorus']!, areaHa, phFactor, tempFactor),
      'potassium': _adjustNutrient(parseValue(soilData.potassium, 'mg/kg'),
          standards['potassium']!, areaHa, phFactor, tempFactor),
    }..removeWhere((_, v) => v == 0);
  }

  double _adjustNutrient(double currentMgKg, Map<String, double> standard,
      double areaHa, double phFactor, double tempFactor) {
    double optimalMgKg = standard['optimal']!;
    double diffMgKg = optimalMgKg - currentMgKg;
    if (diffMgKg.abs() < 5) return 0;
    double diffKgHa =
        diffMgKg * 2000 / 1000000 * areaHa * phFactor * tempFactor;
    return diffKgHa;
  }

  Widget _buildNutrientTile(
      String nutrient, double deficiency, Map<String, double> standard) {
    Color color = deficiency > 0 ? Colors.red : Colors.green;
    IconData icon = deficiency > 0 ? Icons.arrow_downward : Icons.arrow_upward;
    String action = deficiency > 0 ? "Ajouter" : "Réduire";

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text("$nutrient: ${deficiency.abs().toStringAsFixed(2)} kg/ha",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        subtitle: Text("$action (Optimal: ${standard['optimal']} mg/kg)",
            style: GoogleFonts.roboto(color: color)),
      ),
    );
  }
}

// Page des engrais chimiques
class ChemicalFertilizerScreen extends StatelessWidget {
  final ProjectModel project;
  final Map<String, double> deficiencies;

  const ChemicalFertilizerScreen(
      {required this.project, required this.deficiencies});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> suggestions =
        _suggestAdvancedChemicalFertilizers(deficiencies);

    return Scaffold(
      appBar: AppBar(
          title: Text("Engrais chimiques",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Suggestions pour ${project.crop.nom}",
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: suggestions.entries
                    .map((e) => _buildFertilizerTile(context, e.key, e.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, dynamic>> _suggestAdvancedChemicalFertilizers(
      Map<String, double> deficiencies) {
    Map<String, Map<String, dynamic>> suggestions = {};
    for (var fertilizer in chemicalFertilizers.entries) {
      double quantity = 0;
      double efficiency = fertilizer.value['bioavailability']!;
      for (var nutrient in deficiencies.entries) {
        double nutrientContent = fertilizer.value[nutrient.key]! / 100;
        if (nutrientContent > 0) {
          double requiredQty =
              nutrient.value.abs() / (nutrientContent * efficiency);
          quantity = max(quantity, requiredQty);
        }
      }
      if (quantity > 0) {
        suggestions[fertilizer.key] = {
          'quantity': quantity,
          'frequency': quantity > 2 ? 0.25 : 0.5,
          'method': quantity > 2 ? 'Irrigation' : 'Épandage',
        };
      }
    }
    return suggestions;
  }

  Widget _buildFertilizerTile(
      BuildContext context, String name, Map<String, dynamic> details) {
    return Card(
      child: ListTile(
        title:
            Text(name, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Quantité: ${details['quantity'].toStringAsFixed(2)} kg/ha\nMéthode: ${details['method']}\nFréquence: toutes les ${(1 / details['frequency']).toStringAsFixed(1)} semaines"),
        trailing: Icon(Icons.info),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("$name - Détails",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            content: Text(
              "Dosage: ${details['quantity'].toStringAsFixed(2)} kg/ha\nMéthode: ${details['method']}\nPosologie: Appliquer toutes les ${(1 / details['frequency']).toStringAsFixed(1)} semaines.",
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK"))
            ],
          ),
        ),
      ),
    );
  }
}

// Page des engrais organiques
class OrganicFertilizerScreen extends StatefulWidget {
  final double area; // Remplacé project par area
  final Map<String, double> deficiencies;

  const OrganicFertilizerScreen(
      {required this.area, required this.deficiencies});

  @override
  _OrganicFertilizerScreenState createState() =>
      _OrganicFertilizerScreenState();
}

class _OrganicFertilizerScreenState extends State<OrganicFertilizerScreen> {
  String? selectedType;
  Map<String, Map<String, dynamic>> preparationProgress =
      {}; // Ajouté pour suivre les progrès

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Engrais organiques",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choisissez un type d'engrais organique",
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedType,
              hint: Text("Sélectionnez un type"),
              items: organicFertilizerTypes.keys
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => selectedType = value),
            ),
            SizedBox(height: 24),
            if (selectedType != null)
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrganicFertilizerPreparationPage(
                      deficiencies: widget.deficiencies,
                      area:
                          widget.area, // Passé depuis FertilizerAnalysisScreen
                      selectedType: selectedType!,
                      preparationProgress: preparationProgress,
                    ),
                  ),
                ),
                child: Text("Fabriquer",
                    style: GoogleFonts.roboto(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

// Page de préparation des engrais organiques
// class OrganicFertilizerPreparationPage extends StatefulWidget {
//   final Map<String, double> deficiencies;
//   final double area;
//   final String selectedType;
//   final Map<String, Map<String, dynamic>> preparationProgress;

//   const OrganicFertilizerPreparationPage({
//     super.key,
//     required this.deficiencies,
//     required this.area,
//     required this.selectedType,
//     required this.preparationProgress,
//   });

//   @override
//   _OrganicFertilizerPreparationPageState createState() => _OrganicFertilizerPreparationPageState();
// }

// class _OrganicFertilizerPreparationPageState extends State<OrganicFertilizerPreparationPage> with SingleTickerProviderStateMixin {
//   int currentStep = 0;
//   Timer? _timer;
//   Duration _remainingTime = Duration.zero;
//   bool _isStepStarted = false;
//   DateTime? _stepStartTime;
//   late AnimationController _animationController;
//   final FlutterTts _flutterTts = FlutterTts();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   late List<Map<String, dynamic>> preparationSteps;
//   Map<String, double> componentQuantities = {};

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(vsync: this);
//     preparationSteps = _generatePreparationSteps();
//     componentQuantities = _calculateComponentQuantities();
//     final prepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
//     if (widget.preparationProgress.containsKey(prepKey)) {
//       currentStep = widget.preparationProgress[prepKey]!['currentStep'];
//       _stepStartTime = DateTime.tryParse(widget.preparationProgress[prepKey]!['startTime'].toString());
//       if (_stepStartTime != null) {
//         _resumeTimer();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _animationController.dispose();
//     _audioPlayer.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }

//   List<Map<String, dynamic>> _generatePreparationSteps() {
//     final typeData = organicFertilizerTypes[widget.selectedType]!;
//     List<Map<String, dynamic>> steps = [];

//     String mixDescription = "Mélanger les composants : ";
//     componentQuantities.forEach((component, qty) {
//       mixDescription += "$component (${qty.toStringAsFixed(2)} kg/ha), ";
//     });
//     mixDescription = mixDescription.substring(0, mixDescription.length - 2);
//     steps.add({'description': mixDescription, 'duration': Duration(minutes: 10)});

//     if (typeData['form'] == 'solid') {
//       steps.add({'description': "Composter le mélange pendant ${typeData['decomposition_time']} jours", 'duration': Duration(days: typeData['decomposition_time'])});
//     } else {
//       steps.add({'description': "Diluer le mélange dans ${(widget.area * 1000).toStringAsFixed(2)} L d’eau", 'duration': Duration(minutes: 5)});
//     }

//     steps.add({'description': typeData['form'] == 'solid' ? "Appliquer le compost au sol" : "Pulvériser la solution sur les feuilles", 'duration': Duration(minutes: 15)});

//     return steps;
//   }

//   Map<String, double> _calculateComponentQuantities() {
//     Map<String, double> quantities = {};
//     final components = organicFertilizerComponents[widget.selectedType]!;
//     final allComponents = [...components['required']!, ...components['optional']!];

//     for (var component in components['required']!) {
//       quantities[component] = 0;
//     }

//     for (var nutrient in widget.deficiencies.entries) {
//       double target = nutrient.value.abs();
//       double totalProvided = 0;

//       for (var component in allComponents) {
//         double content = organicComponents[component]![nutrient.key]! / 100 * organicComponents[component]!['bioavailability']!;
//         if (content > 0) {
//           double qty = target / content;
//           quantities[component] = max(quantities[component] ?? 0, qty);
//           totalProvided += qty * content;
//         }
//       }

//       if (totalProvided > target * 1.2) {
//         double scale = target / totalProvided;
//         quantities.updateAll((key, value) => value * scale);
//       }
//     }

//     return quantities;
//   }

//   void _startPreparation() {
//     if (currentStep >= preparationSteps.length) {
//       _completePreparation();
//       return;
//     }

//     final prepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
//     final step = preparationSteps[currentStep];
//     _remainingTime = step['duration'] as Duration;

//     widget.preparationProgress[prepKey] = {
//       'currentStep': currentStep,
//       'startTime': DateTime.now().toIso8601String(),
//       'steps': preparationSteps,
//     };
//     _savePreparationProgress();

//     _speakStepInstructions(step['description']);
//     _startStepTimer();
//   }

//   void _startStepTimer() {
//     setState(() {
//       _isStepStarted = true;
//       _stepStartTime = DateTime.now();
//       _animationController.duration = preparationSteps[currentStep]['duration'] as Duration;
//       _animationController.reset();
//       _animationController.forward();
//     });

//     _timer?.cancel();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         final elapsed = DateTime.now().difference(_stepStartTime!);
//         _remainingTime = (preparationSteps[currentStep]['duration'] as Duration) - elapsed;
//         if (_remainingTime <= Duration.zero) {
//           _timer?.cancel();
//           _animationController.stop();
//           _playCompletionSound();
//           _showStepCompleteDialog();
//         }
//       });
//     });
//   }

//   void _resumeTimer() {
//     final stepDuration = preparationSteps[currentStep]['duration'] as Duration;
//     final elapsed = DateTime.now().difference(_stepStartTime!);
//     _remainingTime = stepDuration - elapsed;

//     if (_remainingTime <= Duration.zero) {
//       _showStepCompleteDialog();
//     } else {
//       setState(() {
//         _isStepStarted = true;
//         _animationController.duration = stepDuration;
//         _animationController.forward(from: elapsed.inSeconds / stepDuration.inSeconds.toDouble());
//       });
//       _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//         setState(() {
//           final elapsed = DateTime.now().difference(_stepStartTime!);
//           _remainingTime = stepDuration - elapsed;
//           if (_remainingTime <= Duration.zero) {
//             _timer?.cancel();
//             _animationController.stop();
//             _playCompletionSound();
//             _showStepCompleteDialog();
//           }
//         });
//       });
//     }
//   }

//   void _pauseTimer() {
//     _timer?.cancel();
//     _animationController.stop();
//     setState(() => _isStepStarted = false);
//     _savePreparationProgress();
//   }

//   void _resetPreparation() {
//     _timer?.cancel();
//     _animationController.reset();
//     setState(() {
//       currentStep = 0;
//       _isStepStarted = false;
//       _stepStartTime = null;
//       _remainingTime = Duration.zero;
//     });
//     final prepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
//     widget.preparationProgress.remove(prepKey);
//     _savePreparationProgress();
//   }

//   void _previousStep() {
//     if (currentStep > 0) {
//       _timer?.cancel();
//       _animationController.reset();
//       setState(() {
//         currentStep--;
//         _isStepStarted = false;
//         _stepStartTime = null;
//         _remainingTime = preparationSteps[currentStep]['duration'] as Duration;
//       });
//       _savePreparationProgress();
//     }
//   }

//   void _showStepCompleteDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text("Étape ${currentStep + 1} terminée", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
//         content: Text("Voulez-vous passer à l'étape suivante ?", style: GoogleFonts.roboto()),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 currentStep++;
//                 _isStepStarted = false;
//                 _stepStartTime = null;
//               });
//               _startPreparation();
//             },
//             child: Text("Oui", style: GoogleFonts.roboto(color: Colors.white)),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Non", style: GoogleFonts.roboto(color: Colors.white)),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   void _completePreparation() {
//     final prepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
//     widget.preparationProgress.remove(prepKey);
//     _savePreparationProgress();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Préparation de l'engrais organique terminée !")),
//     );
//     Navigator.pop(context);
//   }

//   Future<void> _savePreparationProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     final prepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
//     if (widget.preparationProgress.containsKey(prepKey)) {
//       final prep = widget.preparationProgress[prepKey]!;
//       final data = "${prep['currentStep']}|${prep['startTime']}";
//       await prefs.setString(prepKey, data);
//     } else {
//       await prefs.remove(prepKey);
//     }
//   }

//   String _formatDuration(Duration duration) {
//     if (duration.isNegative) return "00:00";
//     final days = duration.inDays;
//     final hours = duration.inHours % 24;
//     final minutes = duration.inMinutes % 60;
//     final seconds = duration.inSeconds % 60;
//     if (days > 0) return "$days jours, $hours h";
//     if (hours > 0) return "$hours:${minutes.toString().padLeft(2, '0')}";
//     return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//   }

//   Future<void> _speakStepInstructions(String instruction) async {
//     await _flutterTts.setLanguage("fr-FR");
//     await _flutterTts.setPitch(1.0);
//     await _flutterTts.speak(instruction);
//   }

//   Future<void> _playCompletionSound() async {
//     try {
//       await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
//     } catch (e) {
//       print("Erreur lors de la lecture du son : $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Préparation - ${widget.selectedType}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Superficie: ${widget.area} ha", style: GoogleFonts.roboto(fontSize: 16)),
//             SizedBox(height: 20),
//             LinearProgressIndicator(
//               value: preparationSteps.isEmpty ? 0 : currentStep / preparationSteps.length,
//               backgroundColor: Colors.grey[300],
//               color: Colors.green,
//             ),
//             SizedBox(height: 20),
//             if (currentStep < preparationSteps.length) ...[
//               Text(
//                 "Étape ${currentStep + 1}/${preparationSteps.length}: ${preparationSteps[currentStep]['description']}",
//                 style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               AnimatedBuilder(
//                 animation: _animationController,
//                 builder: (context, child) {
//                   return Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         width: 100,
//                         height: 100,
//                         child: CircularProgressIndicator(
//                           value: _isStepStarted ? 1 - (_remainingTime.inSeconds / (preparationSteps[currentStep]['duration'] as Duration).inSeconds) : 0,
//                           strokeWidth: 8,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       Text(
//                         _formatDuration(_isStepStarted ? _remainingTime : preparationSteps[currentStep]['duration']),
//                         style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: currentStep > 0 ? _previousStep : null,
//                     icon: Icon(Icons.skip_previous, color: Colors.white),
//                     label: Text("Précédente", style: GoogleFonts.roboto(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _isStepStarted ? _pauseTimer : _startPreparation,
//                     icon: Icon(_isStepStarted ? Icons.pause : Icons.play_arrow, color: Colors.white),
//                     label: Text(_isStepStarted ? "Pause" : "Démarrer", style: GoogleFonts.roboto(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _isStepStarted
//                         ? () {
//                             _timer?.cancel();
//                             _animationController.reset();
//                             setState(() {
//                               currentStep++;
//                               _isStepStarted = false;
//                               _stepStartTime = null;
//                             });
//                             _startPreparation();
//                           }
//                         : null,
//                     icon: Icon(Icons.skip_next, color: Colors.white),
//                     label: Text("Suivante", style: GoogleFonts.roboto(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                   ),
//                 ],
//               ),
//             ] else ...[
//               Text(
//                 "Préparation terminée !",
//                 style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//               ),
//             ],
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _resetPreparation,
//                   icon: Icon(Icons.refresh, color: Colors.white),
//                   label: Text("Réinitialiser", style: GoogleFonts.roboto(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(Icons.close, color: Colors.white),
//                   label: Text("Fermer", style: GoogleFonts.roboto(color: Colors.white)),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Page de tutoriel
class TutorialPage extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onComplete;

  const TutorialPage(
      {required this.project, required this.onComplete, super.key});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() =>
        setState(() => _currentPage = _pageController.page?.round() ?? 0));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildStep(
                      "Brancher le capteur",
                      "Connectez le capteur pour collecter des données précises.",
                      "assets/images/connect_sensor.jpg"),
                  _buildStep(
                      "Analyse initiale",
                      "Visualisez les données brutes du sol en temps réel.",
                      "assets/images/data_collection.jpg"),
                  _buildStep(
                      "Analyse avancée",
                      "Découvrez les écarts avec des graphiques interactifs.",
                      "assets/images/analysis_result.jpg"),
                  _buildStep(
                      "Choix des fertilisants",
                      "Optez pour des solutions chimiques ou organiques.",
                      "assets/images/fertilizer_selection.jpg"),
                  _buildStep(
                      "Fabrication organique",
                      "Créez votre propre engrais avec des composants naturels.",
                      "assets/images/fertilizer_preparation.jpg"),
                  _buildStep(
                      "Application",
                      "Suivez les étapes précises pour optimiser votre sol.",
                      "assets/images/fertilization_methods.jpg"),
                  _buildStep(
                      "Résultats",
                      "Obtenez des recommandations personnalisées pour ${widget.project.crop.nom}.",
                      "assets/images/suggestions_illustration.png"),
                ],
              ),
            ),
            SmoothPageIndicator(
                controller: _pageController,
                count: 7,
                effect: WormEffect(activeDotColor: Colors.green)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () => _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    child: Text("Précédent",
                        style: GoogleFonts.roboto(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 6) {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      widget.onComplete();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_currentPage < 6 ? "Suivant" : "Commencer",
                      style: GoogleFonts.roboto(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                widget.onComplete();
                Navigator.pop(context);
              },
              child:
                  Text("Passer", style: GoogleFonts.roboto(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, String description, String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.image_not_supported, size: 200)),
        SizedBox(height: 24),
        Text(title,
            style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(description,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
