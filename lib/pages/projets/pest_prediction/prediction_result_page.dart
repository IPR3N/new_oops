part of 'pest_prediction_screen.dart';

class PredictionResultPage extends ConsumerStatefulWidget {
  final String pest;
  final String advice;
  final File image;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const PredictionResultPage({
    required this.pest,
    required this.advice,
    required this.image,
    required this.area,
    required this.preparationProgress,
  });

  @override
  ConsumerState<PredictionResultPage> createState() =>
      _PredictionResultPageState();
}

class _PredictionResultPageState extends ConsumerState<PredictionResultPage> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    final locale = ref.read(localeProvider).languageCode;
    await _flutterTts.setLanguage(locale == 'fr' ? 'fr-FR' : 'en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _launchPestResource(String pest) async {
    final urlMap = {
      'ants': 'https://www.cabi.org/isc/datasheet/113050',
      'bees': 'https://www.cabi.org/isc/datasheet/109147',
      'beetle': 'https://www.cabi.org/isc/datasheet/10888',
      'caterpillar': 'https://www.cabi.org/isc/datasheet/31826',
      'earthworms': 'https://www.cabi.org/isc/datasheet/108529',
      'earwig': 'https://www.cabi.org/isc/datasheet/21908',
      'grasshopper': 'https://www.cabi.org/isc/datasheet/35643',
      'moth': 'https://www.cabi.org/isc/datasheet/31826',
      'slug': 'https://www.cabi.org/isc/datasheet/108086',
      'snail': 'https://www.cabi.org/isc/datasheet/108086',
      'wasp': 'https://www.cabi.org/isc/datasheet/109148',
      'weevil': 'https://www.cabi.org/isc/datasheet/10887',
    };
    final url =
        Uri.parse(urlMap[pest.toLowerCase()] ?? 'https://www.cabi.org/isc');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocales.getTranslation(
                'link_error', ref.read(localeProvider).languageCode))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? green : green;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocales.getTranslation('prediction_result_title', locale),
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: textColor)),
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
                widget.pest,
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.advice,
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
                        await _flutterTts
                            .speak("${widget.pest}. ${widget.advice}");
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
                    builder: (context) => PestDetailsScreen(
                      pest: widget.pest,
                      area: widget.area,
                      preparationProgress: widget.preparationProgress,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Détails du Ravageur",
                    style: GoogleFonts.roboto(color: Colors.white)),
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
                      pest: widget.pest,
                      area: widget.area,
                      preparationProgress: widget.preparationProgress,
                    ),
                  ),
                ),
                child: Text("Comment éradiquer ?",
                    style: GoogleFonts.roboto(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _launchPestResource(widget.pest),
                child: Text(AppLocales.getTranslation('learn_more', locale),
                    style: GoogleFonts.roboto(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
