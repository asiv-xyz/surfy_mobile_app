import 'package:app_links/app_links.dart';
import 'package:camera/camera.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/place/click_place.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/place/place_repository.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/place/place_service.dart';
import 'package:surfy_mobile_app/service/router/router_service.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/history/history_view.dart';
import 'package:surfy_mobile_app/ui/login/login_view.dart';
import 'package:surfy_mobile_app/ui/map/map_view.dart';
import 'package:surfy_mobile_app/ui/payment/payment_view.dart';
import 'package:surfy_mobile_app/ui/payment/wallet_select_view.dart';
import 'package:surfy_mobile_app/ui/qr/qr_view.dart';
import 'package:surfy_mobile_app/ui/settings/settings_view.dart';
import 'package:surfy_mobile_app/ui/splash/splash_view.dart';
import 'package:surfy_mobile_app/ui/wallet/send_receive_view.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_detail_view.dart';
import 'package:surfy_mobile_app/ui/wallet/wallet_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

Future<void> buildDependencies() async {
  logger.d('Build Dependency graph');
  TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  TokenPriceRepository tokenPriceRepository =
      Get.put(TokenPriceRepository(service: tokenPriceService));
  GetTokenPrice getTokenPrice =
      Get.put(GetTokenPrice(repository: tokenPriceRepository));

  WalletService walletService = Get.put(WalletService());
  Get.put(GetWalletAddress(service: walletService));

  WalletBalancesRepository walletBalancesRepository =
      Get.put(WalletBalancesRepository(walletService: walletService));
  Get.put(GetWalletBalances(
      repository: Get.find(),
      getWalletAddressUseCase: Get.find(),
      getTokenPriceUseCase: Get.find()
  ));

  Get.put(await availableCameras());
  Get.put(SelectToken());

  Get.put(SettingsPreference());
  Get.put(PlaceService());
  Get.put(PlaceRepository(service: Get.find()));

  Get.put(ClickPlace());
}

void main() async {
  dioObject.transformer = DefaultTransformer()..jsonDecodeCallback = parseJson;
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
              unselectedItemColor: Colors.white,
              selectedItemColor: SurfyColor.blue,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/wallet');
                    break;
                  case 1:
                    context.go('/qr');
                    break;
                  case 2:
                    context.go('/history');
                    break;
                  case 3:
                    context.go('/map');
                    break;
                  default:
                    break;
                }
              },
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
            ),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                  path: '/wallet',
                  builder: (context, state) => const WalletPage(),
                  routes: [
                    GoRoute(
                        path: ':token',
                        builder: (context, state) {
                          final token = state.pathParameters["token"];
                          final List<UserTokenData> data =
                              state.extra as List<UserTokenData>;
                          final tokenEnum =
                              tokens.values.where((t) => t.name == token).first;
                          if (token == null) {
                            return Container();
                          }

                          return WalletDetailPage(
                              token: tokenEnum.token, data: data);
                        })
                  ]),
            ],
          ),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/qr',
                builder: (context, state) =>
                    QRPage(camera: Get.find<List<CameraDescription>>().first)),
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
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(path: '/payment', builder: (context, state) {
              return PaymentPage(storeId: 'none');
            }, routes: [
              GoRoute(
                path: ':storeId',
                builder: (context, state) {
                  final storeId = state.pathParameters['storeId'];
                  print('route to payment page with storeId: $storeId');
                  return PaymentPage(storeId: storeId ?? 'none');
                }
              ),
            ]),
            GoRoute(path: '/select', builder: (context, state) => const WalletSelectPage())
          ]),
          StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                    path: '/send',
                    builder: (context, state) {
                      final Pair<Token, Blockchain> extra = state.extra as Pair<Token, Blockchain>;
                      final token = extra.first;
                      final blockchain = extra.second;
                      return SendReceivePage(
                          token: token,
                          blockchain: blockchain
                      );
                    }
                ),
              ]),
        ])
  ]);

  runApp(GetMaterialApp(
      home: SurfyApp(
    goRouter: goRouter,
  )));
}

class SurfyApp extends StatefulWidget {
  const SurfyApp({super.key, required this.goRouter});

  final GoRouter goRouter;

  @override
  State<StatefulWidget> createState() {
    return _SurfyAppState();
  }
}

class _SurfyAppState extends State<SurfyApp> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    Get.put(RouterService(router: widget.goRouter));
    _appLinks.uriLinkStream.listen((uri) {
      final RouterService routerService = Get.find();
      switch (uri.pathSegments[0]) {
        case "payment":
          routerService.checkLoginAndPush("payment", uri.pathSegments);
        default:
          routerService.checkLoginAndGo("/wallet", []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: widget.goRouter,
    );
  }
}
