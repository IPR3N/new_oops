// import 'package:flutter/material.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/pages/auth/login.dart';

// class Splash extends StatefulWidget {
//   const Splash({super.key});

//   @override
//   State<Splash> createState() => _SplashState();
// }

// class _SplashState extends State<Splash> {
//   @override
//   void initState() {
//     super.initState();

//     // Naviguer vers la LoginPage après 3 secondes avec une transition
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.of(context).pushReplacement(
//         PageRouteBuilder(
//           transitionDuration:
//           const Duration(milliseconds: 900), // Durée de la transition
//           pageBuilder: (context, animation, secondaryAnimation) =>
//           const LoginPage(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             // Animation de fondu entrant
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: isDarkMode ? Colors.black : green,
//             ),
//             child: Center(
//               child: Image.asset(
//                 'assets/images/icon-oops.3.png',
//                 width: 160,
//                 height: 250,
//                 color: isDarkMode ? Colors.white : null, // Adapte l'image au mode sombre
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Image.asset(
//                 'assets/images/icon1.png',
//                 width: 65,
//                 height: 70,
//                 color: isDarkMode ? Colors.white : null, // Adapte l'image au mode sombre
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart'; // Importer AuthService
import 'package:new_oppsfarm/pages/view/home.dart'; // Importer la page Home
import 'package:jwt_decoder/jwt_decoder.dart'; // Pour décoder le token

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Vérifier si un token existe
    String? token = await _authService.getToken();

    if (token != null && !JwtDecoder.isExpired(token)) {
      // Si le token existe et n'est pas expiré, aller directement à la page Home
      final decodedToken = JwtDecoder.decode(token);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } else {
      // Sinon, aller à la page de connexion
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 900),
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : green,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/icon-oops.3.png',
                width: 160,
                height: 250,
                color: isDarkMode ? Colors.white : null,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/icon1.png',
                width: 65,
                height: 70,
                color: isDarkMode ? Colors.white : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}