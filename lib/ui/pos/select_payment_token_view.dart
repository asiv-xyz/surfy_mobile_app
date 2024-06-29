import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/pos/viewmodel/select_payment_token_viewmodel.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SelectPaymentTokenPageProps {
  const SelectPaymentTokenPageProps({
    required this.onSelect,
    required this.receiveCurrency,
    required this.wantToReceiveAmount,
  });

  final Function(Token, Blockchain) onSelect;
  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;
}

class SelectPaymentTokenPage extends StatefulWidget {
  const SelectPaymentTokenPage({
    super.key,
    required this.onSelect,
    required this.receiveCurrency,
    required this.wantToReceiveAmount,
  });

  final Function(Token, Blockchain) onSelect;
  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;

  @override
  State<StatefulWidget> createState() {
    return _SelectPaymentTokenPageState();
  }
}

abstract class SelectPaymentTokenView {
  void onLoading();
  void offLoading();
}

class _SelectPaymentTokenPageState extends State<SelectPaymentTokenPage> implements SelectPaymentTokenView {
  final SelectPaymentTokenViewModel _viewModel = SelectPaymentTokenViewModel();
  final Calculator _calculator = Get.find();

  final RxBool _isLoading = false.obs;

  @override
  void onLoading() {
    _isLoading.value = true;
  }

  @override
  void offLoading() {
    _isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.receiveCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Select payment method',),
      ),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: SurfyColor.black,
            child: const Center(child: CircularProgressIndicator(color: SurfyColor.blue))
          );
        } else {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: _viewModel.observableBalanceList.value.map((balance) => SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        TextButton(onPressed: () {
                          if (mounted) {
                            widget.onSelect(balance.token, balance.blockchain);
                            context.pop();
                          }
                        }, child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    TokenIconWithNetwork(
                                        blockchain: balance.blockchain,
                                        token: balance.token,
                                        width: 40,
                                        height: 40),
                                    const SizedBox(width: 10,),
                                    Text(tokens[balance.token]?.name ?? "", style: Theme.of(context).textTheme.titleLarge)
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(formatFiat(balance.balance, widget.receiveCurrency), style: Theme.of(context).textTheme.titleLarge),
                                    Text(formatCrypto(balance.token, _calculator.cryptoToDouble(balance.token, balance.cryptoBalance)), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14)),
                                  ],
                                )
                              ],
                            )
                        )),
                        Divider(color: Theme.of(context).dividerColor),
                      ],
                    )
                )).toList(),
              ),
            )
          );
        }
      }),
    );
  }

}