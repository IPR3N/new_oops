part of 'disease_prediction_screen.dart';

class ChemicalSolutionPage extends StatelessWidget {
  final String disease;
  final double area;
  final String crop;

  ChemicalSolutionPage({required this.disease, required this.area, required this.crop});

  final Map<String, Map<String, dynamic>> chemicalSolutions = {
    'Pepper__bell___Bacterial_spot': {'name': 'Bouillie bordelaise', 'dosagePerM2': 10.0, 'unit': 'g', 'posologie': 'Diluer dans l’eau et pulvériser sur le feuillage'},
    'Potato___Early_blight': {'name': 'Mancozèbe', 'dosagePerM2': 5.0, 'unit': 'g', 'posologie': 'Appliquer tous les 7-10 jours'},
    'Potato___Late_blight': {'name': 'Chlorothalonil', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Pulvériser dès les premiers symptômes'},
    'Tomato_Bacterial_spot': {'name': 'Hydroxyde de cuivre', 'dosagePerM2': 8.0, 'unit': 'g', 'posologie': 'Pulvériser hebdomadairement'},
    'Tomato_Early_blight': {'name': 'Azoxystrobine', 'dosagePerM2': 5.0, 'unit': 'mL', 'posologie': 'Appliquer au début de l’infection'},
    'Tomato_Late_blight': {'name': 'Fosétyl-Aluminium', 'dosagePerM2': 10.0, 'unit': 'g', 'posologie': 'Pulvériser en préventif'},
    'Tomato_Leaf_Mold': {'name': 'Tébuconazole', 'dosagePerM2': 5.0, 'unit': 'mL', 'posologie': 'Traiter toutes les 2 semaines'},
    'Tomato_Septoria_leaf_spot': {'name': 'Chlorothalonil', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Appliquer après la pluie'},
    'Tomato_Spider_mites_Two_spotted_spider_mite': {'name': 'Abamectine', 'dosagePerM2': 2.0, 'unit': 'mL', 'posologie': 'Pulvériser sous les feuilles'},
    'Tomato__Target_Spot': {'name': 'Difenoconazole', 'dosagePerM2': 5.0, 'unit': 'mL', 'posologie': 'Appliquer tous les 10 jours'},
  };

  @override
  Widget build(BuildContext context) {
    final solution = chemicalSolutions[disease] ?? {'name': 'Non disponible', 'dosagePerM2': 0.0, 'unit': '-', 'posologie': 'Consultez un expert'};
    final totalDosage = solution['dosagePerM2'] * area;

    return Scaffold(
      appBar: AppBar(
        title: Text("Solution Chimique", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Culture: $crop", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Superficie: $area m²", style: GoogleFonts.roboto(fontSize: 16)),
            SizedBox(height: 10),
            Text("Produit: ${solution['name']}", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Dosage total: ${totalDosage.toStringAsFixed(2)} ${solution['unit']}", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Posologie: ${solution['posologie']}", style: GoogleFonts.roboto(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text("Fermer", style: GoogleFonts.roboto(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}