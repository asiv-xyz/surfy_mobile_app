import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/check/check_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/confirm/viewmodel/sending_confirm_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendingConfirmViewProps {
  SendingConfirmViewProps({
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.fiat,
    required this.currencyType,
  });

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final BigInt amount;
  final double fiat;
  final CurrencyType currencyType;

  @override
  String toString() {
    return {
      "token": token.name,
      "blockchain": blockchain.name,
      "sender": sender,
      "receiver": receiver,
      "amount": amount.toString(),
      "fiat": fiat,
      "currencyType": currencyType,
    }.toString();
  }
}

abstract class SendingConfirmView {
  void startLoading();
  void finishLoading();
  void onSending();
  void finishSending();
  void onError(String error);
}

class SendingConfirmPage extends StatefulWidget {
  const SendingConfirmPage({
    super.key,
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.fiat,
    required this.currencyType,
  });

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final BigInt amount;
  final double fiat;
  final CurrencyType currencyType;

  @override
  State<StatefulWidget> createState() {
    return _SendingConfirmPage();
  }
}

class _SendingConfirmPage extends State<SendingConfirmPage> implements SendingConfirmView {
  static const updateThreshold = 300000;

  final SendingConfirmViewModel _viewModel = SendingConfirmViewModel();

  final Calculator _calculator = Get.find();

  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final EventBus eventBus = Get.find();
  final SettingsPreference _preference = Get.find();

  @override
  void startLoading() {
    _isLoading.value = true;
  }

  @override
  void finishLoading() {
    _isLoading.value = false;
  }

  @override
  void onSending() {
    _isSending.value = true;
  }

  @override
  void finishSending() {
    _isSending.value = false;
  }

  @override
  void onError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.token, widget.blockchain, widget.receiver, widget.amount, widget.currencyType);
  }

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
                                    Image.asset(tokens[widget.token]?.iconAsset ?? "", width: 24, height: 24,),
                                    const SizedBox(width: 5),
                                    Text(tokens[widget.token]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
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
                                    Image.asset(blockchains[widget.blockchain]?.icon ?? "", width: 24, height: 24,),
                                    const SizedBox(width: 5),
                                    Text(blockchains[widget.blockchain]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 16)),
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
                          Text(shortAddress(widget.receiver), style: Theme.of(context).textTheme.bodySmall),
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
                            Text(formatCrypto(widget.token, _calculator.cryptoToDouble(widget.token, widget.amount)), style: Theme.of(context).textTheme.bodySmall),
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
                            Text(formatFiat(widget.fiat, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall),
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
                                Text(formatFiat(_calculator.cryptoToFiatV2(widget.token, widget.amount, _viewModel.observableTokenPrice.value), _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 2),
                                Text(formatCrypto(_viewModel.observableGasToken.value, _calculator.cryptoToDouble(widget.token, _viewModel.observableGas.value)), style: Theme.of(context).textTheme.labelSmall)
                              ],
                            )
                          ],
                        )
                    ),
                    Divider(color: Theme.of(context).dividerColor, height: 20),
                  ],
                ),
                Obx(() {
                  if (_isSending.isFalse) {
                    return SwipeButton.expand(
                        height: 60,
                        onSwipe: () async {
                          final now = DateTime.now().millisecondsSinceEpoch;
                          if (now - _viewModel.sessionTime > updateThreshold) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Session Timeout", style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold),),
                                backgroundColor: Colors.black,
                              ),
                            );
                            context.go('/wallet');
                            return;
                          } else {
                            try {
                              final response = await _viewModel.processTransfer(
                                  widget.token,
                                  widget.blockchain,
                                  widget.sender,
                                  widget.receiver,
                                  widget.amount);
                              if (!mounted) {
                                return;
                              }
                              context.push('/check', extra: CheckViewProps(
                                  token: widget.token,
                                  blockchain: widget.blockchain,
                                  transactionHash: response,
                                  receiver: widget.receiver,
                                  crypto: widget.amount,
                                  currency: _preference.userCurrencyType.value,
                                  fiat: widget.fiat
                              ));
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
                    ));
                  }
                })
              ],
            ),
            Obx(() {
              if (_isLoading.isTrue) {
                return const LoadingWidget(opacity: 0.4);
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