import 'package:kasidie_city_whisper/data/api/overpass_api.dart';
import 'package:kasidie_city_whisper/data/local/cache_service.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';

class PlacesRepository {
  final OverpassApi _api;
  final CacheService _cache;

  PlacesRepository({
    required OverpassApi api,
    required CacheService cache,
  })  : _api = api,
        _cache = cache;

  Future<List<Place>> getPlaces({
    required Coordinates center,
    required double radius,
    required Set<PlaceCategory> categories,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getCacheKey(center, radius, categories);
    
    if (!forceRefresh) {
      final cached = await _cache.getPlaces(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      final places = await _api.fetchPlaces(
        center: center,
        radius: radius,
        categories: categories,
      );

      if (places.isNotEmpty) {
        await _cache.savePlaces(cacheKey, places);
      }

      return places;
    } catch (e) {
      final cached = await _cache.getPlaces(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  String _getCacheKey(Coordinates center, double radius, Set<PlaceCategory> categories) {
    final categoriesStr = categories.map((c) => c.name).join(',');
    return '${center.lat.toStringAsFixed(4)}_${center.lng.toStringAsFixed(4)}_${radius.toStringAsFixed(0)}_$categoriesStr';
  }
}
