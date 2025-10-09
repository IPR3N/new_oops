// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/auth/forgot_password.dart';
// import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
// import 'package:new_oppsfarm/pages/auth/sign_up.dart';
// import 'package:new_oppsfarm/pages/view/home.dart';
// import 'package:new_oppsfarm/profile/create_profile.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';

// class LoginPage extends ConsumerStatefulWidget { // Changement en ConsumerStatefulWidget
//   const LoginPage({super.key});

//   @override
//   ConsumerState<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends ConsumerState<LoginPage> { // ConsumerState pour Riverpod
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _useremailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   final AuthService _authService = AuthService();

//   void _login() async {
//     final locale = ref.read(localeProvider).languageCode; // Récupère la langue courante
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final result = await _authService.login(
//         email: _useremailController.text,
//         password: _passwordController.text,
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (result['success']) {
//         final decodeToken = JwtDecoder.decode(result['token']);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppLocales.getTranslation('login_success', locale)),
//             backgroundColor: Colors.green,
//           ),
//         );

//         if (decodeToken['profile'] == null) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => CreateProfile(userId: decodeToken['id'])),
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => const Home()),
//             (Route<dynamic> route) => false,
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? AppLocales.getTranslation('incorrect_credentials', locale)),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black : white;
//     final cardColor = isDarkMode ? Colors.black : white;
//     final locale = ref.watch(localeProvider).languageCode; // Écoute la langue courante

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: Stack(
//         children: [
//           Container(
//             margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
//             padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//           ),
//           SingleChildScrollView(
//             child: Container(
//               margin: const EdgeInsets.only(left: 30, right: 30, top: 60),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 30),
//                   Image.asset(
//                     'assets/images/oops_noir.png',
//                     height: 60,
//                   ),
//                   const SizedBox(height: 90.0),
//                   Material(
//                     elevation: 3,
//                     borderRadius: BorderRadius.circular(30),
//                     child: Container(
//                       height: MediaQuery.of(context).size.height / 2.3,
//                       decoration: BoxDecoration(
//                         color: cardColor,
//                         border: Border.all(color: cardColor),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 20.0),
//                           Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 20.0),
//                             child: Center(
//                               child: SingleChildScrollView(
//                                 child: Form(
//                                   key: _formKey,
//                                   child: Column(
//                                     children: [
//                                       const SizedBox(height: 25.0),
//                                       _buildTextField(
//                                         controller: _useremailController,
//                                         label: AppLocales.getTranslation('email_label', locale),
//                                         icon: Icons.email,
//                                       ),
//                                       const SizedBox(height: 25.0),
//                                       _buildTextField(
//                                         controller: _passwordController,
//                                         label: AppLocales.getTranslation('password_label', locale),
//                                         icon: Icons.lock,
//                                         obscureText: _obscurePassword,
//                                         onVisibilityToggle: () {
//                                           setState(() {
//                                             _obscurePassword = !_obscurePassword;
//                                           });
//                                         },
//                                       ),
//                                       const SizedBox(height: 25.0),
//                                       GestureDetector(
//                                         onTap: _isLoading ? null : _login,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(vertical: 12.0),
//                                           margin: const EdgeInsets.symmetric(horizontal: 2),
//                                           width: MediaQuery.of(context).size.width,
//                                           decoration: BoxDecoration(
//                                             color: _isLoading ? lightGreen : green,
//                                             borderRadius: BorderRadius.circular(5),
//                                           ),
//                                           child: Center(
//                                             child: _isLoading
//                                                 ? const CircularProgressIndicator(color: Colors.white)
//                                                 : Text(
//                                                     AppLocales.getTranslation('login_button', locale),
//                                                     style: const TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 20,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                   ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 25.0),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: <Widget>[
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
//                                               );
//                                             },
//                                             style: TextButton.styleFrom(foregroundColor: green),
//                                             child: Text(
//                                               AppLocales.getTranslation('forgot_password', locale),
//                                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(builder: (context) => const SignUpPage()),
//                                               );
//                                             },
//                                             style: TextButton.styleFrom(foregroundColor: green),
//                                             child: Text(
//                                               AppLocales.getTranslation('sign_up', locale),
//                                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     VoidCallback? onVisibilityToggle,
//   }) {
//     final locale = ref.read(localeProvider).languageCode; // Récupère la langue courante
//     return TextFormField(
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return AppLocales.getTranslation('field_required', locale);
//         }
//         return null;
//       },
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: green),
//         suffixIcon: obscureText
//             ? IconButton(
//                 icon: Icon(
//                   _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   color: green,
//                 ),
//                 onPressed: onVisibilityToggle,
//               )
//             : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: green, width: 1.5),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/forgot_password.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/auth/sign_up.dart';
import 'package:new_oppsfarm/pages/view/home.dart';
import 'package:new_oppsfarm/profile/create_profile.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _useremailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  void _login() async {
    final locale = ref.read(localeProvider).languageCode;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _authService.login(
        email: _useremailController.text,
        password: _passwordController.text,
      );

      print('Résultat de la connexion : $result');

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        try {
          final decodeToken = JwtDecoder.decode(result['token']);
          print('Token décodé : $decodeToken');
          print('Profile dans le token : ${decodeToken['profile']}');

          String? storedToken = await _authService.getToken();
          print('Token stocké : $storedToken');

          // Afficher le SnackBar uniquement si le widget est encore monté
          // if (mounted) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(AppLocales.getTranslation('login_success', locale)),
          //       backgroundColor: Colors.green,
          //       duration: const Duration(seconds: 1), // Durée courte pour éviter un conflit
          //     ),
          //   );
          // }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocales.getTranslation('login_success', locale)),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          });

          // Attendre un court délai avant la navigation pour stabiliser l'état
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              if (decodeToken['profile'] == null ||
                  decodeToken['profile'].isEmpty) {
                print('Redirection vers CreateProfile');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateProfile(userId: decodeToken['id'])),
                  (Route<dynamic> route) => false,
                );
              } else {
                print('Redirection vers Home');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (Route<dynamic> route) => false,
                );
              }
            } else {
              print('Widget non monté, navigation annulée');
            }
          });
        } catch (e) {
          print('Erreur lors du décodage du token : $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la connexion : $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        print('Échec de la connexion : ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ??
                  AppLocales.getTranslation('incorrect_credentials', locale)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _useremailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final cardColor = isDarkMode ? Colors.black : white;
    final locale = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
            padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(left: 30, right: 30, top: 60),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/images/oops_noir.png',
                    height: 60,
                  ),
                  const SizedBox(height: 90.0),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2.3,
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: cardColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 25.0),
                                      _buildTextField(
                                        controller: _useremailController,
                                        label: AppLocales.getTranslation(
                                            'email_label', locale),
                                        icon: Icons.email,
                                      ),
                                      const SizedBox(height: 25.0),
                                      _buildTextField(
                                        controller: _passwordController,
                                        label: AppLocales.getTranslation(
                                            'password_label', locale),
                                        icon: Icons.lock,
                                        obscureText: _obscurePassword,
                                        onVisibilityToggle: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 25.0),
                                      GestureDetector(
                                        onTap: _isLoading ? null : _login,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color:
                                                _isLoading ? lightGreen : green,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: _isLoading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white)
                                                : Text(
                                                    AppLocales.getTranslation(
                                                        'login_button', locale),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ForgotPasswordPage()),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                                foregroundColor: green),
                                            child: Text(
                                              AppLocales.getTranslation(
                                                  'forgot_password', locale),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SignUpPage()),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                                foregroundColor: green),
                                            child: Text(
                                              AppLocales.getTranslation(
                                                  'sign_up', locale),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onVisibilityToggle,
  }) {
    final locale = ref.read(localeProvider).languageCode;
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocales.getTranslation('field_required', locale);
        }
        return null;
      },
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: green),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: green,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
    );
  }
}
