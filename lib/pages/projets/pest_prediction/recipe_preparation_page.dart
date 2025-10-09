part of 'pest_prediction_screen.dart';



class RecipePreparationPage extends StatefulWidget {
  final String pest;
  final String solution;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const RecipePreparationPage({
    required this.pest,
    required this.solution,
    required this.area,
    required this.preparationProgress,
  });

  @override
  _RecipePreparationPageState createState() => _RecipePreparationPageState();
}

class _RecipePreparationPageState extends State<RecipePreparationPage> with SingleTickerProviderStateMixin {
  int currentStep = 0;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isStepStarted = false;
  DateTime? _stepStartTime;
  late AnimationController _animationController;
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    final prepKey = 'prep_${widget.pest}';
    if (widget.preparationProgress.containsKey(prepKey)) {
      currentStep = widget.preparationProgress[prepKey]!['currentStep'];
      _stepStartTime = DateTime.parse(widget.preparationProgress[prepKey]!['startTime'].toString());
      if (_stepStartTime != null) {
        _resumeTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPreparation(String solution, List<Map<String, dynamic>> steps) {
    if (currentStep >= steps.length) {
      _completePreparation();
      return;
    }

    final prepKey = 'prep_${widget.pest}';
    final step = steps[currentStep];
    _remainingTime = step['duration'] as Duration;

    widget.preparationProgress[prepKey] = {
      'pest': widget.pest,
      'solution': solution,
      'currentStep': currentStep,
      'startTime': DateTime.now().toIso8601String(),
      'steps': steps,
    };
    _savePreparationProgress();

    _speakStepInstructions(step['description']);
    _startStepTimer();
  }

  void _startStepTimer() {
    setState(() {
      _isStepStarted = true;
      _stepStartTime = DateTime.now();
      _animationController.duration = recipes[widget.solution]!['steps'][currentStep]['duration'] as Duration;
      _animationController.reset();
      _animationController.forward();
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final elapsed = DateTime.now().difference(_stepStartTime!);
        _remainingTime = (recipes[widget.solution]!['steps'][currentStep]['duration'] as Duration) - elapsed;
        if (_remainingTime <= Duration.zero) {
          _timer?.cancel();
          _animationController.stop();
          _playCompletionSound();
          _showStepCompleteDialog();
        }
      });
    });
  }

  void _resumeTimer() {
    final stepDuration = recipes[widget.solution]!['steps'][currentStep]['duration'] as Duration;
    final elapsed = DateTime.now().difference(_stepStartTime!);
    _remainingTime = stepDuration - elapsed;

    if (_remainingTime <= Duration.zero) {
      _showStepCompleteDialog();
    } else {
      setState(() {
        _isStepStarted = true;
        _animationController.duration = stepDuration;
        _animationController.forward(from: elapsed.inSeconds / stepDuration.inSeconds);
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

  void _pauseTimer() {
    _timer?.cancel();
    _animationController.stop();
    setState(() => _isStepStarted = false);
    _savePreparationProgress();
  }

  void _resetPreparation() {
    _timer?.cancel();
    _animationController.reset();
    setState(() {
      currentStep = 0;
      _isStepStarted = false;
      _stepStartTime = null;
      _remainingTime = Duration.zero;
    });
    final prepKey = 'prep_${widget.pest}';
    widget.preparationProgress.remove(prepKey);
    _savePreparationProgress();
  }

  void _previousStep(List<Map<String, dynamic>> steps) {
    if (currentStep > 0) {
      _timer?.cancel();
      _animationController.reset();
      setState(() {
        currentStep--;
        _isStepStarted = false;
        _stepStartTime = null;
        _remainingTime = steps[currentStep]['duration'] as Duration;
      });
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
              });
              _startPreparation(widget.solution, List<Map<String, dynamic>>.from(recipes[widget.solution]!['steps']));
            },
            child: Text("Oui", style: GoogleFonts.roboto(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Non", style: GoogleFonts.roboto(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _completePreparation() {
    final prepKey = 'prep_${widget.pest}';
    widget.preparationProgress.remove(prepKey);
    _savePreparationProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Préparation de ${widget.solution} terminée !")),
    );
    Navigator.pop(context);
  }

  Future<void> _savePreparationProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final prepKey = 'prep_${widget.pest}';
    if (widget.preparationProgress.containsKey(prepKey)) {
      final prep = widget.preparationProgress[prepKey]!;
      final data = "${prep['pest']}|${prep['solution']}|${prep['currentStep']}|${prep['startTime']}";
      await prefs.setString(prepKey, data);
    } else {
      await prefs.remove(prepKey);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00";
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _speakStepInstructions(String instruction) async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(instruction);
  }

  Future<void> _playCompletionSound() async {
    await _audioPlayer.play(AssetSource('sounds/complete.mp3')); // Ajoutez un fichier sonore dans assets
  }

  @override
  Widget build(BuildContext context) {
    final recipe = recipes[widget.solution]!;
    final totalVolume = recipe['dosagePerM2'] * widget.area / 1000;
    final steps = List<Map<String, dynamic>>.from(recipe['steps']);
    final componentsAdjusted = recipe['components'].map((comp) {
      double adjustedAmount = comp['perLitre'] ? comp['baseAmount'] * totalVolume : comp['baseAmount'];
      return "${comp['name']}: ${adjustedAmount.toStringAsFixed(2)} ${comp['unit']}";
    }).join('\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.solution, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Superficie: ${widget.area} m²", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Volume total: ${totalVolume.toStringAsFixed(2)} L", style: GoogleFonts.roboto(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Composants:\n$componentsAdjusted", style: GoogleFonts.roboto(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Recette: ${recipe['recipe']}", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Application: ${recipe['application']}", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Précaution: ${recipe['precaution']}", style: GoogleFonts.roboto(fontSize: 16)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: steps.isEmpty ? 0 : currentStep / steps.length,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            if (currentStep < steps.length) ...[
              Text(
                "Étape ${currentStep + 1}/${steps.length}: ${steps[currentStep]['description']}",
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
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
                          value: _isStepStarted ? 1 - (_remainingTime.inSeconds / (steps[currentStep]['duration'] as Duration).inSeconds) : 0,
                          strokeWidth: 8,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        _formatDuration(_isStepStarted ? _remainingTime : steps[currentStep]['duration']),
                        style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: currentStep > 0
                        ? () => _previousStep(steps)
                        : null,
                    child: Icon(Icons.skip_previous, color: Colors.white),
                    // label: Text("Précédente", style: GoogleFonts.roboto(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isStepStarted
                        ? _pauseTimer
                        : () => _startPreparation(widget.solution, steps),
                    icon: Icon(_isStepStarted ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    label: Text(_isStepStarted ? "Pause" : "Démarrer", style: GoogleFonts.roboto(color: Colors.white)),
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
                            });
                            _startPreparation(widget.solution, steps);
                          }
                        : null,
                    child: Icon(Icons.skip_next, color: Colors.white),
                    // label: Text("Suivante", style: GoogleFonts.roboto(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                "Préparation terminée !",
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetPreparation,
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text("Réinitialiser", style: GoogleFonts.roboto(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                  label: Text("Fermer", style: GoogleFonts.roboto(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}