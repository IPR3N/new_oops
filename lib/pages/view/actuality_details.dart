import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added new import
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/view/actuality.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/profile/profile_page.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActualityDetails extends ConsumerStatefulWidget {
  final int id;
  final String image;
  final String? createdAt;
  final String content;
  final User user; // Post author
  final List<int> likedBy;
  final List<Comment> comments;
  final List<dynamic> likes;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final bool isLiked;
  final int? connectedUserId; // Logged-in user's ID (optional fallback)

  const ActualityDetails({
    super.key,
    required this.id,
    required this.image,
    this.createdAt,
    required this.content,
    required this.user,
    required this.likedBy,
    required this.comments,
    required this.likes,
    required this.likesCount,
    required this.commentsCount,
    required this.onLike,
    required this.onComment,
    required this.isLiked,
    this.connectedUserId,
  });

  @override
  ConsumerState<ActualityDetails> createState() => _ActualityDetailsState();
}

class _ActualityDetailsState extends ConsumerState<ActualityDetails> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  late List<Comment> _comments;
  final HttpService _httpService = HttpService();
  String _selectedFilter = 'All Comments';

  @override
  void initState() {
    super.initState();
    _comments = widget.comments.map((c) => Comment(
          id: c.id,
          content: c.content,
          user: c.user,
          createdAt: c.createdAt,
          likesCount: c.likesCount ?? 0,
        )).toList();
  }

  void onComment() {
    final locale = ref.read(localeProvider).languageCode;
    final connectedUser = ref.read(actualityProvider).connectedUser; // Logged-in user
    if (connectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('login_required', locale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final int userId = connectedUser['id'] ?? widget.connectedUserId ?? widget.user.id;
    final int oops = widget.id;
    final String content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('field_required', locale)),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    _httpService.createComment(oops: oops, user: userId, content: content).then((responseData) {
      if (responseData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? AppLocales.getTranslation('comment_success', locale)),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          final commenterUser = User(
            id: userId,
            nom: connectedUser['nom'] ?? widget.user.nom,
            prenom: connectedUser['prenom'] ?? widget.user.prenom,
            email: connectedUser['email'] ?? widget.user.email,
          );
          _comments.add(Comment(
            id: responseData['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
            content: content,
            user: commenterUser,
            createdAt: DateTime.now(),
            likesCount: responseData['likesCount'] as int? ?? 0,
          ));
          _contentController.clear();
        });
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('comment_error', locale, placeholders: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }).whenComplete(() => setState(() => _isLoading = false));
  }

  List<Comment> _filterComments() {
    final filteredComments = List<Comment>.from(_comments);
    switch (_selectedFilter) {
      case 'Most Relevant':
      case 'Most Liked':
        filteredComments.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case 'Most Recent':
        filteredComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'All Comments':
      default:
        break;
    }
    return filteredComments;
  }

  void _viewUserProfile(User userToView) {
    final connectedUser = ref.read(actualityProvider).connectedUser;
    final int? visitorId = connectedUser?['id'] ?? widget.connectedUserId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          connectedUser: {
            "id": userToView.id,
            "nom": userToView.nom,
            "prenom": userToView.prenom,
            "email": userToView.email,
            "profile": userToView.proofile?.toJson() ?? {},
          },
          visitorId: visitorId,
        ),
      ),
    );
  }

  Widget _buildProfileImage(User user, double size) {
    return GestureDetector(
      onTap: () => _viewUserProfile(user),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: user.proofile?.photoProfile?.isNotEmpty == true
              ? CachedNetworkImage(
                  imageUrl: user.proofile!.photoProfile!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: size / 2,
                  ),
                )
              : Icon(Icons.person, color: Colors.grey, size: size / 2),
        ),
      ),
    );
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
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final textColorUser = isDarkMode ? Colors.green : Colors.green;

    final formattedDatePost = widget.createdAt != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(widget.createdAt!))
        : 'Date unavailable';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppLocales.getTranslation('oops', locale)),
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(color: textColor, fontSize: 20),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: backgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            Row(
                              children: [
                                _buildProfileImage(widget.user, 50),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => _viewUserProfile(widget.user),
                                              child: Text(
                                                '${widget.user.nom} ${widget.user.prenom}',
                                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formattedDatePost,
                                            style: TextStyle(fontSize: 12.0, color: textColor.withOpacity(0.6)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        widget.user.email,
                                        style: TextStyle(fontSize: 12.0, color: textColor.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              widget.content,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                            ),
                            const SizedBox(height: 20.0),
                            if (widget.image.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 230,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    height: 230,
                                    width: double.infinity,
                                  ),
                                  errorWidget: (context, url, error) => Container(),
                                ),
                              ),
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-3, 0),
                                      child: GestureDetector(
                                        onTap: widget.onComment,
                                        child: Icon(Icons.message_outlined, color: textColor, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${widget.commentsCount}', style: TextStyle(color: textColor)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-3, 0),
                                      child: GestureDetector(
                                        onTap: widget.onLike,
                                        child: Icon(
                                          widget.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                          color: widget.isLiked ? Colors.teal : textColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${widget.likesCount}', style: TextStyle(color: textColor)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-3, 0),
                                      child: GestureDetector(
                                        onTap: () => print('Share tapped'),
                                        child: Icon(Icons.share_outlined, color: textColor, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${widget.likesCount}', style: TextStyle(color: textColor)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocales.getTranslation('comments', locale),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        DropdownButton<String>(
                          value: _selectedFilter,
                          items: [
                            'All Comments',
                            'Most Relevant',
                            'Most Liked',
                            'Most Recent',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(color: textColor)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFilter = newValue!;
                            });
                          },
                          underline: Container(),
                          icon: Icon(Icons.filter_list, color: textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    _comments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                AppLocales.getTranslation('no_comments', locale),
                                style: TextStyle(color: textColor.withOpacity(0.6)),
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              Positioned(
                                left: 20,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filterComments().length,
                                itemBuilder: (context, index) {
                                  final comment = _filterComments()[index];
                                  final formattedDateComment = timeago.format(comment.createdAt, locale: locale);

                                  return Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            _buildProfileImage(comment.user, 40),
                                            Positioned(
                                              left: 20,
                                              child: Container(
                                                width: 10,
                                                height: 2,
                                                color: Colors.grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Card(
                                            color: backgroundColor,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                              margin: const EdgeInsets.only(top: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () => _viewUserProfile(comment.user),
                                                          child: Text(
                                                            '${comment.user.nom} ${comment.user.prenom}',
                                                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        formattedDateComment,
                                                        style: TextStyle(fontSize: 12.0, color: textColor.withOpacity(0.6)),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'En réponse à ',
                                                      style: TextStyle(fontSize: 12.0, color: textColor.withOpacity(0.6)),
                                                      children: [
                                                        TextSpan(
                                                          text: '${widget.user.nom} ${widget.user.prenom}',
                                                          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: textColorUser),
                                                          recognizer: TapGestureRecognizer()..onTap = () => _viewUserProfile(widget.user),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  Text(
                                                    comment.content,
                                                    style: TextStyle(fontSize: 14.0, color: textColor),
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => print('Comment reply tapped'),
                                                            child: Icon(Icons.message_outlined, color: textColor, size: 18),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => print('Like comment tapped'),
                                                            child: Icon(Icons.thumb_up_alt_outlined, color: textColor, size: 18),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text('${comment.likesCount}', style: TextStyle(color: textColor, fontSize: 12)),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => print('Share comment tapped'),
                                                            child: Icon(Icons.share_outlined, color: textColor, size: 18),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: AppLocales.getTranslation('add_comment', locale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.green, width: 1.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : onComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          AppLocales.getTranslation('send', locale),
                          style: const TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}