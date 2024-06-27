import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/check_view.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';
import 'package:vibration/vibration.dart';

class SendConfirmViewProps {
  SendConfirmViewProps({
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.fiat,
    required this.currency,
    required this.sessionTime,
    required this.gas,
    required this.gasAsFiat,
  });

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final double amount;
  final double fiat;
  final String currency;
  final int sessionTime;
  final double gas;
  final double gasAsFiat;
}

class SendConfirmView extends StatelessWidget {
  SendConfirmView({
    super.key,
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.fiat,
    required this.currency,
    required this.sessionTime,
    required this.gas,
    required this.gasAsFiat,
  });

  static const updateThreshold = 300000;

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final double amount;
  final double fiat;
  final String currency;
  final int sessionTime;
  final double gas;
  final double gasAsFiat;

  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final SendP2pToken _sendP2pToken = Get.find();
  final RxBool _isLoading = false.obs;
  final SettingsPreference _preference = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Confirm'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('Check your sending!', style: Theme.of(context).textTheme.bodyLarge)
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Token', style: Theme.of(context).textTheme.bodyMedium),
                            Container(
                                decoration: BoxDecoration(
                                    color: SurfyColor.greyBg,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child : Row(
                                  children: [
                                    Image.asset(tokens[token]?.iconAsset ?? "", width: 24, height: 24,),
                                    const SizedBox(width: 5),
                                    Text(tokens[token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Network', style: Theme.of(context).textTheme.bodyMedium),
                            Container(
                                decoration: BoxDecoration(
                                    color: SurfyColor.greyBg,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child : Row(
                                  children: [
                                    Image.asset(blockchains[blockchain]?.icon ?? "", width: 24, height: 24,),
                                    const SizedBox(width: 5),
                                    Text(blockchains[blockchain]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recipient', style: Theme.of(context).textTheme.bodyMedium),
                          Text(shortAddress(receiver), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Crypto', style: Theme.of(context).textTheme.bodyMedium),
                            Text(formatCrypto(token, amount), style: Theme.of(context).textTheme.bodySmall),
                            //Text('${amount.toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fiat', style: Theme.of(context).textTheme.bodyMedium),
                            Text(formatFiat(fiat, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fee', style: Theme.of(context).textTheme.bodyMedium),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatFiat(gasAsFiat, findCurrencyTypeByName(currency)), style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 2),
                                Text(formatCrypto(blockchains[blockchain]?.feeCoin, gas / pow(10, tokens[blockchains[blockchain]?.feeCoin]?.decimal ?? 0)), style: Theme.of(context).textTheme.labelSmall)
                              ],
                            )
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                  ],
                ),
                Obx(() {
                  if (_isLoading.isFalse) {
                    return SwipeButton.expand(
                        height: 60,
                        onSwipeEnd: () async {
                          final now = DateTime.now().millisecondsSinceEpoch;
                          if (now - sessionTime > updateThreshold) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Session Timeout", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                backgroundColor: Colors.black,
                              ),
                            );
                            context.go('/wallet');
                            return;
                          } else {
                            Vibration.vibrate(duration: 100);
                            _isLoading.value = true;
                            try {
                              final response = await _sendP2pToken.send(token, blockchain, receiver, amount);
                              print('response: $response');
                              context.push('/check', extra: CheckViewProps(
                                  token: token,
                                  blockchain: blockchain,
                                  transactionHash: response.transactionHash,
                                  receiver: receiver,
                                  crypto: amount,
                                  fiat: fiat,
                                  currency: currency)
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${e}", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                            _isLoading.value = false;
                          }
                        },
                        borderRadius: BorderRadius.circular(0),
                        activeTrackColor: SurfyColor.white,
                        activeThumbColor: SurfyColor.blue,
                        child: Text('Swipe to confirm', style: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.bold, fontSize: 16),)
                    );
                  } else {
                    return Container(
                        width: double.infinity,
                        height: 60,
                        color: SurfyColor.blue,
                        child: Center(
                            child: Text('Sending...', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),)
                        )
                    );
                  }
                })
              ],
            ),
            Obx(() {
              if (_isLoading.isTrue) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: SurfyColor.black.withOpacity(0.4)
                  ),
                  child: Center(
                    child: CircularProgressIndicator(color: SurfyColor.blue,)
                  ),
                );
              } else {
                return Container();
              }
            })
          ],
        )
      ),
    );
  }

}