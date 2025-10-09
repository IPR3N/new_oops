import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';

// Pages séparées
part 'chemical_solution_page.dart';
part 'natural_solutions_page.dart';
part 'recipe_preparation_page.dart';
part 'tutorial_page.dart';
part 'prediction_result_page.dart';
part 'eradication_methods_page.dart';
part 'pest_details_screen.dart';

final Map<String, Map<String, dynamic>> recipes = {
  'Infusion de Feuilles de Neem': {
    'components': [
      {
        'name': 'Feuilles de Neem fraîches',
        'baseAmount': 100.0,
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
        'Faites bouillir les feuilles dans l’eau pendant 20 min. Laissez refroidir, filtrez, ajoutez le savon liquide.',
    'application': 'Pulvérisez 200 mL par m², 2 fois par semaine.',
    'steps': [
      {
        'description': 'Faire bouillir les feuilles',
        'duration': Duration(minutes: 20)
      },
      {'description': 'Laisser refroidir', 'duration': Duration(minutes: 30)},
      {
        'description': 'Filtrer et ajouter savon',
        'duration': Duration(minutes: 10)
      },
    ],
    'precaution':
        'Évitez les cultures en récolte ; conservez au frais (48h max).',
  },
  'Mélange Borax-Sucre': {
    'components': [
      {'name': 'Borax', 'baseAmount': 10.0, 'unit': 'g', 'perLitre': false},
      {'name': 'Sucre', 'baseAmount': 30.0, 'unit': 'g', 'perLitre': false},
      {'name': 'Eau', 'baseAmount': 250.0, 'unit': 'mL', 'perLitre': false},
    ],
    'dosagePerM2': 10.0,
    'recipe':
        'Dissoudre le borax et le sucre dans l’eau tiède. Imbibez des cotons.',
    'application':
        'Placez 1 coton par mètre linéaire, renouvelez tous les 3 jours.',
    'steps': [
      {
        'description': 'Dissoudre borax et sucre',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Imbiber les cotons', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Toxique pour enfants et animaux ; hors de portée.',
  },
  'Poudre de Piment': {
    'components': [
      {
        'name': 'Poudre de Piment',
        'baseAmount': 10.0,
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
        'Mélangez la poudre dans l’eau, ajoutez le savon. Laissez reposer 1h, filtrez.',
    'application': 'Pulvérisez 100 mL par m², tous les 2 jours.',
    'steps': [
      {
        'description': 'Mélanger poudre et eau',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Laisser reposer', 'duration': Duration(hours: 1)},
      {'description': 'Filtrer', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Portez masque et gants ; évitez les yeux.',
  },
  'Infusion de Feuilles de Tabac': {
    'components': [
      {
        'name': 'Feuilles de tabac séchées',
        'baseAmount': 50.0,
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
    'dosagePerM2': 150.0,
    'recipe':
        'Faites tremper les feuilles dans l’eau chaude pendant 24h. Filtrez et ajoutez le savon.',
    'application': 'Pulvérisez 150 mL par m², tous les 5 jours.',
    'steps': [
      {
        'description': 'Faire tremper les feuilles',
        'duration': Duration(hours: 24)
      },
      {'description': 'Filtrer', 'duration': Duration(minutes: 5)},
      {'description': 'Ajouter savon', 'duration': Duration(minutes: 5)},
    ],
    'precaution':
        'Toxique ; portez des gants et évitez les cultures comestibles.',
  },
  'Huile Essentielle de Citronnelle': {
    'components': [
      {
        'name': 'Huile essentielle de citronnelle',
        'baseAmount': 5.0,
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
    'dosagePerM2': 100.0,
    'recipe':
        'Mélangez l’huile essentielle et le savon dans l’eau tiède. Agitez bien.',
    'application': 'Pulvérisez 100 mL par m², tous les 3 jours.',
    'steps': [
      {
        'description': 'Mélanger huile et savon',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Ajouter eau tiède', 'duration': Duration(minutes: 5)},
    ],
    'precaution': 'Évitez l’exposition prolongée au soleil après application.',
  },
  'Terre de Diatomées': {
    'components': [
      {
        'name': 'Terre de diatomées',
        'baseAmount': 20.0,
        'unit': 'g',
        'perLitre': false
      },
    ],
    'dosagePerM2': 20.0,
    'recipe': 'Saupoudrez la poudre directement sur les zones infestées.',
    'application':
        'Appliquez 20 g par m², renouvelez après pluie ou tous les 7 jours.',
    'steps': [
      {'description': 'Saupoudrer la terre', 'duration': Duration(minutes: 10)},
    ],
    'precaution':
        'Portez un masque pour éviter l’inhalation ; appliquer par temps sec.',
  },
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
  'Huile Essentielle de Lavande': {
    'components': [
      {
        'name': 'Huile essentielle de lavande',
        'baseAmount': 5.0,
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
    'dosagePerM2': 100.0,
    'recipe':
        'Mélangez l’huile essentielle et le savon dans l’eau tiède. Agitez bien.',
    'application': 'Pulvérisez 100 mL par m², tous les 4 jours.',
    'steps': [
      {
        'description': 'Mélanger huile et savon',
        'duration': Duration(minutes: 5)
      },
      {'description': 'Ajouter eau tiède', 'duration': Duration(minutes: 5)},
    ],
    'precaution':
        'Testez sur une petite zone pour éviter les réactions des plantes.',
  },
  'Piège à Bière': {
    'components': [
      {'name': 'Bière', 'baseAmount': 200.0, 'unit': 'mL', 'perLitre': false},
      {
        'name': 'Récipient peu profond',
        'baseAmount': 1.0,
        'unit': 'unité',
        'perLitre': false
      },
    ],
    'dosagePerM2': 1.0,
    'recipe':
        'Versez la bière dans un récipient peu profond et enterrez-le au niveau du sol.',
    'application':
        'Placez 1 piège par m², vérifiez et renouvelez tous les 2 jours.',
    'steps': [
      {
        'description': 'Préparer et placer le piège',
        'duration': Duration(minutes: 5)
      },
    ],
    'precaution': 'Évitez les zones accessibles aux animaux domestiques.',
  },
  'Piège Sucre-Vinaigre': {
    'components': [
      {'name': 'Sucre', 'baseAmount': 20.0, 'unit': 'g', 'perLitre': false},
      {
        'name': 'Vinaigre',
        'baseAmount': 100.0,
        'unit': 'mL',
        'perLitre': false
      },
      {'name': 'Eau', 'baseAmount': 100.0, 'unit': 'mL', 'perLitre': false},
      {
        'name': 'Bouteille en plastique',
        'baseAmount': 1.0,
        'unit': 'unité',
        'perLitre': false
      },
    ],
    'dosagePerM2': 0.5,
    'recipe':
        'Mélangez le sucre, le vinaigre et l’eau. Versez dans une bouteille coupée avec une ouverture.',
    'application': 'Placez 1 piège tous les 2 m², vérifiez tous les 3 jours.',
    'steps': [
      {
        'description': 'Mélanger les ingrédients',
        'duration': Duration(minutes: 5)
      },
      {
        'description': 'Préparer et placer le piège',
        'duration': Duration(minutes: 5)
      },
    ],
    'precaution': 'Suspendez hors de portée des enfants.',
  },
};

class PestPredictionScreen extends ConsumerStatefulWidget {
  final ProjectModel product;

  const PestPredictionScreen({super.key, required this.product});

  @override
  ConsumerState<PestPredictionScreen> createState() => _PestPredictionState();
}

class _PestPredictionState extends ConsumerState<PestPredictionScreen> {
  File? _image;
  late Interpreter _pestInterpreter;
  bool _isLoading = false;
  bool _isPestModelLoaded = false;
  String _result = "";
  String _advice = "";
  List<Map<String, dynamic>> _predictionHistory = [];
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  Map<String, Map<String, dynamic>> _preparationProgress = {};

  final List<String> _pestClasses = [
    'ants',
    'bees',
    'beetle',
    'caterpillar',
    'earthworms',
    'earwig',
    'grasshopper',
    'moth',
    'slug',
    'snail',
    'wasp',
    'weevil'
  ];
  final double _confidenceThreshold = 0.75;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureTts();
      _loadPestModel();
      _updateInitialResult();
      _loadPreparationProgress();
      _showTutorialIfFirstTime();
    });
  }

  @override
  void dispose() {
    if (_isPestModelLoaded) _pestInterpreter.close();
    _flutterTts.stop();
    _savePreparationProgress();
    super.dispose();
  }

  Future<void> _configureTts() async {
    final locale = ref.read(localeProvider).languageCode;
    await _flutterTts.setLanguage(locale == 'fr' ? 'fr-FR' : 'en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  Future<void> _loadPestModel() async {
    try {
      _pestInterpreter = await Interpreter.fromAsset(
          'assets/models/Pest_model_optimized.tflite');
      setState(() {
        _isPestModelLoaded = true;
        _result = AppLocales.getTranslation(
            'pest_model_loaded', ref.read(localeProvider).languageCode);
      });
    } catch (e) {
      setState(() {
        _result = AppLocales.getTranslation(
            'pest_model_error', ref.read(localeProvider).languageCode,
            placeholders: {'error': e.toString()});
      });
    }
  }

  void _updateInitialResult() {
    setState(() {
      _result = AppLocales.getTranslation(
          'no_prediction', ref.read(localeProvider).languageCode);
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
          'pest': parts[0],
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
          "${prep['pest']}|${prep['solution']}|${prep['currentStep']}|${prep['startTime'].toIso8601String()}";
      await prefs.setString(key, data);
    }
  }

  Future<void> _getImage(ImageSource source) async {
    if (!_isPestModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocales.getTranslation(
                'model_not_loaded', ref.read(localeProvider).languageCode))),
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
          _result = AppLocales.getTranslation(
              'processing_image', ref.read(localeProvider).languageCode);
        });
        await _predictPest(_image!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocales.getTranslation(
                'image_capture_error', ref.read(localeProvider).languageCode,
                placeholders: {'error': e.toString()}))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(File image) async {
    try {
      final img.Image? imageInput = img.decodeImage(await image.readAsBytes());
      if (imageInput == null) throw Exception("Invalid image format");
      img.Image resizedImage =
          img.copyResize(imageInput, width: 128, height: 128);
      return List.generate(
          1,
          (_) => List.generate(
              128,
              (y) => List.generate(128, (x) {
                    var pixel = resizedImage.getPixelSafe(x, y);
                    return [
                      (pixel.r / 255.0 - 0.485) / 0.229,
                      (pixel.g / 255.0 - 0.456) / 0.224,
                      (pixel.b / 255.0 - 0.406) / 0.225
                    ];
                  })));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocales.getTranslation('image_preprocessing_error',
                ref.read(localeProvider).languageCode,
                placeholders: {'error': e.toString()}))),
      );
      return null;
    }
  }

  Future<void> _predictPest(File image) async {
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
              Text("Analyzing..."),
            ],
          ),
        ),
      ),
    );
    try {
      var input = await _preprocessImage(image);
      if (input == null) return;
      var output =
          List.generate(1, (_) => List.filled(_pestClasses.length, 0.0));
      _pestInterpreter.run(input, output);
      final scores = output[0];
      final maxScore = scores.reduce((a, b) => a > b ? a : b);
      final predictedIndex = scores.indexOf(maxScore);
      final confidence = maxScore;

      if (confidence < _confidenceThreshold) {
        setState(() {
          _result = AppLocales.getTranslation(
              'low_confidence', ref.read(localeProvider).languageCode,
              placeholders: {
                'confidence': (confidence * 100).toStringAsFixed(2)
              });
        });
        Navigator.pop(context);
        return;
      }

      final predictedPest = _pestClasses[predictedIndex];
      setState(() {
        _result = AppLocales.getTranslation(
            'prediction_result', ref.read(localeProvider).languageCode,
            placeholders: {
              'pest': predictedPest,
              'confidence': (confidence * 100).toStringAsFixed(2)
            });
        _advice = _getPestAdvice(predictedPest);
        _predictionHistory.add({
          'pest': predictedPest,
          'confidence': confidence,
          'timestamp': DateTime.now(),
          'image': image
        });
      });
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultPage(
            pest: predictedPest,
            advice: _advice,
            image: image,
            area: widget.product.estimatedQuantityProduced.toDouble(),
            preparationProgress: _preparationProgress,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _result = AppLocales.getTranslation(
            'prediction_error', ref.read(localeProvider).languageCode,
            placeholders: {'error': e.toString()});
      });
      Navigator.pop(context);
    }
  }

  String _getPestAdvice(String pest) {
    final locale = ref.read(localeProvider).languageCode;
    switch (pest.toLowerCase()) {
      case 'ants':
        return "Fourmis détectées. Choisissez une méthode pour les éradiquer.";
      case 'bees':
        return "Abeilles détectées. Choisissez une méthode pour les gérer.";
      case 'beetle':
        return "Coléoptères détectés. Choisissez une méthode pour les éradiquer.";
      case 'caterpillar':
        return "Chenilles détectées. Choisissez une méthode pour les éradiquer.";
      case 'earthworms':
        return "Vers de terre détectés. Aucun traitement nécessaire, sauf pour les éloigner.";
      case 'earwig':
        return "Perce-oreilles détectés. Choisissez une méthode pour les éradiquer.";
      case 'grasshopper':
        return "Sauterelles détectées. Choisissez une méthode pour les éradiquer.";
      case 'moth':
        return "Papillons de nuit détectés. Choisissez une méthode pour les éradiquer.";
      case 'slug':
        return "Limaces détectées. Choisissez une méthode pour les éradiquer.";
      case 'snail':
        return "Escargots détectés. Choisissez une méthode pour les éradiquer.";
      case 'wasp':
        return "Guêpes détectées. Choisissez une méthode pour les éradiquer.";
      case 'weevil':
        return "Charançons détectés. Choisissez une méthode pour les éradiquer.";
      default:
        return AppLocales.getTranslation('advice_default', locale);
    }
  }

  Future<void> _showTutorialIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimePest') ?? true;
    if (isFirstTime) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialPage(
            onComplete: () async {
              await prefs.setBool('isFirstTimePest', false);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor= isDarkMode ? green : green;
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
                  AppLocales.getTranslation('pest_prediction_title', locale),
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
                      label:
                          AppLocales.getTranslation('capture_camera', locale),
                      onPressed: () => _getImage(ImageSource.camera),
                    ),
                    _buildButton(
                      icon: Icons.photo_library,
                      label:
                          AppLocales.getTranslation('capture_gallery', locale),
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
                        ]),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!,
                            height: 250, fit: BoxFit.cover)),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _result,
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
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
                          AppLocales.getTranslation(
                              'prediction_history', locale),
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _predictionHistory.length,
                            itemBuilder: (context, index) {
                              final entry = _predictionHistory[index];
                              final prepKey = 'prep_${entry['pest']}';
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                color: Colors.white.withOpacity(0.85),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(entry['image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover),
                                  ),
                                  title: Text(entry['pest'],
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    "${(entry['confidence'] * 100).toStringAsFixed(2)}% - ${entry['timestamp'].toString().substring(0, 19)}"
                                    "${_preparationProgress.containsKey(prepKey) ? ' (Préparation en cours: Étape ${_preparationProgress[prepKey]!['currentStep'] + 1})' : ''}",
                                    style: GoogleFonts.roboto(
                                        color: Colors.black54),
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PredictionResultPage(
                                        pest: entry['pest'],
                                        advice: _getPestAdvice(entry['pest']),
                                        image: entry['image'],
                                        area: widget
                                            .product.estimatedQuantityProduced
                                            .toDouble(),
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
