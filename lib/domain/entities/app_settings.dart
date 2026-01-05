import 'package:kasidie_city_whisper/domain/entities/place.dart';

class AppSettings {
  final double searchRadius;
  final Set<PlaceCategory> selectedCategories;
  final bool cacheEnabled;
  final bool firstRun;

  AppSettings({
    this.searchRadius = 500.0,
    Set<PlaceCategory>? selectedCategories,
    this.cacheEnabled = true,
    this.firstRun = true,
  }) : selectedCategories = selectedCategories ??
            {
              PlaceCategory.museum,
              PlaceCategory.art,
              PlaceCategory.viewpoint,
              PlaceCategory.water,
              PlaceCategory.toilet,
              PlaceCategory.bike,
            };

  AppSettings copyWith({
    double? searchRadius,
    Set<PlaceCategory>? selectedCategories,
    bool? cacheEnabled,
    bool? firstRun,
  }) {
    return AppSettings(
      searchRadius: searchRadius ?? this.searchRadius,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      firstRun: firstRun ?? this.firstRun,
    );
  }
}
