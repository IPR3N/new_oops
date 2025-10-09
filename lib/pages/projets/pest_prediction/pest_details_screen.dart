part of 'pest_prediction_screen.dart';


class PestDetailsScreen extends StatelessWidget {
  final String pest;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const PestDetailsScreen({
    required this.pest,
    required this.area,
    required this.preparationProgress,
  });

  Map<String, String> _getPestInfo(String pest) {
    // Exemple de données statiques, à remplacer par une source réelle si disponible
    final pestInfo = {
      'ants': {
        'description': 'Fourmis envahissantes qui protègent les pucerons et endommagent les racines.',
        'damage': 'Transmission de pucerons, perturbation des sols.',
      },
      'bees': {
        'description': 'Abeilles utiles mais parfois nuisibles en grand nombre près des cultures.',
        'damage': 'Peu de dégâts directs, mais peuvent gêner les travaux agricoles.',
      },
      'beetle': {
        'description': 'Coléoptères mangeurs de feuilles ou de racines.',
        'damage': 'Perforation des feuilles, réduction du rendement.',
      },
      'caterpillar': {
        'description': 'Chenilles, larves de papillons, voraces sur les feuilles.',
        'damage': 'Défoliation massive des plantes.',
      },
      'earthworms': {
        'description': 'Vers de terre généralement bénéfiques, mais parfois nuisibles en excès.',
        'damage': 'Perturbation des jeunes plants.',
      },
      'earwig': {
        'description': 'Perce-oreilles, prédateurs utiles mais parfois nuisibles.',
        'damage': 'Mange les jeunes pousses et fleurs.',
      },
      'grasshopper': {
        'description': 'Sauterelles herbivores destructrices.',
        'damage': 'Consommation rapide des feuilles.',
      },
      'moth': {
        'description': 'Papillons dont les larves attaquent les cultures.',
        'damage': 'Trous dans les feuilles, fruits endommagés.',
      },
      'slug': {
        'description': 'Limaces, actives la nuit, mangeuses de tissus tendres.',
        'damage': 'Feuilles et fruits rongés.',
      },
      'snail': {
        'description': 'Escargots similaires aux limaces, mais avec coquille.',
        'damage': 'Dégâts sur feuillage et jeunes plants.',
      },
      'wasp': {
        'description': 'Guêpes prédatrices mais parfois nuisibles.',
        'damage': 'Attaques sur fruits mûrs.',
      },
      'weevil': {
        'description': 'Charançons attaquant graines et racines.',
        'damage': 'Perte de graines, racines endommagées.',
      },
    };
    return pestInfo[pest.toLowerCase()] ?? {
      'description': 'Informations non disponibles pour ce ravageur.',
      'damage': 'Dégâts non spécifiés.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final pestInfo = _getPestInfo(pest);

    return Scaffold(
      appBar: AppBar(
        title: Text(pest, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Superficie affectée: $area m²",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[800]),
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
                      pestInfo['description']!,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Dégâts",
                      style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pestInfo['damage']!,
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