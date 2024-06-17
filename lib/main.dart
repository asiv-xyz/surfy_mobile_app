import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/token/get_balance.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';
import 'package:surfy_mobile_app/ui/login/login_view.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';
import 'package:surfy_mobile_app/ui/qr/qr_view.dart';
import 'package:surfy_mobile_app/ui/settings/settings_view.dart';
import 'package:surfy_mobile_app/ui/splash/splash_view.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_detail_view.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_view.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

Future<void> buildDependencies() async {
  logger.d('Build Dependency graph');
  TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  TokenPriceRepository tokenPriceRepository =
      Get.put(TokenPriceRepository(service: tokenPriceService));
  GetTokenPrice getTokenPrice =
      Get.put(GetTokenPrice(repository: tokenPriceRepository));

  GetBalance getBalance = Get.put(GetBalance());

  List<CameraDescription> cameras = Get.put(await availableCameras());
}

void main() async {
  dio.transformer = DefaultTransformer()..jsonDecodeCallback = parseJson;
  await buildDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      "pk.eyJ1IjoiYm9vc2lrIiwiYSI6ImNsdm9xZmc4OTByOHoycm9jOWE5eHl6bnQifQ.Di5Upe8BfD8olr5r6wldNw");

  final GoRouter goRouter =
  GoRouter(initialLocation: '/splash', routes: <RouteBase>[
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              showUnselectedLabels: true,
              showSelectedLabels: true,
              unselectedLabelStyle:
              GoogleFonts.sora(color: Colors.white, fontSize: 12),
              selectedLabelStyle:
              GoogleFonts.sora(color: const Color(0xFF3B85F3), fontSize: 12),
              items: [
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/ic_home.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: Colors.black,
                    activeIcon: Image.asset('assets/images/ic_home.png',
                        width: 24, height: 24, color: const Color(0xFF3B85F3)),
                    label: 'Home'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/ic_camera.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: Colors.black,
                    activeIcon: Image.asset('assets/images/ic_camera.png',
                        width: 24, height: 24, color: const Color(0xFF3B85F3)),
                    label: 'QR'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/ic_history.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: Colors.black,
                    activeIcon: Image.asset('assets/images/ic_history.png',
                        width: 24, height: 24, color: const Color(0xFF3B85F3)),
                    label: 'History'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/ic_map.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: Colors.black,
                    activeIcon: Image.asset('assets/images/ic_map.png',
                        width: 24, height: 24, color: const Color(0xFF3B85F3)),
                    label: 'Map'),
              ],
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(index);
              },
            ),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/wallet', builder: (context, state) => const WalletPage(),
                routes: [
                  GoRoute(
                      path: ':token', builder: (context, state) {
                    final token = state.pathParameters["token"];
                    final List<UserTokenData> data = state.extra as List<UserTokenData>;
                    final tokenEnum = tokens.values.where((t) => t.name == token).first;
                    if (token == null) {
                      return Container();
                    }

                    return WalletDetailPage(token: tokenEnum.token, data: data);
                  })
                ]),
          ],),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/qr', builder: (context, state) => QRPage(camera: Get.find<List<CameraDescription>>().first)),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/settings', builder: (context, state) => SettingsPage()),
          ]),
        ])
  ]);

  runApp(GetMaterialApp(home: SurfyApp(goRouter: goRouter,)));
}

class SurfyApp extends StatelessWidget {
  const SurfyApp({super.key, required this.goRouter});

  final GoRouter goRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}
