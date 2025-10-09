part of 'pest_prediction_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:google_fonts/google_fonts.dart';

class TutorialPage extends StatefulWidget {
  final Function onComplete;

  const TutorialPage({required this.onComplete});

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final List<String> tutorialSteps = [
    "Use the camera button to take a photo of a pest on your plants. Focus on the pest itself.",
    "Upload an existing pest image from your gallery using the gallery button.",
    "See the predicted pest with a confidence score and get pest control advice.",
    "Listen to results using the Play button. Pause or stop as needed.",
    "Choose how to eradicate the pest: chemical or natural method.",
    "For natural methods, follow step-by-step preparation with real-time tracking.",
    "Resume unfinished preparations anytime from the history.",
    "Click 'Learn More' for detailed pest info and external resources.",
  ];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-US');
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
        return Icons.photo_library;
      case 2:
        return Icons.analytics;
      case 3:
        return Icons.volume_up;
      case 4:
        return Icons.science;
      case 5:
        return Icons.timer;
      case 6:
        return Icons.history;
      case 7:
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _getTitleForStep(int index) {
    switch (index) {
      case 0:
        return "Step 1: Capture an Image";
      case 1:
        return "Step 2: Upload from Gallery";
      case 2:
        return "Step 3: Analyze Results";
      case 3:
        return "Step 4: Use Voice Controls";
      case 4:
        return "Step 5: Choose Eradication Method";
      case 5:
        return "Step 6: Prepare Step-by-Step";
      case 6:
        return "Step 7: Resume Preparations";
      case 7:
        return "Step 8: Learn More";
      default:
        return "Unknown Step";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.withOpacity(0.9), Colors.blueAccent.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
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
                          Icon(_getIconForStep(index), size: 60, color: Colors.white),
                          const SizedBox(height: 20),
                          Text(
                            _getTitleForStep(index),
                            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tutorialSteps[index],
                            style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
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
                            child: Text("Previous", style: GoogleFonts.roboto(color: Colors.white)),
                          ),
                        TextButton(
                          onPressed: () async {
                            await _flutterTts.stop();
                            await widget.onComplete();
                            Navigator.pop(context);
                          },
                          child: Text("Skip", style: GoogleFonts.roboto(color: Colors.white)),
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
                        _currentPage < tutorialSteps.length - 1 ? "Next" : "Commencer",
                        style: GoogleFonts.roboto(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}