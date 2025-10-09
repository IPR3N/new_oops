part of 'pest_prediction_screen.dart';

class NaturalSolutionsPage extends StatelessWidget {
  final String pest;
  final double area;
  final Map<String, Map<String, dynamic>> preparationProgress;
  NaturalSolutionsPage({
    required this.pest,
    required this.area,
    required this.preparationProgress,
  });

  final Map<String, List<String>> naturalSolutions = {
    'ants': ['Infusion de Feuilles de Neem', 'Mélange Borax-Sucre', 'Poudre de Piment'],
    'bees': ['Infusion de Feuilles de Tabac', 'Huile Essentielle de Citronnelle'],
    'beetle': ['Infusion de Feuilles de Neem', 'Terre de Diatomées', 'Poudre de Piment'],
    'caterpillar': ['Infusion de Feuilles de Neem', 'Poudre de Piment', 'Infusion d’Ail'],
    'earthworms': ['Poudre de Piment'],
    'earwig': ['Infusion de Feuilles de Tabac', 'Terre de Diatomées'],
    'grasshopper': ['Infusion de Feuilles de Neem', 'Poudre de Piment', 'Infusion d’Ail'],
    'moth': ['Infusion de Feuilles de Neem', 'Poudre de Piment', 'Huile Essentielle de Lavande'],
    'slug': ['Infusion de Feuilles de Tabac', 'Terre de Diatomées', 'Piège à Bière'],
    'snail': ['Infusion de Feuilles de Tabac', 'Terre de Diatomées', 'Poudre de Piment'],
    'wasp': ['Infusion de Feuilles de Tabac', 'Poudre de Piment', 'Piège Sucre-Vinaigre'],
    'weevil': ['Infusion de Feuilles de Neem', 'Terre de Diatomées', 'Infusion d’Ail'],
  };

  @override
  Widget build(BuildContext context) {
    final solutions = naturalSolutions[pest.toLowerCase()]!;
    final prepKey = 'prep_$pest';

    return Scaffold(
      appBar: AppBar(
        title: Text("Solutions Naturelles", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: solutions.length + (preparationProgress.containsKey(prepKey) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < solutions.length) {
                    return ListTile(
                      title: Text(solutions[index], style: GoogleFonts.roboto()),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipePreparationPage(
                            pest: pest,
                            solution: solutions[index],
                            area: area,
                            preparationProgress: preparationProgress,
                          ),
                        ),
                      ),
                    );
                  } else {
                    final prep = preparationProgress[prepKey]!;
                    return ListTile(
                      title: Text("Reprendre ${prep['solution']}", style: GoogleFonts.roboto()),
                      subtitle: Text("Étape ${prep['currentStep'] + 1} en attente"),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipePreparationPage(
                            pest: pest,
                            solution: prep['solution'],
                            area: area,
                            preparationProgress: preparationProgress,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
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