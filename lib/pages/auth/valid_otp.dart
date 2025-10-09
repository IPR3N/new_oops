import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

class ValidOtp extends StatefulWidget {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  const ValidOtp(
      {super.key,
      required this.email,
      required this.password,
      required this.nom,
      required this.prenom});
  @override
  State<ValidOtp> createState() => _ValidOtpState();
}

class _ValidOtpState extends State<ValidOtp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  late Timer _timer;

  int _remainingTime = 180;

  void _validOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final code = _otpController.text;
      final email = widget.email;
      final nom = widget.nom;
      final prenom = widget.prenom;
      final password = widget.password;
      bool success = await _authService.verfyCode(
        nom: nom,
        prenom: prenom,
        email: email,
        code: code,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Code incorrect, veuillez réessayer'),
        ));
      }
    }
  }

  void _regenerateOtp() async {
    final email = widget.email;

    bool success = await _authService.regenerateCode(email: email);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Un nouveau code a été envoyé à votre adresse email.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Une erreur s\'est produite lors de la régénération du code.'),
      ));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          _showTimeoutAlert();
        }
      });
    });
  }

  void _showTimeoutAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Temps écoulé'),
          content: const Text(
              'Le temps imparti pour saisir le code est écoulé. Veuillez régénérer un nouveau code.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _regenerateOtp();
              },
              child: const Text('OUI'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer();
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
                        const SizedBox(height: 20),
                        Text(
                          'Temps restant: ${_remainingTime ~/ 60}:${_remainingTime % 60}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
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
