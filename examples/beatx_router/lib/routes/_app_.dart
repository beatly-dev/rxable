import 'package:go_router/go_router.dart';
import r'./details.$id.route.dart';
import r'./settings/index.route.dart';
import r'./index.route.dart';
import r'./mypage.alarms.route.dart';

final $routes = [
  GoRouteData.$route(
    path: '/',
    factory: MainScreenRoute.fromState,
    routes: [
      GoRouteData.$route(
        path: '/details/:id',
        factory: DetailsScreenRoute.fromState,
        routes: [],
      ),
      GoRouteData.$route(
        path: '/settings',
        factory: SettingsScreenRoute.fromState,
        routes: [],
      )
    ],
  ),
  GoRouteData.$route(
    path: '/mypage/alarms',
    factory: AlarmsSettingsRoute.fromState,
    routes: [],
  )
];
