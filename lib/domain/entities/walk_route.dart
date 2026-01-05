import 'package:kasidie_city_whisper/domain/entities/place.dart';

class WalkRoute {
  final String id;
  final List<Place> points;
  final double totalDistance;
  final int totalTime;

  WalkRoute({
    required this.id,
    required this.points,
    required this.totalDistance,
    required this.totalTime,
  });
}
