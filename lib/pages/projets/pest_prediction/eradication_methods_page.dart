part of 'pest_prediction_screen.dart';

class EradicationMethodsPage extends StatelessWidget {
  final String pest;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const EradicationMethodsPage({
    required this.pest,
    required this.area,
    required this.preparationProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choisissez une méthode", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChemicalSolutionPage(pest: pest, area: area),
                ),
              ),
              child: Text("Produit Chimique", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NaturalSolutionsPage(
                    pest: pest,
                    area: area,
                    preparationProgress: preparationProgress,
                  ),
                ),
              ),
              child: Text("Produit Naturel", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 10),
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