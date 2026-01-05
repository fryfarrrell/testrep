import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kasidie_city_whisper/app/providers/providers.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/domain/entities/walk_route.dart';
import 'package:kasidie_city_whisper/common/widgets/category_icon.dart';

class Route12Screen extends ConsumerStatefulWidget {
  const Route12Screen({super.key});

  @override
  ConsumerState<Route12Screen> createState() => _Route12ScreenState();
}

class _Route12ScreenState extends ConsumerState<Route12Screen> {
  GoogleMapController? _mapController;
  WalkRoute? _currentRoute;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRoute();
    });
  }

  Future<void> _generateRoute() async {
    setState(() => _isGenerating = true);

    final location = await ref.read(locationProvider.future);
    final settings = ref.read(settingsProvider);
    final userLocation = ref.read(userLocationProvider);

    Coordinates center;
    if (location != null) {
      center = Coordinates(lat: location.latitude, lng: location.longitude);
    } else if (userLocation != null) {
      center = userLocation;
    } else {
      center = const Coordinates(lat: 37.7955, lng: -122.3937);
    }

    try {
      final placesAsync = ref.read(placesProvider(PlacesParams(
        center: center,
        radius: settings.searchRadius,
        categories: settings.selectedCategories,
      )).future);

      final places = await placesAsync;

      if (places.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No places found. Try increasing search radius.')),
          );
          setState(() => _isGenerating = false);
        }
        return;
      }

      final route = _calculate12MinuteRoute(places, center);
      
      if (mounted) {
        setState(() {
          _currentRoute = route;
          _isGenerating = false;
        });
        ref.read(walkRouteProvider.notifier).state = route;
        _updateMapCamera(center);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating route: $e')),
        );
      }
    }
  }

  WalkRoute _calculate12MinuteRoute(List<Place> places, Coordinates start) {
    final sortedPlaces = List<Place>.from(places)
      ..sort((a, b) => a.distance.compareTo(b.distance));

    const targetTime = 12;
    const minTime = 9;
    const maxTime = 15;
    const walkingSpeed = 70.0;

    WalkRoute? bestRoute;
    double bestDiff = double.infinity;

    for (int count = 2; count <= 3; count++) {
      if (sortedPlaces.length < count) continue;

      for (int i = 0; i <= sortedPlaces.length - count; i++) {
        final selected = sortedPlaces.sublist(i, i + count);
        
        double totalDistance = 0;
        Coordinates current = start;

        for (final place in selected) {
          totalDistance += current.distanceTo(place.coordinates);
          current = place.coordinates;
        }
        
        totalDistance += current.distanceTo(start);
        
        final estimatedTime = (totalDistance / walkingSpeed).round();

        if (estimatedTime >= minTime && estimatedTime <= maxTime) {
          final diff = (estimatedTime - targetTime).abs().toDouble();
          if (diff < bestDiff) {
            bestDiff = diff;
            bestRoute = WalkRoute(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              points: selected,
              totalDistance: totalDistance,
              totalTime: estimatedTime,
            );
          }
        }
      }
    }

    if (bestRoute == null && sortedPlaces.isNotEmpty) {
      final selected = sortedPlaces.take(2).toList();
      double totalDistance = 0;
      Coordinates current = start;

      for (final place in selected) {
        totalDistance += current.distanceTo(place.coordinates);
        current = place.coordinates;
      }
      totalDistance += current.distanceTo(start);

      bestRoute = WalkRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: selected,
        totalDistance: totalDistance,
        totalTime: (totalDistance / walkingSpeed).round(),
      );
    }

    return bestRoute ?? WalkRoute(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: [],
      totalDistance: 0,
      totalTime: 0,
    );
  }

  void _updateMapCamera(Coordinates center) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(center.lat, center.lng),
        15,
      ),
    );
  }

  Future<void> _openInAppleMaps() async {
    if (_currentRoute == null || _currentRoute!.points.isEmpty) return;

    final location = await ref.read(locationProvider.future);
    final userLocation = ref.read(userLocationProvider);

    Coordinates? start;
    if (location != null) {
      start = Coordinates(lat: location.latitude, lng: location.longitude);
    } else if (userLocation != null) {
      start = userLocation;
    } else {
      return;
    }

    final waypoints = _currentRoute!.points
        .map((p) => '${p.coordinates.lat},${p.coordinates.lng}')
        .join('&waypoints=');

    final url = Uri.parse(
      'https://maps.apple.com/?saddr=${start.lat},${start.lng}&daddr=${waypoints}&dirflg=w',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final location = ref.watch(locationProvider);
    final userLocation = ref.watch(userLocationProvider);

    Coordinates center;
    if (location.value != null) {
      center = Coordinates(
        lat: location.value!.latitude,
        lng: location.value!.longitude,
      );
    } else if (userLocation != null) {
      center = userLocation;
    } else {
      center = const Coordinates(lat: 37.7955, lng: -122.3937);
    }

    if (isTablet) {
      return Row(
        children: [
          Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: _buildRouteInfo(context, theme),
          ),
          Expanded(
            child: _buildMap(theme, center),
          ),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(theme, center),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildRouteInfo(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(ThemeData theme, Coordinates center) {
    final location = ref.watch(locationProvider);
    final userLocation = ref.watch(userLocationProvider);
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    if (_currentRoute != null && _currentRoute!.points.isNotEmpty) {

      Coordinates? start;
      if (location.value != null) {
        start = Coordinates(lat: location.value!.latitude, lng: location.value!.longitude);
      } else if (userLocation != null) {
        start = userLocation;
      }

      if (start != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: LatLng(start.lat, start.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

        final routePoints = [
          LatLng(start.lat, start.lng),
          ..._currentRoute!.points.map((p) => LatLng(p.coordinates.lat, p.coordinates.lng)),
          LatLng(start.lat, start.lng),
        ];

        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            color: Colors.teal,
            width: 4,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );

        for (int i = 0; i < _currentRoute!.points.length; i++) {
          final place = _currentRoute!.points[i];
          markers.add(
            Marker(
              markerId: MarkerId(place.id),
              position: LatLng(place.coordinates.lat, place.coordinates.lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              infoWindow: InfoWindow(
                title: '${i + 1}. ${place.name}',
              ),
            ),
          );
        }
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(center.lat, center.lng),
        zoom: 15,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: location.value != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildRouteInfo(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURATED LOOP',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12 Minute Walk',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_currentRoute != null && _currentRoute!.points.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '~${_currentRoute!.totalDistance.toStringAsFixed(0)}m',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Est. Time',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '~${_currentRoute!.totalTime} min',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _generateRoute,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentRoute == null || _currentRoute!.points.isEmpty
                          ? null
                          : _openInAppleMaps,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                ],
              ),
              if (_currentRoute!.points.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Route Points',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._currentRoute!.points.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                place.category.displayName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ] else if (_isGenerating) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
