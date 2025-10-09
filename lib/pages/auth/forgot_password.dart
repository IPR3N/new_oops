import 'package:flutter/material.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/pages/auth/restaure_otp.dart';
import 'package:new_oppsfarm/pages/auth/restaure_password.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mailController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late final int userId;
  String email = '';
  void _checkEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      email = _mailController.text;
      Map<String, dynamic> result = await _authService.checkEmail(
        email: email,
      );
      setState(() {
        _isLoading = false;
      });
      if (result['success']) {
        // print(result);
        userId = result['user']['id'];
        email = result['user']['email'];
        _showSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    // final textColor = isDarkMode ? Colors.white : green;
    // final cardColor = isDarkMode ? Colors.grey[900] : white;
    // final borderColor = isDarkMode ? Colors.grey[700]! : green;
    // final iconColor = isDarkMode ? Colors.white : black;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Code de vérification envoyé à votre adresse e-mail',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaureOtp(
              id: userId,
              email: email,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    // final textColor = isDarkMode ? Colors.white : green;
    // final cardColor = isDarkMode ? Colors.grey[900] : white;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    // final iconColor = isDarkMode ? Colors.white : black;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            Container(
              height: 250,
              decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(95),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/oops_blanc.png',
                      height: 60,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Verication d\'adresse mail',
                      style: TextStyle(
                        fontSize: 25,
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // color: white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // const SizedBox(height: 20),
                        // Text(
                        //   'Temps restant: ${_remainingTime ~/ 60}:${_remainingTime % 60}',
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.red,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _mailController,
                          decoration: InputDecoration(
                            labelText: 'Veuiilez saisir votre address mail',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.lock, color: green),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                // color: white,
                                width: 0.8,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: _checkEmail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Valider',
                                      style: TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
