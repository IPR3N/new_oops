part of 'disease_prediction_screen.dart';

class TutorialPage extends StatefulWidget {
  final Function onComplete;

  const TutorialPage({required this.onComplete});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  final List<String> tutorialSteps = [
    "Prenez une photo de la plante malade avec le bouton caméra.",
    "Voyez la maladie prédite avec un pourcentage de confiance.",
    "Choisissez une méthode d'éradication : chimique ou naturelle.",
    "Pour les solutions chimiques, suivez les dosages adaptés à votre terrain.",
    "Pour les solutions naturelles, préparez étape par étape avec des instructions claires.",
    "Reprenez les préparations en cours depuis l’historique.",
  ];

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIconForStep(int index) {
    switch (index) {
      case 0:
        return Icons.camera_alt;
      case 1:
        return Icons.analytics;
      case 2:
        return Icons.science;
      case 3:
        return Icons.local_pharmacy;
      case 4:
        return Icons.timer;
      case 5:
        return Icons.history;
      default:
        return Icons.help;
    }
  }

  String _getTitleForStep(int index) {
    switch (index) {
      case 0:
        return "Étape 1 : Capturer une image";
      case 1:
        return "Étape 2 : Voir le résultat";
      case 2:
        return "Étape 3 : Choisir une méthode";
      case 3:
        return "Étape 4 : Solution chimique";
      case 4:
        return "Étape 5 : Solution naturelle";
      case 5:
        return "Étape 6 : Reprendre une préparation";
      default:
        return "Étape inconnue";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: tutorialSteps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIconForStep(index), size: 60, color: Colors.green),
                        SizedBox(height: 20),
                        Text(
                          _getTitleForStep(index),
                          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          tutorialSteps[index],
                          style: GoogleFonts.roboto(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow, color: Colors.blue),
                              onPressed: () async {
                                if (_isSpeaking) {
                                  await _flutterTts.pause();
                                  setState(() => _isSpeaking = false);
                                } else {
                                  await _flutterTts.speak(tutorialSteps[index]);
                                  setState(() => _isSpeaking = true);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop, color: Colors.red),
                              onPressed: () async {
                                await _flutterTts.stop();
                                setState(() => _isSpeaking = false);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                          child: Text("Précédent", style: GoogleFonts.roboto()),
                        ),
                      TextButton(
                        onPressed: () async {
                          await _flutterTts.stop();
                          await widget.onComplete();
                          Navigator.pop(context);
                        },
                        child: Text("Passer", style: GoogleFonts.roboto()),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _currentPage < tutorialSteps.length - 1
                        ? () {
                            _flutterTts.stop();
                            _pageController.nextPage(
                                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          }
                        : () async {
                            await _flutterTts.stop();
                            await widget.onComplete();
                            Navigator.pop(context);
                          },
                    child: Text(
                      _currentPage < tutorialSteps.length - 1 ? "Suivant" : "Commencer",
                      style: GoogleFonts.roboto(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}