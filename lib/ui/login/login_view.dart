import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/merchant/is_merchant.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3auth_flutter/enums.dart' as web3_auth_enum;
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _isLoading = false.obs;
  final KeyService _keyService = Get.find();

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

  Future<void> loadData(String secp256k1, String ed25519) async {
    GetWalletBalances getWalletBalances = Get.find();
    await getWalletBalances.loadNewTokenDataList(Token.values, secp256k1, ed25519);
  }

  Future<void> initApp() async {
    final GetTokenPrice getTokenPrice = Get.find();
    logger.i('Initialize token price data');
    await getTokenPrice.getTokenPrice(tokens.values.map((token) => token.token).toList(), CurrencyType.usd);
    logger.i('Price data loading completed');

    final SettingsPreference preference = Get.find();
    await preference.changeCurrencyType(CurrencyType.usd);

    logger.i('Initialize wallet balance');
    final key = await _keyService.getKey();
    await loadData(key.first, key.second);
    logger.i('Wallet balance loading completed');

    logger.i('loadMerchant');
    await loadMerchant();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
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
                    child: const Image(
                        image: AssetImage('assets/images/splash_bg.png'),
                        width: double.infinity)),
                Positioned(
                    top: 0,
                    left: 28,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                            image: AssetImage('assets/images/surfy_logo.png')),
                        const SizedBox(height: 10),
                        Text('Nice to see you!',
                            style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))
                      ],
                    )),
                Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login',
                              style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final Web3AuthResponse response =
                                await Web3AuthFlutter.login(
                                  LoginParams(
                                      loginProvider: Provider.google,
                                  ),
                                );
                                if (response.error != null) {
                                  logger.e('error! ${response.error}');
                                } else {
                                  _isLoading.value = true;
                                  await initApp();
                                  _isLoading.value = false;
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                }
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_google.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with Google',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      )))),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final Web3AuthResponse response =
                                  await Web3AuthFlutter.login(
                                    LoginParams(
                                      loginProvider: Provider.twitter,
                                      extraLoginOptions: ExtraLoginOptions(
                                        domain: dotenv.env["AUTH0_DOMAIN"],
                                        client_id: dotenv.env["AUTH0_CLIENT_ID"],
                                        redirect_uri: "surfy://com.riverbank.surfy/auth"
                                      )
                                    ),
                                  );
                                if (response.error != null) {
                                  logger.e('error! ${response.error}');
                                } else {
                                  _isLoading.value = true;
                                  await initApp();
                                  _isLoading.value = false;
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                }
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_x.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with X',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      )))),
                          const SizedBox(height: 20,),
                          MaterialButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final Web3AuthResponse response = await Web3AuthFlutter.login(LoginParams(
                                    loginProvider: Provider.farcaster
                                ));
                                if (response.error != null) {
                                  logger.e('error! ${response.error}');
                                } else {
                                  _isLoading.value = true;
                                  await initApp();
                                  _isLoading.value = false;
                                  if (mounted) {
                                    context.go('/wallet');
                                  }
                                }
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: const Color(0xFF855DCD),
                                  ),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                              image: AssetImage(
                                                  'assets/images/ic_farcaster.png'),
                                              width: 20,
                                              height: 20),
                                          const SizedBox(width: 10),
                                          Text('Sign In with Farcaster',
                                              style: GoogleFonts.sora(
                                                  textStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold)))
                                        ],
                                      ))))
                        ],
                      )
                    )),
                Obx(() {
                  if (_isLoading.isTrue) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: SurfyColor.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(color: SurfyColor.blue,)
                      ),
                    );
                  } else {
                    return Container();
                  }
                })
              ],
            )));
  }
}
