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
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/wallet/send_confirm_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
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
  final _receiverAddress = "".obs;
  final _isFiatInputMode = true.obs;

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

  bool _validateReceiverAddress(String address) {
    return true;
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
      _isLoading.value = false;
    });
    _textController.addListener(() => _receiverAddress.value = _textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: SurfyColor.white),
        backgroundColor: SurfyColor.black,
        titleSpacing: 0,
        title: Text('Send', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),)
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
                    final tokenData = tokens[widget.token];
                    final gasTokenAmount = gas / BigInt.from(pow(10, tokenData?.decimal ?? 0));
                    final gasAsFiat = _tokenPrice * gasTokenAmount;
                    context.push('/sendConfirm', extra: SendConfirmViewProps(
                      token: widget.token,
                      blockchain: widget.blockchain,
                      sender: address,
                      receiver: _receiverAddress.value,
                      amount: _calculateTokenAmount(_inputAmount.value.toDouble()),
                      fiat: _inputAmount.value.toDouble(),
                      currency: _currency.value,
                      sessionTime: _sessionTime,
                      gas: gasAsFiat,
                    ));
                  } else {
                    final gas = await _sendP2pToken.estimateGas(widget.token,
                        widget.blockchain,
                        _receiverAddress.value,
                        _calculateTokenAmount(_inputAmount.value.toDouble()));
                    final tokenData = tokens[widget.token];
                    final gasTokenAmount = gas / BigInt.from(pow(10, tokenData?.decimal ?? 0));
                    final gasAsFiat = _tokenPrice * gasTokenAmount;
                    context.push('/sendConfirm', extra: SendConfirmViewProps(
                      token: widget.token,
                      blockchain: widget.blockchain,
                      sender: address,
                      receiver: _receiverAddress.value,
                      amount: _inputAmount.value.toDouble(),
                      fiat: _calculateFiatAmount(_inputAmount.value.toDouble()),
                      currency: _currency.value,
                      sessionTime: _sessionTime,
                      gas: gasAsFiat,
                    ));
                  }
                } catch (e) {
                  logger.e(e);
                  var errorMsg = "";
                  if (e.toString().contains("insufficient fund")) {
                    errorMsg = "You don't have enough balance. Please check your balance.";
                  } else {
                    errorMsg = "Unknown error.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg, style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
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
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                  Obx(() => Text(_currency.value, style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 36, fontWeight: FontWeight.bold),)),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  // ${tokenData?.symbol}
                                  Obx(() => Text(_inputAmount.value, style: GoogleFonts.sora(color: SurfyColor.blue, fontSize: 36, fontWeight: FontWeight.bold),)),
                                  const SizedBox(width: 10,),
                                  Obx(() => Text(tokens[widget.token]?.symbol ?? "", style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 36, fontWeight: FontWeight.bold),)),
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
                          })
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _isFiatInputMode.value = !_isFiatInputMode.value;
                        },
                        icon: const Icon(Icons.swap_vert_outlined, color: SurfyColor.white, size: 30,)
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: SurfyColor.greyBg,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                            child: Text('Network', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),)
                        ),
                        const SizedBox(width: 10,),
                        Container(
                            decoration: BoxDecoration(
                                color: SurfyColor.greyBg,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(tokens[widget.token]?.iconAsset ?? "", width: 20, height: 20),
                                const SizedBox(width: 5),
                                Text(blockchains[widget.blockchain]?.name ?? "", style: GoogleFonts.sora(fontSize: 12, color: SurfyColor.white),),
                                const SizedBox(width: 2),
                              ],
                            )
                        )
                      ],
                    )
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: TextField(
                          cursorColor: SurfyColor.white,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              label: Text('Wallet Address', style: GoogleFonts.sora(color: SurfyColor.white)),
                              focusColor: SurfyColor.blue,
                              hoverColor: SurfyColor.blue,
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SurfyColor.blue), borderRadius: BorderRadius.all(Radius.circular(10)))
                          ),
                          style: GoogleFonts.sora(color: SurfyColor.white,),
                          controller: _textController,
                        )),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SurfyColor.white,)
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {

                              },
                              icon: Icon(Icons.qr_code_2_outlined, color: SurfyColor.white, size: 30),
                            )
                          )
                        )
                      ],
                    )
                ),
                const Divider(
                  color: SurfyColor.greyBg,
                )
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