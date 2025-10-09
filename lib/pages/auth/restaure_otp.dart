import 'package:flutter/material.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/pages/auth/restaure_password.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

class RestaureOtp extends StatefulWidget {
  final int id;
  final String email;
  const RestaureOtp({super.key, required this.id, required this.email});

  @override
  State<RestaureOtp> createState() => _RestaureOtpState();
}

class _RestaureOtpState extends State<RestaureOtp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  late final int userId;
  late String useremail;
  final AuthService _authService = AuthService();
  void _validOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final String email = widget.email;
      final String code = _otpController.text;

      Map<String, dynamic> result = await _authService.verifyCodeAndEmail(
        email: email,
        code: code,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        userId = result['user']['id'];
        // email = result['user']['email'];
        if (widget.email == result['user']['email']) {
          useremail = result['user']['email'];
        }
        _showSuccessDialog(context);
        // Navigator.pushReplacementNamed(context, '/restaure-password');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      }

      _otpController.clear();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: lightGreen,
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
                  'Code de vérification correct',
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
            builder: (context) => RestaurePassword(
              id: userId,
              email: useremail,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: green,
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
                      'Verification de code',
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
                    border: Border.all(color: green),
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
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Veuiilez saisir le code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.lock, color: green),
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

                        // Bouton Inscription
                        GestureDetector(
                          onTap: _validOtp,
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
