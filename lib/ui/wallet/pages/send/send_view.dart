import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/send/viewmodel/send_viewmodel.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key,
    required this.token,
    required this.blockchain,
    this.defaultReceiverAddress,
    this.defaultAmount,
  });

  final Token token;
  final Blockchain blockchain;

  final String? defaultReceiverAddress;
  final double? defaultAmount;

  @override
  State<StatefulWidget> createState() {
    return _SendPageState();
  }
}

abstract class SendView {
  void onCreate();
  void onLoading();
  void offLoading();
}

class _SendPageState extends State<SendPage> implements SendView {
  late final SendViewModel _viewModel;

  final SettingsPreference _preference = Get.find();

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
    _viewModel = SendViewModel();
    _viewModel.setView(this);
    _viewModel.init(
        widget.token,
        widget.blockchain,
        _preference.userCurrencyType.value
    );
    _textController.addListener(() => _viewModel.observableReceiverAddress.value = _textController.text);

    if (widget.defaultAmount != null) {
      _viewModel.observableInputData.value = widget.defaultAmount.toString();
    }
    if (widget.defaultReceiverAddress != null) {
      _viewModel.observableReceiverAddress.value = widget.defaultReceiverAddress!;
      _textController.text = widget.defaultReceiverAddress!;
    }
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
          Obx(() => KeyboardView(
            buttonText: 'Send',
            enable: _viewModel.canPay(widget.token),
            disabledText: 'Insufficient Balance',
            disabledColor: SurfyColor.deepRed,
            isFiatInputMode: _viewModel.observableIsFiatInputMode.value,
            onClickSend: () async {
              if (mounted) {
                var amount = BigInt.zero;
                var fiat = 0.0;
                if (_viewModel.observableIsFiatInputMode.isTrue) {
                  amount = fiatToCryptoBigInt(_viewModel.observableInputData.value.toDouble(), tokens[widget.token]!, _viewModel.observableTokenPrice.value);
                  fiat = _viewModel.observableInputData.value.toDouble();
                } else {
                  amount = cryptoDecimalToBigInt(tokens[widget.token]!, _viewModel.observableInputData.value.toDouble());
                  fiat = decimalCryptoAmountToFiat(_viewModel.observableInputData.value.toDouble(), _viewModel.observableTokenPrice.value);
                }
                if (widget.defaultReceiverAddress != null) {
                  checkAuthAndPush(context,
                      "/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send/amount/$amount",
                      extra: widget.defaultReceiverAddress);
                } else {
                  checkAuthAndPush(context, "/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send/amount/$amount");
                }
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
                              return Text(formatCrypto(widget.token,
                                  fiatToVisibleCryptoAmount(_viewModel.observableInputData.value.toDouble(), _viewModel.observableTokenPrice.value)),
                                  style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            } else {
                              return Text(formatFiat(
                                decimalCryptoAmountToFiat(_viewModel.observableInputData.value.toDouble(), _viewModel.observableTokenPrice.value),
                                  _preference.userCurrencyType.value),
                                  style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
                            }
                          }),
                          Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('Balance', style: Theme.of(context).textTheme.labelSmall),
                                  const SizedBox(width: 5),
                                  Obx(() => Text(formatFiat(
                                      cryptoAmountToFiat(tokens[widget.token]!, _viewModel.observableCryptoBalance.value, _viewModel.observableTokenPrice.value),
                                      _preference.userCurrencyType.value), style: Theme.of(context).textTheme.labelSmall)),
                                  const SizedBox(width: 2),
                                  Obx(() => Text("(${formatCrypto(
                                      widget.token,
                                      cryptoAmountToDecimal(tokens[widget.token]!, _viewModel.observableCryptoBalance.value))})",
                                      style: Theme.of(context).textTheme.labelSmall))
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
                Divider(color: Theme.of(context).dividerColor),
              ],
            ),
          )),
          Obx(() {
            if (_isLoading.isTrue) {
              return const LoadingWidget(opacity: 0.4);
            }

            return Container();
          })
        ],
      ),
    );
  }

}