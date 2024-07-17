import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/logger/logger.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/payment/viewmodel/payment_viewmodel.dart';
import 'package:surfy_mobile_app/ui/pos/pages/select/select_payment_token_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.storeId});

  final String storeId;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

abstract class PaymentView {
  void startLoading();
  void finishLoading();
  void onError(String e);
}

class _PaymentPageState extends State<PaymentPage> implements PaymentView {
  final PaymentViewModel _viewModel = PaymentViewModel();

  final SettingsPreference _preference = Get.find();

  final _isLoading = false.obs;

  @override
  void startLoading() {
    _isLoading.value = true;
  }

  @override
  void finishLoading() {
    _isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.storeId).then((_) {
      Fluttertoast.showToast(msg: "This store want to receive ${_viewModel.observableMerchant.value?.currency}");
    });
  }

  @override
  void onError(String e) {
    logger.e('Error: $e');
    checkAuthAndPush(context, '/error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Payment'),
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Obx(() {
                if (_isLoading.value == true) {
                  return const LoadingWidget(opacity: 0);
                } else {
                  return KeyboardView(
                    buttonText: 'Send',
                    enable: true,
                    isFiatInputMode: _viewModel.observableIsFiatInputMode.value,
                    onClickSend: () {
                      var amount = 0.0;
                      if (_viewModel.observableIsFiatInputMode.isTrue) {
                        amount = _viewModel.observableInputAmount.value.toDouble();
                      } else {
                        amount = cryptoToFiat(_viewModel.observableSelectedToken.value!,
                            cryptoDecimalToBigInt(tokens[_viewModel.observableSelectedToken.value]!, _viewModel.observableInputAmount.value.toDouble()),
                            _viewModel.observableTokenPriceByMerchantCurrency.value?.price ?? 0,
                            findCurrencyTypeByName(_viewModel.observableMerchant.value?.currency ?? "usd"));
                      }

                      final extra = <String, dynamic>{};
                      extra["defaultToken"] = _viewModel.observableSelectedToken.value;
                      extra["defaultBlockchain"] = _viewModel.observableSelectedBlockchain.value;
                      checkAuthAndPush(context,
                          '/payment/store/${widget.storeId}/amount/$amount/currency/${_viewModel.observableMerchant.value?.currency}', extra: extra);
                    },
                    inputAmount: _viewModel.observableInputAmount,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To ${_viewModel.observableMerchant.value?.storeName}',
                                        style: Theme.of(context).textTheme.bodyLarge),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Obx(() {
                                      if (_viewModel.observableIsFiatInputMode.isTrue) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${_viewModel.observableInputAmount.value} ${_viewModel.observableMerchant.value?.currency}',
                                                style: Theme.of(context).textTheme.displayLarge?.merge(const TextStyle(color: SurfyColor.blue))),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(formatCrypto(
                                                _viewModel.observableSelectedToken.value!,
                                                fiatToVisibleCryptoAmount(_viewModel.observableInputAmount.value.toDouble(), _viewModel.observableTokenPriceByMerchantCurrency.value?.price ?? 0)),
                                                style: Theme.of(context).textTheme.displayMedium),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${_viewModel.observableInputAmount.value} ${tokens[_viewModel.observableSelectedToken.value]?.symbol}',
                                                style:Theme.of(context).textTheme.displayLarge?.merge(const TextStyle(color: SurfyColor.blue))),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(formatFiat(decimalCryptoAmountToFiat(_viewModel.observableInputAmount.value.toDouble(), _viewModel.observableTokenPriceByMerchantCurrency.value?.price ?? 0), findCurrencyTypeByName(_viewModel.observableMerchant.value?.currency ?? ""),), style: Theme.of(context).textTheme.displayMedium),
                                          ],
                                        );
                                      }
                                    }),
                                  ],
                                ),
                                IconButton(
                                    onPressed: () {
                                      _viewModel.observableIsFiatInputMode.value = !_viewModel.observableIsFiatInputMode.value;
                                    },
                                    icon: const Icon(Icons.swap_vert_outlined, size: 50,)
                                )
                              ],
                            )
                        ),
                        const SizedBox(height: 20),
                        Obx(() => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context).cardColor,
                            ),
                            child: MaterialButton(
                                onPressed: () {
                                  if (mounted) {
                                    final props = SelectPaymentTokenPageProps(
                                        onSelect: (Token token, Blockchain blockchain) async {
                                          await _viewModel.changePaymentMethod(
                                              token,
                                              blockchain,
                                          );
                                        },
                                        receiveCurrency: _preference.userCurrencyType.value,
                                        wantToReceiveAmount: _viewModel.getMayPaidAmount(),
                                    );
                                    checkAuthAndPush(context, '/select', extra: props);
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        TokenIconWithNetwork(blockchain: _viewModel.observableSelectedBlockchain.value, token: _viewModel.observableSelectedToken.value, width: 40, height: 40),
                                        const SizedBox(width: 10),
                                        Text(tokens[_viewModel.observableSelectedToken.value]?.name ?? "", style: Theme.of(context).textTheme.headlineLarge)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Obx(() {
                                              if (_isLoading.isTrue) {
                                                return Container(
                                                  width: 50,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                      color: SurfyColor.black,
                                                      borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  margin: const EdgeInsets.only(bottom: 2),
                                                );
                                              }

                                              return Text(formatFiat(_viewModel.getSelectedTokenBalance().balance, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodyMedium);
                                            }),
                                            Obx(() {
                                              if (_isLoading.isTrue) {
                                                return Container(
                                                  width: 50,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                      color: SurfyColor.black,
                                                      borderRadius: BorderRadius.circular(8)
                                                  ),
                                                  margin: const EdgeInsets.only(top: 2),
                                                );
                                              }

                                              return Text(formatCrypto(_viewModel.observableSelectedToken.value,
                                                  cryptoAmountToDecimal(tokens[_viewModel.observableSelectedToken.value!]!, _viewModel.getSelectedTokenBalance().cryptoBalance)),
                                                  style: Theme.of(context).textTheme.labelLarge);
                                            })
                                          ],
                                        ),
                                        const SizedBox(width: 10,),
                                        const Icon(Icons.navigate_next, color: SurfyColor.white,)
                                      ],
                                    )
                                  ],
                                )
                            )
                        ))
                      ],
                    ),
                  );
                }
              }),
            ],
          )),
    );
  }
}
