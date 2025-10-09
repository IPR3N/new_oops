import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/marketPlace/marketService/marketHttpService.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart'; // Add locale provider

class AddProduct extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const AddProduct({super.key});

  @override
  ConsumerState<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProduct> {
  bool _isLoading = false;
  dynamic connectedUser;
  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();
  final MarketHttpService _marketService = MarketHttpService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _product =
      TextEditingController(); // Unused, consider removing
  final TextEditingController _publicDescriptionController =
      TextEditingController();

  Future<void> connectUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
        AppLocales.debugPrint(
            'debug_user_connected', ref.read(localeProvider).languageCode,
            placeholders: {'user': connectedUser.toString()});
      } else {
        AppLocales.debugPrint(
            'debug_no_token', ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint(
          'debug_user_connection_error', ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserConnectedProject() async {
    setState(() {
      _isLoading = true;
    });

    final locale = ref.read(localeProvider).languageCode;
    try {
      if (connectedUser != null) {
        var userId = connectedUser['id'];

        if (userId != null) {
          int? parsedUserId = int.tryParse(userId.toString());
          if (parsedUserId != null && parsedUserId > 0) {
            var response = await _projectService.getUserProject(parsedUserId);
            if (response is List) {
              List<ProjectModel> projects = response.map((project) {
                return ProjectModel.fromJson(project as Map<String, dynamic>);
              }).toList();

              setState(() {
                _projects = projects;
              });
            } else {
              debugPrint(AppLocales.getTranslation('response_not_list', locale,
                  placeholders: {'response': response.toString()}));
            }
          } else {
            debugPrint(AppLocales.getTranslation('invalid_user_id', locale,
                placeholders: {'userId': parsedUserId.toString()}));
          }
        } else {
          debugPrint(AppLocales.getTranslation('user_id_null', locale));
        }
      } else {
        debugPrint(AppLocales.getTranslation('no_user_connected', locale));
      }
    } catch (e) {
      debugPrint(AppLocales.getTranslation('fetch_projects_error', locale,
          placeholders: {'error': e.toString()}));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProjectDropdownField() {
    final locale =
        ref.watch(localeProvider).languageCode; // Watch locale for UI updates
    return DropdownButtonFormField<ProjectModel>(
      value: _selectedProject,
      onChanged: (value) {
        setState(() {
          _selectedProject = value;
        });
      },
      decoration: InputDecoration(
        labelText: AppLocales.getTranslation('project', locale),
        filled: true,
        fillColor: lightGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: green,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: white,
            width: 0.8,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
      items: _projects.map((project) {
        return DropdownMenuItem<ProjectModel>(
          value: project,
          child: Text(project.nom),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return AppLocales.getTranslation('select_project_required', locale);
        }
        return null;
      },
    );
  }

  void _addProduct() {
    final locale = ref.read(localeProvider).languageCode;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_selectedProject != null) {
          var projectId = _selectedProject!.id;
          var publicDescription = _publicDescriptionController.text;

          if (publicDescription.isNotEmpty) {
            _marketService.addMarketItem(projectId).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocales.getTranslation(
                      'product_added_success', locale)),
                  backgroundColor: green,
                ),
              );
              Navigator.pop(context);
            });
          } else {
            debugPrint(AppLocales.getTranslation(
                'invalid_project_or_description', locale));
          }
        } else {
          debugPrint(AppLocales.getTranslation('project_not_selected', locale));
        }
      } catch (e) {
        debugPrint(AppLocales.getTranslation('add_product_error', locale,
            placeholders: {'error': e.toString()}));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocales.getTranslation('add_product_error', locale,
                placeholders: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelProjectCreation() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    connectUser().then((_) {
      _getUserConnectedProject();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        ref.watch(localeProvider).languageCode; // Watch locale for UI updates
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _cancelProjectCreation,
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
        title: Text(AppLocales.getTranslation('add_product_title', locale)),
        backgroundColor: white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 25.0),
                  _buildProjectDropdownField(),
                  const SizedBox(height: 15.0),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: lightGreen,
                      border: Border.all(
                        color: white,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: _publicDescriptionController,
                      maxLength: 280,
                      decoration: InputDecoration(
                        hintText: AppLocales.getTranslation(
                            'describe_product', locale),
                        border: InputBorder.none,
                      ),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _addProduct,
                    child: Container(
                      height: 70,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: green,
                        border: Border.all(
                          color: white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                AppLocales.getTranslation('add_button', locale),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
}
