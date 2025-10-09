import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as ref;
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';

import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';

// Pages séparées
part 'chemical_solution_page.dart';
part 'natural_solutions_page.dart';
part 'recipe_preparation_page.dart';
part 'tutorial_page.dart';
part 'prediction_result_page.dart';
part 'eradication_methods_page.dart';
part 'disease_details_screen.dart';

final Map<String, Map<String, dynamic>> recipes = {
  'Infusion d’Ail': {
    'components': [
      {
        'name': 'Gousses d’ail',
        'baseAmount': 50.0,
        'unit': 'g',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
      {
        'name': 'Savon liquide',
        'baseAmount': 5.0,
        'unit': 'mL',
        'perLitre': true
      },
    ],
    'dosagePerM2': 200.0,
    'recipe':
        'Écrasez l’ail, mélangez avec l’eau et laissez reposer 24h. Filtrez et ajoutez le savon.',
    'application': 'Pulvérisez 200 mL par m² tous les 3 jours.',
    'steps': [
      {'description': 'Écraser l’ail', 'duration': Duration(minutes: 10)},
      {'description': 'Laisser reposer', 'duration': Duration(hours: 24)},
      {
        'description': 'Filtrer et ajouter savon',
        'duration': Duration(minutes: 5)
      },
    ],
    'precaution': 'Portez des gants, évitez le contact avec les yeux.',
  },
  'Huile de Neem': {
    'components': [
      {
        'name': 'Huile de neem',
        'baseAmount': 10.0,
        'unit': 'mL',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
      {
        'name': 'Savon liquide',
        'baseAmount': 2.0,
        'unit': 'mL',
        'perLitre': true
      },
    ],
    'dosagePerM2': 150.0,
    'recipe':
        'Mélangez l’huile de neem et le savon dans l’eau tiède. Agitez bien.',
    'application': 'Pulvérisez 150 mL par m², 2 fois par semaine.',
    'steps': [
      {
        'description': 'Mélanger huile et savon',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Ajouter eau tiède', 'duration': Duration(minutes: 5)},
    ],
    'precaution':
        'Conservez à l’abri de la lumière, évitez les cultures en récolte.',
  },
  'Bicarbonate de Soude': {
    'components': [
      {
        'name': 'Bicarbonate de soude',
        'baseAmount': 5.0,
        'unit': 'g',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
      {
        'name': 'Savon liquide',
        'baseAmount': 2.0,
        'unit': 'mL',
        'perLitre': true
      },
    ],
    'dosagePerM2': 100.0,
    'recipe':
        'Dissoudre le bicarbonate dans l’eau, ajouter le savon et mélanger.',
    'application': 'Pulvérisez 100 mL par m² tous les 5 jours.',
    'steps': [
      {
        'description': 'Dissoudre le bicarbonate',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Ajouter savon', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Ne pas dépasser la dose pour éviter les brûlures foliaires.',
  },
  'Infusion de Prêle': {
    'components': [
      {
        'name': 'Prêle séchée',
        'baseAmount': 100.0,
        'unit': 'g',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
    ],
    'dosagePerM2': 200.0,
    'recipe':
        'Faites bouillir la prêle dans l’eau pendant 20 min. Laissez refroidir et filtrez.',
    'application': 'Pulvérisez 200 mL par m² tous les 7 jours.',
    'steps': [
      {
        'description': 'Faire bouillir la prêle',
        'duration': Duration(minutes: 20)
      },
      {'description': 'Laisser refroidir', 'duration': Duration(minutes: 30)},
      {'description': 'Filtrer', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Utilisez un masque lors de la filtration.',
  },
  'Trichoderma': {
    'components': [
      {
        'name': 'Poudre de Trichoderma',
        'baseAmount': 10.0,
        'unit': 'g',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
    ],
    'dosagePerM2': 100.0,
    'recipe': 'Mélangez la poudre dans l’eau et laissez reposer 1h.',
    'application': 'Appliquez 100 mL par m² au sol, près des racines.',
    'steps': [
      {'description': 'Mélanger la poudre', 'duration': Duration(minutes: 5)},
      {'description': 'Laisser reposer', 'duration': Duration(hours: 1)},
    ],
    'precaution': 'Évitez l’exposition au soleil direct après application.',
  },
  'Savon Insecticide': {
    'components': [
      {
        'name': 'Savon noir',
        'baseAmount': 20.0,
        'unit': 'mL',
        'perLitre': true
      },
      {'name': 'Eau', 'baseAmount': 1.0, 'unit': 'L', 'perLitre': false},
    ],
    'dosagePerM2': 150.0,
    'recipe': 'Diluez le savon noir dans l’eau tiède et mélangez bien.',
    'application': 'Pulvérisez 150 mL par m² sur les zones infestées.',
    'steps': [
      {'description': 'Diluer le savon', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Testez sur une petite zone avant une application complète.',
  },
};

class DiseasePredictionScreen extends StatefulWidget {
  final ProjectModel project;

  const DiseasePredictionScreen({super.key, required this.project});

  @override
  _DiseasePredictionState createState() => _DiseasePredictionState();
}

class _DiseasePredictionState extends State<DiseasePredictionScreen> {
  String result = "Aucune prédiction effectuée.";
  File? _image;
  late Interpreter _diseaseInterpreter;
  bool _isLoading = false;
  bool _isDiseaseModelLoaded = false;
  List<Map<String, dynamic>> _predictionHistory = [];
  Map<String, Map<String, dynamic>> _preparationProgress = {};
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final Map<String, String> cropModels = {
    'Wheat': 'assets/models/Pepper_bell_model_optimized.tflite',
    'Tomato': 'assets/models/Tomato_model_optimized.tflite',
    'Potato': 'assets/models/Potato_model_optimized.tflite',
  };

  final Map<String, int> cropClasses = {
    'Wheat': 2,
    'Tomato': 10,
    'Potato': 3,
  };

  List<String> _diseaseClasses = [];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureTts();
      _loadDiseaseModel(widget.project.crop.nom);
      _updateInitialResult();
      _loadPreparationProgress();
      _showTutorialIfFirstTime();
    });
  }

  @override
  void dispose() {
    if (_isDiseaseModelLoaded) _diseaseInterpreter.close();
    _flutterTts.stop();
    _savePreparationProgress();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _loadDiseaseModel(String crop) async {
    print("Tentative de chargement du modèle pour la culture: $crop");
    if (!cropModels.containsKey(crop)) {
      setState(() {
        result = "Aucun modèle disponible pour $crop.";
      });
      return;
    }

    try {
      String modelPath = cropModels[crop]!;
      _diseaseInterpreter = await Interpreter.fromAsset(modelPath);
      _diseaseClasses = _getDiseaseClassesForCrop(crop);
      setState(() {
        _isDiseaseModelLoaded = true;
        result = "Modèle de maladie pour $crop chargé avec succès!";
      });
    } catch (e) {
      setState(() {
        result = "Erreur lors du chargement du modèle de maladie: $e";
      });
    }
  }

  List<String> _getDiseaseClassesForCrop(String crop) {
    switch (crop) {
      case 'Wheat':
        return ["Pepper__bell___Bacterial_spot", "Pepper__bell___healthy"];
      case 'Tomato':
        return [
          "Tomato_Bacterial_spot",
          "Tomato_Early_blight",
          "Tomato_Late_blight",
          "Tomato_Leaf_Mold",
          "Tomato_Septoria_leaf_spot",
          "Tomato_Spider_mites_Two_spotted_spider_mite",
          "Tomato__Target_Spot",
          "Tomato__Tomato_YellowLeaf__Curl_Virus",
          "Tomato__Tomato_mosaic_virus",
          "Tomato_healthy",
        ];
      case 'Potato':
        return ["Potato_Healthy", "Potato_Early_blight", "Potato_Late_blight"];
      default:
        return [];
    }
  }

  Future<void> _updateInitialResult() async {
    setState(() {
      result = "Aucune prédiction effectuée.";
    });
  }

  Future<void> _loadPreparationProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('prep_'));
    for (var key in keys) {
      final data = prefs.getString(key);
      if (data != null) {
        final parts = data.split('|');
        _preparationProgress[key] = {
          'disease': parts[0],
          'solution': parts[1],
          'currentStep': int.parse(parts[2]),
          'startTime': DateTime.parse(parts[3]),
          'steps': recipes[parts[1]]!['steps'],
        };
      }
    }
    setState(() {});
  }

  Future<void> _savePreparationProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in _preparationProgress.keys) {
      final prep = _preparationProgress[key]!;
      final data =
          "${prep['disease']}|${prep['solution']}|${prep['currentStep']}|${prep['startTime'].toIso8601String()}";
      await prefs.setString(key, data);
    }
  }

  Future<void> _getImage(ImageSource source) async {
    if (!_isDiseaseModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Le modèle n'est pas encore chargé. Veuillez patienter.")),
      );
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading = true;
          result = "Traitement de l'image en cours...";
        });
        await _predictDisease(_image!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la capture de l'image: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(File image) async {
    try {
      final img.Image? imageInput = img.decodeImage(await image.readAsBytes());
      if (imageInput == null) throw Exception("Format d'image invalide");
      img.Image resizedImage =
          img.copyResize(imageInput, width: 128, height: 128);
      return List.generate(
        1,
        (_) => List.generate(
          128,
          (y) => List.generate(
            128,
            (x) {
              var pixel = resizedImage.getPixelSafe(x, y);
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de prétraitement de l'image: $e")),
      );
      return null;
    }
  }

  Future<void> _predictDisease(File image) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Analyse en cours..."),
            ],
          ),
        ),
      ),
    );
    try {
      var input = await _preprocessImage(image);
      if (input == null) return;

      var diseaseOutput =
          List.filled(1, List.filled(_diseaseClasses.length, 0.0));
      _diseaseInterpreter.run(input, diseaseOutput);

      int predictedDiseaseIndex = diseaseOutput[0]
          .indexOf(diseaseOutput[0].reduce((a, b) => a > b ? a : b));
      String predictedDisease = _diseaseClasses[predictedDiseaseIndex];
      String confidence =
          (diseaseOutput[0][predictedDiseaseIndex] * 100).toStringAsFixed(2);

      setState(() {
        result = "Prédiction: $predictedDisease (Confiance: $confidence%)";
        _predictionHistory.add({
          'disease': predictedDisease,
          'confidence': confidence,
          'timestamp': DateTime.now(),
          'image': image,
        });
      });

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultPage(
            disease: predictedDisease,
            confidence: confidence,
            image: image,
            project: widget.project,
            preparationProgress: _preparationProgress,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        result = "Erreur lors de la prédiction: $e";
      });
      Navigator.pop(context);
    }
  }

  Future<void> _showTutorialIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimeDisease') ?? true;
    if (isFirstTime) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialPage(
            onComplete: () async {
              await prefs.setBool('isFirstTimeDisease', false);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? green : green;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    // final back = isDarkMode ? Colors.black : Colors.white;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Prédiction de Maladies Agricoles",
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      icon: Icons.camera_alt,
                      label: "Caméra",
                      onPressed: () => _getImage(ImageSource.camera),
                    ),
                    _buildButton(
                      icon: Icons.photo_library,
                      label: "Galerie",
                      onPressed: () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_image != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 15)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child:
                          Image.file(_image!, height: 250, fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            result,
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: textColor,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                if (_predictionHistory.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Historique des prédictions",
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _predictionHistory.length,
                            itemBuilder: (context, index) {
                              final entry = _predictionHistory[index];
                              final prepKey = 'prep_${entry['disease']}';
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                color:cardColor,
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(entry['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover),
                                  ),
                                  title: Text(
                                    entry['disease'],
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold, color: textColor), 
                                  ),
                                  subtitle: Text(
                                    "${entry['confidence']}% - ${entry['timestamp'].toString().substring(0, 19)}"
                                    "${_preparationProgress.containsKey(prepKey) ? ' (Préparation en cours: Étape ${_preparationProgress[prepKey]!['currentStep'] + 1})' : ''}",
                                    style: GoogleFonts.roboto(
                                        color: textColor),
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PredictionResultPage(
                                        disease: entry['disease'],
                                        confidence: entry['confidence'],
                                        image: entry['image'],
                                        project: widget.project,
                                        preparationProgress:
                                            _preparationProgress,
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: GoogleFonts.roboto(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
