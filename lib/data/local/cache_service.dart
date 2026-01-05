import 'package:hive_flutter/hive_flutter.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';

class CacheService {
  static const String _placesBoxName = 'places_cache';
  static const String _settingsBoxName = 'settings';
  static const Duration _cacheTTL = Duration(hours: 24);

  Box? _placesBox;
  Box? _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _placesBox = await Hive.openBox(_placesBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  Future<List<Place>?> getPlaces(String key) async {
    if (_placesBox == null) return null;
    
    final cached = _placesBox!.get(key);
    if (cached == null) return null;

    final data = cached as Map<String, dynamic>;
    final timestamp = DateTime.parse(data['timestamp'] as String);
    
    if (DateTime.now().difference(timestamp) > _cacheTTL) {
      _placesBox!.delete(key);
      return null;
    }

    final placesData = data['places'] as List<dynamic>;
    return placesData.map((p) => _placeFromMap(p as Map<String, dynamic>)).toList();
  }

  Future<void> savePlaces(String key, List<Place> places) async {
    if (_placesBox == null) return;
    
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'places': places.map((p) => _placeToMap(p)).toList(),
    };
    
    await _placesBox!.put(key, data);
  }

  Future<void> clearCache() async {
    if (_placesBox != null) {
      await _placesBox!.clear();
    }
  }

  Map<String, dynamic> _placeToMap(Place place) {
    return {
      'id': place.id,
      'name': place.name,
      'category': place.category.name,
      'lat': place.coordinates.lat,
      'lng': place.coordinates.lng,
      'distance': place.distance,
      'walkingTime': place.walkingTime,
      'tags': place.tags,
      'description': place.description,
    };
  }

  Place _placeFromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'] as String,
      name: map['name'] as String,
      category: PlaceCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => PlaceCategory.viewpoint,
      ),
      coordinates: Coordinates(
        lat: map['lat'] as double,
        lng: map['lng'] as double,
      ),
      distance: map['distance'] as double,
      walkingTime: map['walkingTime'] as int,
      tags: Map<String, String>.from(map['tags'] as Map),
      description: map['description'] as String?,
    );
  }

  Future<void> saveSettings(String key, dynamic value) async {
    if (_settingsBox == null) return;
    await _settingsBox!.put(key, value);
  }

  dynamic getSettings(String key) {
    if (_settingsBox == null) return null;
    return _settingsBox!.get(key);
  }
}
