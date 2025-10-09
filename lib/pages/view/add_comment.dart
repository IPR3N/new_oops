import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/view/actuality.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class AddComment extends ConsumerStatefulWidget {
  final OppsModel post;

  const AddComment({super.key, required this.post});

  @override
  ConsumerState<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends ConsumerState<AddComment> {
  final TextEditingController _commentController = TextEditingController();
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  dynamic connectedUser;

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

  void _cancelPostCreation() {
    Navigator.pop(context);
  }

  void _postComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Utilisateur connecté, pas l'auteur du post

    final int userId = connectedUser['id'];

    final String content = _commentController.text;
    final int oops = widget.post.id;

    try {
      // Ajouter un timeout pour éviter un chargement infini
      final responseData = await _httpService
          .createComment(
        oops: oops,
        user: userId,
        content: content,
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Délai d'attente dépassé");
      });

      if (responseData != null && responseData.isNotEmpty) {
        final newComment = Comment(
          id: responseData['id'] ??
              DateTime.now()
                  .millisecondsSinceEpoch, // ID temporaire si non fourni
          user: User(
            id: userId,
            nom: connectedUser['nom'] ?? '',
            prenom: connectedUser['prenom'] ?? '',
            email: connectedUser['email'] ?? '',
            proofile: null,
          ),
          content: content,
          createdAt: DateTime.now(),
        );

        final posts = ref.read(actualityProvider).posts;
        final postIndex = posts.indexWhere((p) => p.id == widget.post.id);
        if (postIndex != -1) {
          final updatedPost = posts[postIndex].copyWith(
            comments: [...posts[postIndex].comments, newComment],
          );
          ref.read(actualityProvider.notifier).state =
              ref.read(actualityProvider).copyWith(
            posts: [
              ...posts.sublist(0, postIndex),
              updatedPost,
              ...posts.sublist(postIndex + 1),
            ],
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                AppLocales.getTranslation(
                    'comment_success', ref.read(localeProvider).languageCode)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Réponse invalide de l'API");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final textColorUser = isDarkMode ? Colors.green : Colors.green;

    final formattedDatePost = widget.post.createdAt != null
        ? DateFormat('MMM d, yyyy').format(widget.post.createdAt!)
        : AppLocales.getTranslation('date_unavailable', locale);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppLocales.getTranslation('add_comment', locale)),
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          onPressed: _cancelPostCreation,
          icon: Icon(Icons.close, color: textColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _postComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocales.getTranslation('post', locale),
                      style: const TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original Post Card
              Card(
                color: backgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.post.user.proofile?.photoProfile
                                      ?.isNotEmpty ==
                                  true
                              ? CachedNetworkImage(
                                  imageUrl:
                                      widget.post.user.proofile!.photoProfile!,
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.post.user.nom} ${widget.post.user.prenom}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  formattedDatePost,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.post.content ?? '',
                              style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      textColor), // Removed fontWeight: FontWeight.bold
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Comment Input Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: connectedUser != null &&
                              connectedUser['photoProfile']?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: connectedUser['photoProfile'],
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      color: backgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (connectedUser != null)
                              Text(
                                "${connectedUser['nom']} ${connectedUser['prenom']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _commentController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText:
                                    "${AppLocales.getTranslation('reply_to', locale)} @${widget.post.user.nom}...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: textColor.withOpacity(0.6),
                                    fontSize: 14),
                              ),
                              style: TextStyle(color: textColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
