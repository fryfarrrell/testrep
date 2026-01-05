import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasidie_city_whisper/features/map/map_screen.dart';
import 'package:kasidie_city_whisper/features/list/list_screen.dart';
import 'package:kasidie_city_whisper/features/route12/route12_screen.dart';
import 'package:kasidie_city_whisper/features/settings/settings_screen.dart';

enum AppTab {
  map,
  list,
  route12,
  settings,
}

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  AppTab _currentTab = AppTab.map;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    
    if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          MapScreen(),
          ListScreen(),
          Route12Screen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(
            child: IndexedStack(
              index: _currentTab.index,
              children: const [
                MapScreen(),
                ListScreen(),
                Route12Screen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              icon: Icons.map,
              label: 'Map',
              tab: AppTab.map,
            ),
            _buildNavButton(
              icon: Icons.list,
              label: 'List',
              tab: AppTab.list,
            ),
            _buildNavButton(
              icon: Icons.directions_walk,
              label: '12 min',
              tab: AppTab.route12,
            ),
            _buildNavButton(
              icon: Icons.settings,
              label: 'Settings',
              tab: AppTab.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required AppTab tab,
  }) {
    final isActive = _currentTab == tab;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Container(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    final theme = Theme.of(context);
    
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'k.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                _buildRailButton(
                  icon: Icons.map,
                  label: 'Explore',
                  tab: AppTab.map,
                ),
                const SizedBox(height: 16),
                _buildRailButton(
                  icon: Icons.directions_walk,
                  label: '12 min',
                  tab: AppTab.route12,
                ),
                const SizedBox(height: 16),
                _buildRailButton(
                  icon: Icons.list,
                  label: 'List',
                  tab: AppTab.list,
                ),
              ],
            ),
          ),
          _buildRailButton(
            icon: Icons.settings,
            label: 'Settings',
            tab: AppTab.settings,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRailButton({
    required IconData icon,
    required String label,
    required AppTab tab,
  }) {
    final isActive = _currentTab == tab;
    final theme = Theme.of(context);
    
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive
                ? theme.scaffoldBackgroundColor
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
