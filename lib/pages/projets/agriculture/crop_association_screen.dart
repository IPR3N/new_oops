import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class CropAssociationScreen extends ConsumerStatefulWidget {
  final Crop crop;

  const CropAssociationScreen({Key? key, required this.crop}) : super(key: key);

  @override
  ConsumerState<CropAssociationScreen> createState() => _CropAssociationScreenState();
}

class _CropAssociationScreenState extends ConsumerState<CropAssociationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FlutterTts _flutterTts;
  List<CropData> _crops = [];
  Map<String, CropCompatibility> _compatibilityMap = {};
  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedCropForComparison;
  CropCompatibility? _comparisonResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _flutterTts = FlutterTts();
    _configureTts();
    _loadCrops();
  }

  Future<void> _configureTts() async {
    final locale = ref.read(localeProvider).languageCode;
    await _flutterTts.setLanguage(locale == 'fr' ? 'fr-FR' : 'en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    setState(() => _isLoading = true);
    try {
      final db = CropDatabase();
      _crops = await db.getCrops();
      if (_crops.isEmpty) throw Exception('No crops loaded from database.');
      _computeCompatibility();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load crops: $e';
        _isLoading = false;
      });
    }
  }

  CropCompatibility _calculateCompatibility(CropData crop1, CropData crop2) {
    const weights = {
      'nutrients': 0.35,
      'environment': 0.30,
      'growth': 0.15,
      'biotic': 0.20,
    };

    final nutrientScore = _calculateNutrientScore(crop1, crop2);
    final envScore = _calculateEnvironmentalScore(crop1, crop2);
    final growthScore = _calculateGrowthScore(crop1, crop2);
    final bioticScore = _calculateBioticScore(crop1, crop2);

    double totalScore = (nutrientScore * weights['nutrients']! +
            envScore * weights['environment']! +
            growthScore * weights['growth']! +
            bioticScore * weights['biotic']!)
        .clamp(0.0, 10.0);

    final isFriendThreshold = crop1.isPerennial || crop2.isPerennial ? 6.5 : 7.0;
    final isEnemyThreshold = crop1.isPerennial || crop2.isPerennial ? 3.5 : 3.0;

    return CropCompatibility(
      crop2.name,
      totalScore,
      totalScore >= isFriendThreshold,
      totalScore <= isEnemyThreshold,
      _generateReasons(crop1, crop2, nutrientScore, envScore, growthScore, bioticScore, totalScore),
    );
  }

  double _calculateNutrientScore(CropData crop1, CropData crop2) {
    final nutrients = ['N', 'P', 'K'];
    double diff = nutrients
        .map((n) => (crop1.nutrients[n] ?? 0.0) - (crop2.nutrients[n] ?? 0.0).abs())
        .reduce((a, b) => a + b) /
        3.0;
    double score = (1.0 - diff / 3.0) * 10.0;

    if (crop1.isNitrogenFixing && (crop2.nutrients['N'] ?? 0.0) > 2.0) score += 2.0;
    return score.clamp(0.0, 10.0);
  }

  double _calculateEnvironmentalScore(CropData crop1, CropData crop2) {
    final factors = {
      'ph': ((crop1.environment['ph'] ?? 0.0) - (crop2.environment['ph'] ?? 0.0)).abs() / 2.0,
      'temp': ((crop1.environment['temperature'] ?? 0.0) - (crop2.environment['temperature'] ?? 0.0)).abs() / 10.0,
      'humidity': ((crop1.environment['humidity'] ?? 0.0) - (crop2.environment['humidity'] ?? 0.0)).abs() / 20.0,
      'water': ((crop1.environment['water'] ?? 0.0) - (crop2.environment['water'] ?? 0.0)).abs() / 2.0,
      'rootDepth': ((crop1.rootDepth ?? 0.0) - (crop2.rootDepth ?? 0.0)).abs() / 100.0,
    };
    double avgDiff = factors.values.reduce((a, b) => a + b) / factors.length;
    double score = (1.0 - avgDiff) * 10.0;

    if (crop1.environment['soilType'] == crop2.environment['soilType']) score += 1.0;
    return score.clamp(0.0, 10.0);
  }

  double _calculateGrowthScore(CropData crop1, CropData crop2) {
    double growthDiff = (crop1.growthDuration - crop2.growthDuration).abs() / 100.0;
    double score = (1.0 - growthDiff) * 10.0;

    if (growthDiff > 0.1 && growthDiff < 0.3) score += 2.0;
    return score.clamp(0.0, 10.0);
  }

  double _calculateBioticScore(CropData crop1, CropData crop2) {
    double score = 5.0;

    if (crop1.hasAllelopathy || crop2.hasAllelopathy) score -= 3.0;
    if (crop1.pestResistance == crop2.pestResistance && crop1.pestResistance == 'high') score += 2.0;
    if (crop1.diseaseSusceptibility.any((d) => crop2.diseaseSusceptibility.contains(d))) score -= 2.0;
    if ((crop1.height ?? 0) > 150 && (crop2.height ?? 0) < 50) score += 1.5;

    return score.clamp(0.0, 10.0);
  }

  List<String> _generateReasons(
    CropData crop1,
    CropData crop2,
    double nutrientScore,
    double envScore,
    double growthScore,
    double bioticScore,
    double totalScore,
  ) {
    List<String> reasons = [];

    // Nutrient-based reasons
    final nutrientDiff = ((crop1.nutrients['N'] ?? 0.0) - (crop2.nutrients['N'] ?? 0.0).abs() +
            (crop1.nutrients['P'] ?? 0.0) - (crop2.nutrients['P'] ?? 0.0).abs() +
            (crop1.nutrients['K'] ?? 0.0) - (crop2.nutrients['K'] ?? 0.0).abs()) /
        3.0;
    if (nutrientScore > 8.0) {
      reasons.add('Highly compatible nutrient needs minimize competition.');
    } else if (nutrientScore < 3.0) {
      reasons.add('Divergent nutrient demands may deplete soil unevenly.');
    }
    if (crop1.isNitrogenFixing && (crop2.nutrients['N'] ?? 0.0) > 2.0) {
      reasons.add('Nitrogen fixation complements ${crop2.name}’s high nitrogen needs.');
    } else if (crop2.isNitrogenFixing && (crop1.nutrients['N'] ?? 0.0) > 2.0) {
      reasons.add('Nitrogen fixation supports ${crop1.name}’s nitrogen demand.');
    }

    // Environmental-based reasons
    final phDiff = ((crop1.environment['ph'] ?? 0.0) - (crop2.environment['ph'] ?? 0.0)).abs();
    final tempDiff = ((crop1.environment['temperature'] ?? 0.0) - (crop2.environment['temperature'] ?? 0.0)).abs();
    final humidityDiff = ((crop1.environment['humidity'] ?? 0.0) - (crop2.environment['humidity'] ?? 0.0)).abs();
    final waterDiff = ((crop1.environment['water'] ?? 0.0) - (crop2.environment['water'] ?? 0.0)).abs();
    final rootDepthDiff = ((crop1.rootDepth ?? 0.0) - (crop2.rootDepth ?? 0.0)).abs();

    if (envScore > 8.0) {
      reasons.add('Similar environmental needs ensure mutual thriving.');
    } else if (envScore < 3.0) {
      reasons.add('Incompatible environmental preferences hinder growth.');
    }
    if (phDiff < 0.3) reasons.add('Close soil pH preferences enhance compatibility.');
    if (phDiff > 1.0) reasons.add('Differing pH needs may stress one crop.');
    if (tempDiff < 2.0) reasons.add('Similar temperature ranges support synergy.');
    if (tempDiff > 5.0) reasons.add('Temperature mismatch disrupts growth cycles.');
    if (humidityDiff < 10.0) reasons.add('Comparable humidity needs reduce stress.');
    if (humidityDiff > 15.0) reasons.add('Humidity differences may cause imbalance.');
    if (waterDiff < 0.3) reasons.add('Similar water needs optimize irrigation.');
    if (waterDiff > 1.0) reasons.add('Differing water demands complicate management.');
    if (rootDepthDiff < 20.0) reasons.add('Similar root depths may compete for resources.');
    if (rootDepthDiff > 50.0) reasons.add('Complementary root depths reduce competition.');
    if (crop1.environment['soilType'] == crop2.environment['soilType']) {
      reasons.add('Matching soil types enhance compatibility.');
    } else {
      reasons.add('Different soil preferences may limit synergy.');
    }

    // Growth-based reasons
    final growthDiff = (crop1.growthDuration - crop2.growthDuration).abs();
    if (growthScore > 8.0) {
      reasons.add('Synchronized growth cycles improve field management.');
    } else if (growthScore < 3.0) {
      reasons.add('Divergent growth durations complicate harvesting.');
    }
    if (growthDiff > 10.0 && growthDiff < 30.0) {
      reasons.add('Staggered growth aids pest control and harvest timing.');
    }

    // Biotic-based reasons
    if (bioticScore > 8.0) {
      reasons.add('Strong biotic synergy boosts pest and disease resistance.');
    } else if (bioticScore < 3.0) {
      reasons.add('Biotic conflicts increase pest and disease risks.');
    }
    if (crop1.hasAllelopathy || crop2.hasAllelopathy) {
      reasons.add('Allelopathic effects may suppress growth.');
    }
    if (crop1.pestResistance == 'high' && crop2.pestResistance == 'high') {
      reasons.add('Shared high pest resistance strengthens resilience.');
    } else if (crop1.pestResistance == 'low' || crop2.pestResistance == 'low') {
      reasons.add('Low pest resistance in one crop increases vulnerability.');
    }
    if (crop1.diseaseSusceptibility.any((d) => crop2.diseaseSusceptibility.contains(d))) {
      reasons.add('Shared disease susceptibility heightens risk.');
    }
    if ((crop1.height ?? 0) > 150 && (crop2.height ?? 0) < 50) {
      reasons.add('Height difference optimizes light and space use.');
    } else if (((crop1.height ?? 0) - (crop2.height ?? 0)).abs() < 20) {
      reasons.add('Similar heights may lead to light competition.');
    }

    // Final compatibility context
    if (totalScore >= 7.0) {
      reasons.add('Overall strong compatibility for companion planting.');
    } else if (totalScore <= 3.0) {
      reasons.add('Overall poor compatibility; avoid planting together.');
    }

    return reasons.take(3).toList();
  }

  void _computeCompatibility() {
    final selectedCrop = _crops.firstWhere(
      (c) => c.name.toLowerCase() == widget.crop.nom.toLowerCase(),
      orElse: () => CropData.empty(),
    );

    if (selectedCrop.name.isEmpty) {
      setState(() {
        _errorMessage = 'Crop "${widget.crop.nom}" not found in database.';
        _isLoading = false;
      });
      return;
    }

    _compatibilityMap = {
      for (var crop in _crops.where((c) => c.name != selectedCrop.name))
        crop.name: _calculateCompatibility(selectedCrop, crop)
    };

    setState(() => _isLoading = false);
  }

  void _compareCrops() {
    if (_selectedCropForComparison == null) return;
    setState(() => _comparisonResult = _compatibilityMap[_selectedCropForComparison]);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Associations: ${widget.crop.nom}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Associations'),
            Tab(text: 'Compare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssociationsTab(textColor),
          _buildCompareTab(textColor),
        ],
      ),
    );
  }

  Widget _buildAssociationsTab(Color textColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    final bestFriends = _compatibilityMap.values.where((c) => c.isFriend).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final worstEnemies = _compatibilityMap.values.where((c) => c.isEnemy).toList()
      ..sort((a, b) => a.score.compareTo(b.score));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Companions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          if (bestFriends.isEmpty)
            const Text('No strong companions found.', style: TextStyle(color: Colors.grey))
          else
            ...bestFriends.take(3).map((c) => _buildCropCard(c, Colors.green, textColor)),
          const SizedBox(height: 20),
          const Text(
            'Worst Enemies',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          if (worstEnemies.isEmpty)
            const Text('No strong enemies found.', style: TextStyle(color: Colors.grey))
          else
            ...worstEnemies.take(3).map((c) => _buildCropCard(c, Colors.red, textColor)),
        ],
      ),
    );
  }

  Widget _buildCropCard(CropCompatibility crop, Color iconColor, Color textColor) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        leading: Icon(crop.isFriend ? Icons.thumb_up : Icons.thumb_down, color: iconColor),
        title: Text(crop.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        // subtitle: Text('Score: ${crop.score.toStringAsFixed(1)}', style: TextStyle(color: textColor)),
        children: crop.reasons
            .map((r) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(r, style: TextStyle(color: textColor)),
                ))
            .toList(),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () => _speak('${crop.name}: ${crop.reasons.join(" ")}'),
        ),
      ),
    );
  }

  Widget _buildCompareTab(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: _selectedCropForComparison,
            hint: const Text('Select a crop to compare'),
            isExpanded: true,
            items: _crops
                .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedCropForComparison = value),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _compareCrops,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Compare Crops', style: TextStyle(color: Colors.white),),
          ),
          if (_comparisonResult != null) ...[
            const SizedBox(height: 20),
            _buildCropCard(
              _comparisonResult!,
              _comparisonResult!.isFriend ? Colors.green : Colors.red,
              textColor,
            ),
          ],
        ],
      ),
    );
  }
}

class CropData {
  final String name;
  final Map<String, double> nutrients; // N, P, K
  final Map<String, dynamic> environment; // ph, temperature, humidity, water, soilType
  final int growthDuration; // days
  final double? rootDepth; // cm
  final bool isNitrogenFixing;
  final bool hasAllelopathy;
  final String pestResistance; // 'low', 'medium', 'high'
  final List<String> diseaseSusceptibility;
  final bool isPerennial;
  final double? height; // cm

  CropData({
    required this.name,
    required this.nutrients,
    required this.environment,
    required this.growthDuration,
    this.rootDepth,
    this.isNitrogenFixing = false,
    this.hasAllelopathy = false,
    this.pestResistance = 'medium',
    this.diseaseSusceptibility = const [],
    this.isPerennial = false,
    this.height,
  });

  factory CropData.empty() => CropData(name: '', nutrients: {}, environment: {}, growthDuration: 0);
}

class CropCompatibility {
  final String name;
  final double score;
  final bool isFriend;
  final bool isEnemy;
  final List<String> reasons;

  CropCompatibility(this.name, this.score, this.isFriend, this.isEnemy, this.reasons);
}

class CropDatabase {
  Future<List<CropData>> getCrops() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      CropData(
        name: 'Maïs',
        nutrients: {'N': 2.0, 'P': 1.5, 'K': 2.0},
        environment: {'ph': 6.0, 'temperature': 25.0, 'humidity': 80.0, 'water': 1.2, 'soilType': 'clay'},
        growthDuration: 90,
        rootDepth: 150.0,
        hasAllelopathy: true,
        pestResistance: 'high',
        height: 200.0,
        diseaseSusceptibility: ['Fusarium'],
      ),
      CropData(
        name: 'Soja',
        nutrients: {'N': 2.3, 'P': 1.6, 'K': 2.1},
        environment: {'ph': 6.2, 'temperature': 24.0, 'humidity': 75.0, 'water': 1.3, 'soilType': 'loam'},
        growthDuration: 100,
        rootDepth: 50.0,
        isNitrogenFixing: true,
        pestResistance: 'high',
        height: 80.0,
        diseaseSusceptibility: ['Phytophthora'],
      ),
      CropData(
        name: 'Wheat',
        nutrients: {'N': 2.2, 'P': 1.4, 'K': 1.8},
        environment: {'ph': 6.5, 'temperature': 20.0, 'humidity': 60.0, 'water': 1.0, 'soilType': 'loam'},
        growthDuration: 120,
        rootDepth: 100.0,
        pestResistance: 'high',
        height: 90.0,
        diseaseSusceptibility: ['Rust', 'Fusarium'],
      ),
      CropData(
        name: 'Tomato',
        nutrients: {'N': 2.5, 'P': 1.3, 'K': 2.0},
        environment: {'ph': 6.5, 'temperature': 22.0, 'humidity': 70.0, 'water': 1.5, 'soilType': 'loam'},
        growthDuration: 70,
        rootDepth: 40.0,
        pestResistance: 'medium',
        height: 150.0,
        diseaseSusceptibility: ['Blossom End Rot', 'Fusarium'],
      ),
      CropData(
        name: 'Potato',
        nutrients: {'N': 2.1, 'P': 1.7, 'K': 2.3},
        environment: {'ph': 5.8, 'temperature': 18.0, 'humidity': 75.0, 'water': 1.4, 'soilType': 'loam'},
        growthDuration: 90,
        rootDepth: 60.0,
        pestResistance: 'medium',
        height: 60.0,
        diseaseSusceptibility: ['Late Blight'],
      ),
      CropData(
        name: 'Carrot',
        nutrients: {'N': 1.8, 'P': 1.3, 'K': 1.7},
        environment: {'ph': 6.0, 'temperature': 16.0, 'humidity': 70.0, 'water': 1.1, 'soilType': 'sandy'},
        growthDuration: 80,
        rootDepth: 120.0,
        pestResistance: 'high',
        height: 30.0,
        diseaseSusceptibility: ['Root Rot'],
      ),
      CropData(
        name: 'Bean',
        nutrients: {'N': 1.9, 'P': 1.2, 'K': 1.8},
        environment: {'ph': 6.3, 'temperature': 20.0, 'humidity': 70.0, 'water': 1.1, 'soilType': 'loam'},
        growthDuration: 70,
        rootDepth: 45.0,
        isNitrogenFixing: true,
        pestResistance: 'high',
        height: 50.0,
        diseaseSusceptibility: ['Anthracnose'],
      ),
      CropData(
        name: 'Pea',
        nutrients: {'N': 1.7, 'P': 1.1, 'K': 1.6},
        environment: {'ph': 6.0, 'temperature': 18.0, 'humidity': 65.0, 'water': 1.0, 'soilType': 'sandy'},
        growthDuration: 90,
        rootDepth: 40.0,
        isNitrogenFixing: true,
        pestResistance: 'medium',
        height: 60.0,
        diseaseSusceptibility: ['Powdery Mildew'],
      ),
      CropData(
        name: 'Onion',
        nutrients: {'N': 1.6, 'P': 1.2, 'K': 1.5},
        environment: {'ph': 6.5, 'temperature': 20.0, 'humidity': 65.0, 'water': 1.0, 'soilType': 'loam'},
        growthDuration: 100,
        rootDepth: 30.0,
        pestResistance: 'high',
        height: 40.0,
        diseaseSusceptibility: ['Downy Mildew'],
      ),
      CropData(
        name: 'Rice',
        nutrients: {'N': 2.4, 'P': 1.5, 'K': 2.2},
        environment: {'ph': 5.5, 'temperature': 28.0, 'humidity': 85.0, 'water': 2.0, 'soilType': 'clay'},
        growthDuration: 110,
        rootDepth: 25.0,
        pestResistance: 'medium',
        height: 100.0,
        diseaseSusceptibility: ['Blast'],
      ),
      CropData(
        name: 'Sunflower',
        nutrients: {'N': 1.8, 'P': 1.4, 'K': 1.9},
        environment: {'ph': 6.8, 'temperature': 24.0, 'humidity': 60.0, 'water': 1.2, 'soilType': 'sandy'},
        growthDuration: 95,
        rootDepth: 180.0,
        hasAllelopathy: true,
        pestResistance: 'medium',
        height: 200.0,
        diseaseSusceptibility: ['Sclerotinia'],
      ),
      CropData(
        name: 'Cucumber',
        nutrients: {'N': 2.1, 'P': 1.4, 'K': 2.0},
        environment: {'ph': 6.0, 'temperature': 25.0, 'humidity': 80.0, 'water': 1.5, 'soilType': 'clay'},
        growthDuration: 60,
        rootDepth: 50.0,
        pestResistance: 'medium',
        height: 120.0,
        diseaseSusceptibility: ['Powdery Mildew'],
      ),
      CropData(
        name: 'Lettuce',
        nutrients: {'N': 1.5, 'P': 1.0, 'K': 1.4},
        environment: {'ph': 6.5, 'temperature': 15.0, 'humidity': 60.0, 'water': 0.8, 'soilType': 'loam'},
        growthDuration: 45,
        rootDepth: 30.0,
        pestResistance: 'low',
        height: 25.0,
        diseaseSusceptibility: ['Downy Mildew'],
      ),
    ];
  }
}