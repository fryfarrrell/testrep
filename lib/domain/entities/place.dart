import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';

enum PlaceCategory {
  museum,
  art,
  viewpoint,
  water,
  toilet,
  bike,
}

extension PlaceCategoryExtension on PlaceCategory {
  String get displayName {
    switch (this) {
      case PlaceCategory.museum:
        return 'Museums';
      case PlaceCategory.art:
        return 'Art';
      case PlaceCategory.viewpoint:
        return 'Viewpoints';
      case PlaceCategory.water:
        return 'Water';
      case PlaceCategory.toilet:
        return 'Toilets';
      case PlaceCategory.bike:
        return 'Bike parking';
    }
  }

  String get osmTag {
    switch (this) {
      case PlaceCategory.museum:
        return 'tourism=museum';
      case PlaceCategory.art:
        return 'tourism=artwork';
      case PlaceCategory.viewpoint:
        return 'tourism=viewpoint';
      case PlaceCategory.water:
        return 'amenity=drinking_water';
      case PlaceCategory.toilet:
        return 'amenity=toilets';
      case PlaceCategory.bike:
        return 'amenity=bicycle_parking';
    }
  }
}

class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final Coordinates coordinates;
  final double distance;
  final int walkingTime;
  final Map<String, String> tags;
  final String? description;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.coordinates,
    required this.distance,
    required this.walkingTime,
    required this.tags,
    this.description,
  });

  Place copyWith({
    String? id,
    String? name,
    PlaceCategory? category,
    Coordinates? coordinates,
    double? distance,
    int? walkingTime,
    Map<String, String>? tags,
    String? description,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      coordinates: coordinates ?? this.coordinates,
      distance: distance ?? this.distance,
      walkingTime: walkingTime ?? this.walkingTime,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }
}
