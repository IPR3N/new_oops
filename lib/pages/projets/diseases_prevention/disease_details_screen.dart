part of 'disease_prediction_screen.dart';



class DiseaseDetailsScreen extends StatelessWidget {
  final String disease;
  final String crop;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const DiseaseDetailsScreen({
    required this.disease,
    required this.crop,
    required this.area,
    required this.preparationProgress,
  });

  String _getFormattedDiseaseName(String disease) {
    return disease.replaceAll('___', ' ').replaceAll('_', ' ').trim();
  }

  Map<String, String> _getDiseaseInfo(String disease) {
    // Exemple de données statiques, à remplacer par une source réelle si disponible
    final diseaseInfo = {
      'tomato bacterial spot': {
        'description': 'Maladie bactérienne causée par Xanthomonas spp., affectant les feuilles et les fruits.',
        'symptoms': 'Taches sombres avec halos jaunes sur les feuilles, fruits tachés.',
      },
      'tomato early blight': {
        'description': 'Maladie fongique causée par Alternaria solani, courante en climat humide.',
        'symptoms': 'Taches concentriques brunes/noires sur les feuilles inférieures.',
      },
      'tomato late blight': {
        'description': 'Maladie fongique grave causée par Phytophthora infestans.',
        'symptoms': 'Taches irrégulières vertes à brunes, pourriture des fruits.',
      },
    };
    return diseaseInfo[disease.toLowerCase()] ?? {
      'description': 'Informations non disponibles pour cette maladie.',
      'symptoms': 'Symptômes non spécifiés.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final formattedDisease = _getFormattedDiseaseName(disease);
    final diseaseInfo = _getDiseaseInfo(disease);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? green : green;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.grey[100];
    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDisease, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: textColor)),  
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Culture: $crop",
              style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              "Superficie: $area m²",
              style: GoogleFonts.roboto(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      diseaseInfo['description']!,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Symptômes",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      diseaseInfo['symptoms']!,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),            
              ),
          ],
        ),
      ),
    );
  }
}