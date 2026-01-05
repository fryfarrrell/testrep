import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';

class PlaceModel extends Place {
  PlaceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.coordinates,
    required super.distance,
    required super.walkingTime,
    required super.tags,
    super.description,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json, Coordinates userLocation) {
    final lat = double.parse(json['lat']?.toString() ?? '0');
    final lng = double.parse(json['lon']?.toString() ?? '0');
    final coords = Coordinates(lat: lat, lng: lng);
    
    final distance = userLocation.distanceTo(coords);
    final walkingTime = (distance / 70).round();

    final tags = <String, String>{};
    if (json['tags'] != null) {
      final tagsMap = json['tags'] as Map<String, dynamic>;
      tagsMap.forEach((key, value) {
        if (value != null) {
          tags[key] = value.toString();
        }
      });
    }

    String name = tags['name'] ?? 
                 tags['name:en'] ?? 
                 'Unnamed ${_getCategoryFromTags(tags).displayName.toLowerCase()}';
    
    final category = _getCategoryFromTags(tags);

    return PlaceModel(
      id: json['id']?.toString() ?? '',
      name: name,
      category: category,
      coordinates: coords,
      distance: distance,
      walkingTime: walkingTime,
      tags: tags,
      description: tags['description'] ?? tags['note'],
    );
  }

  static PlaceCategory _getCategoryFromTags(Map<String, String> tags) {
    if (tags['tourism'] == 'museum' || tags['tourism'] == 'gallery') {
      return PlaceCategory.museum;
    }
    if (tags['tourism'] == 'artwork') {
      return PlaceCategory.art;
    }
    if (tags['tourism'] == 'viewpoint') {
      return PlaceCategory.viewpoint;
    }
    if (tags['amenity'] == 'drinking_water') {
      return PlaceCategory.water;
    }
    if (tags['amenity'] == 'toilets') {
      return PlaceCategory.toilet;
    }
    if (tags['amenity'] == 'bicycle_parking') {
      return PlaceCategory.bike;
    }
    return PlaceCategory.viewpoint;
  }
}
