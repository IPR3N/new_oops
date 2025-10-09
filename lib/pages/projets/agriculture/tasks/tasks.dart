// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/projets/agriculture/tasks/createTask.dart';
// import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
// import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';

// class Tasks extends ConsumerStatefulWidget {
//   final int id;
//   final String nom;
//   final List<Membership> memberships;
//   const Tasks({
//     super.key,
//     required this.nom,
//     required this.memberships,
//     required this.id,
//     required List<Task> tasks,
//   });

//   @override
//   ConsumerState<Tasks> createState() => _TasksState();
// }

// class _TasksState extends ConsumerState<Tasks> {
//   final HttpService _projectService = HttpService();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;
//   dynamic connectedUser;
//   List<Task> tasks = []; // State-managed task list
//   List<Task> filteredTasks = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     connectUser();
//     fetchTasks(); // Fetch tasks on initialization
//   }

//   Future<void> connectUser() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       String? token = await _authService.readToken();
//       if (token != null) {
//         connectedUser = JwtDecoder.decode(token);
//       } else {
//         AppLocales.debugPrint(
//             'debug_no_token', ref.read(localeProvider).languageCode);
//       }
//     } catch (e) {
//       AppLocales.debugPrint(
//           'debug_user_connection_error', ref.read(localeProvider).languageCode,
//           placeholders: {'error': e.toString()});
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchTasks() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final fetchedTasks = await _projectService.getTasksByProject(widget.id);
//       print(fetchedTasks);
//       setState(() {
//         tasks = fetchedTasks;
//         print(tasks);
//         filteredTasks = tasks;
//         // Reset search if necessary
//         if (searchController.text.isNotEmpty) {
//           filterTasks(searchController.text);
//         }
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur lors du chargement des tâches: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void filterTasks(String query) {
//     final filtered = tasks.where((task) {
//       final taskTitleLower = task.titre.toLowerCase();
//       final searchLower = query.toLowerCase();
//       return taskTitleLower.contains(searchLower);
//     }).toList();

//     setState(() {
//       filteredTasks = filtered;
//     });
//   }

//   Future<bool> _confirmDelete(BuildContext context, String locale) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(AppLocales.getTranslation('confirm_delete', locale)),
//             content: Text(
//                 AppLocales.getTranslation('confirm_delete_message', locale)),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text(AppLocales.getTranslation('cancel', locale)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: Text(AppLocales.getTranslation('ok', locale)),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<void> _deleteTask(Task task) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final message = await _projectService.deleteTask(task.id);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//       await fetchTasks(); // Refresh task list
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur lors de la suppression: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = ref.watch(localeProvider).languageCode;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final textColor = isDarkMode ? Colors.white : green;
//     final cardColor = isDarkMode ? Colors.grey[900] : white;
//     final borderColor = isDarkMode ? Colors.grey[700]! : green;
//     final iconColor = isDarkMode ? Colors.white : black;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         title: Text(AppLocales.getTranslation('tasks', locale)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () async {
//               // Navigate to CreateTask and wait for result
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CreateTask(
//                     id: widget.id,
//                     nom: widget.nom,
//                     memberships: widget.memberships,
//                   ),
//                 ),
//               );

//               // Refresh tasks if a new task was created
//               if (result == true) {
//                 await fetchTasks();
//               }
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       labelText:
//                           AppLocales.getTranslation('search_task', locale),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       prefixIcon: const Icon(Icons.search),
//                     ),
//                     onChanged: filterTasks,
//                   ),
//                 ),
//                 Expanded(
//                   child: filteredTasks.isEmpty
//                       ? Center(
//                           child: Text(
//                             AppLocales.getTranslation('no_tasks_found', locale),
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: textColor,
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           itemCount: filteredTasks.length,
//                           itemBuilder: (context, index) {
//                             final task = filteredTasks[index];
//                             return Dismissible(
//                               key: Key(task.id.toString()),
//                               direction: DismissDirection.endToStart,
//                               background: Container(
//                                 color: Colors.red,
//                                 alignment: Alignment.centerRight,
//                                 padding: const EdgeInsets.only(right: 20.0),
//                                 child: const Icon(
//                                   Icons.delete,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               confirmDismiss: (direction) async {
//                                 return await _confirmDelete(context, locale);
//                               },
//                               onDismissed: (direction) {
//                                 _deleteTask(task);
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(16),
//                                     border: Border.all(
//                                       color: green,
//                                     ),
//                                   ),
//                                   child: Card(
//                                     color: white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12.0),
//                                     ),
//                                     elevation: 3,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(12.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             task.titre,
//                                             style: const TextStyle(
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             '${AppLocales.getTranslation('priority', locale)}: ${task.priority}',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             '${AppLocales.getTranslation('status', locale)}: ${task.status}',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             '${AppLocales.getTranslation('description', locale)}: ${task.description}',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/tasks/createTask.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/tasks/editTasks.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class Tasks extends ConsumerStatefulWidget {
  final int id;
  final String nom;
  final List<Membership> memberships;
  const Tasks({
    super.key,
    required this.nom,
    required this.memberships,
    required this.id,
    required List<Task> tasks,
  });

  @override
  ConsumerState<Tasks> createState() => _TasksState();
}

class _TasksState extends ConsumerState<Tasks> {
  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  dynamic connectedUser;
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectUser();
    fetchTasks();
  }

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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedTasks = await _projectService.getTasksByProject(widget.id);
      setState(() {
        tasks = fetchedTasks;
        filteredTasks = tasks;
        if (searchController.text.isNotEmpty) {
          filterTasks(searchController.text);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des tâches: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterTasks(String query) {
    final filtered = tasks.where((task) {
      final taskTitleLower = task.titre.toLowerCase();
      final searchLower = query.toLowerCase();
      return taskTitleLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredTasks = filtered;
    });
  }

  Future<bool> _confirmDelete(BuildContext context, String locale) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocales.getTranslation('confirm_delete', locale)),
            content: Text(
                AppLocales.getTranslation('confirm_delete_message', locale)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocales.getTranslation('cancel', locale)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocales.getTranslation('ok', locale)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _projectService.deleteTask(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      await fetchTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(AppLocales.getTranslation('tasks', locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTask(
                    id: widget.id,
                    nom: widget.nom,
                    memberships: widget.memberships,
                  ),
                ),
              );
              if (result == true) {
                await fetchTasks();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText:
                          AppLocales.getTranslation('search_task', locale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: filterTasks,
                  ),
                ),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? Center(
                          child: Text(
                            AppLocales.getTranslation('no_tasks_found', locale),
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return Dismissible(
                              key: Key(task.id.toString()),
                              direction: DismissDirection.horizontal,
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20.0),
                                child:
                                    const Icon(Icons.edit, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  // Edit action
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTask(
                                        projectId: widget.id,
                                        projectNom: widget.nom,
                                        memberships: widget.memberships,
                                        task: task,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    await fetchTasks();
                                  }
                                  return false; // Prevent dismissal
                                } else {
                                  // Delete action
                                  return await _confirmDelete(context, locale);
                                }
                              },
                              onDismissed: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  _deleteTask(task);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: green),
                                  ),
                                  child: Card(
                                    color: white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.titre,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${AppLocales.getTranslation('priority', locale)}: ${task.priority}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${AppLocales.getTranslation('status', locale)}: ${task.status}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${AppLocales.getTranslation('description', locale)}: ${task.description}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
