import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/service/key/key_service.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletItem extends StatefulWidget {
  WalletItem({super.key, required this.token});

  final Token token;

  @override
  State<StatefulWidget> createState() {
    return _WalletItemState();
  }
}

class _WalletItemState extends State<WalletItem> {
  final GetWalletBalances getWalletBalances = Get.find();
  final GetTokenPrice getTokenPrice = Get.find();
  final SettingsPreference preference = Get.find();
  final Rx<List<UserTokenData>> _userTokenData = Rx<List<UserTokenData>>([]);
  final Rx<TokenPrice?> _tokenPrice = Rx<TokenPrice?>(null);

  String visualizeAmount(Token token, BigInt amount) {
    final tokenData = tokens[token];
    if (tokenData == null) {
      return "0";
    }
    return (amount / BigInt.from(pow(10, tokenData.decimal))).toStringAsFixed(2);
  }

  Future<void> loadData() async {
    final balances = await getWalletBalances.getTokenDataList(widget.token);
    _userTokenData.value = balances;

    final prices = await getTokenPrice.getSingleTokenPrice(widget.token, preference.userCurrencyType.value);
    _tokenPrice.value = prices;
  }

  Future<Widget> _buildTotalBalanceTab() async {
    final uiBalancePair = getWalletBalances.parseTotalTokenBalanceForUi(widget.token,
        _userTokenData.value,
        _tokenPrice.value?.price ?? 0,
        preference.userCurrencyType.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
            child: Text(uiBalancePair.second, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),)
        ),
        Container(
            child: Text(uiBalancePair.first, style: GoogleFonts.sora(color: Color(0xFFA0A0A0), fontSize: 14))
        )
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
        onTap: () {
          final token = tokens[widget.token];
          if (token != null) {
            context.go("/wallet/${token.name}");
          }
        },
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1E1E1E),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(tokens[widget.token]?.iconAsset ?? "", width: 40, height: 40,)
                        )
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(tokens[widget.token]?.name ?? "", style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                          ],
                        ),
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
    ));
  }

}