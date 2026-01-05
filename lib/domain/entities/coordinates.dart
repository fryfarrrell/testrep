import 'dart:math' as math;

class Coordinates {
  final double lat;
  final double lng;

  const Coordinates({
    required this.lat,
    required this.lng,
  });

  Coordinates copyWith({
    double? lat,
    double? lng,
  }) {
    return Coordinates(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  double distanceTo(Coordinates other) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(other.lat - lat);
    final double dLng = _toRadians(other.lng - lng);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat)) *
            math.cos(_toRadians(other.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180);
}
