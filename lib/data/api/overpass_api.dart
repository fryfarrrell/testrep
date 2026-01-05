import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/data/models/place_model.dart';

class OverpassApi {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';
  static DateTime? _lastRequestTime;
  static const Duration _throttleDuration = Duration(seconds: 3);

  Future<List<Place>> fetchPlaces({
    required Coordinates center,
    required double radius,
    required Set<PlaceCategory> categories,
  }) async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _throttleDuration) {
        await Future.delayed(_throttleDuration - timeSinceLastRequest);
      }
    }

    _lastRequestTime = DateTime.now();

    final bbox = _calculateBbox(center, radius);
    final query = _buildQuery(bbox, categories);

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=$encodedQuery',
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseResponse(data, center);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  String _calculateBbox(Coordinates center, double radius) {
    final latOffset = radius / 111320.0;
    final lngOffset = radius / (111320.0 * math.cos(center.lat * math.pi / 180));
    
    final south = center.lat - latOffset;
    final north = center.lat + latOffset;
    final west = center.lng - lngOffset;
    final east = center.lng + lngOffset;
    
    return '$south,$west,$north,$east';
  }

  String _buildQuery(String bbox, Set<PlaceCategory> categories) {
    if (categories.isEmpty) {
      return '[out:json][timeout:25];(node($bbox);way($bbox);relation($bbox););out center meta;';
    }

    final queries = <String>[];
    
    for (final category in categories) {
      final tag = category.osmTag.split('=');
      final key = tag[0];
      final value = tag[1];
      
      queries.add('node["$key"="$value"]($bbox);');
      queries.add('way["$key"="$value"]($bbox);');
      queries.add('relation["$key"="$value"]($bbox);');
    }

    final queryStr = queries.join('');
    
    return '[out:json][timeout:25];($queryStr);out center meta;';
  }

  List<Place> _parseResponse(Map<String, dynamic> data, Coordinates userLocation) {
    final elements = data['elements'] as List<dynamic>? ?? [];
    final places = <Place>[];

    for (final element in elements) {
      try {
        double? lat, lng;
        
        if (element['type'] == 'node') {
          lat = double.tryParse(element['lat']?.toString() ?? '');
          lng = double.tryParse(element['lon']?.toString() ?? '');
        } else if (element['center'] != null) {
          lat = double.tryParse(element['center']['lat']?.toString() ?? '');
          lng = double.tryParse(element['center']['lon']?.toString() ?? '');
        }

        if (lat != null && lng != null) {
          final place = PlaceModel.fromJson({
            'id': '${element['type']}_${element['id']}',
            'lat': lat,
            'lon': lng,
            'tags': element['tags'] ?? {},
          }, userLocation);
          places.add(place);
        }
      } catch (e) {
        continue;
      }
    }

    return places;
  }
}
