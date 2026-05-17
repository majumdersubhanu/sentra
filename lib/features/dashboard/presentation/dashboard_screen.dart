import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sentra_ui/sentra_ui.dart';

import '../../../core/storage/app_preferences.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../routes/app_router.dart';

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _homeIndex = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedTab();
  }

  Future<void> _loadSelectedTab() async {
    final savedIndex = await AppPreferences.instance.getSelectedDashboardTab();
    if (!mounted) return;
    setState(() {
      _homeIndex = savedIndex.clamp(0, 5);
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AutoTabsRouter(
      routes: const [
        WorkOrdersRoute(),
        WorkOrdersCalendarRoute(),
        InspectionsRoute(),
        AssetsRoute(),
        UploadsRoute(),
        ProfileRoute(),
      ],
      homeIndex: _homeIndex,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final isWide = MediaQuery.sizeOf(context).width >= 900;
        final isOnline = ref.watch(isOnlineProvider);

        return Scaffold(
          backgroundColor: SentraColors.gray50,
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: tabsRouter.activeIndex,
                  onDestinationSelected: (index) {
                    tabsRouter.setActiveIndex(index);
                    AppPreferences.instance.setSelectedDashboardTab(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(LucideIcons.listTodo),
                      label: 'Orders',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.calendarDays),
                      label: 'Calendar',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.clipboardCheck),
                      label: 'Forms',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.package),
                      label: 'Assets',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.refreshCw),
                      label: 'Sync',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.userRound),
                      label: 'Profile',
                    ),
                  ],
                ),
          body: SafeArea(
            child: Column(
              children: [
                if (!isOnline)
                  Container(
                    width: double.infinity,
                    color: SentraColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.wifiOff,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline Mode - Changes will sync later',
                            style: SentraTypography.label.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: isWide
                      ? Row(
                          children: [
                            NavigationRail(
                              selectedIndex: tabsRouter.activeIndex,
                              onDestinationSelected: (index) {
                                tabsRouter.setActiveIndex(index);
                                AppPreferences.instance.setSelectedDashboardTab(
                                  index,
                                );
                              },
                              labelType: NavigationRailLabelType.all,
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.listTodo),
                                  label: Text('Orders'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.calendarDays),
                                  label: Text('Calendar'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.clipboardCheck),
                                  label: Text('Forms'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.package),
                                  label: Text('Assets'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.refreshCw),
                                  label: Text('Sync'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(LucideIcons.userRound),
                                  label: Text('Profile'),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              width: 1,
                              color: SentraColors.gray200,
                            ),
                            Expanded(child: child),
                          ],
                        )
                      : child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
