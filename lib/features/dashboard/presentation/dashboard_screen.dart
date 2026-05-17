import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/storage/app_preferences.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/theme/sentra_tokens.dart';
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
      _homeIndex = savedIndex.clamp(0, 4);
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
          backgroundColor: kSurface,
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
                      icon: Icon(LucideIcons.briefcaseBusiness),
                      selectedIcon: Icon(LucideIcons.briefcaseBusiness),
                      label: 'Orders',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.clipboardCheck),
                      selectedIcon: Icon(LucideIcons.clipboardCheck),
                      label: 'Forms',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.package),
                      selectedIcon: Icon(LucideIcons.package),
                      label: 'Assets',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.refreshCw),
                      selectedIcon: Icon(LucideIcons.refreshCw),
                      label: 'Sync',
                    ),
                    NavigationDestination(
                      icon: Icon(LucideIcons.userRound),
                      selectedIcon: Icon(LucideIcons.userRound),
                      label: 'Profile',
                    ),
                  ],
                ),
          body: SafeArea(
            child: FutureBuilder<bool>(
              future: AppPreferences.instance.getShowOfflineBanner(),
              builder: (context, snapshot) {
                final showOfflineBanner = snapshot.data ?? true;
                return Column(
                  children: [
                    if (showOfflineBanner && !isOnline)
                      Container(
                        width: double.infinity,
                        color: kDanger,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0.w,
                          vertical: 8.0.h,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.wifiOff,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.0.w),
                            Expanded(
                              child: Text(
                                'You are offline. Changes are stored locally and will sync when online.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w600,
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
                                    AppPreferences.instance
                                        .setSelectedDashboardTab(index);
                                  },
                                  labelType: NavigationRailLabelType.all,
                                  destinations: const [
                                    NavigationRailDestination(
                                      icon: Icon(LucideIcons.briefcaseBusiness),
                                      selectedIcon: Icon(
                                        LucideIcons.briefcaseBusiness,
                                      ),
                                      label: Text('Orders'),
                                    ),
                                    NavigationRailDestination(
                                      icon: Icon(LucideIcons.clipboardCheck),
                                      selectedIcon: Icon(
                                        LucideIcons.clipboardCheck,
                                      ),
                                      label: Text('Forms'),
                                    ),
                                    NavigationRailDestination(
                                      icon: Icon(LucideIcons.package),
                                      selectedIcon: Icon(LucideIcons.package),
                                      label: Text('Assets'),
                                    ),
                                    NavigationRailDestination(
                                      icon: Icon(LucideIcons.refreshCw),
                                      selectedIcon: Icon(LucideIcons.refreshCw),
                                      label: Text('Sync'),
                                    ),
                                    NavigationRailDestination(
                                      icon: Icon(LucideIcons.userRound),
                                      selectedIcon: Icon(LucideIcons.userRound),
                                      label: Text('Profile'),
                                    ),
                                  ],
                                ),
                                const VerticalDivider(width: 1, color: kBorder),
                                Expanded(child: child),
                              ],
                            )
                          : child,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
