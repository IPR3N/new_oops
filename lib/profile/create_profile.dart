import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/view/home.dart';
import 'package:new_oppsfarm/profile/service/profile_Http_service.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart'; // Add locale provider

class CreateProfile extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  final int userId;
  const CreateProfile({super.key, required this.userId});

  @override
  ConsumerState<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends ConsumerState<CreateProfile> {
  final ProfileHttpService _profileHttpService = ProfileHttpService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _profileImage;
  String? _coverImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isCover) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isCover) {
          _coverImage = image.path;
        } else {
          _profileImage = image.path;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  void _createProfile() async {
    final locale = ref.read(localeProvider).languageCode; // Access locale
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final int user = widget.userId;
    final String bio = _bioController.text;
    final String location = _locationController.text;
    final String dob = _dobController.text;
    String? photoProfile;
    String? photoCouverture;

    try {
      if (_coverImage != null) {
        photoCouverture =
            await _profileHttpService.uploadImage(File(_coverImage!));
      }

      if (_profileImage != null) {
        photoProfile =
            await _profileHttpService.uploadImage(File(_profileImage!));
      }

      final response = await _profileHttpService.createProfile(
        user: user,
        bio: bio,
        location: location,
        username: _usernameController.text,
        dob: dob,
        photoProfile: photoProfile,
        photoCouverture: photoCouverture,
      );

      print(response);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocales.getTranslation('profile_created_success', locale)),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (Route<dynamic> route) => false,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocales.getTranslation(
                'profile_creation_error',
                locale,
                placeholders: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale =
        ref.watch(localeProvider).languageCode; // Watch locale changes
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(
          AppLocales.getTranslation('create_profile', locale),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                      image: _coverImage != null
                          ? DecorationImage(
                              image: FileImage(File(_coverImage!)),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: _coverImage == null
                        ? const Center(child: Icon(Icons.camera_alt, size: 40))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: lightGreen,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!))
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocales.getTranslation('username', locale),
                        ),
                        validator: (value) => value!.isEmpty
                            ? AppLocales.getTranslation(
                                'required_field', locale)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: AppLocales.getTranslation('bio', locale),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocales.getTranslation('location', locale),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocales.getTranslation(
                              'date_of_birth', locale),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDate,
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? AppLocales.getTranslation('select_date', locale)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _isLoading ? null : _createProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: _isLoading ? lightGreen : green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppLocales.getTranslation(
                                  'create_profile_button', locale),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
