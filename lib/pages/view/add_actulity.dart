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
import 'package:new_oppsfarm/pages/view/models/opps-model.dart'; // Ajout pour OppsModel
import 'package:new_oppsfarm/providers/locale_provider.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  XFile? _image;
  bool _isPosting = false;
  bool _isLoading = false;
  dynamic connectedUser;

  final AuthService _authService = AuthService();
  final HttpService _httpService = HttpService();

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

// void _publishPost() async {
//   setState(() {
//     _isPosting = true;
//   });

//   final int posterId = connectedUser['id'];
//   final String? content = _contentController.text.isNotEmpty ? _contentController.text : null;
//   String? imageUrl;
//   try {
//     if (_image != null) {
//       imageUrl = await _httpService.uploadImage(File(_image!.path));
//     }

//     if (content == null && imageUrl == null) {
//       throw Exception("Ajoutez du texte ou une image avant de publier.");
//     }

//     // Créer le post via le service HTTP
//     String message = await _httpService.createPost(
//       user: posterId,
//       content: content,
//       image: imageUrl ?? "",
//     );

//     // Construire un nouvel objet OppsModel pour le post créé
//     final newPost = OppsModel(
//       id: DateTime.now().millisecondsSinceEpoch, // ID temporaire, remplacez par l'ID réel si renvoyé par l'API
//       user: User(
//         id: posterId,
//         nom: connectedUser['nom'] ?? '',
//         prenom: connectedUser['prenom'] ?? '',
//         email: connectedUser['email'] ?? '',
//         proofile: null, // Corrigez en profile si nécessaire
//       ),
//       content: content,
//       image: imageUrl,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(), // Ajouté pour le champ requis
//       comments: [], // Liste vide pour les commentaires
//       likes: [], // Liste vide pour les likes (List<Like>)
//       sharedFrom: null, // Pas de post partagé à l'origine
//       sharedPosts: [], // Liste vide pour les partages (List<OppsModel>)
//       likesCount: ValueNotifier(0),
//       sharedPostsCount: ValueNotifier(0),
//       isLiked: ValueNotifier(false),
//       likedBy: [], // Liste vide pour les utilisateurs ayant aimé
//     );

//     // Mettre à jour l'état de actualityProvider
//     ref.read(actualityProvider.notifier).state = ref.read(actualityProvider).copyWith(
//       posts: [newPost, ...ref.read(actualityProvider).posts],
//     );

//     setState(() {
//       _isPosting = false;
//     });

//     // Afficher une confirmation via SnackBar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );

//     // Réinitialiser le formulaire
//     _contentController.clear();
//     setState(() {
//       _image = null;
//     });

//     // Revenir à la page précédente (Actuality)
//     Navigator.pop(context);
//   } catch (e) {
//     setState(() {
//       _isPosting = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Erreur : ${e.toString()}"),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }

  void _publishPost() async {
    setState(() {
      _isPosting = true;
    });

    final int posterId = connectedUser['id'];
    final String? content =
        _contentController.text.isNotEmpty ? _contentController.text : null;
    String? imageUrl;
    try {
      if (_image != null) {
        imageUrl = await _httpService.uploadImage(File(_image!.path));
      }

      if (content == null && imageUrl == null) {
        throw Exception("Ajoutez du texte ou une image avant de publier.");
      }

      String message = await _httpService.createPost(
        user: posterId,
        content: content,
        image: imageUrl ?? "",
      );

      final newPost = OppsModel(
        id: DateTime.now().millisecondsSinceEpoch,
        user: User(
          id: posterId,
          nom: connectedUser['nom'] ?? '',
          prenom: connectedUser['prenom'] ?? '',
          email: connectedUser['email'] ?? '',
          proofile:
              null, // Consider correcting to 'profile' if that's the intended field
        ),
        content: content,
        image: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        comments: [],
        likes: [],
        sharedFrom: null,
        sharedPosts: [],
        likesCount: ValueNotifier(0),
        sharedPostsCount: ValueNotifier(0),
        isLiked: ValueNotifier(false),
        likedBy: [],
      );

      ref.read(actualityProvider.notifier).state =
          ref.read(actualityProvider).copyWith(
        posts: [newPost, ...ref.read(actualityProvider).posts],
      );

      setState(() {
        _isPosting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

      _contentController.clear();
      setState(() {
        _image = null;
      });

      Navigator.pop(context);
    } catch (e, stackTrace) {
      // Print error and stack trace to console
      print('Error posting: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isPosting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelPostCreation() {
    Navigator.pop(context);
  }

  void _saveAsDraft() {
    setState(() {
      _isPosting = true;
    });

    setState(() {
      _isPosting = false;
    });

    final locale = ref.read(localeProvider).languageCode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocales.getTranslation('saved_as_draft', locale))),
    );
  }

  @override
  void initState() {
    connectUser();
    super.initState();
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
          onPressed: _cancelPostCreation,
          icon: Icon(
            Icons.close,
            color: isDarkMode ? Colors.white : Colors.red,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _saveAsDraft,
            child: Text(
              AppLocales.getTranslation('draft', locale),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: _isPosting ? null : _publishPost,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocales.getTranslation('publish', locale),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.send,
                      color: white,
                    )
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocales.getTranslation('create_post_title', locale),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _contentController,
                      maxLength: 300,
                      decoration: InputDecoration(
                        hintText: AppLocales.getTranslation(
                            'write_something', locale),
                        border: InputBorder.none,
                      ),
                      maxLines: 6,
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.file(
                          File(_image!.path),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
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
