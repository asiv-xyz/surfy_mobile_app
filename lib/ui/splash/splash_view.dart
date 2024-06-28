import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/merchant/merchant_repository.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  Future<void> initApp() async {
    var startTime = DateTime.now().millisecondsSinceEpoch;
    logger.i('initApp start');
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
    await Web3AuthFlutter.getUserInfo();

    final GetTokenPrice getTokenPrice = Get.find();
    logger.i('Initialize token price data');

    final SettingsPreference preference = Get.find();
    final currencyType = await preference.getCurrencyType();

    final List<Future> jobList = [
      getTokenPrice.getTokenPrice(tokens.values.map((token) => token.token).toList(), currencyType),
      // loadData(),
      // loadPlace()
    ];
    await Future.wait(jobList);
    logger.i('initApp end, duration=${DateTime.now().millisecondsSinceEpoch - startTime}');
  }

  Future<void> loadData() async {
    var startTime = DateTime.now().millisecondsSinceEpoch;
    logger.i('loadData');
    GetWalletBalances getWalletBalances = Get.find();
    KeyService keyService = Get.find();
    final key = await keyService.getKey();
    await getWalletBalances.loadNewTokenDataList(Token.values, key.first, key.second);
    logger.i('loadData end, duration: ${DateTime.now().millisecondsSinceEpoch - startTime}');
  }

  Future<bool> loadPlace() async {
    logger.i('loadPlace');
    MerchantRepository repository = Get.find();
    await repository.getPlaceList();
    logger.i('loadPlace end');
    return true;
  }

  Future<bool> loadMerchant() async {
    logger.i('loadMerchat: is this user merchant?');
    IsMerchant isMerchant = Get.find();
    final isMerchantFlag = await isMerchant.isMerchant();
    if (isMerchantFlag == true) {
      logger.i('This user is merchant!');
      isMerchant.userMerchantInfo.value = await isMerchant.getMyMerchantData();
      return true;
    } else {
      logger.i('This user is not merchant.');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initApp().then((_) {
        loadMerchant().then((_) {
          context.go('/wallet');
        });
      }).catchError((e) {
        if (e.toString().contains('No user found')) {
          logger.i('Not logged in, go to login page');
          context.go('/login');
        } else {
          logger.e('error! $e');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: const Image(image: AssetImage('assets/images/splash_bg.png'), width: double.infinity)
              ),
              const Align(
                  alignment: Alignment.center,
                  child: Image(image: AssetImage('assets/images/surfy_logo.png'), width: 180)
              )
            ],
          )
      )
    );
  }
}