import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importez Riverpod
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';


class Memberships extends ConsumerStatefulWidget {
  final int id;
  final String nom;
  final List<Membership> memberships;
  Memberships({
    super.key,
    required this.id,
    required this.nom,
    required this.memberships,
  });

  @override
  ConsumerState<Memberships> createState() => _MembershipsState();
}

class _MembershipsState extends ConsumerState<Memberships> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUser;
  String? _selectedRole;
  bool _isLoading = false;

  List<Map<String, dynamic>> _users = [];

  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();
  dynamic connectedUser;

 Future<void> connectUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await _authService.readToken();
      if (token != null) {
        connectedUser = JwtDecoder.decode(token);
      } else {
        AppLocales.debugPrint('debug_no_token', ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint('debug_user_connection_error', ref.read(localeProvider).languageCode, placeholders: {'error': e.toString()});
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
      List<int> memberIds = widget.memberships.map((m) => m.user!.id).toList();
      users = users.where((user) => !memberIds.contains(user['id'])).toList();
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

  Future<void> refreshMembers() async {
    try {
      List<Membership> updatedMembers =
          await _projectService.getMemberByProject(projectId: widget.id);

      setState(() {
        widget.memberships
          ..clear()
          ..addAll(updatedMembers);
      });
    } catch (error) {
      print("Erreur lors du rafraîchissement des membres : $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppLocales.getTranslation('refresh_members_error', ref.read(localeProvider).languageCode)}: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addMember(int project, int user, String role) async {
    if (_selectedUser != null && _selectedRole != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String successMessage = await _projectService.createMembership(
          project: project,
          user: user,
          role: role,
        );

        Navigator.of(context).pop();

        await refreshMembers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppLocales.getTranslation('error', ref.read(localeProvider).languageCode)}: $error"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _selectedUser = null;
          _selectedRole = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    connectUser();
    getUserForMembership();
  }

  void _showAddMemberDialog() {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final buttonColor = isDarkMode ? Colors.grey[900] : green;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          elevation: 10,
          backgroundColor: backgroundColor,
          title: Text(AppLocales.getTranslation('add_member', locale)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('select_user', locale),
                      filled: true,
                      fillColor: backgroundColor,
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
                        borderSide: BorderSide(
                          color: borderColor,
                          width: 0.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                    ),
                    items: _users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user['id'].toString(),
                        child: Text(user['nom']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocales.getTranslation('select_user_required', locale);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('select_role', locale),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: green,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: borderColor,
                          width: 0.8,
                        ),
                      ),
                    ),
                    items: ['Admin', 'Collaborator'].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocales.getTranslation('select_role_required', locale);
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocales.getTranslation('cancel', locale),
                style: const TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        addMember(widget.id, int.parse(_selectedUser!), _selectedRole!);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(AppLocales.getTranslation('validate', locale)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final iconColor = isDarkMode ? Colors.white : black;
    final buttonColor = isDarkMode ? Colors.grey[900] : green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(AppLocales.getTranslation('memberships', locale)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        onPressed: _showAddMemberDialog,
        child: const Icon(
          Icons.add,
          color: lightGreen,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.memberships.length,
        itemBuilder: (context, index) {
          final member = widget.memberships[index];
          return Column(
            children: [
              Card(
                elevation: 1,
                color: backgroundColor,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: backgroundColor,
                    child: const Icon(Icons.person, color: green),
                  ),
                  title: Text(
                    member.user?.nom ?? AppLocales.getTranslation('name_unavailable', locale),
                  ),
                  subtitle: Text(
                    '${AppLocales.getTranslation('role', locale)}: ${member.role ?? AppLocales.getTranslation('role_unavailable', locale)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: green),
                    onPressed: () {
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return AlertDialog(
                      //       title: const Text('Supprimer'),
                      //       content: const Text('Voulez-vous vraiment supprimer ce membre
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}