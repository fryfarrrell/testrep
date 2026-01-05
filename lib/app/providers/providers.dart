import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kasidie_city_whisper/data/api/overpass_api.dart';
import 'package:kasidie_city_whisper/data/local/cache_service.dart';
import 'package:kasidie_city_whisper/data/repositories/places_repository.dart';
import 'package:kasidie_city_whisper/domain/entities/app_settings.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/domain/entities/walk_route.dart';

final cacheServiceProvider = FutureProvider<CacheService>((ref) async {
  final service = CacheService();
  await service.init();
  return service;
});

final overpassApiProvider = Provider<OverpassApi>((ref) => OverpassApi());

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final api = ref.watch(overpassApiProvider);
  final cacheServiceAsync = ref.watch(cacheServiceProvider);
  final cacheService = cacheServiceAsync.value;
  if (cacheService == null) {
    throw Exception('Cache service not initialized');
  }
  return PlacesRepository(api: api, cache: cacheService);
});

final locationProvider = FutureProvider<Position?>((ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition();
  } catch (e) {
    return null;
  }
});

final userLocationProvider = StateProvider<Coordinates?>((ref) => null);

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;
  CacheService? _cacheService;

  SettingsNotifier(this._ref) : super(AppSettings()) {
    _init();
  }

  Future<void> _init() async {
    _cacheService = await _ref.read(cacheServiceProvider.future);
    _loadSettings();
  }

  void _loadSettings() {
    if (_cacheService == null) return;
    
    final firstRun = _cacheService!.getSettings('firstRun') ?? true;
    final radius = _cacheService!.getSettings('radius') ?? 500.0;
    final cacheEnabled = _cacheService!.getSettings('cacheEnabled') ?? true;
    
    final selectedCategories = <PlaceCategory>{};
    final categoriesList = _cacheService!.getSettings('categories') as List<dynamic>?;
    if (categoriesList != null) {
      for (final cat in categoriesList) {
        try {
          selectedCategories.add(PlaceCategory.values.firstWhere(
            (c) => c.name == cat,
          ));
        } catch (e) {
          continue;
        }
      }
    } else {
      selectedCategories.addAll(PlaceCategory.values);
    }

    state = AppSettings(
      firstRun: firstRun,
      searchRadius: radius,
      selectedCategories: selectedCategories,
      cacheEnabled: cacheEnabled,
    );
  }

  void updateRadius(double radius) {
    state = state.copyWith(searchRadius: radius);
    _cacheService?.saveSettings('radius', radius);
  }

  void toggleCategory(PlaceCategory category) {
    final newCategories = Set<PlaceCategory>.from(state.selectedCategories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    state = state.copyWith(selectedCategories: newCategories);
    _cacheService?.saveSettings('categories', newCategories.map((c) => c.name).toList());
  }

  void setFirstRun(bool value) {
    state = state.copyWith(firstRun: value);
    _cacheService?.saveSettings('firstRun', value);
  }

  void setCacheEnabled(bool value) {
    state = state.copyWith(cacheEnabled: value);
    _cacheService?.saveSettings('cacheEnabled', value);
  }

  Future<void> ensureInitialized() async {
    if (_cacheService == null) {
      _cacheService = await _ref.read(cacheServiceProvider.future);
      _loadSettings();
    }
  }
}

final placesProvider = FutureProvider.family<List<Place>, PlacesParams>((ref, params) async {
  final repository = ref.watch(placesRepositoryProvider);
  return repository.getPlaces(
    center: params.center,
    radius: params.radius,
    categories: params.categories,
    forceRefresh: params.forceRefresh,
  );
});

class PlacesParams {
  final Coordinates center;
  final double radius;
  final Set<PlaceCategory> categories;
  final bool forceRefresh;

  PlacesParams({
    required this.center,
    required this.radius,
    required this.categories,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacesParams &&
          runtimeType == other.runtimeType &&
          center.lat == other.center.lat &&
          center.lng == other.center.lng &&
          radius == other.radius &&
          categories.length == other.categories.length &&
          categories.every((c) => other.categories.contains(c)) &&
          forceRefresh == other.forceRefresh;

  @override
  int get hashCode =>
      center.lat.hashCode ^
      center.lng.hashCode ^
      radius.hashCode ^
      categories.hashCode ^
      forceRefresh.hashCode;
}

final selectedPlaceProvider = StateProvider<Place?>((ref) => null);

final walkRouteProvider = StateProvider<WalkRoute?>((ref) => null);
