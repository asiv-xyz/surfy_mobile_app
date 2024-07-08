import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class WalletItem extends StatefulWidget {
  const WalletItem({
    super.key,
    required this.token,
    required this.tokenAmount,
    required this.tokenPrice,
    required this.currencyType,
  });

  final Token token;
  final BigInt tokenAmount;
  final double tokenPrice;
  final CurrencyType currencyType;

  @override
  State<StatefulWidget> createState() {
    return _WalletItemState();
  }
}

abstract class WalletItemView {

}

class _WalletItemState extends State<WalletItem> implements WalletItemView {
  final SettingsPreference preference = Get.find();

  String visualizeAmount(Token token, BigInt amount) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return "0";
    }
    return (amount / BigInt.from(pow(10, tokenData.decimal))).toStringAsFixed(2);
  }

  Future<Widget> _buildTotalBalanceTab() async {
    final fiat = cryptoAmountToFiat(tokens[widget.token]!, widget.tokenAmount, widget.tokenPrice);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(formatFiat(fiat, preference.userCurrencyType.value), style: Theme.of(context).textTheme.titleLarge),
        Text(formatCrypto(widget.token, visualizeAmount(widget.token, widget.tokenAmount).toDouble()), style: Theme.of(context).textTheme.labelLarge)
      ],
    );
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          final token = tokens[widget.token];
          if (token != null) {
            checkAuthAndGo(context, "/wallet/${token.name}");
          }
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          // color: SurfyColor.white,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(tokens[widget.token]?.iconAsset ?? "", width: 40, height: 40,)
                        )
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(tokens[widget.token]?.name ?? "", style: Theme.of(context).textTheme.titleLarge)
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 5,
                          alignment: WrapAlignment.start,
                          children: tokens[widget.token]?.supportedBlockchain.where((blockchain) {
                            final blockchainData = blockchains[blockchain];
                            if (blockchainData == null) {
                              return false;
                            }

                            return !blockchainData.isTestnet;
                          }).map((blockchain) {
                            final blockchainData = blockchains[blockchain];
                            return SizedBox(
                                width: 14,
                                height: 14,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(blockchainData?.icon ?? "", width: 14, height: 14)
                                )
                            );
                          }).toList() ?? [],
                        )
                      ],
                    ),
                  ],
                ),

                // Price and amount
                FutureBuilder(
                  future: _buildTotalBalanceTab(),
                  builder: (context, state) {
                    if (state.hasData) {
                      return state.data ?? Container();
                    }

                    if (state.hasError) {
                      return Text('Error...');
                    }

                    return const CircularProgressIndicator(color: Color(0xFF3B85F3));
                  },
                )
              ],
            )
        )
    );
  }

}