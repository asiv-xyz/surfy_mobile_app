import 'package:app_links/app_links.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/merchant/click_place.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/navigation_bar.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/repository/token/token_price_repository.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/service/merchant/merchant_service.dart';
import 'package:surfy_mobile_app/service/qr/qr_service.dart';
import 'package:surfy_mobile_app/service/router/router_service.dart';
import 'package:surfy_mobile_app/service/token/token_price_service.dart';
import 'package:surfy_mobile_app/service/transaction/transaction_service.dart';
import 'package:surfy_mobile_app/service/wallet/wallet_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';

Future<void> buildDependencies() async {
  logger.d('Build Dependency graph');
  TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  TokenPriceRepository tokenPriceRepository =
      Get.put(TokenPriceRepository(service: tokenPriceService));
  GetTokenPrice getTokenPrice =
      Get.put(GetTokenPrice(repository: tokenPriceRepository));

  Get.put(KeyService());

  WalletService walletService = Get.put(WalletService());
  Get.put(GetWalletAddress(service: Get.find(), keyService: Get.find()));

  WalletBalancesRepository walletBalancesRepository =
    Get.put(WalletBalancesRepository(walletService: walletService));
  Get.put(GetWalletBalances(
    repository: Get.find(),
    getWalletAddressUseCase: Get.find(),
    getTokenPriceUseCase: Get.find(),
    keySerivce: Get.find(),
  ));

  Get.put(await availableCameras());
  Get.put(SelectToken());

  Get.put(SettingsPreference());
  Get.put(MerchantService());
  Get.put(MerchantRepository(service: Get.find()));

  Get.put(ClickPlace());
  Get.put(TransactionService(keyService: Get.find()));
  Get.put(SendP2pToken(transactionService: Get.find()));

  Get.put(QRService());
  Get.put(GetQRController());
  Get.put(GetMerchants(placeService: Get.find()));

  Get.put(IsMerchant(service: Get.find()));
}

void main() async {
  dioObject.transformer = BackgroundTransformer()..jsonDecodeCallback = parseJson;
  await buildDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(
      "pk.eyJ1IjoiYm9vc2lrIiwiYSI6ImNsdm9xZmc4OTByOHoycm9jOWE5eHl6bnQifQ.Di5Upe8BfD8olr5r6wldNw");

  Get.put(NavigationController());
  final goRouter = await generateRouter(Get.find(), Get.find());
  // Get.put(NavigationController(goRouter: goRouter));

  runApp(GetMaterialApp(home: SurfyApp(goRouter: goRouter)));
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
          break;
        case "send":
          routerService.checkLoginAndPush("send", uri.pathSegments);
          break;
        case "pos":
          routerService.checkLoginAndPush("pos", uri.pathSegments);
          break;
        default:
          routerService.checkLoginAndGo("wallet", []);
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
