import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';

import 'package:new_oppsfarm/main.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';

import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/add_projet.dart';
import 'package:new_oppsfarm/pages/projets/add_projet_trans.dart';
import 'package:new_oppsfarm/pages/projets/edit_project.dart';
import 'package:new_oppsfarm/pages/projets/projet_details.dart'
    as ProjetDetails;
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:new_oppsfarm/reusableComponent/drawer.dart';

// Modèle d'état
class ProjectState with EquatableMixin {
  final List<ProjectModel> projects;
  final bool isLoading;
  final dynamic connectedUser;

  const ProjectState({
    required this.projects,
    required this.isLoading,
    this.connectedUser,
  });

  factory ProjectState.initial() => const ProjectState(
        projects: [],
        isLoading: false,
        connectedUser: null,
      );

  ProjectState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    dynamic connectedUser,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      connectedUser: connectedUser ?? this.connectedUser,
    );
  }

  @override
  List<Object?> get props => [projects, isLoading, connectedUser];
}

// Notifier pour gérer l'état
class ProjectNotifier extends StateNotifier<ProjectState> {
  final HttpService _projectService;
  final AuthService _authService;
  final Ref _ref;

  ProjectNotifier(this._projectService, this._authService, this._ref)
      : super(ProjectState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectUser();
    await _fetchUserProjects();
  }

  Future<void> _connectUser() async {
    state = state.copyWith(isLoading: true);
    try {
      String? token = await _authService.readToken();
      if (token != null) {
        state = state.copyWith(connectedUser: JwtDecoder.decode(token));
      } else {
        AppLocales.debugPrint(
            'debug_no_token', _ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint(
          'debug_user_connection_error', _ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _fetchUserProjects() async {
    state = state.copyWith(isLoading: true);
    try {
      if (state.connectedUser == null) {
        throw Exception('No connected user found');
      }

      final userId = state.connectedUser!['id'];
      final parsedUserId = int.tryParse(userId.toString());

      if (parsedUserId == null || parsedUserId <= 0) {
        throw Exception('Invalid user ID: $userId');
      }

      final response = await _projectService.getUserProject(parsedUserId);
      state = state.copyWith(projects: response);
    } catch (e) {
      print("Erreur lors de la récupération des projets: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Future<void> _fetchUserProjects() async {
  //   state = state.copyWith(isLoading: true);
  //   try {
  //     if (state.connectedUser != null) {
  //       var userId = state.connectedUser['id'];
  //       int? parsedUserId = int.tryParse(userId.toString());
  //       if (parsedUserId != null && parsedUserId > 0) {
  //         var response = await _projectService.getUserProject(parsedUserId);
  //         if (response is List) {
  //           List<ProjectModel> projects = response
  //               .map((project) =>
  //                   ProjectModel.fromJson(project))
  //               .toList();
  //           state = state.copyWith(projects: projects);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print("Erreur lors de la récupération des projets: $e");
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }

  Future<void> deleteProject(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      var response = await _projectService.deleteProject(id);
      if (response.contains('Projet supprimé avec succès')) {
        final updatedProjects =
            state.projects.where((p) => p.id != id).toList();
        state = state.copyWith(projects: updatedProjects);
      } else {
        throw Exception('Échec de la suppression: $response');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshProjects() async {
    await _fetchUserProjects();
  }
}

// Provider
final projectProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  final httpService = HttpService();
  final authService = AuthService();
  return ProjectNotifier(httpService, authService, ref);
});

// Widget principal
class Projet extends ConsumerStatefulWidget {
  const Projet({super.key});

  @override
  ConsumerState<Projet> createState() => _ProjetState();
}

class _ProjetState extends ConsumerState<Projet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await ref.read(projectProvider.notifier)._authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation(
                    'choose_theme', ref.read(localeProvider).languageCode),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text(AppLocales.getTranslation(
                    'system_theme', ref.read(localeProvider).languageCode)),
                value: themeMode == ThemeMode.system,
                onChanged: (value) {
                  final newMode = value ? ThemeMode.system : ThemeMode.light;
                  ref.read(themeProvider.notifier).setThemeMode(newMode);
                },
                secondary: const Icon(Icons.phone_android),
              ),
              if (themeMode != ThemeMode.system)
                SwitchListTile(
                  title: Text(themeMode == ThemeMode.dark
                      ? AppLocales.getTranslation(
                          'dark_mode', ref.read(localeProvider).languageCode)
                      : AppLocales.getTranslation(
                          'light_mode', ref.read(localeProvider).languageCode)),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    final newMode = value ? ThemeMode.dark : ThemeMode.light;
                    ref.read(themeProvider.notifier).setThemeMode(newMode);
                  },
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocales.getTranslation(
                    'close',
                    ref.read(localeProvider).languageCode,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation(
                    'choose_language', ref.read(localeProvider).languageCode),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Français'),
                leading: Radio<String>(
                  value: 'fr',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocales.getTranslation(
                    'close', ref.read(localeProvider).languageCode)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: green,
                size: 30,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocales.getTranslation('project_deleted_success', locale),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    // final cardColor = isDarkMode ? Colors.black : Colors.white;

    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final tabColor = isDarkMode ? Colors.white : Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('projects', locale),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          GestureDetector(
            onTap: () {
              _showProjectTypeDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 50,
                height: 35,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: iconColor,
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        connectedUser: projectState.connectedUser,
        backgroundColor: backgroundColor,
        textColor: textColor,
        isDarkMode: isDarkMode,
        onLogout: _logout,
        onShowThemeBottomSheet: _showThemeBottomSheet,
        onShowLanguageBottomSheet: _showLanguageBottomSheet,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: AppLocales.getTranslation('my_projects', locale)),
              Tab(text: AppLocales.getTranslation('collaboration', locale)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                projectState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: projectState.projects.length,
                              itemBuilder: (context, index) {
                                final project = projectState.projects[index];
                                return ProjectTile(
                                  id: project.id,
                                  nom: project.nom,
                                  description: project.description,
                                  crop: project.crop,
                                  cropVariety: project.cropVariety,
                                  imageUrl: project.imageUrl ?? '',
                                  memberships: project.memberships,
                                  tasks: project.tasks,
                                  startDate:
                                      project.startDate.toIso8601String(),
                                  endDate: project.endDate.toIso8601String(),
                                  estimatedQuantityProduced:
                                      project.estimatedQuantityProduced,
                                  basePrice: project.basePrice,
                                  owner: project.owner?.nom,
                                  isListedOnMarketplace:
                                      project.isListedOnMarketplace,
                                  onDelete: () async {
                                    await ref
                                        .read(projectProvider.notifier)
                                        .deleteProject(project.id);
                                    _showSuccessDialog(context, locale);
                                  },
                                  locale: locale,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocales.getTranslation(
                              'collaborations_in_progress', locale),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          AppLocales.getTranslation(
                              'no_collaborations_available', locale),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectTypeDialog(BuildContext context) {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.green;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            AppLocales.getTranslation('choose_project_type', locale),
            style: TextStyle(color: textColor),
          ),
          content: Text(
            AppLocales.getTranslation('what_to_add', locale),
            style: TextStyle(color: textColor),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AddProject(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const offsetBegin = Offset(0, 1);
                      const offsetEnd = Offset.zero;
                      var tween = Tween(begin: offsetBegin, end: offsetEnd);
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                ).then((_) =>
                    ref.read(projectProvider.notifier)._fetchUserProjects());
              },
              child: Center(
                child: Text(
                  AppLocales.getTranslation('agricultural_project', locale),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AddProject(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const offsetBegin = Offset(0, 1);
                      const offsetEnd = Offset.zero;
                      var tween = Tween(begin: offsetBegin, end: offsetEnd);
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);

                      // pageBuilder: (context, animation, secondaryAnimation) =>
                      //     const AddProjetTrans(),
                      // transitionsBuilder:
                      //     (context, animation, secondaryAnimation, child) {
                      //   const offsetBegin = Offset(0, 1);
                      //   const offsetEnd = Offset.zero;

                      //   var tween = Tween(
                      //     begin: offsetBegin,
                      //     end: offsetEnd,
                      //   );
                      //   var offsetAnimation = animation.drive(
                      //     tween,
                      //   );
                      //   return SlideTransition(
                      //     position: offsetAnimation,
                      //     child: child,
                      //   );
                    },
                  ),
                ).then((_) =>
                    ref.read(projectProvider.notifier)._fetchUserProjects());
              },
              child: Center(
                child: Text(
                  AppLocales.getTranslation(
                      'agricultural_transformation_project', locale),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ProjectTile avec correction de l'overflow et confirmation de suppression
class ProjectTile extends StatelessWidget {
  final int id;
  final String nom;
  final String description;
  final String startDate;
  final String endDate;
  final int estimatedQuantityProduced;
  final int? basePrice;
  final Crop crop;
  final CropVariety? cropVariety;
  final String imageUrl;
  final String? owner;
  final bool? isListedOnMarketplace;
  final VoidCallback onDelete;
  final List<Membership> memberships;
  final List<Task>? tasks;
  final String locale;

  const ProjectTile({
    super.key,
    required this.id,
    required this.nom,
    required this.description,
    required this.crop,
    this.cropVariety,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.estimatedQuantityProduced,
    required this.basePrice,
    required this.owner,
    required this.isListedOnMarketplace,
    required this.onDelete,
    required this.memberships,
    this.tasks,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Dismissible(
      key: Key(nom),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text(AppLocales.getTranslation('confirm_deletion', locale)),
                content: Text(
                    AppLocales.getTranslation('are_you_sure_delete', locale)),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(false), // Annuler
                    child: Text(AppLocales.getTranslation('no', locale)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(true), // Confirmer
                    child: Text(AppLocales.getTranslation('yes', locale)),
                  ),
                ],
              );
            },
          );
        } else if (direction == DismissDirection.startToEnd) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProject(projectId: id),
            ),
          );
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjetDetails.ProjectDetails(
                id: id,
                nom: nom,
                description: description,
                crop: crop,
                cropVariety: cropVariety,
                imageUrl: imageUrl,
                startDate: startDate,
                endDate: endDate,
                estimatedQuantityProduced: estimatedQuantityProduced,
                basePrice: basePrice,
                owner: owner,
                isListedOnMarketplace: isListedOnMarketplace,
                memberships: memberships,
                tasks: tasks ?? [],
                marketplaceListings: [],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: green),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Material(
              borderRadius: BorderRadius.circular(15),
              color: backgroundColor,
              child: Container(
                height: 185,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: backgroundColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl,
                                fit: BoxFit.cover, height: 130, width: 130)
                            : Image.asset('assets/images/projectDefaultimg.jpg',
                                height: 130, width: 130, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      // Utilisation de Expanded pour éviter l'overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            softWrap: true,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            softWrap: true,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                AppLocales.getTranslation('crop_label', locale),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                // Utilisation de Flexible pour éviter l'overflow ici aussi
                                child: Text(
                                  crop.nom,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
