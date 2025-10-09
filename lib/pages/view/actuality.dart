import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/main.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/story/story_feed_page.dart';
import 'package:new_oppsfarm/pages/view/actuality_details.dart';
import 'package:new_oppsfarm/pages/view/add_actulity.dart';
import 'package:new_oppsfarm/pages/view/add_comment.dart';
import 'package:new_oppsfarm/pages/view/edit_post.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/pages/view/settings_page.dart';
import 'package:new_oppsfarm/profile/profile_page.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:new_oppsfarm/reusableComponent/drawer.dart';
import 'package:new_oppsfarm/socket/socket-service.dart';
import 'package:equatable/equatable.dart';

// Actuality State Model
class ActualityState with EquatableMixin {
  final List<OppsModel> posts;
  final List<OppsModel> newPosts;
  final Map<String, dynamic>? connectedUser;
  final bool isLoading;
  final bool showNewPostsNotification;

  const ActualityState({
    required this.posts,
    required this.newPosts,
    this.connectedUser,
    required this.isLoading,
    required this.showNewPostsNotification,
  });

  factory ActualityState.initial() => const ActualityState(
        posts: [],
        newPosts: [],
        connectedUser: null,
        isLoading: false,
        showNewPostsNotification: false,
      );

  ActualityState copyWith({
    List<OppsModel>? posts,
    List<OppsModel>? newPosts,
    Map<String, dynamic>? connectedUser,
    bool? isLoading,
    bool? showNewPostsNotification,
  }) {
    return ActualityState(
      posts: posts ?? this.posts,
      newPosts: newPosts ?? this.newPosts,
      connectedUser: connectedUser ?? this.connectedUser,
      isLoading: isLoading ?? this.isLoading,
      showNewPostsNotification:
          showNewPostsNotification ?? this.showNewPostsNotification,
    );
  }

  @override
  List<Object?> get props =>
      [posts, newPosts, connectedUser, isLoading, showNewPostsNotification];
}

// Actuality Notifier
class ActualityNotifier extends StateNotifier<ActualityState> {
  final HttpService _httpService;
  final AuthService _authService;
  final WebSocketService _webSocketService;
  final Ref _ref;

  ActualityNotifier(
      this._httpService, this._authService, this._webSocketService, this._ref)
      : super(ActualityState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectUser();
    await _fetchPosts();
    _listenForUpdates();
  }

  Future<void> _connectUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _authService.readToken();
      if (token != null) {
        state = state.copyWith(connectedUser: JwtDecoder.decode(token));
      } else {
        print("No token found!");
      }
    } catch (e) {
      print("Error connecting user: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _fetchPosts() async {
    state = state.copyWith(isLoading: true);
    try {
      final List<dynamic> response = await _httpService.getOopsPost();
      state = state.copyWith(
        posts: response.map((data) => OppsModel.fromJson(data)).toList(),
      );
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _listenForUpdates() {
    _webSocketService.socket.on('likeUpdated', (data) {
      final int postId = data['postId'];
      final int newLikesCount = data['newLikesCount'] ?? data['likeCount'] ?? 0;
      final List<int> newLikedBy =
          data['likedBy'] != null ? List<int>.from(data['likedBy']) : [];

      final index = state.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = state.posts[index];
        final updatedPost = post.copyWith(
          likesCount: ValueNotifier(newLikesCount),
          likedBy: newLikedBy,
          likes: newLikedBy.map((id) => Like(userId: id)).toList(),
          isLiked:
              ValueNotifier(newLikedBy.contains(state.connectedUser?['id'])),
        );
        state = state.copyWith(
          posts: List.from(state.posts)..[index] = updatedPost,
        );
        print(
            'WebSocket updated post $postId: likesCount=$newLikesCount, likedBy=$newLikedBy');
      }
    });

    _webSocketService.socket.on('commentAdded', (data) {
      final int postId = data['postId'];
      final Comment newComment = Comment.fromJson(data['comment']);
      final index = state.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        state = state.copyWith(
          posts: List.from(state.posts)
            ..[index] = state.posts[index].copyWith(
              comments: List.from(state.posts[index].comments)..add(newComment),
            ),
        );
      }
    });

    _webSocketService.socket.on('postShared', (data) {
      final int postId = data['postId'];
      final int newShareCount = data['newShareCount'] ?? 0;
      final index = state.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        state = state.copyWith(
          posts: List.from(state.posts)
            ..[index] = state.posts[index].copyWith(
              sharedPostsCount: ValueNotifier(newShareCount),
            ),
        );
      }
    });

    _webSocketService.socket.on('newPostCreated', (data) {
      print("New post received from server: $data");
      try {
        final newPost = OppsModel.fromJson(data);
        if (!state.posts.any((p) => p.id == newPost.id) &&
            !state.newPosts.any((p) => p.id == newPost.id)) {
          final scrollController = _ref.read(scrollControllerProvider);
          if (scrollController.hasClients && scrollController.offset <= 0) {
            state = state.copyWith(
              posts: [newPost, ...state.posts],
              newPosts: state.newPosts,
            );
          } else {
            state = state.copyWith(
              newPosts: [...state.newPosts, newPost],
              showNewPostsNotification: true,
            );
          }
        }
      } catch (e) {
        print("Error parsing new post: $e");
      }
    });
  }

  Future<void> toggleLike(int postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1 || state.connectedUser == null) {
      print('Post not found or user not connected');
      return;
    }

    final post = state.posts[index];
    final int userId = state.connectedUser!['id'];
    final bool hasLiked = post.likedBy.contains(userId);
    final bool newLikeStatus = !hasLiked;
    final int newLikesCount = post.likesCount.value + (newLikeStatus ? 1 : -1);
    final List<int> newLikedBy = newLikeStatus
        ? [...post.likedBy, userId]
        : post.likedBy.where((id) => id != userId).toList();
    final List<Like> newLikes = newLikeStatus
        ? [...post.likes, Like(userId: userId)]
        : post.likes.where((like) => like.userId != userId).toList();

    // Optimistic update
    state = state.copyWith(
      posts: List.from(state.posts)
        ..[index] = post.copyWith(
          likedBy: newLikedBy,
          likes: newLikes,
          likesCount: ValueNotifier(newLikesCount),
          isLiked: ValueNotifier(newLikeStatus),
        ),
    );

    try {
      final success =
          await _httpService.likePost(postId.toString(), userId, newLikeStatus);
      if (!success) {
        throw Exception('Failed to like post');
      }
      _webSocketService.sendLikeUpdate(postId, newLikesCount, newLikedBy);
    } catch (e) {
      // Revert on failure
      state = state.copyWith(
        posts: List.from(state.posts)
          ..[index] = post.copyWith(
            likedBy: post.likedBy,
            likes: post.likes,
            likesCount: ValueNotifier(post.likesCount.value),
            isLiked: ValueNotifier(hasLiked),
          ),
      );
      print('Error toggling like: $e');
    }
  }

  Future<void> sharePost(int postId, String shareContent) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1 || state.connectedUser == null) return;

    final originalPost = state.posts[index];
    state = state.copyWith(isLoading: true);
    try {
      final success = await _httpService.shareOops(postId, shareContent);
      if (success) {
        final newShareCount = originalPost.sharedPostsCount.value + 1;
        final newPost = OppsModel(
          id: DateTime.now().millisecondsSinceEpoch,
          content: shareContent,
          image: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          user: User(
            id: state.connectedUser!['id'],
            nom: state.connectedUser!['nom'],
            prenom: state.connectedUser!['prenom'],
            email: state.connectedUser!['email'],
            proofile: originalPost.user.proofile,
          ),
          comments: [],
          likes: [],
          sharedFrom: originalPost,
          sharedPosts: [],
          likesCount: ValueNotifier(0),
          sharedPostsCount: ValueNotifier(0),
          isLiked: ValueNotifier(false),
          likedBy: [],
        );

        // First update the original post's share count
        final updatedPosts = List.from(state.posts)
          ..[index] = originalPost.copyWith(
            sharedPostsCount: ValueNotifier(newShareCount),
          );

        // Then add the new shared post to the list
        state = state.copyWith(
          posts: [newPost, ...updatedPosts],
          isLoading: false,
        );

        _webSocketService.sendShareUpdate(postId, newShareCount);
      } else {
        throw Exception('Failed to share post');
      }
    } catch (e) {
      print("Error sharing post: $e");
      state = state.copyWith(isLoading: false);
    }
  }
  // Future<void> sharePost(int postId, String shareContent) async {
  //   final index = state.posts.indexWhere((p) => p.id == postId);
  //   if (index == -1 || state.connectedUser == null) return;

  //   final originalPost = state.posts[index];
  //   state = state.copyWith(isLoading: true);
  //   try {
  //     final success = await _httpService.shareOops(postId, shareContent);
  //     if (success) {
  //       final newShareCount = originalPost.sharedPostsCount.value + 1;
  //       state = state.copyWith(
  //         posts: List.from(state.posts)
  //           ..[index] = originalPost.copyWith(
  //             sharedPostsCount: ValueNotifier(newShareCount),
  //           ),
  //         posts: [
  //           OppsModel(
  //             id: DateTime.now().millisecondsSinceEpoch,
  //             content: shareContent,
  //             image: null,
  //             createdAt: DateTime.now(),
  //             updatedAt: DateTime.now(),
  //             user: User(
  //               id: state.connectedUser!['id'],
  //               nom: state.connectedUser!['nom'],
  //               prenom: state.connectedUser!['prenom'],
  //               email: state.connectedUser!['email'],
  //               proofile: originalPost.user.proofile,
  //             ),
  //             comments: [],
  //             likes: [],
  //             sharedFrom: originalPost,
  //             sharedPosts: [],
  //             likesCount: ValueNotifier(0),
  //             sharedPostsCount: ValueNotifier(0),
  //             isLiked: ValueNotifier(false),
  //             likedBy: [],
  //           ),
  //           ...state.posts,
  //         ],
  //       );
  //       _webSocketService.sendShareUpdate(postId, newShareCount);
  //     } else {
  //       throw Exception('Failed to share post');
  //     }
  //   } catch (e) {
  //     print("Error sharing post: $e");
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }

  Future<void> editPost(
      int postId, String newContent, String? newImageUrl) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1 || state.connectedUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final success = await _httpService.editPost(postId, newContent,
          newImageUrl: newImageUrl);
      if (success) {
        state = state.copyWith(
          posts: List.from(state.posts)
            ..[index] = state.posts[index].copyWith(
              content: newContent,
              image: newImageUrl,
            ),
        );
      } else {
        throw Exception('Failed to edit post');
      }
    } catch (e) {
      print("Error editing post: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deletePost(int postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1 || state.connectedUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final success = await _httpService.deletePost(postId);
      if (success) {
        state = state.copyWith(
          posts: List.from(state.posts)..removeAt(index),
        );
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      print("Error deleting post: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateFeedWithNewPosts() {
    if (state.newPosts.isNotEmpty) {
      state = state.copyWith(
        posts: [...state.newPosts, ...state.posts],
        newPosts: [],
        showNewPostsNotification: false,
      );
      _ref.read(scrollControllerProvider).animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
    }
  }

  Future<void> refreshPosts() async {
    await _fetchPosts();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}

// Providers
final scrollControllerProvider =
    Provider<ScrollController>((ref) => ScrollController());

final actualityProvider =
    StateNotifierProvider<ActualityNotifier, ActualityState>((ref) {
  final httpService = HttpService();
  final authService = AuthService();
  final webSocketService = WebSocketService();
  return ActualityNotifier(httpService, authService, webSocketService, ref);
});

// Main Widget
class Actuality extends ConsumerStatefulWidget {
  const Actuality({super.key});

  @override
  ConsumerState<Actuality> createState() => _ActualityState();
}

class _ActualityState extends ConsumerState<Actuality> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout() async {
    await ref.read(actualityProvider.notifier)._authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actualityState = ref.watch(actualityProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final scrollController = ref.watch(scrollControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () =>
                  ref.read(actualityProvider.notifier).refreshPosts(),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: false,
                    backgroundColor: backgroundColor,
                    elevation: 0,
                    title: Text(
                      AppLocales.getTranslation('news_feed', locale),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    iconTheme: IconThemeData(color: textColor),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchBarDelegate(
                      isDarkMode: isDarkMode,
                      locale: locale,
                    ),
                  ),
                  actualityState.isLoading
                      ? const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = actualityState.posts[index];
                              return ValueListenableBuilder(
                                valueListenable: article.likesCount,
                                builder: (context, likesCount, child) {
                                  return ValueListenableBuilder(
                                    valueListenable: article.isLiked,
                                    builder: (context, isLiked, child) {
                                      return BlogTile(
                                        id: article.id,
                                        image: article.image ?? "",
                                        content: article.content ?? "",
                                        user: article.user,
                                        createdAt: article.createdAt.toString(),
                                        likesCount: likesCount,
                                        commentsCount: article.comments.length,
                                        shareCount:
                                            article.sharedPostsCount.value,
                                        onLike: () => ref
                                            .read(actualityProvider.notifier)
                                            .toggleLike(article.id),
                                        onComment: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddComment(post: article),
                                          ),
                                        ),
                                        onShare: () =>
                                            _sharePost(context, article.id),
                                        onEdit: () =>
                                            _editPost(context, article),
                                        onDelete: () =>
                                            _deletePost(context, article.id),
                                        isLiked: isLiked,
                                        comments: article.comments,
                                        likedBy: article.likedBy,
                                        connectedUserId: actualityState
                                                .connectedUser?['id'] ??
                                            0,
                                        isDarkMode: isDarkMode,
                                        sharedFrom: article.sharedFrom,
                                        locale: locale,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            childCount: actualityState.posts.length,
                          ),
                        ),
                ],
              ),
            ),
            if (actualityState.showNewPostsNotification)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => ref
                      .read(actualityProvider.notifier)
                      .updateFeedWithNewPosts(),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            actualityState.newPosts.length == 1
                                ? AppLocales.getTranslation('new_post', locale)
                                : AppLocales.getTranslation(
                                    'new_posts',
                                    locale,
                                    placeholders: {
                                      'count': actualityState.newPosts.length
                                          .toString()
                                    },
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      drawer: CustomDrawer(
        connectedUser: actualityState.connectedUser,
        backgroundColor: backgroundColor,
        textColor: textColor,
        isDarkMode: isDarkMode,
        onLogout: _logout,
        onShowThemeBottomSheet: _showThemeBottomSheet,
        onShowLanguageBottomSheet: _showLanguageBottomSheet,
      ),
    );
  }

  void _sharePost(BuildContext context, int postId) async {
    String? shareContent;
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocales.getTranslation(
                  'share_post', ref.read(localeProvider).languageCode)),
              TextField(
                onChanged: (value) => shareContent = value,
                decoration: InputDecoration(
                  hintText: AppLocales.getTranslation(
                      'write_something', ref.read(localeProvider).languageCode),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocales.getTranslation(
                    'share', ref.read(localeProvider).languageCode)),
              ),
            ],
          ),
        );
      },
    );

    if (shareContent != null && shareContent!.isNotEmpty) {
      await ref
          .read(actualityProvider.notifier)
          .sharePost(postId, shareContent!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocales.getTranslation(
                  'share_success', ref.read(localeProvider).languageCode),
            ),
          ),
        );
      }
    } else if (shareContent != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocales.getTranslation(
                'no_content', ref.read(localeProvider).languageCode),
          ),
        ),
      );
    }
  }

  void _editPost(BuildContext context, OppsModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          post: post,
          onSave: (newContent, newImageUrl) => ref
              .read(actualityProvider.notifier)
              .editPost(post.id, newContent, newImageUrl),
        ),
      ),
    );
  }

  void _deletePost(BuildContext context, int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocales.getTranslation(
              'confirm_delete', ref.read(localeProvider).languageCode),
        ),
        content: Text(
          AppLocales.getTranslation(
              'delete_post_message', ref.read(localeProvider).languageCode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocales.getTranslation(
                'cancel', ref.read(localeProvider).languageCode)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocales.getTranslation(
                  'delete', ref.read(localeProvider).languageCode),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(actualityProvider.notifier).deletePost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocales.getTranslation(
                'delete_success', ref.read(localeProvider).languageCode)),
          ),
        );
      }
    }
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeProvider);
            final locale = ref.watch(localeProvider).languageCode;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocales.getTranslation('choose_theme', locale),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title:
                        Text(AppLocales.getTranslation('system_theme', locale)),
                    value: themeMode == ThemeMode.system,
                    onChanged: (value) {
                      final newMode =
                          value ? ThemeMode.system : ThemeMode.light;
                      ref.read(themeProvider.notifier).setThemeMode(newMode);
                    },
                    secondary: const Icon(Icons.phone_android),
                  ),
                  if (themeMode != ThemeMode.system)
                    SwitchListTile(
                      title: Text(themeMode == ThemeMode.dark
                          ? AppLocales.getTranslation('dark_mode', locale)
                          : AppLocales.getTranslation('light_mode', locale)),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        final newMode =
                            value ? ThemeMode.dark : ThemeMode.light;
                        ref.read(themeProvider.notifier).setThemeMode(newMode);
                      },
                      secondary: Icon(themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode),
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocales.getTranslation('close', locale)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation(
                    'choose_language', ref.read(localeProvider).languageCode),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Français'),
                leading: Radio<String>(
                  value: 'fr',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocales.getTranslation(
                    'close', ref.read(localeProvider).languageCode)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;
  final String locale;

  SearchBarDelegate({required this.isDarkMode, required this.locale});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black54;
    final iconColor = isDarkMode ? Colors.white : green;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
              ),
              child: Container(
                height: 60.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  border: Border.all(color: green),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: iconColor),
                    const SizedBox(width: 10.0),
                    Text(
                      AppLocales.getTranslation('what_s_new', locale),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: textColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15.0),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StoryFeedPage()),
            ),
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class BlogTile extends StatefulWidget {
  final int id;
  final String image;
  final String content;
  final User user;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final int shareCount;
  final List<Comment> comments;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isLiked;
  final List<int> likedBy;
  final int connectedUserId;
  final bool isDarkMode;
  final OppsModel? sharedFrom;
  final String locale;

  const BlogTile({
    super.key,
    required this.id,
    required this.image,
    required this.content,
    required this.user,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.shareCount,
    required this.comments,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.isLiked,
    required this.likedBy,
    required this.connectedUserId,
    required this.isDarkMode,
    required this.sharedFrom,
    required this.locale,
  });

  @override
  State<BlogTile> createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatRelativeDate(String date) {
    final now = DateTime.now();
    final parsedDate = DateTime.parse(date);
    final difference = now.difference(parsedDate);

    if (difference.inMinutes < 60) {
      return AppLocales.getTranslation('just_now', widget.locale);
    } else if (difference.inHours < 24) {
      return AppLocales.getTranslation('hours_ago', widget.locale,
          placeholders: {'hours': difference.inHours.toString()});
    } else if (difference.inDays == 1) {
      return AppLocales.getTranslation('yesterday', widget.locale);
    } else if (difference.inDays < 7) {
      return AppLocales.getTranslation('days_ago', widget.locale,
          placeholders: {'days': difference.inDays.toString()});
    } else if (difference.inDays < 30) {
      return AppLocales.getTranslation('weeks_ago', widget.locale,
          placeholders: {'weeks': (difference.inDays ~/ 7).toString()});
    } else {
      return DateFormat('dd/MM/yyyy', widget.locale).format(parsedDate);
    }
  }

  void _viewUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          connectedUser: {
            "id": widget.user.id,
            "nom": widget.user.nom,
            "prenom": widget.user.prenom,
            "email": widget.user.email,
            "profile": widget.user.proofile?.toJson() ?? {},
          },
          visitorId: widget.connectedUserId,
        ),
      ),
    );
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActualityDetails(
          id: widget.id,
          image: widget.image,
          createdAt: widget.createdAt,
          content: widget.content,
          user: widget.user,
          likedBy: widget.likedBy,
          comments: widget.comments,
          likes: widget.likedBy.map((id) => Like(userId: id)).toList(),
          likesCount: widget.likesCount,
          onLike: widget.onLike,
          onComment: widget.onComment,
          isLiked: widget.isLiked,
          commentsCount: widget.commentsCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white : white;
    final isSharedPost = widget.sharedFrom != null;

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: _viewUserProfile,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.user.proofile?.photoProfile?.isNotEmpty ?? false
                      ? CachedNetworkImage(
                          imageUrl: widget.user.proofile!.photoProfile!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 24,
                        ),
                ),
              ),
            ),
            title: GestureDetector(
              onTap: _viewUserProfile,
              child: Text(
                "${widget.user.nom} ${widget.user.prenom}".trim(),
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            subtitle: Text(
              _formatRelativeDate(widget.createdAt),
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  widget.onEdit();
                } else if (value == 'delete') {
                  widget.onDelete();
                } else if (value == 'share') {
                  widget.onShare();
                } else if (value == 'report') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocales.getTranslation(
                            'report_submitted', widget.locale),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                if (widget.connectedUserId == widget.user.id)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(AppLocales.getTranslation('edit', widget.locale)),
                      ],
                    ),
                  ),
                if (widget.connectedUserId == widget.user.id)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                            AppLocales.getTranslation('delete', widget.locale)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(AppLocales.getTranslation('share', widget.locale)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      const Icon(Icons.report, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text(AppLocales.getTranslation('report', widget.locale)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.image.isNotEmpty)
            GestureDetector(
              onTap: _navigateToDetails,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _navigateToDetails,
              child: Text(
                widget.content,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ),
          if (isSharedPost)
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(10.0),
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.sharedFrom?.user.proofile?.photoProfile
                                  ?.isNotEmpty ??
                              false
                          ? CachedNetworkImage(
                              imageUrl: widget
                                  .sharedFrom!.user.proofile!.photoProfile!,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            ),
                    ),
                    title: Text(
                      "${widget.sharedFrom!.user.nom} ${widget.sharedFrom!.user.prenom}"
                          .trim(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      _formatRelativeDate(
                          widget.sharedFrom!.createdAt.toString()),
                      style: TextStyle(color: textColor.withOpacity(0.6)),
                    ),
                  ),
                  if (widget.sharedFrom!.image?.isNotEmpty ?? false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.sharedFrom!.image!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.sharedFrom!.content ?? '',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _animationController.forward().then(
                              (_) => _animationController.reverse(),
                            );
                        widget.onLike();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.isLiked
                              ? (isDarkMode ? Colors.black87 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Icon(
                                widget.isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                color: widget.isLiked
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : iconColor,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.likesCount}',
                              style: TextStyle(
                                color: widget.isLiked
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : iconColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onComment,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              color: iconColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.commentsCount}',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onShare,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: iconColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.shareCount}',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 12,
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
          ),
        ],
      ),
    );
  }
}
