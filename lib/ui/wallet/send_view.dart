import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/service/transaction/exceptions/exceptions.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/wallet/send_confirm_view.dart';
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

class _SendPageState extends State<SendPage> {
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final SettingsPreference _preference = Get.find();
  final SendP2pToken _sendP2pToken = Get.find();

  final _inputAmount = "0".obs;
  final _currency = "".obs;
  final _isLoading = false.obs;
  final _tokenPrice = 0.0.obs;
  final _gasTokenPrice = 0.0.obs;
  final _receiverAddress = "".obs;
  final _isFiatInputMode = true.obs;

  final RxDouble _userTokenBalance = 0.0.obs;
  final RxDouble _userFiatBalance = 0.0.obs;

  final _textController = TextEditingController();

  int _sessionTime = 0;

  String _formattingFiatAmount(String fiat) {
    final formatter = NumberFormat.decimalPattern('en_US');
    if (fiat == "0") {
      return "0";
    }

    if (fiat.endsWith(".")) {
      final splited = fiat.split(".");
      final doubled = splited[0].toDouble();
      return "${formatter.format(doubled)}.";
    }

    return formatter.format(fiat.toDouble());
  }

  String _formattingTokenAmount(double tokenAmount) {
    final tokenData = tokens[widget.token];
    return "${tokenAmount.toStringAsFixed(tokenData?.fixedDecimal ?? 2)} ${tokenData?.symbol}";
  }

  double _calculateTokenAmount(double fiat) {
    final cryptoAmount = fiat / _tokenPrice.value;
    if (cryptoAmount == 0.0) {
      return 0.0;
    }

    return cryptoAmount;
  }

  double _calculateFiatAmount(double crypto) {
    if (crypto == 0.0) {
      return 0.0;
    }

    final fiatAmount = _tokenPrice.value * crypto;
    if (fiatAmount == 0.0) {
      return 0.0;
    }

    return fiatAmount;
  }

  @override
  void initState() {
    super.initState();
    _sessionTime = DateTime.now().millisecondsSinceEpoch;
    _preference.getCurrencyType().then((currencyType) async {
      _currency.value = currencyType.name.toUpperCase();
      _isLoading.value = true;
      final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(widget.token, currencyType);
      _tokenPrice.value = tokenPrice?.price ?? 0.0;
      final gasTokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(blockchains[widget.blockchain]?.feeCoin ??  widget.token, currencyType);
      _gasTokenPrice.value = gasTokenPrice?.price ?? 0.0;

      _userTokenBalance.value = _getWalletBalancesUseCase.aggregateUserTokenAmountByBlockchain(widget.token, widget.blockchain, _getWalletBalancesUseCase.userDataObs.value);
      _userFiatBalance.value = _userTokenBalance.value * _tokenPrice.value;

      _isLoading.value = false;
    });
    _textController.addListener(() => _receiverAddress.value = _textController.text);
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
            isFiatInputMode: _isFiatInputMode.value,
            onClickSend: () async {
              // await _sendP2pToken.send(widget.token, widget.blockchain, _receiverAddress.value, 0);
              if (mounted) {
                try {
                  _isLoading.value = true;
                  final address = await _getWalletAddressUseCase.getAddress(widget.blockchain);
                  if (_isFiatInputMode.isTrue) {
                    final gas = await _sendP2pToken.estimateGas(widget.token,
                        widget.blockchain,
                        _receiverAddress.value,
                        _calculateTokenAmount(_inputAmount.value.toDouble()));
                    final gasTokenAmount = gas.toDouble()/ BigInt.from(pow(10, tokens[blockchains[widget.blockchain]?.feeCoin]?.decimal ?? 0)).toDouble();
                    print('gasTokenAmount: $gasTokenAmount');
                    final gasAsFiat = _gasTokenPrice.value * gasTokenAmount;
                    context.push('/sendConfirm', extra: SendConfirmViewProps(
                      token: widget.token,
                      blockchain: widget.blockchain,
                      sender: address,
                      receiver: _receiverAddress.value,
                      amount: _calculateTokenAmount(_inputAmount.value.toDouble()),
                      fiat: _inputAmount.value.toDouble(),
                      currency: _currency.value,
                      sessionTime: _sessionTime,
                      gas: gas.toDouble(),
                      gasAsFiat: gasAsFiat,
                    ));
                  } else {
                    final gas = await _sendP2pToken.estimateGas(widget.token,
                        widget.blockchain,
                        _receiverAddress.value,
                        _calculateTokenAmount(_inputAmount.value.toDouble()));
                    final gasTokenAmount = gas.toDouble()/ BigInt.from(pow(10, tokens[blockchains[widget.blockchain]?.feeCoin]?.decimal ?? 0)).toDouble();
                    print('gasTokenAmount: $gasTokenAmount');
                    final gasAsFiat = _gasTokenPrice.value * gasTokenAmount;
                    context.push('/sendConfirm', extra: SendConfirmViewProps(
                      token: widget.token,
                      blockchain: widget.blockchain,
                      sender: address,
                      receiver: _receiverAddress.value,
                      amount: _inputAmount.value.toDouble(),
                      fiat: _calculateFiatAmount(_inputAmount.value.toDouble()),
                      currency: _currency.value,
                      sessionTime: _sessionTime,
                      gas: gas.toDouble(),
                      gasAsFiat: gasAsFiat,
                    ));
                  }
                } catch (e) {
                  logger.e(e);
                  var errorMsg = "";
                  if (e is NotActivatedAccountException) {
                    errorMsg = e.toString();
                  } else if (e.toString().contains("insufficient fund")) {
                    errorMsg = "You don't have enough balance. Please check your balance.";
                  } else {
                    errorMsg = "Unknown error.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg, style: Theme.of(context).textTheme.displayLarge),
                      backgroundColor: Colors.black,
                    ),
                  );
                } finally {
                  _isLoading.value = false;
                }
              }
            },
            inputAmount: _inputAmount,
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
                            if (_isFiatInputMode.value) {
                              return Row(
                                children: [
                                  Obx(() => Text(_inputAmount.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36, fontWeight: FontWeight.bold),)),
                                  const SizedBox(width: 10,),
                                  Obx(() => Text(_currency.value, style: Theme.of(context).textTheme.headlineLarge)),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  // ${tokenData?.symbol}
                                  Obx(() => Text(_inputAmount.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36, fontWeight: FontWeight.bold),)),
                                  const SizedBox(width: 10,),
                                  Obx(() => Text(tokens[widget.token]?.symbol ?? "", style: Theme.of(context).textTheme.headlineLarge)),
                                ],
                              );
                            }
                          }),
                          const SizedBox(height: 10),
                          Obx(() {
                            if (_isFiatInputMode.value) {
                              return Text(_formattingTokenAmount(_calculateTokenAmount(_inputAmount.value.toDouble())), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            } else {
                              return Text("${_formattingFiatAmount(_calculateFiatAmount(_inputAmount.value.toDouble()).toString())} ${_currency.value}", style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            }
                          }),
                          Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('Balance', style: Theme.of(context).textTheme.labelSmall),
                                  const SizedBox(width: 5),
                                  Obx(() => Text(formatFiat(_userFiatBalance.value, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.labelSmall)),
                                  Obx(() => Text("(${formatCrypto(widget.token, _userTokenBalance.value)})", style: Theme.of(context).textTheme.labelSmall)),
                                ],
                              )
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _isFiatInputMode.value = !_isFiatInputMode.value;
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