import 'package:intl/intl.dart';

class ProjectModel {
  final int id;
  final String nom;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isListedOnMarketplace;
  final String? imageUrl;
  final int estimatedQuantityProduced;
  final int basePrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Owner? owner;
  final Crop crop;
  final CropVariety? cropVariety;
  final List<Membership> memberships;
  final List<Task> tasks;

  ProjectModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.isListedOnMarketplace,
    this.imageUrl,
    required this.estimatedQuantityProduced,
    required this.basePrice,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    required this.crop,
    this.cropVariety,
    required this.memberships,
    required this.tasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // print(json['tasks']);
    return ProjectModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      isListedOnMarketplace: json['is_listed_on_marketplace'] ?? false,
      imageUrl: json['image_url'],
      estimatedQuantityProduced: int.tryParse(
              json['estimated_quantity_produced']?.toString() ?? '0') ??
          0,
      basePrice: int.tryParse(json['base_price']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      crop: Crop.fromJson(json['crop'] ?? {}),
      cropVariety: json['cropVariety'] != null
          ? CropVariety.fromJson(json['cropVariety'])
          : null,
      memberships: json['memberships'] != null
          ? (json['memberships'] as List)
              .map((membership) => Membership.fromJson(membership))
              .toList()
          : [],
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((task) => Task.fromJson(task)).toList()
          : [],
    );
  }
}

class Membership {
  final int id;
  final String role;
  final User? user;
  final List<Task> tasks;

  Membership({
    required this.id,
    required this.role,
    this.user,
    required this.tasks,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    // Ajout de logging pour debug
    // print('Parsing membership: ${json.toString()}');
    // print('User data: ${json['user']}');

    return Membership(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      role: json['role'] ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      tasks:
          (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
    );
  }
}

class User {
  final int id;
  final String? nom;
  final String? prenom;
  final String email;
  final String? password;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
    );
  }
}

class Task {
  final int id;
  final String titre;
  final String description;
  final String priority;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  Task({
    required this.id,
    required this.titre,
    required this.description,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id'].toString()),
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] ?? '',
    );
  }

  String get formattedStartDate => DateFormat('yyyy-MM-dd').format(startDate);
  String get formattedEndDate => DateFormat('yyyy-MM-dd').format(endDate);
}

class Owner {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String password;

  Owner({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class Crop {
  final int id;
  final String nom;
  final String description;
  final DateTime plantingDate;
  final String fertilizerUsed;
  final String yield;
  final String waterUsage;
  final String photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Crop({
    required this.id,
    required this.nom,
    required this.description,
    required this.plantingDate,
    required this.fertilizerUsed,
    required this.yield,
    required this.waterUsage,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      plantingDate:
          DateTime.tryParse(json['planting_date'] ?? '') ?? DateTime.now(),
      fertilizerUsed: json['fertilizer_used'] ?? '',
      yield: json['yield'] ?? '',
      waterUsage: json['water_usage'] ?? '',
      photos: json['photos'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class CropVariety {
  final int id;
  final String nom;
  final String description;
  final int standardTemperature;
  final int standardHumidity;
  final int days_to_croissant;
  final int days_to_germinate;
  final int days_to_maturity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropVariety({
    required this.id,
    required this.nom,
    required this.description,
    required this.standardTemperature,
    required this.standardHumidity,
    required this.days_to_croissant,
    required this.days_to_germinate,
    required this.days_to_maturity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CropVariety.fromJson(Map<String, dynamic> json) {
    return CropVariety(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      standardTemperature:
          int.tryParse(json['standard_temperature']?.toString() ?? '0') ?? 0,
      standardHumidity:
          int.tryParse(json['standard_humidity']?.toString() ?? '0') ?? 0,
      days_to_croissant:
          int.tryParse(json['days_to_croissant']?.toString() ?? '0') ?? 0,
      days_to_germinate:
          int.tryParse(json['days_to_germinate']?.toString() ?? '0') ?? 0,
      days_to_maturity:
          int.tryParse(json['days_to_maturity']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
