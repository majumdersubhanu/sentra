import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../core/storage/database.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/work_orders/presentation/work_orders_screen.dart';
import '../features/work_orders/presentation/work_order_detail_screen.dart';
import '../features/work_orders/presentation/work_order_create_screen.dart';
import '../features/work_orders/presentation/work_orders_calendar_screen.dart';
import '../features/inspections/presentation/inspections_screen.dart';
import '../features/inspections/presentation/inspection_detail_screen.dart';
import '../features/inspections/presentation/inspection_create_screen.dart';
import '../features/inspections/presentation/template_builder_screen.dart';
import '../features/assets/presentation/assets_screen.dart';
import '../features/assets/presentation/asset_detail_screen.dart';
import '../features/assets/presentation/asset_scanner_screen.dart';
import '../features/assets/presentation/asset_create_screen.dart';
import '../features/uploads/presentation/uploads_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/conflicts/presentation/conflict_list_screen.dart';
import '../features/conflicts/presentation/conflict_resolution_screen.dart';
import '../features/users/presentation/users_screen.dart';
import 'auth_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: DashboardRoute.page,
      initial: true,
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: WorkOrdersRoute.page, initial: true),
        AutoRoute(page: WorkOrdersCalendarRoute.page),
        AutoRoute(page: InspectionsRoute.page),
        AutoRoute(page: AssetsRoute.page),
        AutoRoute(page: UploadsRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
    AutoRoute(page: AuthRoute.page),
    // Work Order routes
    AutoRoute(
      page: WorkOrderDetailRoute.page,
      path: '/work-orders/:id',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: WorkOrderCreateRoute.page,
      path: '/work-orders/new',
      guards: [AuthGuard()],
    ),
    // Inspection routes
    AutoRoute(
      page: InspectionDetailRoute.page,
      path: '/inspections/:id',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: InspectionCreateRoute.page,
      path: '/inspections/new',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: TemplateBuilderRoute.page,
      path: '/inspections/template-builder',
      guards: [AuthGuard()],
    ),
    // Asset routes
    AutoRoute(
      page: AssetDetailRoute.page,
      path: '/assets/:id',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: AssetScannerRoute.page,
      path: '/assets/scan',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: AssetCreateRoute.page,
      path: '/assets/create',
      guards: [AuthGuard()],
    ),
    // Conflict routes
    AutoRoute(
      page: ConflictListRoute.page,
      path: '/conflicts',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ConflictResolutionRoute.page,
      path: '/conflicts/:entityType/:entityId',
      guards: [AuthGuard()],
    ),
    // Users routes
    AutoRoute(page: UsersRoute.page, path: '/users', guards: [AuthGuard()]),
  ];
}
