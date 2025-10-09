part of 'disease_prediction_screen.dart';

class EradicationMethodsPage extends StatelessWidget {
  final String disease;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;

  const EradicationMethodsPage({
    required this.disease,
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
                  builder: (context) => ChemicalSolutionPage(
                    disease: disease,
                    area: area,
                    crop: "", // Vous pouvez passer widget.project.crop.nom si nécessaire
                  ),
                ),
              ),
              child: Text("Solution Chimique", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NaturalSolutionsPage(
                    disease: disease,
                    area: area,
                    crop: "", // Vous pouvez passer widget.project.crop.nom si nécessaire
                    preparationProgress: preparationProgress,
                  ),
                ),
              ),
              child: Text("Solution Naturelle", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}