import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasidie_city_whisper/app/providers/providers.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 48 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  theme,
                  title: 'Preferences',
                  children: [
                    _buildSettingTile(
                      context,
                      theme,
                      icon: Icons.location_on,
                      iconColor: Colors.blue,
                      title: 'Search Radius',
                      trailing: Text(
                        '${settings.searchRadius.toStringAsFixed(0)}m',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Slider(
                      value: settings.searchRadius,
                      min: 300,
                      max: 1500,
                      divisions: 12,
                      label: '${settings.searchRadius.toStringAsFixed(0)}m',
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).updateRadius(value);
                      },
                    ),
                    const Divider(),
                    _buildSettingTile(
                      context,
                      theme,
                      icon: Icons.storage,
                      iconColor: Colors.green,
                      title: 'Offline Cache',
                      subtitle: 'Maps cached for 24 hours',
                      trailing: Switch(
                        value: settings.cacheEnabled,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).setCacheEnabled(value);
                        },
                      ),
                    ),
                    if (settings.cacheEnabled)
                      Padding(
                        padding: const EdgeInsets.only(left: 64, top: 8),
                        child: TextButton.icon(
                          onPressed: () async {
                            final cacheService = await ref.read(cacheServiceProvider.future);
                            await cacheService.clearCache();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cache cleared')),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Clear Cache'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  theme,
                  title: 'Categories',
                  children: PlaceCategory.values.map((category) {
                    return CheckboxListTile(
                      value: settings.selectedCategories.contains(category),
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleCategory(category);
                      },
                      title: Text(category.displayName),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                _buildSection(
                  context,
                  theme,
                  title: 'Data & Privacy',
                  children: [
                    _buildSettingTile(
                      context,
                      theme,
                      icon: Icons.shield,
                      iconColor: Colors.grey,
                      title: 'Privacy First',
                      subtitle: 'Kasidie does not store your location history. '
                          'All processing happens on your device or via anonymous '
                          'requests to OpenStreetMap.',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
    );
  }
}
