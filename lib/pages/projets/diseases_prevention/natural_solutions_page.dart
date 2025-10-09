part of 'disease_prediction_screen.dart';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:new_oppsfarm/pages/projets/diseases_prevention/disease_prediction_screen.dart';

class NaturalSolutionsPage extends StatelessWidget {
  final String disease;
  final double area;
  final String crop;
  final Map<String, Map<String, dynamic>> preparationProgress;

  NaturalSolutionsPage({
    required this.disease,
    required this.area,
    required this.crop,
    required this.preparationProgress,
  });

  final Map<String, List<String>> naturalSolutions = {
    'Pepper__bell___Bacterial_spot': ['Infusion d’Ail', 'Huile de Neem'],
    'Potato___Early_blight': ['Infusion de Prêle', 'Bicarbonate de Soude'],
    'Potato___Late_blight': ['Infusion d’Ail', 'Trichoderma'],
    'Tomato_Bacterial_spot': ['Infusion d’Ail', 'Huile de Neem'],
    'Tomato_Early_blight': ['Bicarbonate de Soude', 'Infusion de Prêle'],
    'Tomato_Late_blight': ['Infusion d’Ail', 'Trichoderma'],
    'Tomato_Leaf_Mold': ['Bicarbonate de Soude', 'Huile de Neem'],
    'Tomato_Septoria_leaf_spot': ['Infusion de Prêle', 'Bicarbonate de Soude'],
    'Tomato_Spider_mites_Two_spotted_spider_mite': ['Huile de Neem', 'Savon Insecticide'],
    'Tomato__Target_Spot': ['Infusion d’Ail', 'Bicarbonate de Soude'],
  };

  @override
  Widget build(BuildContext context) {
    final solutions = naturalSolutions[disease] ?? ['Aucune solution disponible'];
    final prepKey = 'prep_$disease';

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
            Text("Culture: $crop", style: GoogleFonts.roboto(fontSize: 16)),
            Text("Superficie: $area m²", style: GoogleFonts.roboto(fontSize: 16)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: solutions.length + (preparationProgress.containsKey(prepKey) ? 1 : 0),
               itemBuilder: (context, index) {
  if (index < solutions.length) {
    bool isNoSolution = solutions[index] == "Aucune solution disponible";

    return ListTile(
      title: Text(solutions[index], style: GoogleFonts.roboto()),
      onTap: isNoSolution
          ? null // Désactive le clic si aucune solution
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipePreparationPage(
                  disease: disease,
                  solution: solutions[index],
                  area: area,
                  crop: crop,
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
            disease: disease,
            solution: prep['solution'],
            area: area,
            crop: crop,
            preparationProgress: preparationProgress,
          ),
        ),
      ),
    );
  }
}

              ),
            ),
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