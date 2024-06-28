import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/fiat_and_crypto/calculator.dart';
import 'package:surfy_mobile_app/domain/merchant/get_merchants.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/transaction/send_p2p_token.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/merchant/merchant.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/pos/payment_complete_view.dart';
import 'package:surfy_mobile_app/ui/pos/select_payment_token_view.dart';
import 'package:surfy_mobile_app/ui/pos/viewmodel/payment_confirm_viewmodel.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class PaymentConfirmPageProps {
  PaymentConfirmPageProps({required this.storeId, required this.receiveCurrency, required this.wantToReceiveAmount});

  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;
  final String storeId;
}

class PaymentConfirmPage extends StatefulWidget {
  const PaymentConfirmPage({super.key, required this.storeId, required this.receiveCurrency, required this.wantToReceiveAmount});

  final String storeId;
  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;

  @override
  State<StatefulWidget> createState() {
    return _PaymentConfirmPageState();
  }
}

abstract class PaymentConfirmView {
  void onCreate();
  void onChangePaymentMethod();
  void offChangePaymentMethod();
  void onLoading();
  void offLoading();
  void onStartPayment();
  void onFinishPayment();
  void onError(String error);
}

class _PaymentConfirmPageState extends State<PaymentConfirmPage> implements PaymentConfirmView{

  final PaymentConfirmViewModel _viewModel = PaymentConfirmViewModel();

  final Calculator _calculator = Get.find();

  final RxBool _isLoading = false.obs;
  final RxBool _isSendProcessing = false.obs;
  final RxBool _isChangePaymentMethodLoading = false.obs;

  @override
  void onCreate() {

  }

  @override
  void onStartPayment() {
    _isSendProcessing.value = true;
  }

  @override
  void onFinishPayment() {
    _isSendProcessing.value = false;
  }

  @override
  void onLoading() {
    _isLoading.value = true;
  }

  @override
  void offLoading() {
    _isLoading.value = false;
  }

  @override
  void onChangePaymentMethod() {
    _isChangePaymentMethodLoading.value = true;
  }

  @override
  void offChangePaymentMethod() {
    _isChangePaymentMethodLoading.value = false;
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
    _viewModel.init(widget.storeId, widget.wantToReceiveAmount, widget.receiveCurrency);
  }

  bool _canPay() {
    if (_isChangePaymentMethodLoading.isTrue) {
      return true;
    }
    
    return widget.wantToReceiveAmount < _calculator.cryptoToFiat(_viewModel.observableSelectedToken.value,
        _viewModel.observableUserBalance.value, widget.receiveCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Obx(() {
          if (_isLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(color: SurfyColor.blue)
            );
          } else {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text('You pay to ${_viewModel.observableMerchant.value?.storeName}', style: Theme.of(context).textTheme.displayMedium)),
                                const SizedBox(height: 5,),
                                Text(formatFiat(widget.wantToReceiveAmount, widget.receiveCurrency), style: GoogleFonts.sora(fontSize: 48, color: SurfyColor.blue),),
                              ],
                            )
                        ),
                        Divider(color: Theme.of(context).dividerColor),
                        Obx(() => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: SurfyColor.greyBg,
                          ),
                          child: Material(
                              color: SurfyColor.greyBg,
                              borderRadius: BorderRadius.circular(30),
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    if (mounted) {
                                      final props = SelectPaymentTokenPageProps(
                                          onSelect: (Token token, Blockchain blockchain) async {
                                            await _viewModel.changePaymentMethod(token, blockchain, widget.wantToReceiveAmount, widget.receiveCurrency);
                                          }, receiveCurrency: widget.receiveCurrency,
                                          wantToReceiveAmount: widget.wantToReceiveAmount);
                                      context.push("/pos/select", extra: props);
                                    }
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Obx(() {
                                                    if (_isChangePaymentMethodLoading.isTrue) {
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
                                                    return Text(formatFiat(_calculator.cryptoToFiat(_viewModel.observableSelectedToken.value, _viewModel.observableUserBalance.value, widget.receiveCurrency), widget.receiveCurrency), style: GoogleFonts.sora(color: SurfyColor.white, fontSize: 14));
                                                  }),
                                                  Obx(() {
                                                    if (_isChangePaymentMethodLoading.isTrue) {
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
                                                    return Text(formatCrypto(_viewModel.observableSelectedToken.value, _calculator.cryptoToDouble(_viewModel.observableSelectedToken.value, _viewModel.observableUserBalance.value)), style: GoogleFonts.sora(color: SurfyColor.lightGrey, fontSize: 14));
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
                          ),
                        )),
                        Divider(color: Theme.of(context).dividerColor),
                        Obx(() {
                          final gasData = UserTokenData(
                              blockchain: _viewModel.observableSelectedBlockchain.value,
                              token: blockchains[_viewModel.observableSelectedBlockchain.value]?.feeCoin ?? Token.ETHEREUM,
                              // amount: _gas.value,
                              amount: _viewModel.observableGas.value,
                              decimal: tokens[blockchains[_viewModel.observableSelectedBlockchain.value]?.feeCoin]?.decimal ?? 1,
                              address: "");
                          final gasFiat = gasData.toVisibleAmount() * (_viewModel.observableTokenPrice.value);
                          print('gas: $gasData');
                          print('gasFiat: $gasFiat');
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: SurfyColor.greyBg,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pay', style: Theme.of(context).textTheme.labelLarge),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Obx(() {
                                          if (_isChangePaymentMethodLoading.isTrue) {
                                            return Container(
                                              width: 50,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                  color: SurfyColor.black,
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              margin: const EdgeInsets.only(bottom: 2),
                                            );
                                          } else {
                                            return Text(formatFiat(widget.wantToReceiveAmount, widget.receiveCurrency), style: Theme.of(context).textTheme.bodySmall);
                                          }
                                        }),
                                        Obx(() {
                                          if (_isChangePaymentMethodLoading.isTrue) {
                                            return Container(
                                              width: 50,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                  color: SurfyColor.black,
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              margin: const EdgeInsets.only(top: 2),
                                            );
                                          } else {
                                            return Text(formatCrypto(_viewModel.observableSelectedToken.value, _calculator.cryptoToDouble(_viewModel.observableSelectedToken.value, _viewModel.observablePayCrypto.value)), style: Theme.of(context).textTheme.bodySmall);
                                          }
                                        })
                                      ],
                                    )
                                  ],
                                ),
                                const Divider(color: SurfyColor.black),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Fee', style: Theme.of(context).textTheme.labelLarge),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Obx(() {
                                          if (_isChangePaymentMethodLoading.isTrue) {
                                            return Container(
                                              width: 50,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: SurfyColor.black,
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              margin: const EdgeInsets.only(bottom: 2),
                                            );
                                          } else {
                                            return Text(formatFiat(gasFiat, widget.receiveCurrency), style: Theme.of(context).textTheme.bodySmall);
                                          }
                                        }),
                                        Obx(() {
                                          if (_isChangePaymentMethodLoading.isTrue) {
                                            return Container(
                                                width: 50,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: SurfyColor.black,
                                                  borderRadius: BorderRadius.circular(8)
                                                ),
                                                margin: const EdgeInsets.only(top: 2),
                                            );
                                          } else {
                                            return Text(formatCrypto(blockchains[_viewModel.observableSelectedBlockchain.value]?.feeCoin, gasData.toVisibleAmount()), style: Theme.of(context).textTheme.bodySmall);
                                          }
                                        })
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        Obx(() {
                          if (!_canPay()) {
                            return Container(
                                child: Text('Insufficient balance, check your wallet!', style: GoogleFonts.sora(color: SurfyColor.deepRed, fontSize: 14),)
                            );
                          }

                          return Container();
                        })
                      ],
                    ),
                    Obx(() {
                      if (_isChangePaymentMethodLoading.isTrue) {
                        return Container(
                          width: double.infinity,
                          height: 60,
                          color: SurfyColor.lightGrey,
                          child: Center(
                            child: Text('Loading...', style: GoogleFonts.sora(color: SurfyColor.white, fontWeight: FontWeight.bold, fontSize: 16),)
                          )
                        );
                      }
                      if (_isSendProcessing.isFalse) {
                        return SwipeButton.expand(
                            height: 60,
                            onSwipe: () {
                              _viewModel.processPayment(
                                  _viewModel.observableSelectedToken.value,
                                  _viewModel.observableSelectedBlockchain.value,
                                  _viewModel.observableReceiverWallet.value,
                                  _viewModel.observablePayCrypto.value
                              ).then((_) {
                                context.go('/pos/check', extra: PaymentCompletePageProps(
                                    storeName: widget.storeId,
                                    fiatAmount: widget.wantToReceiveAmount,
                                    currencyType: widget.receiveCurrency,
                                    blockchain: _viewModel.observableSelectedBlockchain.value,
                                    txHash: _viewModel.observableTransactionHash.value
                                ));
                              });
                            },
                            enabled: _canPay(),
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
                          )
                        );
                      }
                    }),
                  ],
                ),
                Obx(() {
                  if (_isSendProcessing.isTrue) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: SurfyColor.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: SurfyColor.blue),
                      )
                    );
                  }

                  return Container();
                }),
              ],
            );
          }
        })
      ),
    );
  }
}