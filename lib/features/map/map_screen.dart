import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasidie_city_whisper/app/providers/providers.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/features/point_details/point_details_sheet.dart';
import 'package:kasidie_city_whisper/features/route12/route12_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlaces();
    });
  }

  Future<void> _loadPlaces() async {
    final locationAsync = ref.read(locationProvider);
    final location = await locationAsync.future;
    final settings = ref.read(settingsProvider);
    final userLocation = ref.read(userLocationProvider);

    Coordinates center;
    if (location != null) {
      center = Coordinates(lat: location.latitude, lng: location.longitude);
      ref.read(userLocationProvider.notifier).state = center;
    } else if (userLocation != null) {
      center = userLocation;
    } else {
      center = const Coordinates(lat: 37.7955, lng: -122.3937);
    }

    setState(() => _isLoading = true);

    try {
      final placesAsync = ref.read(placesProvider(PlacesParams(
        center: center,
        radius: settings.searchRadius,
        categories: settings.selectedCategories,
      )).future);

      final places = await placesAsync;
      
      if (mounted) {
        _updateMarkers(places, center);
        _updateMapCamera(center);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateMarkers(List<Place> places, Coordinates userLocation) {
    _markers.clear();
    
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(userLocation.lat, userLocation.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    for (final place in places) {
      _markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.coordinates.lat, place.coordinates.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            ref.read(selectedPlaceProvider.notifier).state = place;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => PointDetailsSheet(place: place),
            );
          },
        ),
      );
    }
    
    setState(() {});
  }

  void _updateMapCamera(Coordinates center) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(center.lat, center.lng),
        15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final location = ref.watch(locationProvider);
    final userLocation = ref.watch(userLocationProvider);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              userLocation?.lat ?? 37.7955,
              userLocation?.lng ?? -122.3937,
            ),
            zoom: 15,
          ),
          markers: _markers,
          myLocationEnabled: location.value != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: _buildCategoryChips(theme, settings),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Route12Screen()),
              );
            },
            icon: const Icon(Icons.directions_walk),
            label: const Text('12 min walk'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.scaffoldBackgroundColor,
          ),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          child: FloatingActionButton(
            onPressed: _loadPlaces,
            child: const Icon(Icons.refresh),
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme, settings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            theme,
            label: 'All',
            isSelected: settings.selectedCategories.length == PlaceCategory.values.length,
            onTap: () {
              // Toggle all categories
            },
          ),
          const SizedBox(width: 8),
          ...PlaceCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  theme,
                  label: category.displayName,
                  isSelected: settings.selectedCategories.contains(category),
                  onTap: () {
                    ref.read(settingsProvider.notifier).toggleCategory(category);
                    _loadPlaces();
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChip(
    ThemeData theme, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.scaffoldBackgroundColor
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
