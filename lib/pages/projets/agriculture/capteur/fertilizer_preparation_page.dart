part of 'fertilizers_pages.dart';

const Map<String, Map<String, dynamic>> organicFertilizerTypes = {
  'Compost': {
    'nitrogen': 2.0,
    'phosphorus': 1.5,
    'potassium': 1.0,
    'calcium': 2.0,
    'magnesium': 0.5,
    'form': 'solid',
    'decomposition_time': 28
  },
  'Blood Meal': {
    'nitrogen': 13.0,
    'phosphorus': 1.0,
    'potassium': 0.5,
    'calcium': 0.2,
    'magnesium': 0.1,
    'form': 'solid',
    'decomposition_time': 14
  },
  'Fish Emulsion': {
    'nitrogen': 5.0,
    'phosphorus': 2.0,
    'potassium': 2.0,
    'calcium': 0.5,
    'magnesium': 0.3,
    'form': 'liquid',
    'decomposition_time': 7
  },
  'Manure': {
    'nitrogen': 1.5,
    'phosphorus': 1.0,
    'potassium': 2.0,
    'calcium': 1.8,
    'magnesium': 0.6,
    'form': 'solid',
    'decomposition_time': 21
  },
  'Vermicompost': {
    'nitrogen': 2.5,
    'phosphorus': 1.8,
    'potassium': 1.5,
    'calcium': 2.5,
    'magnesium': 0.7,
    'form': 'solid',
    'decomposition_time': 45
  },
  'Green Manure': {
    'nitrogen': 3.5,
    'phosphorus': 0.8,
    'potassium': 2.2,
    'calcium': 1.0,
    'magnesium': 0.4,
    'form': 'solid',
    'decomposition_time': 30
  },
  'Bone Meal': {
    'nitrogen': 3.0,
    'phosphorus': 15.0,
    'potassium': 0.0,
    'calcium': 22.0,
    'magnesium': 0.2,
    'form': 'solid',
    'decomposition_time': 60
  },
  'Seaweed Extract': {
    'nitrogen': 1.0,
    'phosphorus': 0.5,
    'potassium': 4.0,
    'calcium': 1.2,
    'magnesium': 0.8,
    'form': 'liquid',
    'decomposition_time': 5
  },
};

// Composants naturels
const Map<String, Map<String, double>> organicComponents = {
  'Cow Manure': {
    'nitrogen': 0.6,
    'phosphorus': 0.3,
    'potassium': 0.5,
    'calcium': 0.9,
    'magnesium': 0.2,
    'bioavailability': 0.55
  },
  'Poultry Manure': {
    'nitrogen': 3.5,
    'phosphorus': 2.8,
    'potassium': 1.8,
    'calcium': 2.5,
    'magnesium': 0.6,
    'bioavailability': 0.75
  },
  'Horse Manure': {
    'nitrogen': 0.7,
    'phosphorus': 0.3,
    'potassium': 0.6,
    'calcium': 0.8,
    'magnesium': 0.3,
    'bioavailability': 0.60
  },
  'Sheep Manure': {
    'nitrogen': 0.9,
    'phosphorus': 0.4,
    'potassium': 0.8,
    'calcium': 1.0,
    'magnesium': 0.4,
    'bioavailability': 0.65
  },
  'Rabbit Manure': {
    'nitrogen': 2.4,
    'phosphorus': 1.4,
    'potassium': 0.6,
    'calcium': 1.2,
    'magnesium': 0.3,
    'bioavailability': 0.70
  },
  'Pig Manure': {
    'nitrogen': 0.5,
    'phosphorus': 0.4,
    'potassium': 0.5,
    'calcium': 0.7,
    'magnesium': 0.2,
    'bioavailability': 0.50
  },
  'Grass Clippings (Fresh)': {
    'nitrogen': 3.0,
    'phosphorus': 0.5,
    'potassium': 2.0,
    'calcium': 0.4,
    'magnesium': 0.2,
    'bioavailability': 0.60
  },
  'Grass Clippings (Dried)': {
    'nitrogen': 1.5,
    'phosphorus': 0.3,
    'potassium': 1.2,
    'calcium': 0.3,
    'magnesium': 0.1,
    'bioavailability': 0.55
  },
  'Coffee Grounds': {
    'nitrogen': 2.1,
    'phosphorus': 0.3,
    'potassium': 0.6,
    'calcium': 0.2,
    'magnesium': 0.1,
    'bioavailability': 0.65
  },
  'Banana Peels': {
    'nitrogen': 0.1,
    'phosphorus': 0.2,
    'potassium': 3.2,
    'calcium': 0.3,
    'magnesium': 0.2,
    'bioavailability': 0.50
  },
  'Vegetable Scraps': {
    'nitrogen': 1.0,
    'phosphorus': 0.4,
    'potassium': 0.8,
    'calcium': 0.5,
    'magnesium': 0.2,
    'bioavailability': 0.60
  },
  'Fruit Peels': {
    'nitrogen': 0.5,
    'phosphorus': 0.3,
    'potassium': 1.5,
    'calcium': 0.4,
    'magnesium': 0.1,
    'bioavailability': 0.55
  },
  'Straw': {
    'nitrogen': 0.5,
    'phosphorus': 0.2,
    'potassium': 1.1,
    'calcium': 0.3,
    'magnesium': 0.1,
    'bioavailability': 0.45
  },
  'Sawdust': {
    'nitrogen': 0.1,
    'phosphorus': 0.1,
    'potassium': 0.2,
    'calcium': 0.2,
    'magnesium': 0.1,
    'bioavailability': 0.30
  },
  'Leaves (Fresh)': {
    'nitrogen': 1.0,
    'phosphorus': 0.2,
    'potassium': 0.5,
    'calcium': 0.7,
    'magnesium': 0.3,
    'bioavailability': 0.50
  },
  'Leaves (Dried)': {
    'nitrogen': 0.8,
    'phosphorus': 0.1,
    'potassium': 0.4,
    'calcium': 0.6,
    'magnesium': 0.2,
    'bioavailability': 0.45
  },
  'Fish Waste': {
    'nitrogen': 4.5,
    'phosphorus': 3.5,
    'potassium': 0.8,
    'calcium': 2.0,
    'magnesium': 0.3,
    'bioavailability': 0.80
  },
  'Bone Meal': {
    'nitrogen': 3.0,
    'phosphorus': 15.0,
    'potassium': 0.0,
    'calcium': 22.0,
    'magnesium': 0.2,
    'bioavailability': 0.85
  },
  'Feather Meal': {
    'nitrogen': 12.0,
    'phosphorus': 0.5,
    'potassium': 0.2,
    'calcium': 0.3,
    'magnesium': 0.1,
    'bioavailability': 0.70
  },
  'Blood Meal': {
    'nitrogen': 13.0,
    'phosphorus': 1.0,
    'potassium': 0.5,
    'calcium': 0.2,
    'magnesium': 0.1,
    'bioavailability': 0.75
  },
  'Crab Shells': {
    'nitrogen': 2.0,
    'phosphorus': 1.5,
    'potassium': 0.3,
    'calcium': 23.0,
    'magnesium': 0.4,
    'bioavailability': 0.80
  },
  'Shrimp Shells': {
    'nitrogen': 2.5,
    'phosphorus': 1.8,
    'potassium': 0.4,
    'calcium': 15.0,
    'magnesium': 0.5,
    'bioavailability': 0.75
  },
  'Wood Ash': {
    'nitrogen': 0.0,
    'phosphorus': 1.0,
    'potassium': 6.0,
    'calcium': 15.0,
    'magnesium': 1.2,
    'bioavailability': 0.90
  },
  'Eggshells': {
    'nitrogen': 0.0,
    'phosphorus': 0.1,
    'potassium': 0.1,
    'calcium': 38.0,
    'magnesium': 0.4,
    'bioavailability': 0.85
  },
  'Seaweed (Dried)': {
    'nitrogen': 1.5,
    'phosphorus': 0.8,
    'potassium': 4.5,
    'calcium': 1.5,
    'magnesium': 0.9,
    'bioavailability': 0.85
  },
  'Kelp Meal': {
    'nitrogen': 1.0,
    'phosphorus': 0.5,
    'potassium': 3.0,
    'calcium': 1.2,
    'magnesium': 0.7,
    'bioavailability': 0.80
  },
  'Rock Dust': {
    'nitrogen': 0.0,
    'phosphorus': 0.2,
    'potassium': 0.5,
    'calcium': 5.0,
    'magnesium': 2.0,
    'bioavailability': 0.90
  },
  'Epsom Salt': {
    'nitrogen': 0.0,
    'phosphorus': 0.0,
    'potassium': 0.0,
    'calcium': 0.0,
    'magnesium': 10.0,
    'bioavailability': 0.95
  },
  'Clover': {
    'nitrogen': 3.0,
    'phosphorus': 0.5,
    'potassium': 2.0,
    'calcium': 1.0,
    'magnesium': 0.4,
    'bioavailability': 0.65
  },
  'Alfalfa': {
    'nitrogen': 2.8,
    'phosphorus': 0.4,
    'potassium': 2.5,
    'calcium': 1.5,
    'magnesium': 0.5,
    'bioavailability': 0.70
  },
  'Vetch': {
    'nitrogen': 3.5,
    'phosphorus': 0.6,
    'potassium': 1.8,
    'calcium': 0.8,
    'magnesium': 0.3,
    'bioavailability': 0.65
  },
};

// Composants spécifiques par type d'engrais organique (corrigé)
const Map<String, Map<String, List<String>>> organicFertilizerComponents = {
  'Compost': {
    'required': ['Cow Manure', 'Grass Clippings (Fresh)'],
    'optional': [
      'Coffee Grounds',
      'Banana Peels',
      'Vegetable Scraps',
      'Leaves (Fresh)',
      'Straw'
    ],
  },
  'Blood Meal': {
    'required': ['Blood Meal'],
    'optional': ['Feather Meal'],
  },
  'Fish Emulsion': {
    'required': ['Fish Waste'],
    'optional': ['Banana Peels', 'Seaweed (Dried)', 'Shrimp Shells'],
  },
  'Manure': {
    'required': ['Poultry Manure'],
    'optional': ['Wood Ash', 'Eggshells', 'Horse Manure', 'Sheep Manure'],
  },
  'Vermicompost': {
    'required': ['Cow Manure', 'Vegetable Scraps'],
    'optional': ['Coffee Grounds', 'Fruit Peels', 'Grass Clippings (Dried)'],
  },
  'Green Manure': {
    'required': ['Clover'],
    'optional': ['Alfalfa', 'Vetch', 'Grass Clippings (Fresh)'],
  },
  'Bone Meal': {
    'required': ['Bone Meal'],
    'optional': ['Crab Shells', 'Eggshells'],
  },
  'Seaweed Extract': {
    'required': ['Seaweed (Dried)'],
    'optional': ['Kelp Meal', 'Fish Waste'],
  },
};



class OrganicFertilizerPreparationPage extends StatefulWidget {
  final Map<String, double> deficiencies;
  final double area; // en hectares
  final String selectedType;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const OrganicFertilizerPreparationPage({
    super.key,
    required this.deficiencies,
    required this.area,
    required this.selectedType,
    required this.preparationProgress,
  });

  @override
  _OrganicFertilizerPreparationPageState createState() => _OrganicFertilizerPreparationPageState();
}

class _OrganicFertilizerPreparationPageState extends State<OrganicFertilizerPreparationPage> with SingleTickerProviderStateMixin {
  int currentStep = 0;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isStepStarted = false;
  DateTime? _stepStartTime;
  late AnimationController _animationController;
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<Map<String, dynamic>> preparationSteps;
  Map<String, double> componentQuantitiesPerHa = {};
  Map<String, double> totalComponentQuantities = {};
  Map<String, bool> selectedComponents = {};
  Map<String, double> nutrientCoverage = {};
  bool isSelectionPhase = true;
  final ImagePicker _picker = ImagePicker();
  String? _currentPrepKey;
  String _stepStatus = "idle"; // idle (Démarrer), running (Pause), paused (Reprendre)


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);

    // Initialiser les composants pertinents
    final components = organicFertilizerComponents[widget.selectedType]!;
    (components['required']! + components['optional']!).forEach((component) {
      selectedComponents[component] = components['required']!.contains(component);
    });

    // Charger une préparation en cours si elle existe
    _currentPrepKey = widget.preparationProgress.keys.firstWhere(
      (key) => key.startsWith('prep_organic_${widget.selectedType}_'),
      orElse: () => '',
    );
    if (_currentPrepKey!.isNotEmpty) {
      _loadPreparationProgress();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _suggestComponents();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _suggestComponents() {
    List<String> currentSelection = selectedComponents.entries.where((e) => e.value).map((e) => e.key).toList();
    Map<String, double> currentCoverage = _calculateNutrientCoverage(currentSelection);
    final components = organicFertilizerComponents[widget.selectedType]!;
    List<String> availableComponents = components['optional']!;

    int suggestionCount = 0;
    for (var nutrient in widget.deficiencies.keys) {
      double deficit = widget.deficiencies[nutrient]! - (currentCoverage[nutrient] ?? 0);
      if (deficit > 0 && suggestionCount < 2) {
        String? bestComponent;
        double bestScore = 0;

        for (var component in availableComponents) {
          if (!selectedComponents[component]!) {
            double nutrientValue = organicComponents[component]![nutrient]! * organicComponents[component]!['bioavailability']!;
            if (nutrientValue > bestScore) {
              bestScore = nutrientValue;
              bestComponent = component;
            }
          }
        }

        if (bestComponent != null) {
          final String componentToAdd = bestComponent;
          setState(() {
            selectedComponents[componentToAdd] = true;
          });
          suggestionCount++;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Suggestion : $componentToAdd ajouté pour $nutrient")),
            );
          });
        }
      }
    }
  }

void _toggleStep() {
  setState(() {
    if (_stepStatus == "idle") {
      _stepStatus = "running";  // Démarrer
      _startPreparation();
    } else if (_stepStatus == "running") {
      _stepStatus = "paused";   // Mettre en pause
      _pauseTimer();
    } else if (_stepStatus == "paused") {
      _stepStatus = "running";  // Reprendre
      _startPreparation();
    }
  });
}


  Map<String, double> _calculateNutrientCoverage(List<String> components) {
    Map<String, double> coverage = {'nitrogen': 0, 'phosphorus': 0, 'potassium': 0, 'calcium': 0, 'magnesium': 0};
    for (var component in components) {
      organicComponents[component]!.forEach((nutrient, value) {
        if (nutrient != 'bioavailability') {
          coverage[nutrient] = (coverage[nutrient] ?? 0) + (value / 100 * organicComponents[component]!['bioavailability']! * (componentQuantitiesPerHa[component] ?? 0));
        }
      });
    }
    return coverage;
  }

  List<Map<String, dynamic>> _generatePreparationSteps() {
    final typeData = organicFertilizerTypes[widget.selectedType]!;
    List<Map<String, dynamic>> steps = [];
    final selectedComponentList = selectedComponents.entries.where((e) => e.value).map((e) => e.key).toList();

    // Étape 1 : Mélange
    String mixDescription = "Mélanger les composants suivants dans un récipient adapté :\n";
    mixDescription += totalComponentQuantities.entries.map((entry) {
      final component = entry.key;
      final qty = entry.value.toStringAsFixed(2);
      final bioavailability = organicComponents[component]!['bioavailability']!;
      String recommendation = bioavailability < 0.6 ? "(Remuer soigneusement, faible biodisponibilité)" : "(Mélange standard)";
      return "- $component : $qty kg $recommendation";
    }).join("\n");

    steps.add({
      'description': mixDescription,
      'duration': Duration(minutes: 10),
      'interactiveOptions': {
        'method': {'title': "Méthode de mélange", 'options': ["À la main", "Mélangeur mécanique"], 'default': "À la main"},
        'precaution': "Assurez-vous que le récipient est propre et sec avant de commencer.",
      },
      'comments': '',
      'photoPath': '',
    });

    // Étape 2 : Traitement
    if (typeData['form'] == 'solid') {
      int decompositionDays = typeData['decomposition_time'] as int;
      double areaFactor = widget.area > 10 ? 1.2 : 1.0;
      int adjustedDays = (decompositionDays * areaFactor).round();

      String compostDescription = "Composter le mélange pendant $adjustedDays jours.\n";
      compostDescription += "Conditions recommandées :\n- Température : 50-65°C (retourner toutes les 3-5 jours).\n- Humidité : 40-60% (comme une éponge essorée).\n";
      if (selectedComponentList.any((c) => organicComponents[c]!['nitrogen']! > 5)) {
        compostDescription += "- Attention : Forte teneur en azote, surveiller les odeurs.\n";
      }

      steps.add({
        'description': compostDescription,
        'duration': Duration(days: adjustedDays),
        'interactiveOptions': {
          'temperature': {'title': "Contrôle de la température", 'options': ["Ambiante", "50-65°C (recommandé)", "Chauffage externe"], 'default': "50-65°C (recommandé)"},
          'turningFrequency': {'title': "Fréquence de retournement", 'options': ["3 jours", "5 jours", "7 jours"], 'default': "5 jours"},
        },
        'comments': '',
        'photoPath': '',
      });
    } else {
      double waterVolume = widget.area * 1000;
      double totalNutrients = nutrientCoverage.values.fold(0, (sum, value) => sum + value);
      double waterAdjustment = totalNutrients > 50 ? 1.1 : 1.0;
      String dilutionDescription = "Diluer le mélange dans ${(waterVolume * waterAdjustment).toStringAsFixed(2)} L d’eau.\n";
      dilutionDescription += "Recommandations :\n- Utiliser de l’eau non chlorée si possible.\n- Agiter pendant 2-3 minutes pour homogénéité.\n";

      steps.add({
        'description': dilutionDescription,
        'duration': Duration(minutes: 5),
        'interactiveOptions': {
          'waterType': {'title': "Type d’eau", 'options': ["Eau du robinet", 'Eau de pluie', "Eau déchlorée"], 'default': "Eau de pluie"},
          'stirring': {'title': "Méthode d’agitation", 'options': ["Manuelle", "Mécanique"], 'default': "Manuelle"},
        },
        'comments': '',
        'photoPath': '',
      });
    }

    // Étape 3 : Application
    String applicationDescription = typeData['form'] == 'solid'
        ? "Appliquer le compost au sol uniformément.\n"
        : "Pulvériser la solution sur les feuilles avec un pulvérisateur.\n";
    applicationDescription += "Conseils :\n";
    applicationDescription += typeData['form'] == 'solid'
        ? "- Étaler sur ${widget.area.toStringAsFixed(2)} ha à une profondeur de 5-10 cm.\n"
        : "- Pulvériser tôt le matin ou tard le soir pour éviter l’évaporation.\n";
    applicationDescription += "- Quantité totale : ${totalComponentQuantities.values.fold(0.0, (sum, qty) => sum + qty).toStringAsFixed(2)} kg.";

    steps.add({
      'description': applicationDescription,
      'duration': Duration(minutes: 15),
      'interactiveOptions': {
        'applicationMethod': {
          'title': "Méthode d’application",
          'options': typeData['form'] == 'solid' ? ["Manuelle", "Épandeur"] : ["Pulvérisateur manuel", "Pulvérisateur motorisé"],
          'default': typeData['form'] == 'solid' ? "Manuelle" : "Pulvérisateur manuel",
        },
      },
      'comments': '',
      'photoPath': '',
    });

    return steps;
  }

  Map<String, double> _calculateComponentQuantities() {
    Map<String, double> quantitiesPerHa = {};
    List<String> chosenComponents = selectedComponents.entries.where((e) => e.value).map((e) => e.key).toList();

    if (chosenComponents.isEmpty) return quantitiesPerHa;

    for (var component in chosenComponents) {
      quantitiesPerHa[component] = 0;
    }

    for (var nutrient in widget.deficiencies.entries) {
      double target = nutrient.value.abs();
      double totalProvided = 0;

      for (var component in chosenComponents) {
        double content = organicComponents[component]![nutrient.key]! / 100 * organicComponents[component]!['bioavailability']!;
        if (content > 0) {
          double qty = target / content;
          quantitiesPerHa[component] = max(quantitiesPerHa[component] ?? 0, qty);
          totalProvided += qty * content;
        }
      }

      if (totalProvided > target * 1.2) {
        double scale = target / totalProvided;
        quantitiesPerHa.updateAll((key, value) => value * scale);
      }
    }

    return quantitiesPerHa;
  }

  void _confirmSelection() {
    componentQuantitiesPerHa = _calculateComponentQuantities();
    totalComponentQuantities = componentQuantitiesPerHa.map((key, value) => MapEntry(key, value * widget.area));
    nutrientCoverage = _calculateNutrientCoverage(totalComponentQuantities.keys.toList());

    bool isCoverageSufficient = widget.deficiencies.entries.every((e) => (nutrientCoverage[e.key] ?? 0) >= e.value);
    if (!isCoverageSufficient) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Attention", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text("Les composants choisis ne couvrent pas tous les déficits. Voulez-vous continuer ou ajuster vos choix ?", style: GoogleFonts.roboto()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Ajuster", style: GoogleFonts.roboto(color: Colors.blue))),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _proceedToPreparation();
              },
              child: Text("Continuer", style: GoogleFonts.roboto(color: Colors.green)),
            ),
          ],
        ),
      );
    } else {
      _proceedToPreparation();
    }
  }

  void _proceedToPreparation() {
    setState(() {
      preparationSteps = _generatePreparationSteps();
      isSelectionPhase = false;
      _currentPrepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
    });
    _showQuantitiesSummary();
  }

  void _showQuantitiesSummary() {
    String message = "Pour votre superficie de ${widget.area} hectares, voici les quantités totales à apporter :\n\n";
    totalComponentQuantities.forEach((component, qty) {
      message += "- $component : ${qty.toStringAsFixed(2)} kg\n";
    });
    message += "\nCouverture des déficits :\n";
    widget.deficiencies.forEach((nutrient, value) {
      message += "- $nutrient : ${(nutrientCoverage[nutrient] ?? 0).toStringAsFixed(2)} kg/ha (besoin : ${value.toStringAsFixed(2)} kg/ha)\n";
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Résumé", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Text(message, style: GoogleFonts.roboto())),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: GoogleFonts.roboto(color: Colors.blue)))],
      ),
    );
  }

  void _startPreparation() {
    if (currentStep >= preparationSteps.length) {
      _completePreparation();
      return;
    }

    final step = preparationSteps[currentStep];
    _remainingTime = step['duration'] as Duration;

    if (_currentPrepKey == null || _currentPrepKey!.isEmpty) {
      _currentPrepKey = 'prep_organic_${widget.selectedType}_${DateTime.now().millisecondsSinceEpoch}';
    }

    widget.preparationProgress[_currentPrepKey!] = {
      'currentStep': currentStep,
      'startTime': _stepStartTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'remainingTime': _remainingTime.inSeconds,
      'steps': preparationSteps,
    };
    _savePreparationProgress();

    _speakStepInstructions(step['description']);
    _startStepTimer();
  }

  void _startStepTimer() {
    setState(() {
      _isStepStarted = true;
      _stepStartTime ??= DateTime.now();
      _animationController.duration = preparationSteps[currentStep]['duration'] as Duration;
      _animationController.reset();
      _animationController.forward(from: 1 - (_remainingTime.inSeconds / (preparationSteps[currentStep]['duration'] as Duration).inSeconds));
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final elapsed = DateTime.now().difference(_stepStartTime!);
        _remainingTime = (preparationSteps[currentStep]['duration'] as Duration) - elapsed;
        if (_remainingTime <= Duration.zero) {
          _timer?.cancel();
          _animationController.stop();
          _playCompletionSound();
          _showStepCompleteDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() => _isStepStarted = false);
    widget.preparationProgress[_currentPrepKey!]!['remainingTime'] = _remainingTime.inSeconds;
    widget.preparationProgress[_currentPrepKey!]!['startTime'] = _stepStartTime!.toIso8601String();
    _savePreparationProgress();
  }

  void _resumeTimer() {
    final stepDuration = preparationSteps[currentStep]['duration'] as Duration;
    final elapsed = DateTime.now().difference(_stepStartTime!);
    _remainingTime = stepDuration - elapsed;

    if (_remainingTime <= Duration.zero) {
      _showStepCompleteDialog();
    } else {
      setState(() {
        _isStepStarted = true;
        _animationController.duration = stepDuration;
        _animationController.forward(from: 1 - (_remainingTime.inSeconds / stepDuration.inSeconds.toDouble()));
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          final elapsed = DateTime.now().difference(_stepStartTime!);
          _remainingTime = stepDuration - elapsed;
          if (_remainingTime <= Duration.zero) {
            _timer?.cancel();
            _animationController.stop();
            _playCompletionSound();
            _showStepCompleteDialog();
          }
        });
      });
    }
  }

  void _resetPreparation() {
    _timer?.cancel();
    _animationController.reset();
    setState(() {
      currentStep = 0;
      _isStepStarted = false;
      _stepStartTime = null;
      _remainingTime = Duration.zero;
      isSelectionPhase = true;
      final components = organicFertilizerComponents[widget.selectedType]!;
      selectedComponents.clear();
      (components['required']! + components['optional']!).forEach((component) {
        selectedComponents[component] = components['required']!.contains(component);
      });
    });
    if (_currentPrepKey != null) {
      widget.preparationProgress.remove(_currentPrepKey);
      _currentPrepKey = null;
    }
    _savePreparationProgress();
  }

  void _previousStep() {
    if (currentStep > 0) {
      _timer?.cancel();
      _animationController.reset();
      setState(() {
        currentStep--;
        _isStepStarted = false;
        _stepStartTime = null;
        _remainingTime = preparationSteps[currentStep]['duration'] as Duration;
      });
      widget.preparationProgress[_currentPrepKey!]!['currentStep'] = currentStep;
      _savePreparationProgress();
    }
  }

  void _showStepCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Étape ${currentStep + 1} terminée", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text("Voulez-vous passer à l'étape suivante ?", style: GoogleFonts.roboto()),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentStep++;
                _isStepStarted = false;
                _stepStartTime = null;
                _remainingTime = preparationSteps[currentStep]['duration'] as Duration;
              });
              _startPreparation();
            },
            child: Text("Oui", style: GoogleFonts.roboto(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Non", style: GoogleFonts.roboto(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
        ],
      ),
    );
  }

  void _completePreparation() {
    if (_currentPrepKey != null) {
      widget.preparationProgress.remove(_currentPrepKey);
      _savePreparationProgress();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Préparation de l'engrais organique terminée !")));
    });
    Navigator.pop(context);
  }

  Future<void> _savePreparationProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentPrepKey != null && widget.preparationProgress.containsKey(_currentPrepKey)) {
      final prep = widget.preparationProgress[_currentPrepKey!]!;
      final data = jsonEncode({
        'currentStep': prep['currentStep'],
        'startTime': prep['startTime'],
        'remainingTime': prep['remainingTime'],
        'steps': prep['steps'],
      });
      await prefs.setString(_currentPrepKey!, data);
    } else if (_currentPrepKey != null) {
      await prefs.remove(_currentPrepKey!);
    }
  }

  void _loadPreparationProgress() {
  final prep = widget.preparationProgress[_currentPrepKey!];
  if (prep != null) { // Vérification de nullité
    setState(() {
      currentStep = prep['currentStep'] as int;
      _stepStartTime = DateTime.parse(prep['startTime'] as String);
      _remainingTime = Duration(seconds: prep['remainingTime'] as int);
      preparationSteps = List<Map<String, dynamic>>.from(prep['steps'] as List);
      isSelectionPhase = false;
    });
  } else {
    // Si aucune préparation n'est trouvée, initialiser par défaut
    setState(() {
      currentStep = 0;
      _stepStartTime = null;
      _remainingTime = Duration.zero;
      isSelectionPhase = true;
      preparationSteps = [];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suggestComponents();
    });
  }
}

  Future<void> _addStepNote(int stepIndex) async {
    TextEditingController commentController = TextEditingController(text: preparationSteps[stepIndex]['comments']);
    File? photoFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajouter une note pour l'étape ${stepIndex + 1}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: "Commentaire"),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final path = '${directory.path}/step_${stepIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    photoFile = await File(path).writeAsBytes(await image.readAsBytes());
                  }
                },
                child: Text("Prendre une photo", style: GoogleFonts.roboto()),
              ),
              if (preparationSteps[stepIndex]['photoPath'].isNotEmpty) ...[
                SizedBox(height: 10),
                Image.file(File(preparationSteps[stepIndex]['photoPath']), height: 100, width: 100, fit: BoxFit.cover),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                preparationSteps[stepIndex]['comments'] = commentController.text;
                if (photoFile != null) preparationSteps[stepIndex]['photoPath'] = photoFile!.path;
              });
              widget.preparationProgress[_currentPrepKey!]!['steps'] = preparationSteps;
              _savePreparationProgress();
              Navigator.pop(context);
            },
            child: Text("Sauvegarder", style: GoogleFonts.roboto(color: Colors.blue)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler", style: GoogleFonts.roboto(color: Colors.red))),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00";
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (days > 0) return "$days jours, $hours h";
    if (hours > 0) return "$hours:${minutes.toString().padLeft(2, '0')}";
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _speakStepInstructions(String instruction) async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(instruction);
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
    } catch (e) {
      print("Erreur lors de la lecture du son : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final components = organicFertilizerComponents[widget.selectedType]!;
    List<String> requiredComponents = components['required']!;
    List<String> optionalComponents = components['optional']!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Préparation - ${widget.selectedType}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Superficie: ${widget.area} ha", style: GoogleFonts.roboto(fontSize: 16)),
            SizedBox(height: 20),
            if (isSelectionPhase) ...[
              Text("Composants requis", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...requiredComponents.map((component) => CheckboxListTile(
                    title: Text("$component (requis)", style: GoogleFonts.roboto(color: Colors.black87)),
                    subtitle: Text("$component - N: ${organicComponents[component]!['nitrogen']}%, P: ${organicComponents[component]!['phosphorus']}%, K: ${organicComponents[component]!['potassium']}%, Ca: ${organicComponents[component]!['calcium']}%, Mg: ${organicComponents[component]!['magnesium']}%"),
                    value: selectedComponents[component],
                    onChanged: null,
                  )),
              SizedBox(height: 20),
              Text("Composants optionnels", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ...optionalComponents.map((component) => CheckboxListTile(
                    title: Text(component, style: GoogleFonts.roboto(color: Colors.black87)),
                    subtitle: Text("$component - N: ${organicComponents[component]!['nitrogen']}%, P: ${organicComponents[component]!['phosphorus']}%, K: ${organicComponents[component]!['potassium']}%, Ca: ${organicComponents[component]!['calcium']}%, Mg: ${organicComponents[component]!['magnesium']}%"),
                    value: selectedComponents[component],
                    onChanged: (value) {
                      setState(() => selectedComponents[component] = value!);
                    },
                  )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedComponents.values.any((selected) => selected) ? _confirmSelection : null,
                child: Text("Confirmer et calculer", style: GoogleFonts.roboto(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ] else ...[
              LinearProgressIndicator(
                value: preparationSteps.isEmpty ? 0 : currentStep / preparationSteps.length,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text("Résumé des quantités", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              Table(
                border: TableBorder.all(),
                columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
                children: [
                  TableRow(
                    decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 3), borderRadius: BorderRadius.circular(8)),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text("Composant", style: GoogleFonts.roboto(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text("kg/ha", style: GoogleFonts.roboto(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text("Total (kg)", style: GoogleFonts.roboto(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...totalComponentQuantities.entries.map((e) => TableRow(
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text(e.key, style: GoogleFonts.roboto())),
                          Padding(padding: EdgeInsets.all(8), child: Text(componentQuantitiesPerHa[e.key]!.toStringAsFixed(2), style: GoogleFonts.roboto())),
                          Padding(padding: EdgeInsets.all(8), child: Text(e.value.toStringAsFixed(2), style: GoogleFonts.roboto())),
                        ],
                      )),
                ],
              ),
              SizedBox(height: 20),
              Text("Couverture des déficits", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              ...widget.deficiencies.entries.map((e) => Text(
                    "${e.key}: ${(nutrientCoverage[e.key] ?? 0).toStringAsFixed(2)} kg/ha (besoin: ${e.value.toStringAsFixed(2)} kg/ha)",
                    style: GoogleFonts.roboto(color: (nutrientCoverage[e.key] ?? 0) >= e.value ? Colors.green : Colors.red),
                  )),
              SizedBox(height: 20),
              if (currentStep < preparationSteps.length) ...[
               Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alignement équilibré
  children: [
    Text(
      "Étape ${currentStep + 1}/${preparationSteps.length}",
      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    OutlinedButton(
      onPressed: () => _addStepNote(currentStep),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.green, width: 2), // Bordure verte
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Ajustement du padding
      ),
      child: Row(
        children: [
          Icon(Icons.note_add, color: Colors.green),
          SizedBox(width: 6), // Petit espace entre l'icône et le texte
          Text("Ajouter", style: GoogleFonts.roboto(color: Colors.green, fontSize: 14)),
        ],
      ),
    ),
  ],
),

                SizedBox(height: 10),
                Text(preparationSteps[currentStep]['description'], style: GoogleFonts.roboto(fontSize: 16)),
                if (preparationSteps[currentStep]['comments'].isNotEmpty) ...[
                  SizedBox(height: 10),
                  Text("Commentaire : ${preparationSteps[currentStep]['comments']}", style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700])),
                ],
                if (preparationSteps[currentStep]['photoPath'].isNotEmpty) ...[
                  SizedBox(height: 10),
                  Image.file(File(preparationSteps[currentStep]['photoPath']), height: 100, width: 100, fit: BoxFit.cover),
                ],
                // SizedBox(height: 10),
                // ElevatedButton.icon(
                //   onPressed: () => _addStepNote(currentStep),
                //   icon: Icon(Icons.note_add, color: Colors.white),
                //   label: Text("Ajouter une note/photo", style: GoogleFonts.roboto(color: Colors.white)),
                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                // ),
                SizedBox(height: 10),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: _isStepStarted ? 1 - (_remainingTime.inSeconds / (preparationSteps[currentStep]['duration'] as Duration).inSeconds) : 0,
                            strokeWidth: 8,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          _formatDuration(_isStepStarted ? _remainingTime : preparationSteps[currentStep]['duration']),
                          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: currentStep > 0 ? _previousStep : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Icon(Icons.skip_previous, color: Colors.white),
                    ),
                    ElevatedButton.icon(
  onPressed: _toggleStep,
  icon: Icon(
    _stepStatus == "idle"
        ? Icons.play_arrow // Démarrer
        : (_stepStatus == "running" ? Icons.pause : Icons.play_arrow), // Pause/Reprendre
    color: Colors.white,
  ),
  label: Text(
    _stepStatus == "idle"
        ? "Démarrer"
        : (_stepStatus == "running" ? "Pause" : "Reprendre"),
    style: GoogleFonts.roboto(color: Colors.white),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
),
                    ElevatedButton(
                      onPressed: _isStepStarted
                          ? () {
                              _timer?.cancel();
                              _animationController.reset();
                              setState(() {
                                currentStep++;
                                _isStepStarted = false;
                                _stepStartTime = null;
                                _remainingTime = preparationSteps[currentStep]['duration'] as Duration;
                              });
                              _startPreparation();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Icon(Icons.skip_next, color: Colors.white),
                    ),
                  ],
                ),
              ] else ...[
                Text("Préparation terminée !", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetPreparation,
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text("Réinitialiser", style: GoogleFonts.roboto(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                    label: Text("Fermer", style: GoogleFonts.roboto(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}