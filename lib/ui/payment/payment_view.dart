import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/payment/select_token.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/keyboard_view.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/payment/viewmodel/payment_viewmodel.dart';
import 'package:surfy_mobile_app/ui/pos/select_payment_token_view.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.storeId});

  final String storeId;

  @override
  State<StatefulWidget> createState() {
    return _PaymentPageState();
  }
}

abstract class PaymentView {
  void onLoading();
  void offLoading();

}

class _PaymentPageState extends State<PaymentPage> implements PaymentView {
  final PaymentViewModel _viewModel = PaymentViewModel();

  final SettingsPreference _preference = Get.find();

  final Calculator _calculator = Get.find();
  final _isLoading = false.obs;

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
    _viewModel.init(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Payment',),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          color: SurfyColor.black,
          child: Stack(
            children: [
              Obx(() {
                if (_isLoading.value == true) {
                  return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          color: SurfyColor.black.withOpacity(0.8)),
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: SurfyColor.blue)));
                } else {
                  return KeyboardView(
                    buttonText: 'Send',
                    isFiatInputMode: _viewModel.observableIsFiatInputMode.value,
                    onClickSend: () {},
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
                                        style: GoogleFonts.sora(
                                            color: SurfyColor.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Obx(() {
                                      if (_viewModel.observableIsFiatInputMode.isTrue) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${_viewModel.observableInputAmount.value} ${_viewModel.observableMerchant.value?.currency}',
                                                style: GoogleFonts.sora(
                                                    color: SurfyColor.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(formatCrypto(_viewModel.observableSelectedToken.value!, _calculator.fiatToCryptoV2(_viewModel.observableInputAmount.value.toDouble(), _viewModel.observableTokenPriceByMerchantCurrency.value?.price ?? 0)),
                                                style: GoogleFonts.sora(
                                                    color: SurfyColor.lightGrey, fontSize: 16)),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${_viewModel.observableInputAmount.value} ${tokens[_viewModel.observableSelectedToken.value]?.symbol}',
                                                style: GoogleFonts.sora(
                                                    color: SurfyColor.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(formatFiat(_calculator.cryptoAmountToFiatV2(_viewModel.observableInputAmount.value.toDouble(), _viewModel.observableTokenPriceByMerchantCurrency.value?.price ?? 0), findCurrencyTypeByName(_viewModel.observableMerchant.value?.currency ?? "")),
                                                style: GoogleFonts.sora(
                                                    color: SurfyColor.lightGrey, fontSize: 16)),
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
                              color: SurfyColor.greyBg,
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
                                        receiveCurrency: findCurrencyTypeByName(_viewModel.observableMerchant.value?.currency ?? ""),
                                        wantToReceiveAmount: _viewModel.getMayPaidAmount(),
                                    );
                                    context.push("/pos/select", extra: props);
                                  }
                                },
                                child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TokenIconWithNetwork(blockchain: _viewModel.observableSelectedBlockchain.value, token: _viewModel.observableSelectedToken.value, width: 40, height: 40),
                                            const SizedBox(width: 10),
                                            Text(tokens[_viewModel.observableSelectedToken.value]?.name ?? "", style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 18),)
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

                                                  return Text(formatFiat(_viewModel.getSelectedTokenBalance().balance, _preference.userCurrencyType.value), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14));
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

                                                  return Text(formatCrypto(_viewModel.observableSelectedToken.value, _calculator.cryptoToDouble(_viewModel.observableSelectedToken.value!, _viewModel.getSelectedTokenBalance().cryptoBalance)), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
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
