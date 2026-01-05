import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasidie_city_whisper/app/providers/providers.dart';
import 'package:kasidie_city_whisper/domain/entities/coordinates.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';
import 'package:kasidie_city_whisper/features/point_details/point_details_sheet.dart';
import 'package:kasidie_city_whisper/common/widgets/category_icon.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
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

    final placesAsync = ref.watch(placesProvider(PlacesParams(
      center: center,
      radius: settings.searchRadius,
      categories: settings.selectedCategories,
    )));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: placesAsync.when(
        data: (places) {
          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No places found',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search radius',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedPlaces = List<Place>.from(places)
            ..sort((a, b) => a.distance.compareTo(b.distance));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedPlaces.length,
            itemBuilder: (context, index) {
              final place = sortedPlaces[index];
              return _buildPlaceCard(context, theme, place);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load places',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, ThemeData theme, Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ref.read(selectedPlaceProvider.notifier).state = place;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PointDetailsSheet(place: place),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: CategoryIcon(
                    category: place.category,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          place.category.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${place.distance.toStringAsFixed(0)}m',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
