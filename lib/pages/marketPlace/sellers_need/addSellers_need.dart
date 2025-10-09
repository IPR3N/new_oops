import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/marketPlace/marketService/marketHttpService.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class AddsellersNeed extends ConsumerStatefulWidget {
  const AddsellersNeed({super.key});

  @override
  ConsumerState<AddsellersNeed> createState() => _AddsellersNeedState();
}

class _AddsellersNeedState extends ConsumerState<AddsellersNeed> {
  bool _isLoading = false;
  dynamic connectedUser;
  Map<String, dynamic>? _selectedCrop;
  final HttpService _projectService = HttpService();
  final AuthService _authService = AuthService();
  final MarketHttpService _marketService = MarketHttpService();
  List<Map<String, dynamic>> _crops = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productId = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _sellerId = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCrop();
    connectUser();
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

  void _addSellerNeed() async {
    final locale = ref.read(localeProvider).languageCode;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final bool success = await _marketService.createSellerNeed(
          productId: int.parse(_productId.text),
          quantity: int.parse(_quantity.text),
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          _showSuccessDialog(context);
        } else {
          throw Exception(AppLocales.getTranslation(
              'seller_need_creation_error', locale,
              placeholders: {'error': 'Failed to create seller need'}));
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
                AppLocales.getTranslation(
                    'seller_need_created_success', locale),
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
        Navigator.pop(context); // Retourne à la page précédente
      }
    });
  }

  void _cancelCreation() {
    Navigator.pop(context);
  }

  Widget _buildDropdownField() {
    final locale = ref.read(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final borderColor = isDarkMode ? Colors.grey[200]! : green;

    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedCrop,
      onChanged: (value) {
        setState(() {
          _selectedCrop = value;
          _productId.text = value != null ? value['id'].toString() : '';
        });
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
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
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final iconColors = isDarkMode ? Colors.white : black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _cancelCreation,
          icon: Icon(Icons.close, color: iconColors),
        ),
        title: const Text('Creer un besoin'),
        // Text(AppLocales.getTranslation('create_seller_need', locale)),
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
                  _buildDropdownField(),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isDarkMode ? Colors.black : lightGreen,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: _buildTextField(
                      controller: _quantity,
                      label: AppLocales.getTranslation('quantity', locale),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoading ? null : _addSellerNeed,
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
}
