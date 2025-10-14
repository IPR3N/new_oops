
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/pages/view/actuality_details.dart';
import 'package:new_oppsfarm/pages/view/models/opps-model.dart';
import 'package:new_oppsfarm/profile/edit-profile_page.dart';
import 'package:new_oppsfarm/profile/follow_followers/follow_folowers.dart';
import 'package:new_oppsfarm/profile/service/profile_Http_service.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:new_oppsfarm/socket/socket-service.dart';

enum FollowStatus { notFollowing, following, pending, rejected }

class ProfilePage extends ConsumerStatefulWidget {
  final dynamic connectedUser;
  final int? visitorId;

  const ProfilePage({super.key, required this.connectedUser, this.visitorId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final double coverHeight = 200;
  final double profileHeight = 100;
  final HttpService _httpService = HttpService();
  final AuthService _authService = AuthService();
  final ProfileHttpService _profileService = ProfileHttpService();

  List<Map<String, dynamic>> _outgoingRequests = [];
  List<Map<String, dynamic>> _incomingRequests = [];
  List<int> _incomingSenderIds = [];

  bool _isLoading = false;
  bool _isLoadingLikedPosts = false;
  List<OppsModel> _oopsPosts = [];
  List<OppsModel> _likedPosts = [];
  late final int userId;
  late final String userNom;
  FollowStatus _followStatus = FollowStatus.notFollowing;
  bool _isFollowActionLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<dynamic> _friends = [];

  @override
  void initState() {
    super.initState();
    userId = widget.connectedUser["id"];
    userNom = widget.connectedUser["profile"]["username"] ?? "Unknown";
    _fetchUserPosts();
    _fetchLikedPosts();
    _checkFollowStatus();
    _fetchFriendsAndUpdateCounts();
  }

  Future<void> _fetchFriendsAndUpdateCounts() async {
    setState(() => _isLoading = true);
    try {
      final friendsData = await _profileService.getFriends(userId: userId);
      final friendsList = jsonDecode(friendsData);
      if (mounted) {
        setState(() {
          _friends = friendsList;
          _followersCount = _friends.length;
          _followingCount = _friends.length;
        });
      }
      await getOutgoingFriendRequests();
      await getIncomingFriendRequests();
    } catch (e) {
      print('Error fetching friends: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement des amis: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> getOutgoingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileService.getOutgoingFriendRequests(userId);
      if (mounted) {
        setState(() {
          _outgoingRequests = List<Map<String, dynamic>>.from(data['requests']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getIncomingFriendRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _profileService.getIncomingFriendRequests(userId);
      if (mounted) {
        setState(() {
          _incomingRequests =
              List<Map<String, dynamic>>.from(data['requests'] ?? []);
          _incomingSenderIds = _incomingRequests
              .map((request) => request['requester']?['id'] as int?)
              .where((id) => id != null)
              .cast<int>()
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fetchUserPosts() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> response = List<Map<String, dynamic>>.from(
          await _httpService.getPostByConnectUser(userId));
      _oopsPosts = response.map((data) => OppsModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fetchLikedPosts() async {
    setState(() => _isLoadingLikedPosts = true);
    try {
      final response = await _profileService.getLikedPosts(userId);
      final List<dynamic> likedPostsData = jsonDecode(response);
      _likedPosts = likedPostsData.map((data) => OppsModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching liked posts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du chargement des posts likés: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLikedPosts = false);
    }
  }

  void _checkFollowStatus() async {
    if (widget.visitorId == null || widget.visitorId == userId) return;

    setState(() => _isLoading = true);
    try {
      final outgoingRequests =
          await _profileService.getOutgoingFriendRequests(widget.visitorId!);
      final friends =
          jsonDecode(await _profileService.getFriends(userId: userId));

      final request = outgoingRequests['requests']?.firstWhere(
        (req) => req['receiver']['id'] == userId,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _friends = friends;
          _followersCount = _friends.length;
          _followingCount = _friends.length;

          if (request != null) {
            switch (request['status'].toLowerCase()) {
              case 'pending':
                _followStatus = FollowStatus.pending;
                break;
              case 'rejected':
                _followStatus = FollowStatus.rejected;
                break;
              case 'accepted':
                _followStatus = FollowStatus.following;
                break;
              default:
                _followStatus = FollowStatus.notFollowing;
            }
          } else {
            _followStatus =
                friends.any((friend) => friend['id'] == widget.visitorId)
                    ? FollowStatus.following
                    : FollowStatus.notFollowing;
          }
          _followersCount = friends.length;
          _followingCount = friends.length;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (widget.visitorId == null || _isFollowActionLoading) return;

    setState(() => _isFollowActionLoading = true);
    try {
      switch (_followStatus) {
        case FollowStatus.notFollowing:
        case FollowStatus.rejected:
          await _profileService.sendFriendRequest(
            requesterId: widget.visitorId!,
            receiverId: userId,
          );
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.pending;
              _followersCount++;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Follow request sent')));
          }
          break;
        case FollowStatus.following:
          await _profileService.cancelFriendRequest(widget.visitorId!, userId);
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.notFollowing;
              _followersCount--;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Unfollowed')));
          }
          break;
        case FollowStatus.pending:
          await _profileService.cancelFriendRequest(widget.visitorId!, userId);
          if (mounted) {
            setState(() {
              _followStatus = FollowStatus.notFollowing;
              _followersCount--;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request cancelled')));
          }
          break;
      }
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isFollowActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isOwnProfile = widget.visitorId == null || widget.visitorId == userId;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                buildCoverImage(isDarkMode: isDarkMode),
                Positioned(
                    bottom: -50,
                    child: buildProfileImage(isDarkMode: isDarkMode)),
              ],
            ),
            const SizedBox(height: 60),
            buildUserInfo(
                isDarkMode: isDarkMode,
                isOwnProfile: isOwnProfile,
                locale: locale,
                textColor: textColor),
            const SizedBox(height: 20),
            buildStats(isOwnProfile: isOwnProfile, locale: locale),
            const SizedBox(height: 20),
            buildTabs(isDarkMode: isDarkMode, locale: locale),
          ],
        ),
      ),
    );
  }

  Widget buildCoverImage({required bool isDarkMode}) => Container(
        height: coverHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.connectedUser["profile"]
                    ["photoCouverture"] ??
                "https://picsum.photos/id/1015/500/300"),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
      );

  Widget buildProfileImage({required bool isDarkMode}) => ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          widget.connectedUser["profile"]["photoProfile"] ??
              "https://picsum.photos/id/1011/100/100",
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.network(
              "https://picsum.photos/id/1011/100/100",
              height: 80,
              width: 80,
              fit: BoxFit.cover),
        ),
      );

  Widget buildUserInfo(
          {required bool isDarkMode,
          required Color textColor,
          required bool isOwnProfile,
          required String locale}) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}" ??
                      "Unknown",
                  style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "@${widget.connectedUser["profile"]?["username"] ?? "pseudo"}",
                  style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (widget.connectedUser["profile"]?["bio"]?.isNotEmpty ??
                    false)
                  Text(
                    widget.connectedUser["profile"]["bio"],
                    style: TextStyle(color: textColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          isOwnProfile
              ? ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                              userId: userId,
                              userProfile: widget.connectedUser["profile"]))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: Text(AppLocales.getTranslation('edit_profile', locale),
                      style: const TextStyle(color: Colors.white)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isFollowActionLoading ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getFollowButtonColor(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: _isFollowActionLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_getFollowButtonText(locale),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.visitorId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Vous devez être connecté pour envoyer un message')));
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Text(AppLocales.getTranslation('message', locale),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
        ],
      );

  Color _getFollowButtonColor() {
    switch (_followStatus) {
      case FollowStatus.following:
        return Colors.grey[700]!;
      case FollowStatus.pending:
        return Colors.orange[600]!;
      case FollowStatus.rejected:
      case FollowStatus.notFollowing:
        return green;
    }
  }

  String _getFollowButtonText(String locale) {
    switch (_followStatus) {
      case FollowStatus.following:
        return AppLocales.getTranslation('unfollow', locale);
      case FollowStatus.pending:
        return AppLocales.getTranslation('pending', locale);
      case FollowStatus.rejected:
      case FollowStatus.notFollowing:
        return AppLocales.getTranslation('follow', locale);
    }
  }

  Widget buildStats({required bool isOwnProfile, required String locale}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text("$_followingCount",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FollowFolowers(
                              userId: userId,
                              userNom: userNom,
                              initialTabIndex: 1))),
                  child: Text(AppLocales.getTranslation('following', locale))),
            ],
          ),
          Column(
            children: [
              Text("$_followersCount",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FollowFolowers(
                              userId: userId, userNom: userNom))),
                  child: Text(AppLocales.getTranslation('followers', locale))),
            ],
          ),
          Column(
            children: [
              Text(
                "${_oopsPosts.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                AppLocales.getTranslation(
                  'posts',
                  locale,
                ),
              ),
            ],
          ),
        ],
      );

  Widget buildTabs({required bool isDarkMode, required String locale}) =>
      DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: isDarkMode ? Colors.white : green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: green,
              tabs: [
                Tab(text: AppLocales.getTranslation('posts', locale)),
                Tab(text: AppLocales.getTranslation('media', locale)),
                Tab(text: AppLocales.getTranslation('likes', locale)),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  buildPostsList(locale: locale),
                  Center(
                      child:
                          Text(AppLocales.getTranslation('no_media', locale))),
                  buildLikedPostsList(locale: locale),
                ],
              ),
            ),
          ],
        ),
      );

  Widget buildPostsList({required String locale}) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_oopsPosts.isEmpty)
      return Center(child: Text(AppLocales.getTranslation('no_posts', locale)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _oopsPosts.length,
      itemBuilder: (context, index) {
        final post = _oopsPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActualityDetails(
                  id: post.id,
                  image: post.image ?? '',
                  createdAt: DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt),
                  content: post.content ?? '',
                  user: post.user,
                  likedBy: post.likedBy,
                  comments: post.comments,
                  likes: post.likes,
                  likesCount: post.likesCount.value,
                  onLike: () {
                    setState(() {
                      if (post.isLiked.value) {
                        post.isLiked.value = false;
                        post.likesCount.value--;
                        post.likedBy.remove(widget.connectedUser["id"]);
                      } else {
                        post.isLiked.value = true;
                        post.likesCount.value++;
                        post.likedBy.add(widget.connectedUser["id"]);
                      }
                    });
                  },
                  onComment: () {},
                  isLiked: post.isLiked.value,
                  commentsCount: post.comments.length,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.connectedUser["profile"]["photoProfile"]
                              ?.isNotEmpty ??
                          false
                      ? Image.network(
                          widget.connectedUser["profile"]["photoProfile"],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white))
                      : const Icon(Icons.person, color: Colors.white),
                ),
              ),
              title: Text(
                  "${widget.connectedUser["nom"]} ${widget.connectedUser["prenom"]}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.content ??
                      AppLocales.getTranslation('no_content', locale)),
                  if (post.image?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(post.image!,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLikedPostsList({required String locale}) {
    if (_isLoadingLikedPosts) return const Center(child: CircularProgressIndicator());
    if (_likedPosts.isEmpty)
      return Center(child: Text(AppLocales.getTranslation('no_likes', locale)));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _likedPosts.length,
      itemBuilder: (context, index) {
        final post = _likedPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActualityDetails(
                  id: post.id,
                  image: post.image ?? '',
                  createdAt: DateFormat('yyyy-MM-dd HH:mm').format(post.createdAt),
                  content: post.content ?? '',
                  user: post.user,
                  likedBy: post.likedBy,
                  comments: post.comments,
                  likes: post.likes,
                  likesCount: post.likesCount.value,
                  onLike: () {
                    setState(() {
                      if (post.isLiked.value) {
                        post.isLiked.value = false;
                        post.likesCount.value--;
                        post.likedBy.remove(userId);
                        // Retirer le post de la liste des posts likés
                        _likedPosts.removeAt(index);
                      } else {
                        post.isLiked.value = true;
                        post.likesCount.value++;
                        post.likedBy.add(userId);
                      }
                    });
                  },
                  onComment: () {},
                  isLiked: post.isLiked.value,
                  commentsCount: post.comments.length,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: post.user.proofile?.photoProfile?.isNotEmpty ?? false
                      ? Image.network(
                          post.user.proofile!.photoProfile!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white))
                      : const Icon(Icons.person, color: Colors.white),
                ),
              ),
              title: Text("${post.user.nom} ${post.user.prenom}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.content ??
                      AppLocales.getTranslation('no_content', locale)),
                  if (post.image?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(post.image!,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container()),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
