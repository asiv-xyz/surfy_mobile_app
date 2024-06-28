import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/transaction/exceptions/exceptions.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/wallet/sending_confirm_view.dart';
import 'package:surfy_mobile_app/ui/wallet/viewmodel/send_viewmodel.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _SendPageState();
  }
}

abstract class SendPageInterface {
  void onCreate();
  void onLoading();
  void offLoading();
}

class _SendPageState extends State<SendPage> implements SendPageInterface {

  final SendViewModel _viewModel = SendViewModel();

  final SettingsPreference _preference = Get.find();
  final Calculator _calculator = Get.find();

  final _isLoading = false.obs;
  final _textController = TextEditingController();

  @override
  void onCreate() {

  }

  @override
  void onLoading() {

  }

  @override
  void offLoading() {

  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.token, widget.blockchain, _preference.userCurrencyType.value);
    _textController.addListener(() => _viewModel.observableReceiverAddress.value = _textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Send')
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          KeyboardView(
            buttonText: 'Send',
            isFiatInputMode: _viewModel.observableIsFiatInputMode.value,
            onClickSend: () async {
              if (mounted) {
                final address = _viewModel.observableReceiverAddress.value;
                var amount = BigInt.zero;
                var fiat = 0.0;
                if (_viewModel.observableIsFiatInputMode.isTrue) {
                  amount = _calculator.fiatToCryptoAmount(_viewModel.observableInputData.value.toDouble(), widget.token);
                  fiat = _viewModel.observableInputData.value.toDouble();
                } else {
                  amount = _calculator.cryptoWithDecimal(widget.token, _viewModel.observableInputData.value.toDouble());
                  fiat = _calculator.cryptoAmountToFiat(widget.token, _viewModel.observableInputData.value.toDouble(), _preference.userCurrencyType.value);
                }
                context.push('/sendConfirm', extra: SendingConfirmViewProps(
                  token: widget.token,
                  blockchain: widget.blockchain,
                  sender: _viewModel.observableAddress.value,
                  receiver: _viewModel.observableReceiverAddress.value,
                  amount: amount,
                  fiat: fiat,
                ));
              }
            },
            inputAmount: _viewModel.observableInputData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (_viewModel.observableIsFiatInputMode.isTrue) {
                              return Row(
                                children: [
                                  Obx(() => Text(_viewModel.observableInputData.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36, fontWeight: FontWeight.bold),)),
                                  const SizedBox(width: 10,),
                                  Obx(() => Text(_preference.userCurrencyType.value.name.toUpperCase(), style: Theme.of(context).textTheme.headlineLarge)),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  Obx(() => Text(_viewModel.observableInputData.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36, fontWeight: FontWeight.bold),)),
                                  const SizedBox(width: 10,),
                                  Text(tokens[widget.token]?.symbol ?? "", style: Theme.of(context).textTheme.headlineLarge),
                                ],
                              );
                            }
                          }),
                          const SizedBox(height: 10),
                          Obx(() {
                            if (_viewModel.observableIsFiatInputMode.isTrue) {
                              return Text(formatCrypto(widget.token, _calculator.fiatToCrypto(_viewModel.observableInputData.value.toDouble(), widget.token)), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            } else {
                              return Text(formatFiat(_calculator.cryptoAmountToFiat(widget.token, _viewModel.observableInputData.value.toDouble(), _preference.userCurrencyType.value), _preference.userCurrencyType.value), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            }
                          }),
                          Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('Balance', style: Theme.of(context).textTheme.labelSmall),
                                  const SizedBox(width: 5),
                                  Obx(() => Text(formatFiat(_calculator.cryptoToFiat(widget.token, _viewModel.observableCryptoBalance.value, _preference.userCurrencyType.value), _preference.userCurrencyType.value), style: Theme.of(context).textTheme.labelSmall)),
                                  Obx(() => Text(formatCrypto(widget.token, _calculator.cryptoToDouble(widget.token, _viewModel.observableCryptoBalance.value)), style: Theme.of(context).textTheme.labelSmall))
                                ],
                              )
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _viewModel.observableIsFiatInputMode.value = !_viewModel.observableIsFiatInputMode.value;
                        },
                        icon: const Icon(Icons.swap_vert_outlined, size: 50,)
                      )
                    ],
                  ),
                ),
                Divider(color: Theme.of(context).dividerColor),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: NetworkBadge(blockchain: widget.blockchain)
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          cursorColor: SurfyColor.darkGrey,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              label: Text('Wallet Address', style: Theme.of(context).textTheme.labelLarge),
                              focusColor: SurfyColor.blue,
                              hoverColor: SurfyColor.blue,
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                          ),
                          style: Theme.of(context).textTheme.labelLarge,
                          controller: _textController,
                        )),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {

                              },
                              icon: Icon(Icons.qr_code_2_outlined, size: 30),
                            )
                          )
                        )
                      ],
                    )
                ),
                Divider(color: Theme.of(context).dividerColor),
              ],
            ),
          ),
          Obx(() {
            if (_isLoading.isTrue) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: SurfyColor.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: SurfyColor.blue)
                )
              );
            }

            return Container();
          })
        ],
      ),
    );
  }

}