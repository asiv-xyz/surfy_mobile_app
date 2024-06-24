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


  final GetTokenPrice _getTokenPriceUseCase = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: SurfyColor.white),
        titleSpacing: 0,
        title: Text('Confirm', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold)),
        backgroundColor: SurfyColor.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: SurfyColor.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Check your sending!', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 24),)
                ),
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Token', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Network', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recipient', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(shortAddress(receiver), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                    ],
                  ),
                ),
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Crypto', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${amount.toStringAsFixed(tokens[token]?.fixedDecimal ?? 2)} ${tokens[token]?.symbol}', style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                    ],
                  )
                ),
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fiat', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$fiat $currency', style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                    ],
                  )
                ),
                const Divider(color: SurfyColor.greyBg, height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fee', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(formatFiat(gas, findCurrencyTypeByName(currency)), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
                    ],
                  )
                ),
                const Divider(color: SurfyColor.greyBg, height: 20),
              ],
            ),
            Container(
              width: double.infinity,
              height: 60,
              child: SwipeButton.expand(
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
                    // await _sendP2pToken.send(token, blockchain, receiver, 0);
                    context.push('/check', extra: CheckViewProps(
                        token: token,
                        blockchain: blockchain,
                        transactionHash: "0xb78e674c2d4bf36356c3aed8bc049328d6bac3486c70eede7f28ee51c74c84db",
                        receiver: receiver,
                        crypto: amount,
                        fiat: fiat,
                        currency: currency)
                    );
                  }
                },
                borderRadius: BorderRadius.circular(0),
                activeTrackColor: SurfyColor.white,
                activeThumbColor: SurfyColor.blue,
                child: Text('Swipe to confirm', style: GoogleFonts.sora(color: SurfyColor.blue, fontWeight: FontWeight.bold),)
              )
            )
          ],
        )
      ),
    );
  }

}