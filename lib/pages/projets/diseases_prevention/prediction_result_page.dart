part of 'disease_prediction_screen.dart';

class PredictionResultPage extends StatefulWidget {
  final String disease;
  final String confidence;
  final File image;
  final ProjectModel project;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const PredictionResultPage({
    required this.disease,
    required this.confidence,
    required this.image,
    required this.project,
    required this.preparationProgress,
  });

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  String _getFormattedDiseaseName(String disease) {
    return disease.replaceAll('___', ' ').replaceAll('_', ' ').trim();
  }

  String _getDiseaseAdvice(String disease) {
    // Simple logique d'exemple pour les conseils, à personnaliser selon vos besoins
    switch (disease.toLowerCase()) {
      case 'tomato bacterial spot':
        return "Tache bactérienne détectée. Choisissez une méthode pour traiter.";
      case 'tomato early blight':
        return "Mildiou précoce détecté. Choisissez une méthode pour traiter.";
      case 'tomato late blight':
        return "Mildiou tardif détecté. Choisissez une méthode pour traiter.";
      default:
        return "Maladie détectée. Choisissez une méthode pour traiter.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDisease = _getFormattedDiseaseName(widget.disease);
    final advice = _getDiseaseAdvice(widget.disease);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? green : green;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Résultat de la Prédiction",
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(widget.image,
                    height: 150, width: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 15),
              Text(
                "$formattedDisease (${widget.confidence}%)",
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                advice,
                style: GoogleFonts.roboto(fontSize: 16, color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow,
                        size: 40, color: Colors.blue),
                    onPressed: () async {
                      if (_isSpeaking) {
                        await _flutterTts.pause();
                        setState(() => _isSpeaking = false);
                      } else {
                        await _flutterTts.speak(
                            "$formattedDisease avec une confiance de ${widget.confidence} pour cent. $advice");
                        setState(() => _isSpeaking = true);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 40, color: Colors.red),
                    onPressed: () async {
                      await _flutterTts.stop();
                      setState(() => _isSpeaking = false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiseaseDetailsScreen(
                      disease: widget.disease,
                      crop: widget.project.crop.nom,
                      area: widget.project.estimatedQuantityProduced.toDouble(),
                      preparationProgress: widget.preparationProgress,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Détails de la Maladie",
                    style:
                        GoogleFonts.roboto(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EradicationMethodsPage(
                      disease: widget.disease,
                      area: widget.project.estimatedQuantityProduced.toDouble(),
                      preparationProgress: widget.preparationProgress,
                    ),
                  ),
                ),
                child: Text("Comment traiter ?",
                    style: GoogleFonts.roboto(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Retour",
                    style: GoogleFonts.roboto(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
