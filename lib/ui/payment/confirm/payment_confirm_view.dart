import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/loadable_widget.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/shimmer_loading.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/payment/confirm/viewmodel/payment_confirm_viewmodel.dart';
import 'package:surfy_mobile_app/ui/pos/pages/check/payment_complete_view.dart';
import 'package:surfy_mobile_app/ui/pos/pages/select/select_payment_token_view.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:vibration/vibration.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class PaymentConfirmPage extends StatefulWidget {
  const PaymentConfirmPage({
    super.key,
    required this.storeId,
    required this.receiveCurrency,
    required this.wantToReceiveAmount,
    this.defaultSelectedToken,
    this.defaultSelectedBlockchain,
  });

  final String storeId;
  final CurrencyType receiveCurrency;
  final double wantToReceiveAmount;

  final Token? defaultSelectedToken;
  final Blockchain? defaultSelectedBlockchain;

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
  final SettingsPreference _preference = Get.find();

  final RxBool _isLoading = false.obs;
  final RxBool _isSendProcessing = false.obs;
  final RxBool _isChangePaymentMethodLoading = false.obs;
  final LocalAuthentication _auth = LocalAuthentication();

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
        content: Text(error, style: Theme.of(context).textTheme.headlineLarge),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(
      widget.storeId,
      widget.wantToReceiveAmount,
      widget.receiveCurrency,
      defaultToken: widget.defaultSelectedToken,
      defaultBlockchain: widget.defaultSelectedBlockchain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Shimmer(
        linearGradient: shimmerGradient,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Obx(() {
              if (_isLoading.isTrue) {
                return const LoadingWidget(opacity: 0.4);
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
                                    const SizedBox(height: 10,),
                                    Text(formatFiat(widget.wantToReceiveAmount, widget.receiveCurrency), style: Theme.of(context).textTheme.displayLarge?.apply(color: SurfyColor.blue)),
                                    const SizedBox(height: 10,),
                                    Obx(() {
                                      return ShimmerLoading(
                                          isLoading: _isChangePaymentMethodLoading.value,
                                          child: LoadableWidget(
                                            isLoading: _isChangePaymentMethodLoading.value,
                                            loadingTemplate: Container(
                                              width: 80,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                            ),
                                            child: Text(formatCrypto(_viewModel.observableSelectedToken.value,
                                                cryptoAmountToDecimal(tokens[_viewModel.observableSelectedToken.value]!, _viewModel.observablePayCrypto.value)),
                                                style: Theme.of(context).textTheme.displayMedium),
                                          )
                                      );
                                    })
                                  ],
                                )
                            ),
                            Divider(color: Theme.of(context).dividerColor),
                            Obx(() => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).primaryColorLight,
                              ),
                              child: Material(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () {
                                        if (mounted) {
                                          final props = SelectPaymentTokenPageProps(
                                            onSelect: (Token token, Blockchain blockchain) async {
                                              await _viewModel.changePaymentMethod(token, blockchain, widget.wantToReceiveAmount, widget.receiveCurrency);
                                            },
                                            receiveCurrency: _viewModel.observableUserCurrencyType.value ?? CurrencyType.usd,
                                            wantToReceiveAmount: widget.wantToReceiveAmount);
                                          checkAuthAndPush(context, '/select', extra: props);
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
                                                  Text(tokens[_viewModel.observableSelectedToken.value]?.name ?? "", style: Theme.of(context).textTheme.headlineLarge)
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Obx(() {
                                                        return ShimmerLoading(
                                                            isLoading: _isChangePaymentMethodLoading.value,
                                                            child: LoadableWidget(
                                                                isLoading: _isChangePaymentMethodLoading.value,
                                                                loadingTemplate: Container(
                                                                  width: 80,
                                                                  height: 20,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.black,
                                                                      borderRadius: BorderRadius.circular(10)
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                    formatFiat(
                                                                        cryptoAmountToFiat(
                                                                            tokens[_viewModel.observableSelectedToken.value]!,
                                                                            _viewModel.observableUserBalance.value,
                                                                            _viewModel.observableTokenPrice.value[_preference.userCurrencyType.value] ?? 0.0),
                                                                        _viewModel.observableUserCurrencyType.value ?? CurrencyType.usd), style: Theme.of(context).textTheme.headlineSmall
                                                            )
                                                        ));
                                                      }),
                                                      const SizedBox(height: 4),
                                                      Obx(() {
                                                        return ShimmerLoading(
                                                            isLoading: _isChangePaymentMethodLoading.value,
                                                            child: LoadableWidget(
                                                                isLoading: _isChangePaymentMethodLoading.value,
                                                                loadingTemplate: Container(
                                                                  width: 80,
                                                                  height: 20,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.black,
                                                                      borderRadius: BorderRadius.circular(10)
                                                                  ),
                                                                ),
                                                                child: Text(formatCrypto(_viewModel.observableSelectedToken.value,
                                                                    cryptoAmountToDecimal(tokens[_viewModel.observableSelectedToken.value]!, _viewModel.observableUserBalance.value)),
                                                                    style: Theme.of(context).textTheme.headlineSmall?.apply(color: SurfyColor.mainGrey))
                                                            ));
                                                      }),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Icon(Icons.navigate_next, color: Theme.of(context).primaryColor)
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
                              final gasFiat = gasData.toVisibleAmount() * (_viewModel.observableTokenPrice.value[_preference.userCurrencyType.value] ?? 0.0);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Fee', style: Theme.of(context).textTheme.labelLarge),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Obx(() {
                                              return ShimmerLoading(
                                                  isLoading: _isChangePaymentMethodLoading.value,
                                                  child: LoadableWidget(
                                                    isLoading: _isChangePaymentMethodLoading.value,
                                                    loadingTemplate: Container(
                                                      width: 80,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                    ),
                                                    child: Text(formatFiat(gasFiat, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall),
                                                  )
                                              );
                                            }),
                                            const SizedBox(height: 2,),
                                            Obx(() {
                                              return ShimmerLoading(
                                                  isLoading: _isChangePaymentMethodLoading.value,
                                                  child: LoadableWidget(
                                                    isLoading: _isChangePaymentMethodLoading.value,
                                                    loadingTemplate: Container(
                                                      width: 80,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                    ),
                                                    child: Text(formatCrypto(blockchains[_viewModel.observableSelectedBlockchain.value]?.feeCoin, gasData.toVisibleAmount()), style: Theme.of(context).textTheme.bodySmall)
                                                  )
                                              );
                                            }),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Obx(() {
                              if (_viewModel.observableCanPay.isFalse) {
                                return Container(
                                    child: Text('Insufficient balance, check your wallet!', style: Theme.of(context).textTheme.headlineSmall?.apply(color: SurfyColor.deepRed))
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
                                    child: Text('Loading...', style: Theme.of(context).textTheme.titleLarge)
                                )
                            );
                          }
                          if (_isSendProcessing.isFalse) {
                            return SwipeButton.expand(
                                height: 60,
                                onSwipe: () async {
                                  _isSendProcessing.value = true;
                                  Vibration.vibrate(duration: 100);
                                  final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
                                  final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
                                  if (canAuthenticate) {
                                    final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
                                    if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.face) || availableBiometrics.contains(BiometricType.fingerprint)) {
                                      try {
                                        final bool didAuthenticate = await _auth.authenticate(
                                            localizedReason: 'Please authenticate to pay',
                                            options: const AuthenticationOptions(useErrorDialogs: false));
                                        if (didAuthenticate) {
                                          final job = _viewModel.generateTransferJob(
                                            _viewModel.observableSelectedToken.value,
                                            _viewModel.observableSelectedBlockchain.value,
                                            _viewModel.observableSenderWallet.value,
                                            _viewModel.observableReceiverWallet.value,
                                            _viewModel.observablePayCrypto.value,
                                            fiat: widget.wantToReceiveAmount,
                                            currencyType: widget.receiveCurrency,
                                            memo: 'SURFY Payment!'
                                          );
                                          checkAuthAndPush(context, "/check", extra: PaymentCompletePageProps(
                                              storeName: _viewModel.observableMerchant.value?.storeName ?? "",
                                              fiatAmount: widget.wantToReceiveAmount,
                                              currencyType: widget.receiveCurrency,
                                              token: _viewModel.observableSelectedToken.value,
                                              blockchain: _viewModel.observableSelectedBlockchain.value,
                                              senderAddress: _viewModel.observableSenderWallet.value,
                                              sendingJob: job));
                                          _isSendProcessing.value = false;
                                        } else {
                                          _isSendProcessing.value = false;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("You cancelled authorization", style: Theme.of(context).textTheme.titleMedium),
                                              backgroundColor: Colors.black,
                                            ),
                                          );
                                        }

                                      } on PlatformException catch (e) {
                                        _isSendProcessing.value = false;
                                        print("error: $e");
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("$e", style: Theme.of(context).textTheme.titleMedium),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                        if (e.code == auth_error.notAvailable) {
                                          // Add handling of no hardware here.
                                        } else if (e.code == auth_error.notEnrolled) {
                                          // ...
                                        } else {
                                          // ...
                                        }
                                      } catch (e) {
                                        _isSendProcessing.value = false;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("$e", style: Theme.of(context).textTheme.titleMedium),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                enabled: _viewModel.observableCanPay.value,
                                borderRadius: BorderRadius.circular(0),
                                activeTrackColor: SurfyColor.white,
                                activeThumbColor: SurfyColor.blue,
                                inactiveTrackColor: SurfyColor.lightGrey,
                                child: Text('Swipe to confirm', style: Theme.of(context).textTheme.titleLarge?.apply(color: SurfyColor.blue))
                            );
                          } else {
                            return Container(
                                width: double.infinity,
                                height: 60,
                                color: SurfyColor.blue,
                                child: Center(
                                    child: Text('Sending...', style: Theme.of(context).textTheme.titleLarge?.apply(color: Theme.of(context).primaryColorLight))
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
        )
      ),
    );
  }
}