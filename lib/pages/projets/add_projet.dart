import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/projet.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class AddProject extends ConsumerStatefulWidget {
  // Changement en ConsumerStatefulWidget
  const AddProject({super.key});

  @override
  ConsumerState<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends ConsumerState<AddProject> {
  // ConsumerState pour Riverpod
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nom = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _dateDebut = TextEditingController();
  final TextEditingController _dateFin = TextEditingController();
  final TextEditingController _owner = TextEditingController();
  final TextEditingController _typeCulture = TextEditingController();
  final TextEditingController _cropVariety = TextEditingController();
  final TextEditingController _memberShip = TextEditingController();
  final TextEditingController _estimated_quantity_produced =
      TextEditingController();
  final TextEditingController _base_price = TextEditingController();

  bool _isLoading = false;
  dynamic connectedUser;
  int? _days_to_croissant;
  int? _days_to_germinate;
  int? _days_to_maturity;
  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();

  Future<void> connectUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
      } else {
        AppLocales.debugPrint(
            'debug_no_token', ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint(
          'debug_user_connection_error', ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _AddProject() async {
    final locale =
        ref.read(localeProvider).languageCode; // Récupère la langue courante
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final DateTime startDate = DateTime.parse(_dateDebut.text);
        final DateTime endDate = DateTime.parse(_dateFin.text);
        final int owner = connectedUser['id'];
        final int? typeCulture =
            _selectedCrop != null ? _selectedCrop!['id'] as int : null;
        final int? typeCultureVariety = _selectedCropVariety != null
            ? _selectedCropVariety!['id'] as int
            : null;

        String message = await _projectService.createProject(
          nom: _nom.text,
          description: _description.text,
          startDate: startDate.toIso8601String(),
          endDate: endDate.toIso8601String(),
          owner: owner,
          cropId: typeCulture,
          cropVarietyId: typeCultureVariety,
          memberShip: selectedCollaborators.join(','),
          estimatedQuantityProduced: _estimated_quantity_produced.text,
          basePrice: _base_price.text,
        );

        _nom.clear();
        _description.clear();
        _dateDebut.clear();
        _dateFin.clear();
        _owner.clear();
        _typeCulture.clear();
        _cropVariety.clear();
        _memberShip.clear();
        _estimated_quantity_produced.clear();
        _base_price.clear();

        setState(() {
          _isLoading = false;
        });

        if (message.contains('Projet créé avec succès')) {
          _showSuccessDialog(context);
        } else {
          throw Exception(AppLocales.getTranslation(
              'project_creation_error', locale,
              placeholders: {'error': message}));
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocales.getTranslation('error', locale)),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocales.getTranslation('ok', locale)),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    final locale = ref.read(localeProvider).languageCode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(height: 16),
              Text(
                AppLocales.getTranslation('project_created_success', locale),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Ferme le dialogue
        Navigator.pop(
            context); // Retourne à Projet (suppose que AddProject est poussé sur Projet)
        ref
            .read(projectProvider.notifier)
            .refreshProjects(); // Rafraîchit les projets
      }
    });
  }

  Future<void> getCrop() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> crops = await _projectService.getCrop();
      setState(() {
        _crops = crops;
      });
    } catch (error) {
      print("Erreur lors de la récupération des cultures : $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getUserForMembership() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> users =
          List<Map<String, dynamic>>.from(await _projectService.getUser());
      users = users.where((user) => user['id'] != connectedUser['id']).toList();

      setState(() {
        _users = users;
      });
    } catch (error) {
      print("Erreur lors de la récupération des utilisateurs : $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCrop();
    connectUser();
    getUserForMembership();
  }

  Map<String, dynamic>? _selectedCrop;
  Map<String, dynamic>? _selectedCropVariety;
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _cropVarieties = [];
  List<Map<String, dynamic>> _users = [];
  List<String> selectedCollaborators = [];

  void _updateCropVarieties() {
    setState(() {
      if (_selectedCrop != null) {
        _cropVarieties = List<Map<String, dynamic>>.from(
            _selectedCrop!['cropVariety'] ?? []);
        _selectedCropVariety = null;
        _cropVariety.clear();
        _days_to_croissant = null;
        _days_to_germinate = null;
        _days_to_maturity = null;
      } else {
        _cropVarieties.clear();
      }
    });
  }

  Widget _buildCropVarietyField() {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final borderColor = isDarkMode ? Colors.grey[200]! : green;
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedCropVariety,
      onChanged: (value) {
        setState(() {
          _selectedCropVariety = value;
          _cropVariety.text = value != null ? value['id'].toString() : '';
          _days_to_croissant = value?['days_to_croissant'];
          _days_to_germinate = value?['days_to_germinate'];
          _days_to_maturity = value?['days_to_maturity'];
        });
      },
      decoration: InputDecoration(
        labelText: AppLocales.getTranslation('crop_variety', locale),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      items: _cropVarieties.map((cropVariety) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: cropVariety,
          child: Text(cropVariety['nom']),
        );
      }).toList(),
      validator: (value) => value == null
          ? AppLocales.getTranslation('select_crop_variety', locale)
          : null,
    );
  }

  Widget _buildDropdownField() {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;

    // final textColor = isDarkMode ? Colors.white : Colors.black;
    // final cardColor = isDarkMode ? Colors.grey[900] : white;
    final borderColor = isDarkMode ? Colors.grey[200]! : green;
    // final iconColors = isDarkMode ? Colors.white : black;

    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedCrop,
      onChanged: (value) {
        setState(() {
          _selectedCrop = value;
          _typeCulture.text = value != null ? value['id'].toString() : '';
        });
        _updateCropVarieties();
      },
      decoration: InputDecoration(
        labelText: AppLocales.getTranslation('crop_type', locale),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      items: _crops.map((crop) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: crop,
          child: Text(crop['nom']),
        );
      }).toList(),
      validator: (value) => value == null
          ? AppLocales.getTranslation('select_crop_type', locale)
          : null,
    );
  }

  void _cancelProjectCreation() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        ref.watch(localeProvider).languageCode; // Écoute la langue courante
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    // final cardColor = isDarkMode ? Colors.grey[900] : white;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final iconColors = isDarkMode ? Colors.white : black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _cancelProjectCreation,
          icon: Icon(Icons.close, color: iconColors),
        ),
        title: Text(AppLocales.getTranslation('create_project', locale)),
        backgroundColor: backgroundColor,
        elevation: 0.5,
        titleTextStyle: TextStyle(color: textColor, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 25.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isDarkMode ? Colors.black : lightGreen,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _buildTextField(
                      controller: _nom,
                      label: AppLocales.getTranslation('project_name', locale),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(),
                  const SizedBox(height: 20),
                  _buildCropVarietyField(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _dateDebut.text = selectedDate
                                    .toIso8601String()
                                    .split('T')[0];
                                if (_days_to_croissant != null &&
                                    _days_to_germinate != null &&
                                    _days_to_maturity != null) {
                                  DateTime endDate = selectedDate.add(Duration(
                                      days: _days_to_croissant! +
                                          _days_to_germinate! +
                                          _days_to_maturity!));
                                  _dateFin.text =
                                      endDate.toIso8601String().split('T')[0];
                                }
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: backgroundColor,
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _dateDebut,
                                label: AppLocales.getTranslation(
                                    'sowing_date', locale),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              _dateFin.text =
                                  selectedDate.toIso8601String().split('T')[0];
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: backgroundColor,
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _dateFin,
                                label: AppLocales.getTranslation(
                                    'end_date', locale),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: _buildTextField(
                            controller: _estimated_quantity_produced,
                            label:
                                AppLocales.getTranslation('land_area', locale),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: _buildTextField(
                            controller: _base_price,
                            label:
                                AppLocales.getTranslation('base_price', locale),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: TextField(
                            controller: _description,
                            maxLength: 380,
                            decoration: InputDecoration(
                              hintText: AppLocales.getTranslation(
                                  'description', locale),
                              border: InputBorder.none,
                              counterText: "",
                            ),
                            maxLines: 5,
                            style: TextStyle(fontSize: 16, color: textColor),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => print('Ajout d\'image'),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: backgroundColor,
                              child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: green,
                                  size: 20),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 50,
                          child: GestureDetector(
                            onTap: () async {
                              await getUserForMembership();
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20))),
                                backgroundColor: backgroundColor,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppLocales.getTranslation(
                                                  'select_collaborators',
                                                  locale),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor),
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              child: _isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : ListView.builder(
                                                      itemCount: _users.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return CheckboxListTile(
                                                          title: Text(
                                                              _users[index]
                                                                  ['nom'],
                                                              style: TextStyle(
                                                                  color:
                                                                      textColor)),
                                                          value: _users[index][
                                                                  'isSelected'] ??
                                                              false,
                                                          activeColor: green,
                                                          onChanged:
                                                              (bool? value) {
                                                            setState(() {
                                                              _users[index][
                                                                      'isSelected'] =
                                                                  value!;
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                              ),
                                              onPressed: () {
                                                selectedCollaborators = _users
                                                    .where((user) =>
                                                        user['isSelected'] ==
                                                        true)
                                                    .map((user) =>
                                                        user['id'].toString())
                                                    .toList();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                AppLocales.getTranslation(
                                                    'add', locale),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: backgroundColor,
                              child: const Icon(Icons.alternate_email,
                                  color: green, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : _AddProject,
                    child: Container(
                      height: 70,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: green,
                        border: Border.all(color: white, width: 2),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                AppLocales.getTranslation('create', locale),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    final locale = ref.read(localeProvider).languageCode;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) => value == null || value.isEmpty
          ? AppLocales.getTranslation('field_required', locale)
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 0.8),
        ),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}
