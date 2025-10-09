// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';

// // class AddProjetTrans extends StatefulWidget {
// //   const AddProjetTrans({super.key});

// //   @override
// //   State<AddProjetTrans> createState() => _AddProjetTransState();
// // }

// // class _AddProjetTransState extends State<AddProjetTrans> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Créer un Projet de transformation', style: TextStyle(fontSize: 20),),
// //       ),
// //       body: const Center(
// //         child: Text('Ajouter un projet'),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class AddProjetTrans extends StatefulWidget {
//   const AddProjetTrans({super.key});

//   @override
//   State<AddProjetTrans> createState() => _AddProjetTransState();
// }

// class _AddProjetTransState extends State<AddProjetTrans> {
//   final _formKey = GlobalKey<FormState>();
//   final _projectNameController = TextEditingController();
//   final _projectDescriptionController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   String? _selectedTransformationType; // Variable to store the selected value

//   Widget _buildDropdownTypeTransformation() {
//     // List of transformation types
//     final List<String> transformationTypes = [
//       'Digital Transformation',
//       'Business Process Reengineering',
//       'Organizational Change',
//       'Technology Upgrade',
//       'Other',
//     ];

//     return DropdownButtonFormField<String>(
//       value: _selectedTransformationType,
//       decoration: InputDecoration(
//         labelText: 'Type de transformation',
//         border: OutlineInputBorder(),
//       ),
//       items: transformationTypes.map((String type) {
//         return DropdownMenuItem<String>(
//           value: type,
//           child: Text(type),
//         );
//       }).toList(),
//       onChanged: (String? newValue) {
//         setState(() {
//           _selectedTransformationType = newValue;
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Veuillez sélectionner un type de transformation';
//         }
//         return null;
//       },
//     );
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Process the form data
//       final projectName = _projectNameController.text;
//       final projectDescription = _projectDescriptionController.text;

//       // You can now use the projectName, projectDescription, _startDate, and _endDate
//       // to create a new project or send the data to an API, etc.
//       print('Project Name: $projectName');
//       print('Project Description: $projectDescription');
//       print('Start Date: $_startDate');
//       print('End Date: $_endDate');

//       // Optionally, you can navigate to another screen or show a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Projet "$projectName" créé avec succès!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Créer un Projet de transformation',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _projectNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Nom du projet',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Veuillez entrer un nom de projet';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _projectDescriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description du projet',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Veuillez entrer une description du projet';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               _buildDropdownTypeTransformation(), // Add the dropdown here
//               SizedBox(height: 24),
//               SizedBox(height: 16),
//               Row(
//                 children: [
//                   Text('Date de début: '),
//                   TextButton(
//                     onPressed: () => _selectDate(context, true),
//                     child: Text(
//                       _startDate == null
//                           ? 'Sélectionner une date'
//                           : '${_startDate!.toLocal()}'.split(' ')[0],
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   const Text('Date de fin: '),
//                   TextButton(
//                     onPressed: () => _selectDate(context, false),
//                     child: Text(
//                       _endDate == null
//                           ? 'Sélectionner une date'
//                           : '${_endDate!.toLocal()}'.split(' ')[0],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitForm,
//                   child: const Text('Créer le projet'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddProjetTrans extends StatefulWidget {
  const AddProjetTrans({super.key});

  @override
  State<AddProjetTrans> createState() => _AddProjetTransState();
}

class _AddProjetTransState extends State<AddProjetTrans> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _quantityController = TextEditingController(); // Contrôleur pour la quantité
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProduct;
  String? _selectedProductVariety;
  String? _selectedPackagingType;
  List<String> _productVarieties = []; // Liste dynamique basée sur le produit sélectionné

  // Données simulées pour les produits et leurs variétés
  final Map<String, List<String>> _productData = {
    'Produit A': ['Variété A1', 'Variété A2', 'Variété A3'],
    'Produit B': ['Variété B1', 'Variété B2'],
    'Produit C': ['Variété C1', 'Variété C2', 'Variété C3', 'Variété C4'],
    'Produit D': ['Variété D1'],
  };

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildDropdownProduit() {
    final List<String> produits = _productData.keys.toList();

    return DropdownButtonFormField<String>(
      value: _selectedProduct,
      decoration: const InputDecoration(
        labelText: 'Produit',
        border: OutlineInputBorder(),
      ),
      items: produits.map((String produit) {
        return DropdownMenuItem<String>(
          value: produit,
          child: Text(produit),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedProduct = newValue;
          // Mettre à jour la liste des variétés en fonction du produit sélectionné
          _productVarieties = _productData[newValue] ?? [];
          _selectedProductVariety = null; // Réinitialiser la variété sélectionnée
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner un produit';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownVarietesProduit() {
    return DropdownButtonFormField<String>(
      value: _selectedProductVariety,
      decoration: const InputDecoration(
        labelText: 'Variétés de Produits',
        border: OutlineInputBorder(),
      ),
      items: _productVarieties.map((String variete) {
        return DropdownMenuItem<String>(
          value: variete,
          child: Text(variete),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedProductVariety = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une variété de produit';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownTypeEmballage() {
    final List<String> typesEmballage = [
      'Emballage A',
      'Emballage B',
      'Emballage C',
      'Emballage D',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedPackagingType,
      decoration: const InputDecoration(
        labelText: 'Type d\'Emballage',
        border: OutlineInputBorder(),
      ),
      items: typesEmballage.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPackagingType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner un type d\'emballage';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final projectName = _projectNameController.text;
      final projectDescription = _projectDescriptionController.text;
      final quantity = _quantityController.text;

      // Process the data (e.g., save to database or send to an API)
      print('Project Name: $projectName');
      print('Project Description: $projectDescription');
      print('Start Date: $_startDate');
      print('End Date: $_endDate');
      print('Produit: $_selectedProduct');
      print('Variété de Produit: $_selectedProductVariety');
      print('Type d\'Emballage: $_selectedPackagingType');
      print('Quantité de matière première: $quantity');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Projet "$projectName" créé avec succès!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer un Projet de transformation',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du projet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de projet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description du projet',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description du projet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownProduit(),
              const SizedBox(height: 16),
              if (_selectedProduct != null) _buildDropdownVarietesProduit(),
              const SizedBox(height: 16),
              _buildDropdownTypeEmballage(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantité de matière première',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Clavier numérique
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date de début'),
                        TextButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(
                            _startDate == null
                                ? 'Sélectionner une date'
                                : '${_startDate!.toLocal()}'.split(' ')[0],
                            style: TextStyle(
                              color: _startDate == null ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date de fin'),
                        TextButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            _endDate == null
                                ? 'Sélectionner une date'
                                : '${_endDate!.toLocal()}'.split(' ')[0],
                            style: TextStyle(
                              color: _endDate == null ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Créer le projet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}