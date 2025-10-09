import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/profile/service/profile_http_service.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final int userId;
  final dynamic userProfile;
  const EditProfilePage({super.key, required this.userProfile, required this.userId});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final ProfileHttpService _profileHttpService = ProfileHttpService();

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _profilePhoto;
  String? _coverPhoto;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.userProfile["bio"] ?? "";
    _locationController.text = widget.userProfile["location"] ?? "";
    _usernameController.text = widget.userProfile["username"] ?? "";
    _dobController.text = widget.userProfile["dob"] ?? "";
    _profilePhoto = widget.userProfile["photoProfile"];
    _coverPhoto = widget.userProfile["photoCouverture"];

    // Debugging print using AppLocales for consistency
    AppLocales.debugPrint(
      'debug_cover_profile_photos',
      ref.read(localeProvider).languageCode,
      placeholders: {
        'cover': _coverPhoto ?? 'null',
        'profile': _profilePhoto ?? 'null',
      },
    );

    if (widget.userProfile["dob"] != null && widget.userProfile["dob"].isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.userProfile["dob"]);
      if (_selectedDate != null) {
        _dobController.text = DateFormat("dd/MM/yyyy").format(_selectedDate!);
      }
    }
  }

  Future<void> _pickImage(bool isCover) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isCover) {
          _coverPhoto = image.path;
        } else {
          _profilePhoto = image.path;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  Future<void> _saveProfile() async {
    final locale = ref.read(localeProvider).languageCode;
    setState(() => _isLoading = true);

    try {
      String? profilePhotoUrl;
      String? coverPhotoUrl;

      if (_profilePhoto != null && File(_profilePhoto!).existsSync()) {
        profilePhotoUrl = await _profileHttpService.uploadImage(File(_profilePhoto!));
      } else {
        profilePhotoUrl = widget.userProfile["photoProfile"];
      }

      if (_coverPhoto != null && File(_coverPhoto!).existsSync()) {
        coverPhotoUrl = await _profileHttpService.uploadImage(File(_coverPhoto!));
      } else {
        coverPhotoUrl = widget.userProfile["photoCouverture"];
      }

      if (widget.userProfile["id"] == null || widget.userId == null) {
        throw Exception(
          AppLocales.getTranslation('missing_id_error', locale),
        );
      }

      final response = await _profileHttpService.updateProfile(
        id: widget.userProfile["id"],
        bio: _bioController.text,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        username: _usernameController.text,
        dob: _dobController.text,
        photoProfile: profilePhotoUrl,
        photoCouverture: coverPhotoUrl,
        user: widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocales.getTranslation('profile_updated_success', locale)),
          ),
        );

        setState(() {
          if (profilePhotoUrl != null) {
            widget.userProfile["photoProfile"] = profilePhotoUrl;
          }
          if (coverPhotoUrl != null) {
            widget.userProfile["photoCouverture"] = coverPhotoUrl;
          }
        });

        Navigator.pop(context, {
          "bio": _bioController.text,
          "location": _locationController.text,
          "username": _usernameController.text,
          "dob": _dobController.text,
          "photoProfile": profilePhotoUrl ?? widget.userProfile["photoProfile"],
          "photoCouverture": coverPhotoUrl ?? widget.userProfile["photoCouverture"],
        });
      }
    } on http.ClientException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocales.getTranslation(
                'network_error',
                locale,
                placeholders: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocales.getTranslation(
                'update_profile_error',
                locale,
                placeholders: {'error': e.toString()},
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocales.getTranslation('edit_profile', locale),
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    AppLocales.getTranslation('save', locale),
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _coverPhoto != null && _coverPhoto!.isNotEmpty
                            ? (File(_coverPhoto!).existsSync()
                                ? FileImage(File(_coverPhoto!))
                                : NetworkImage(_coverPhoto!)) as ImageProvider
                            : (widget.userProfile["photoCouverture"] != null
                                ? NetworkImage(widget.userProfile["photoCouverture"])
                                : const AssetImage('assets/images/default_cover.jpg')) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: GestureDetector(
                    onTap: () => _pickImage(false),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: backgroundColor,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: _profilePhoto != null && _profilePhoto!.isNotEmpty
                            ? (File(_profilePhoto!).existsSync()
                                ? FileImage(File(_profilePhoto!))
                                : NetworkImage(_profilePhoto!)) as ImageProvider
                            : (widget.userProfile["photoProfile"] != null
                                ? NetworkImage(widget.userProfile["photoProfile"])
                                : const AssetImage('assets/images/default_profile.jpg')) as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('username', locale),
                      labelStyle: TextStyle(color: textColor),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('bio', locale),
                      labelStyle: TextStyle(color: textColor),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('location', locale),
                      labelStyle: TextStyle(color: textColor),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('date_of_birth', locale),
                      labelStyle: TextStyle(color: textColor),
                      suffixIcon: Icon(Icons.calendar_today, color: textColor),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: _pickDate,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}