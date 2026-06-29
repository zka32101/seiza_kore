import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/timecapsule_provider.dart';
import '../widgets/observation_tab.dart';
import '../widgets/catalog_tab.dart';
import '../widgets/records_tab.dart';
import '../widgets/settings_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const ObservationTab(),
    const CatalogTab(),
    const RecordsTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final activeEvents = ref.watch(activeEventsProvider);
    final hasActive = activeEvents.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐ 星座コレ！'),
          ],
        ),
        centerTitle: true,
        actions: [
          // Timecapsule alert icon
          if (hasActive)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.hourglass_top),
                  onPressed: () => context.push('/timecapsule'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: '観測',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '図鑑',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: '記録',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
