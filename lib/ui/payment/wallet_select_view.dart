import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletSelectPage extends StatefulWidget {
  const WalletSelectPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletSelectPageState();
  }
}

class _WalletSelectPageState extends State<WalletSelectPage> {
  final GetWalletBalances getWalletBalancesUseCase = Get.find();
  final GetTokenPrice getTokenPriceUseCase = Get.find();
  final SelectToken selectTokenUseCase = Get.find();
  final SettingsPreference preference = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: const Text('What coin will you pay with?'),
            ),
            body: Container(
                width: double.infinity,
                height: double.infinity,
                color: SurfyColor.black,
                child: SingleChildScrollView(
                  child: Column(
                    children: Token.values.map((token) {
                      return InkWell(
                          onTap: () {
                            selectTokenUseCase.selectedToken.value = token;
                            context.pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                                color: SurfyColor.greyBg,
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(tokens[token]?.iconAsset ?? "",
                                        width: 40, height: 40),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tokens[token]?.name ?? "",
                                            style: GoogleFonts.sora(
                                                color: SurfyColor.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        FutureBuilder<Pair<String, String>>(
                                          future: getWalletBalancesUseCase.getUiTokenBalance(token, preference.userCurrencyType.value),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final crypto = snapshot.data?.first;
                                              final fiat = snapshot.data?.second;
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("$fiat", style: GoogleFonts.sora(fontSize: 16, color: SurfyColor.white)),
                                                  Text("$crypto", style: GoogleFonts.sora(fontSize: 16, color: SurfyColor.white))
                                                ],
                                              );
                                            }

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 60,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: SurfyColor.lightGrey,
                                                    borderRadius: BorderRadius.circular(10)
                                                  ),
                                                ),
                                                const SizedBox(height: 6,),
                                                Container(
                                                  width: 60,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      color: SurfyColor.lightGrey,
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                selectTokenUseCase.selectedToken.value == token
                                    ? Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: SurfyColor.blue,
                                        borderRadius:
                                        BorderRadius.circular(100)),
                                    child: Center(
                                        child: Icon(
                                          Icons.check,
                                          color: SurfyColor.white,
                                        )))
                                    : Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                      color: SurfyColor.lightGrey,
                                      borderRadius:
                                      BorderRadius.circular(100)),
                                )
                              ],
                            ),
                          ));
                    }).toList(),
                  ),
                ))));
  }
}
