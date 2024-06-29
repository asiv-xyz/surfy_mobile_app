import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/cache/token/token_price_cache.dart';
import 'package:surfy_mobile_app/cache/wallet/wallet_cache.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/merchant/click_place.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/qr/get_qr_controller.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
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
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> buildDependencies() async {
  await Hive.initFlutter();

  logger.d('Build Dependency graph');
  TokenPriceService tokenPriceService = Get.put(TokenPriceService());
  TokenPriceCache tokenPriceCache = Get.put(TokenPriceCache());
  TokenPriceRepository tokenPriceRepository =
      Get.put(TokenPriceRepository(service: tokenPriceService, tokenPriceCache: tokenPriceCache));
  GetTokenPrice getTokenPrice =
      Get.put(GetTokenPrice(repository: tokenPriceRepository));

  Get.put(KeyService());

  WalletService walletService = Get.put(WalletService());
  Get.put(GetWalletAddress(service: Get.find(), keyService: Get.find()));

  WalletCache walletCache = Get.put(WalletCache());
  WalletBalancesRepository walletBalancesRepository =
      Get.put(WalletBalancesRepository(walletService: walletService, walletCache: walletCache));

  Get.put(Calculator(getTokenPrice: getTokenPrice));
  Get.put(GetWalletBalances(
    repository: Get.find(),
    getWalletAddressUseCase: Get.find(),
    getTokenPriceUseCase: Get.find(),
    keySerivce: Get.find(),
    calculator: Get.find(),
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

Future<void> web3AuthInit() async {
  late final Uri redirectUrl;
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('surfy://com.riverbank.surfy/auth');
  } else {
    redirectUrl = Uri.parse('com.example.surfyMobileApp://auth');
  }
  await Web3AuthFlutter.init(Web3AuthOptions(
    clientId: dotenv.env["WEB3AUTH_CLIENT_ID"] ?? "",
    network: Network.sapphire_devnet,
    redirectUrl: redirectUrl,
  ));
  await Web3AuthFlutter.initialize();
}

Future<void> loadTokenPrice() async {
  final GetTokenPrice getTokenPrice = Get.find();
  final SettingsPreference preference = Get.find();
  final currencyType = await preference.getCurrencyType();
  await getTokenPrice.getTokenPrice(tokens.values.map((token) => token.token).toList(), currencyType);
}


Future<void> loadDefaultData() async {
  final List<Future> jobList = [
    web3AuthInit(),
    loadTokenPrice(),
  ];

  await Future.wait(jobList);
}

void setEventBus() {
  final EventBus bus = Get.put(EventBus());
  final WalletBalancesRepository walletBalancesRepository = Get.find();
  bus.addEventListener(walletBalancesRepository);
}

void main() async {
  await dotenv.load(fileName: ".env");
  dioObject.transformer = BackgroundTransformer()
    ..jsonDecodeCallback = parseJson;
  await buildDependencies();
  setEventBus();
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_API_KEY"] ?? "");

  Get.put(NavigationController());
  await loadDefaultData();
  String initialLocation = "";
  try {
    await Web3AuthFlutter.getUserInfo();
    initialLocation = "/wallet";
  } catch (e) {
    initialLocation = "/login";
  }
  final goRouter = await generateRouter(Get.find(), Get.find(), initialLocation);
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
      darkTheme: ThemeData(
          appBarTheme: AppBarTheme(
              iconTheme: const IconThemeData(color: SurfyColor.white),
              backgroundColor: SurfyColor.black,
              titleTextStyle: GoogleFonts.sora(
                  color: SurfyColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: SurfyColor.black,
              unselectedIconTheme: IconThemeData(color: SurfyColor.white, size: 24),
              selectedIconTheme: IconThemeData(color: SurfyColor.blue, size: 24),
              unselectedLabelStyle: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600),
              selectedLabelStyle: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.w600),
              selectedItemColor: SurfyColor.blue,
              unselectedItemColor: SurfyColor.white,
              showSelectedLabels: true,
              showUnselectedLabels: true,
          ),
          scaffoldBackgroundColor: SurfyColor.black,
          textTheme: TextTheme(
            // headlineLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 36),
            // headlineMedium: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 24),
            // bodyLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 24),
            // bodyMedium: GoogleFonts.sora(color: SurfyColor.white, fontSize: 20),
            // displayLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),
            // displayMedium: GoogleFonts.sora(color: SurfyColor.white, fontSize: 12),
            // displaySmall: GoogleFonts.sora(color: SurfyColor.white, fontSize: 8),
            // labelLarge: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 12, fontWeight: FontWeight.bold),
            // labelMedium: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 10),
            // labelSmall: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 8),

            displayLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 36),
            displayMedium: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 24),
            displaySmall: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 16),

            titleLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 16),
            titleMedium: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 14),
            titleSmall: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 12),

            headlineLarge: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.w600, fontSize: 18),
            headlineMedium: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16),
            headlineSmall: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14),

            bodyLarge: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16),
            bodyMedium: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14),
            bodySmall: GoogleFonts.sora(color: SurfyColor.white, fontSize: 12),

            labelLarge: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14, fontWeight: FontWeight.w600),
            labelMedium: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 12),
            labelSmall: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 10),
          ),
          iconTheme: const IconThemeData(color: SurfyColor.white),
          cardColor: SurfyColor.darkThemeCardBackground,
          dividerColor: SurfyColor.greyBg
      ),
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              iconTheme: const IconThemeData(color: SurfyColor.black),
              backgroundColor: SurfyColor.lightThemeBackground,
              titleTextStyle: GoogleFonts.sora(
                  color: SurfyColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: SurfyColor.lightThemeBackground,
              unselectedIconTheme: IconThemeData(color: SurfyColor.black, size: 24),
              selectedIconTheme: IconThemeData(color: SurfyColor.blue, size: 24),
              unselectedLabelStyle: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600),
              selectedLabelStyle: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.w600),
              selectedItemColor: SurfyColor.blue,
              unselectedItemColor: SurfyColor.black,
              showSelectedLabels: true,
              showUnselectedLabels: true,
          ),
          scaffoldBackgroundColor: SurfyColor.lightThemeBackground,
          textTheme: TextTheme(
            displayLarge: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 36),
            displayMedium: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 24),
            displaySmall: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 16),

            titleLarge: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 16),
            titleMedium: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 14),
            titleSmall: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 12),

            headlineLarge: GoogleFonts.sora(color: SurfyColor.black, fontWeight: FontWeight.w600, fontSize: 18),
            headlineMedium: GoogleFonts.sora(color: SurfyColor.black, fontSize: 16),
            headlineSmall: GoogleFonts.sora(color: SurfyColor.black, fontSize: 14),

            bodyLarge: GoogleFonts.sora(color: SurfyColor.black, fontSize: 16),
            bodyMedium: GoogleFonts.sora(color: SurfyColor.black, fontSize: 14),
            bodySmall: GoogleFonts.sora(color: SurfyColor.black, fontSize: 12),

            labelLarge: GoogleFonts.sora(color: SurfyColor.darkGrey, fontSize: 14, fontWeight: FontWeight.w600),
            labelMedium: GoogleFonts.sora(color: SurfyColor.darkGrey, fontSize: 12),
            labelSmall: GoogleFonts.sora(color: SurfyColor.darkGrey, fontSize: 10),
          ),
          iconTheme: const IconThemeData(color: SurfyColor.black),
          cardColor: SurfyColor.white,
          dividerColor: SurfyColor.lightGrey
      ),
      themeMode: ThemeMode.dark,
      routerConfig: widget.goRouter,
    );
  }
}
