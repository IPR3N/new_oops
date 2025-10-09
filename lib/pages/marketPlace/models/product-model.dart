// class DataModel {
//   final int id;
//   final Project project;

//   DataModel({
//     required this.id,
//     required this.project,
//   });

//   factory DataModel.fromJson(Map<String, dynamic> json) {
//     return DataModel(
//       id: json['id'],
//       project: Project.fromJson(json['projectId']),
//     );
//   }
// }

// class Project {
//   final int id;
//   final String nom;
//   final String description;
//   final DateTime startDate;
//   final DateTime endDate;
//   final bool isListedOnMarketplace;
//   final String? imageUrl;
//   final String estimatedQuantityProduced;
//   final String basePrice;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final Owner owner;
//   final Crop crop;
//   final CropVariety cropVariety;

//   Project({
//     required this.id,
//     required this.nom,
//     required this.description,
//     required this.startDate,
//     required this.endDate,
//     required this.isListedOnMarketplace,
//     this.imageUrl,
//     required this.estimatedQuantityProduced,
//     required this.basePrice,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.owner,
//     required this.crop,
//     required this.cropVariety,
//   });

//   factory Project.fromJson(Map<String, dynamic> json) {
//     return Project(
//       id: json['id'] ?? '',
//       nom: json['nom'] ?? '',
//       description: json['description'] ?? '',
//       startDate: DateTime.parse(json['start_date'] ?? ''),
//       endDate: DateTime.parse(json['end_date'] ?? ''),
//       isListedOnMarketplace: json['is_listed_on_marketplace'] ?? '',
//       imageUrl: json['image_url'] ?? '',
//       estimatedQuantityProduced: json['estimated_quantity_produced'],
//       basePrice: json['base_price'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       owner: Owner.fromJson(json['owner']),
//       crop: Crop.fromJson(json['crop']),
//       cropVariety: CropVariety.fromJson(json['cropVariety']),
//     );
//   }
// }

// class Owner {
//   final int id;
//   final String nom;
//   final String prenom;
//   final String email;
//   final String password;

//   Owner({
//     required this.id,
//     required this.nom,
//     required this.prenom,
//     required this.email,
//     required this.password,
//   });

//   factory Owner.fromJson(Map<String, dynamic> json) {
//     return Owner(
//       id: json['id'],
//       nom: json['nom'],
//       prenom: json['prenom'],
//       email: json['email'],
//       password: json['password'],
//     );
//   }
// }

// class Crop {
//   final int id;
//   final String nom;
//   final String description;
//   final DateTime plantingDate;
//   final String fertilizerUsed;
//   final String yield;
//   final String waterUsage;
//   final String photos;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Crop({
//     required this.id,
//     required this.nom,
//     required this.description,
//     required this.plantingDate,
//     required this.fertilizerUsed,
//     required this.yield,
//     required this.waterUsage,
//     required this.photos,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Crop.fromJson(Map<String, dynamic> json) {
//     return Crop(
//       id: json['id'],
//       nom: json['nom'],
//       description: json['description'],
//       plantingDate: DateTime.parse(json['planting_date']),
//       fertilizerUsed: json['fertilizer_used'],
//       yield: json['yield'],
//       waterUsage: json['water_usage'],
//       photos: json['photos'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }
// }

// class CropVariety {
//   final int id;
//   final String nom;
//   final String description;
//   final String standardTemperature;
//   final String standardHumidity;
//   final int daysToCroissant;
//   final int daysToGerminate;
//   final int daysToMaturity;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   CropVariety({
//     required this.id,
//     required this.nom,
//     required this.description,
//     required this.standardTemperature,
//     required this.standardHumidity,
//     required this.daysToCroissant,
//     required this.daysToGerminate,
//     required this.daysToMaturity,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory CropVariety.fromJson(Map<String, dynamic> json) {
//     return CropVariety(
//       id: json['id'],
//       nom: json['nom'],
//       description: json['description'],
//       standardTemperature: json['standard_temperature'],
//       standardHumidity: json['standard_humidity'],
//       daysToCroissant: json['days_to_croissant'],
//       daysToGerminate: json['days_to_germinate'],
//       daysToMaturity: json['days_to_maturity'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }
// }

class DataModel {
  final int id;
  final Project project;

  DataModel({
    required this.id,
    required this.project,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      id: json['id'] ?? 0,
      project: Project.fromJson(json['projectId'] ?? {}),
    );
  }
}

class Project {
  final int id;
  final String nom;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isListedOnMarketplace;
  final String? imageUrl;
  final String estimatedQuantityProduced;
  final String basePrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Owner owner;
  final Crop crop;
  final CropVariety cropVariety;

  Project({
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
    required this.owner,
    required this.crop,
    required this.cropVariety,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      startDate:
          DateTime.parse(json['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
      isListedOnMarketplace: json['is_listed_on_marketplace'] ?? false,
      imageUrl: json['image_url'],
      estimatedQuantityProduced: json['estimated_quantity_produced'] ?? '',
      basePrice: json['base_price'] ?? '',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      owner: Owner.fromJson(json['owner'] ?? {}),
      crop: Crop.fromJson(json['crop'] ?? {}),
      cropVariety: CropVariety.fromJson(json['cropVariety'] ?? {}),
    );
  }
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
      id: json['id'] ?? 0,
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
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      plantingDate:
          DateTime.parse(json['planting_date'] ?? DateTime.now().toString()),
      fertilizerUsed: json['fertilizer_used'] ?? '',
      yield: json['yield'] ?? '',
      waterUsage: json['water_usage'] ?? '',
      photos: json['photos'] ?? '',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }
}

class CropVariety {
  final int id;
  final String nom;
  final String description;
  final String standardTemperature;
  final String standardHumidity;
  final int daysToCroissant;
  final int daysToGerminate;
  final int daysToMaturity;
  final DateTime createdAt;
  final DateTime updatedAt;

  CropVariety({
    required this.id,
    required this.nom,
    required this.description,
    required this.standardTemperature,
    required this.standardHumidity,
    required this.daysToCroissant,
    required this.daysToGerminate,
    required this.daysToMaturity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CropVariety.fromJson(Map<String, dynamic> json) {
    return CropVariety(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      standardTemperature: json['standard_temperature'] ?? '',
      standardHumidity: json['standard_humidity'] ?? '',
      daysToCroissant: json['days_to_croissant'] ?? 0,
      daysToGerminate: json['days_to_germinate'] ?? 0,
      daysToMaturity: json['days_to_maturity'] ?? 0,
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }
}
