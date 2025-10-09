part of 'pest_prediction_screen.dart';

class ChemicalSolutionPage extends StatelessWidget {
  final String pest;
  final double area;

 ChemicalSolutionPage({required this.pest, required this.area});

  final Map<String, Map<String, dynamic>> chemicalSolutions = {
    'ants': {'name': 'Fipronil (0.01%)', 'dosagePerM2': 1.0, 'unit': 'g', 'posologie': 'Appâts autour des nids'},
    'bees': {'name': 'Perméthrine (0.1%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Spray sur le nid, de nuit'},
    'beetle': {'name': 'Deltaméthrine (0.025%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Spray sur le feuillage'},
    'caterpillar': {'name': 'Spinosad (0.5%)', 'dosagePerM2': 5.0, 'unit': 'mL', 'posologie': 'Spray sur le feuillage'},
    'earthworms': {'name': 'Aucun', 'dosagePerM2': 0.0, 'unit': '-', 'posologie': 'Pas de traitement'},
    'earwig': {'name': 'Cyfluthrine (0.03%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Spray ciblé'},
    'grasshopper': {'name': 'Malathion (0.5%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Spray à large spectre'},
    'moth': {'name': 'Spinosad (0.5%)', 'dosagePerM2': 5.0, 'unit': 'mL', 'posologie': 'Spray sur les larves'},
    'slug': {'name': 'Phosphate de Fer (1%)', 'dosagePerM2': 5.0, 'unit': 'g', 'posologie': 'Granulés autour des plantes'},
    'snail': {'name': 'Métaldéhyde (3-5%)', 'dosagePerM2': 5.0, 'unit': 'g', 'posologie': 'Granulés autour des plantes'},
    'wasp': {'name': 'Perméthrine (0.1%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Spray sur le nid'},
    'weevil': {'name': 'Imidaclopride (0.03%)', 'dosagePerM2': 10.0, 'unit': 'mL', 'posologie': 'Arrosage ou spray'},
  };

  @override
  Widget build(BuildContext context) {
    final solution = chemicalSolutions[pest.toLowerCase()]!;
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
            Text(
              "Nom: ${solution['name']}",
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            Text(
              "Dosage pour $area m²: ${totalDosage.toStringAsFixed(2)} ${solution['unit']}",
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            Text(
              "Posologie: ${solution['posologie']}",
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Fermer", style: GoogleFonts.roboto(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}