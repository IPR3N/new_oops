import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class EditTask extends ConsumerStatefulWidget {
  final int projectId;
  final String projectNom;
  final List<Membership> memberships;
  final Task task;

  const EditTask({
    super.key,
    required this.projectId,
    required this.projectNom,
    required this.memberships,
    required this.task,
  });

  @override
  ConsumerState<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends ConsumerState<EditTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _taskOwnerController = TextEditingController();

  bool _isLoading = false;
  Membership? _selectedMember;
  String? _selectedPriority;

  final HttpService _httpService = HttpService();

  @override
  void initState() {
    super.initState();
    // Prepopulate form fields with task data
    _titreController.text = widget.task.titre;
    _descriptionController.text = widget.task.description;
    _dateDebutController.text = widget.task.formattedStartDate;
    _dateFinController.text = widget.task.formattedEndDate;
    _statusController.text = widget.task.status;
    _selectedPriority = widget.task.priority;
    // _taskOwnerController.text = widget.task.taskOwner?.id.toString() ?? '';
    if (_taskOwnerController.text.isNotEmpty && widget.memberships.isNotEmpty) {
      try {
        _selectedMember = widget.memberships.firstWhere(
          (member) => member.id.toString() == _taskOwnerController.text,
        );
      } catch (e) {
        _selectedMember = widget.memberships.first;
      }
    } else {
      _selectedMember =
          widget.memberships.isNotEmpty ? widget.memberships.first : null;
    }
  }

  Future<void> updateTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final message = await _httpService.updateTask(
          taskId: widget.task.id,
          titre: _titreController.text,
          description: _descriptionController.text,
          startDate: _dateDebutController.text,
          endDate: _dateFinController.text,
          priority: _selectedPriority,
          status: _statusController.text,
          project: widget.projectId.toString(),
          taskOwner: _taskOwnerController.text,
          id: '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        Navigator.pop(context, true); // Signal successful update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour de la tâche: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
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
        title: Text(AppLocales.getTranslation('edit_task', locale)),
        backgroundColor: backgroundColor,
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
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _buildTextField(
                      controller: _titreController,
                      label: AppLocales.getTranslation('title', locale),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _buildTextField(
                      controller: _descriptionController,
                      label: AppLocales.getTranslation('description', locale),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPriority = newValue;
                              });
                            },
                            items: <String>[
                              AppLocales.getTranslation('important', locale),
                              AppLocales.getTranslation(
                                  'very_important', locale),
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelText:
                                  AppLocales.getTranslation('priority', locale),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<Membership>(
                          value: _selectedMember,
                          onChanged: (Membership? newValue) {
                            setState(() {
                              _selectedMember = newValue;
                              _taskOwnerController.text =
                                  newValue?.id.toString() ?? '';
                            });
                          },
                          items: widget.memberships
                              .map<DropdownMenuItem<Membership>>(
                                  (Membership member) {
                            return DropdownMenuItem<Membership>(
                              value: member,
                              child: Text(member.user?.nom ??
                                  AppLocales.getTranslation(
                                      'no_name_available', locale)),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: AppLocales.getTranslation(
                                'select_member', locale),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: TextFormField(
                            controller: _dateDebutController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, _dateDebutController),
                            decoration: InputDecoration(
                              labelText: AppLocales.getTranslation(
                                  'start_date', locale),
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
                            ),
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
                          child: TextFormField(
                            controller: _dateFinController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, _dateFinController),
                            decoration: InputDecoration(
                              labelText:
                                  AppLocales.getTranslation('end_date', locale),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: backgroundColor,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _buildTextField(
                      controller: _statusController,
                      label: AppLocales.getTranslation('status', locale),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.red,
                              border: Border.all(color: white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                AppLocales.getTranslation('cancel', locale),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: updateTask,
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: green,
                              border: Border.all(color: white, width: 2),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      AppLocales.getTranslation(
                                          'update', locale),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocales.getTranslation(
              'field_required', ref.watch(localeProvider).languageCode);
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
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
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}
