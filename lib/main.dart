import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';
import 'package:surfy_mobile_app/ui/qr/qr_view.dart';
import 'package:surfy_mobile_app/ui/splash/splash_view.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken("pk.eyJ1IjoiYm9vc2lrIiwiYSI6ImNsdm9xZmc4OTByOHoycm9jOWE5eHl6bnQifQ.Di5Upe8BfD8olr5r6wldNw");
  runApp(const SurfyApp());
}

final GoRouter _goRouter = GoRouter(
  initialLocation: '/wallet',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.blue,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history, color: Colors.blue), label: 'QR'),
              BottomNavigationBarItem(icon: Icon(Icons.credit_card, color: Colors.blue), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined, color: Colors.blue), label: 'Map'),
            ],
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(index);
            },
          ),
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/wallet', builder: (context, state) => const WalletPage()),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/qr', builder: (context, state) => const QRPage()),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
          ]
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          ]
        ),
      ]
    )
  ]
);

class SurfyApp extends StatelessWidget {
  const SurfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _goRouter,
    );
  }
}
