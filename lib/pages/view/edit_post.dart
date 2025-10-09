import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:io';

import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/view/actuality.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class EditPostPage extends ConsumerStatefulWidget {
  final OppsModel post;
  final Function(String, String?) onSave;

  const EditPostPage({super.key, required this.post, required this.onSave});

  @override
  ConsumerState<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends ConsumerState<EditPostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  XFile? _newImage; // For newly picked image
  bool _isSaving = false;
  dynamic connectedUser;

  final AuthService _authService = AuthService();
  final HttpService _httpService = HttpService();

  @override
  void initState() {
    super.initState();
    // Initialize with original content, handling null case
    _contentController = TextEditingController(text: widget.post.content ?? '');
    _connectUser();
    // Position cursor at the end for easy appending, or allow user to move it
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _contentController.text.length),
    );
  }

  Future<void> _connectUser() async {
    try {
      String? token = await _authService.readToken();
      if (token != null) {
        setState(() {
          connectedUser = JwtDecoder.decode(token);
        });
      } else {
        AppLocales.debugPrint('debug_no_token', ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint('debug_user_connection_error', ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _newImage = pickedFile;
    });
  }

  void _removeImage() {
    setState(() {
      _newImage = null; // Clear the image; will send null to backend if saved
    });
  }

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      String? imageUrl = widget.post.image; // Default to original image
      try {
        if (_newImage != null) {
          imageUrl = await _httpService.uploadImage(File(_newImage!.path));
        } else if (_newImage == null && widget.post.image != null && imageUrl != null) {
          // Keep original image if no new image is picked and not removed
        } else {
          imageUrl = null; // Image was removed
        }

        widget.onSave(_contentController.text, imageUrl);

        setState(() {
          _isSaving = false;
        });

        _showSuccessDialog(context);
      } catch (e) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    Navigator.pop(context);
  }

  void _showSuccessDialog(BuildContext context) {
    final locale = ref.read(localeProvider).languageCode;

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
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocales.getTranslation('post_updated_success', locale),
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

    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Actuality()));
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _cancelEdit,
          icon: Icon(
            Icons.close,
            color: isDarkMode ? Colors.white : Colors.red,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePost,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: _isSaving ? Colors.grey : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            AppLocales.getTranslation('save', locale),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.save, color: Colors.white),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocales.getTranslation('edit_post_title', locale),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contentController,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText: AppLocales.getTranslation('write_something', locale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: iconColor),
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        ),
                        maxLines: null, // Allows unlimited lines
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        // Optional: Add validator if you want to enforce rules
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocales.getTranslation('content_required', locale);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Image Section
                      if (_newImage != null)
                        Stack(
                          children: [
                            Image.file(
                              File(_newImage!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _removeImage,
                              ),
                            ),
                          ],
                        )
                      else if (widget.post.image != null && widget.post.image!.isNotEmpty)
                        Stack(
                          children: [
                            Image.network(
                              widget.post.image!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _removeImage,
                              ),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            AppLocales.getTranslation('no_image', locale),
                            style: TextStyle(color: textColor.withOpacity(0.6)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: lightGreen.withValues(green: 1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: iconColor),
                    onPressed: _pickImage,
                    tooltip: AppLocales.getTranslation('add_image', locale),
                  ),
                  IconButton(
                    icon: Icon(Icons.gif, color: iconColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.list, color: iconColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on, color: iconColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: iconColor),
                    onPressed: () {},
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