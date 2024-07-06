import 'dart:collection';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:surfy_mobile_app/dependency.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/user/onboarding.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/service/router/router_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/dio_utils.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

Future<void> web3AuthInit() async {
  late final Uri redirectUrl;
  if (Platform.isAndroid) {
    redirectUrl = Uri.parse('surfy://com.riverbank.surfy/auth');
  } else {
    redirectUrl = Uri.parse('com.example.surfyMobileApp://auth');
  }

  await Web3AuthFlutter.init(Web3AuthOptions(
    clientId: dotenv.env["WEB3AUTH_CLIENT_ID"] ?? "",
    network: Network.sapphire_mainnet,
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

void main() async {
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  dioObject.transformer = BackgroundTransformer()
    ..jsonDecodeCallback = parseJson;
  buildDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_API_KEY"] ?? "");

  await loadDefaultData();
  String initialLocation = "";
  try {
    final user = await Web3AuthFlutter.getUserInfo();
    final Onboarding onboarding = Get.find();
    await onboarding.run(user.name ?? "", user.typeOfLogin ?? "");
    initialLocation = "/wallet";
  } catch (e) {
    logger.i('Route to login: $e');
    initialLocation = "/login";
  }
  final goRouter = await generateRouter(Get.find(), initialLocation);
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
      onNavigationNotification: (value) {
        return true;
      },
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
            labelSmall: GoogleFonts.sora(color: SurfyColor.white, fontSize: 10),
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
            labelSmall: GoogleFonts.sora(color: SurfyColor.white, fontSize: 10),
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
