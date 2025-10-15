

import 'package:flutter/foundation.dart';

class OppsModel {
  final int id;
  final String? content;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<Comment> comments;
  final List<Like> likes;
  final OppsModel? sharedFrom;
  final List<OppsModel> sharedPosts;
  final ValueNotifier<int> likesCount;
  final ValueNotifier<int> sharedPostsCount;
  final ValueNotifier<bool> isLiked;
  final List<int> likedBy;

  OppsModel({
    required this.id,
    this.content,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.comments,
    required this.likes,
    this.sharedFrom,
    required this.sharedPosts,
    required this.likesCount,
    required this.sharedPostsCount,
    required this.isLiked,
    required this.likedBy,
  });

  // factory OppsModel.fromJson(Map<String, dynamic> json) {
  //   var likesList = (json['likes'] as List<dynamic>? ?? [])
  //       .map((e) => Like.fromJson(e as Map<String, dynamic>))
  //       .toList();

  //   return OppsModel(
  //     id: json['id'] as int,
  //     // Fallback to shareContent if content is null/missing
  //     content:
  //         json['content'] as String? ?? json['shareContent'] as String? ?? '',
  //     image: json['image'] as String?,
  //     createdAt: DateTime.parse(json['createdAt'] as String),
  //     updatedAt: DateTime.parse(json['updatedAt'] as String),
  //     user: User.fromJson(json['user'] as Map<String, dynamic>),
  //     comments: (json['comments'] as List<dynamic>? ?? [])
  //         .map((e) => Comment.fromJson(e as Map<String, dynamic>))
  //         .toList(),
  //     likes: likesList,
  //     sharedFrom: json['sharedFrom'] != null
  //         ? OppsModel.fromJson(json['sharedFrom'] as Map<String, dynamic>)
  //         : null,
  //     sharedPosts: (json['sharedPosts'] as List<dynamic>? ?? [])
  //         .map((e) => OppsModel.fromJson(e as Map<String, dynamic>))
  //         .toList(),
  //     likesCount: ValueNotifier(likesList.length),
  //     sharedPostsCount:
  //         ValueNotifier((json['sharedPosts'] as List<dynamic>? ?? []).length),
  //     // isLiked: ValueNotifier(false),
  //         isLiked: ValueNotifier(hasLiked), // ✅ Maintenant correctement initialisé
  //     likedBy: likesList.map((like) => like.userId).toList(),
  //   );
  // }
    factory OppsModel.fromJson(Map<String, dynamic> json, {int? currentUserId}) {
  var likesList = (json['likes'] as List<dynamic>? ?? [])
      .map((e) => Like.fromJson(e))
      .toList();
  
  final likedByList = likesList.map((like) => like.userId).toList();
  final hasLiked = currentUserId != null && likedByList.contains(currentUserId);

  print('✅ Post ${json['id']}: currentUserId=$currentUserId, likedBy=$likedByList, hasLiked=$hasLiked');

  return OppsModel(
    id: json['id'] as int,
    content: json['content'] as String? ?? json['shareContent'] as String? ?? '',
    image: json['image'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    comments: (json['comments'] as List<dynamic>? ?? [])
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList(),
    likes: likesList,
    sharedFrom: json['sharedFrom'] != null
        ? OppsModel.fromJson(json['sharedFrom'] as Map<String, dynamic>, currentUserId: currentUserId)
        : null,
    sharedPosts: (json['sharedPosts'] as List<dynamic>? ?? [])
        .map((e) => OppsModel.fromJson(e as Map<String, dynamic>, currentUserId: currentUserId))
        .toList(),
    likesCount: ValueNotifier(likesList.length),
    sharedPostsCount: ValueNotifier((json['sharedPosts'] as List<dynamic>? ?? []).length),
    isLiked: ValueNotifier(hasLiked),
    likedBy: likedByList,
  );
}
  OppsModel copyWith({
    int? id,
    String? content,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    List<Comment>? comments,
    List<Like>? likes,
    OppsModel? sharedFrom,
    List<OppsModel>? sharedPosts,
    ValueNotifier<int>? likesCount,
    ValueNotifier<int>? sharedPostsCount,
    ValueNotifier<bool>? isLiked,
    List<int>? likedBy,
  }) {
    return OppsModel(
      id: id ?? this.id,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      sharedFrom: sharedFrom ?? this.sharedFrom,
      sharedPosts: sharedPosts ?? this.sharedPosts,
      likesCount: likesCount ?? this.likesCount,
      sharedPostsCount: sharedPostsCount ?? this.sharedPostsCount,
      isLiked: isLiked ?? this.isLiked,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}

// class Like {
//   final int userId;

//   Like({required this.userId});

//   factory Like.fromJson(Map<String, dynamic> json) {
//     return Like(
//       userId: json['id'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': userId,
//     };
//   }
// }


class Like {
  final int userId;

  Like({required this.userId});

  factory Like.fromJson(dynamic json) {
    if (json is int) {
      // Si c'est juste un nombre, c'est déjà le userId
      return Like(userId: json);
    } else if (json is Map<String, dynamic>) {
      // ✅ CORRECTION : Extraire user.id, pas l'id du like !
      int? extractedUserId;
      
      // Cas 1 : {id: 60, user: {id: 1, ...}}
      if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
        extractedUserId = json['user']['id'] as int?;
        print('🔧 Extraction userId depuis user.id: $extractedUserId');
      }
      // Cas 2 : {userId: 1}
      else if (json.containsKey('userId')) {
        extractedUserId = json['userId'] as int?;
        print('🔧 Extraction userId depuis userId: $extractedUserId');
      }
      // Cas 3 fallback : {id: 1} (si pas de nested user)
      else if (json.containsKey('id')) {
        extractedUserId = json['id'] as int?;
        print('🔧 Extraction userId depuis id (fallback): $extractedUserId');
      }
      
      if (extractedUserId == null) {
        print('❌ ERREUR: userId introuvable dans $json');
        return Like(userId: 0);
      }
      
      return Like(userId: extractedUserId);
    } else {
      print('❌ ERREUR: Type de Like invalide: $json');
      throw FormatException('Invalid Like data: $json');
    }
  }

  dynamic toJson() => userId;
}

// class Like {
//   final int userId;

//   Like({required this.userId});

//   factory Like.fromJson(dynamic json) {
//     if (json is int) {
//       return Like(userId: json);
//     } else if (json is Map<String, dynamic>) {
//       return Like(userId: json['userId'] ?? json['id'] ?? 0);
//     } else {
//       throw FormatException('Invalid Like data: $json');
//     }
//   }

//   // Convert to simple JSON representation
//   dynamic toJson() => userId;
// }

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? password;
  final Profile? proofile;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.password,
    this.proofile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String?,
      proofile: json['proofile'] != null
          ? Profile.fromJson(json['proofile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': password,
      'proofile': proofile?.toJson(),
    };
  }
}

class Profile {
  final int id;
  final String? bio;
  final String? photoProfile;
  final String? photoCouverture;
  final String? location;
  final String? username;
  final String? dob;

  Profile({
    required this.id,
    this.bio,
    this.photoProfile,
    this.photoCouverture,
    this.location,
    this.username,
    this.dob,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      photoProfile: json['photoProfile'] as String?,
      photoCouverture: json['photoCouverture'] as String?,
      location: json['location'] as String?,
      username: json['username'] as String?,
      dob: json['dob'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'photoProfile': photoProfile,
      'photoCouverture': photoCouverture,
      'location': location,
      'username': username,
      'dob': dob,
    };
  }
}

// class Comment {
//   final int id;
//   final String content;
//   final DateTime createdAt;
//   final User user;

//   Comment({
//     required this.id,
//     required this.content,
//     required this.createdAt,
//     required this.user,
//   });

//   factory Comment.fromJson(Map<String, dynamic> json) {
//     return Comment(
//       id: json['id'] as int,
//       content: json['content'] as String? ?? '',
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       user: User.fromJson(json['user'] as Map<String, dynamic>),
//     );
//   }

//   // Added toJson method
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'content': content,
//       'createdAt': createdAt.toIso8601String(), // Convert DateTime to string
//       'user': user.toJson(),
//     };
//   }
// }

class Comment {
  final int id;
  final String content;
  final DateTime createdAt;
  final User user;
  final int likesCount; // Added field

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
    this.likesCount = 0, // Default to 0
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int? ?? 0, // Fallback if null
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      likesCount:
          json['likesCount'] as int? ?? 0, // Fallback if missing or null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
      'likesCount': likesCount,
    };
  }
}
