import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/repository/place/place_repository.dart';
import 'package:surfy_mobile_app/repository/wallet/wallet_balances_repository.dart';
import 'package:surfy_mobile_app/service/place/place_service.dart';
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
    late final Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('surfy://com.riverbank.surfy_mobile_app/auth');
    } else {
      redirectUrl = Uri.parse('com.example.surfyMobileApp://auth');
    }
    await Web3AuthFlutter.init(Web3AuthOptions(
      clientId: "BPcfE0gT3pagAlb0yWekXmsxCXxcYQ3jrdKodfDJgM8G3rV5kQ71kZW1kqWlKVzQyj0sIiCSM816kYpU4i1t7ww",
      network: Network.sapphire_devnet,
      redirectUrl: redirectUrl,
    ));
    await Web3AuthFlutter.initialize();
    // await Web3AuthFlutter.getUserInfo();

    final GetTokenPrice getTokenPrice = Get.find();
    logger.i('Initialize token price data');

    final SettingsPreference preference = Get.find();
    final currencyType = await preference.getCurrencyType();

    final List<Future> jobList = [
      getTokenPrice.getTokenPrice(tokens.values.map((token) => token.token).toList(), currencyType),
      loadData(await Web3AuthFlutter.getPrivKey(), await Web3AuthFlutter.getEd25519PrivKey()),
      loadPlace()
    ];
    await Future.wait(jobList);
  }

  Future<void> loadData(String secp256k1, String ed25519) async {
    GetWalletBalances getWalletBalances = Get.find();
    await getWalletBalances.loadNewTokenDataList(Token.values, secp256k1, ed25519);
  }

  Future<bool> loadPlace() async {
    PlaceRepository repository = Get.find();
    await repository.getPlaceList();
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initApp().then((_) {
        context.go('/wallet');
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