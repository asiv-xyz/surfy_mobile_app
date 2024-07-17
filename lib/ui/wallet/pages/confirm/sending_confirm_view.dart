import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/badge.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/check/check_view.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/confirm/viewmodel/sending_confirm_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:vibration/vibration.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

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
    // required this.sender,
    required this.receiver,
    required this.amount,
    // required this.fiat,
    // required this.currencyType,
    this.memo,
  });

  final Token token;
  final Blockchain blockchain;
  // final String sender;
  final String receiver;
  final BigInt amount;
  // final double fiat;
  // final CurrencyType currencyType;
  final String? memo;

  @override
  State<StatefulWidget> createState() {
    return _SendingConfirmPage();
  }
}

class _SendingConfirmPage extends State<SendingConfirmPage> implements SendingConfirmView {
  static const updateThreshold = 300000;

  final SendingConfirmViewModel _viewModel = SendingConfirmViewModel();

  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxBool _isError = false.obs;
  final SettingsPreference _preference = Get.find();
  final LocalAuthentication _auth = LocalAuthentication();

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
    _isSending.value = false;
    _isLoading.value = false;
    _isError.value = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
  }

  Widget _buildScaffold() {
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
                              TokenBadge(token: widget.token)
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
                              NetworkBadge(blockchain: widget.blockchain)
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
                              Text(formatCrypto(
                                  widget.token,
                                  cryptoAmountToDecimal(tokens[widget.token]!, widget.amount)),
                                  style: Theme.of(context).textTheme.bodySmall),
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
                              Obx(() => Text(formatFiat(_viewModel.observableFiat.value, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall)),
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
                                  Obx(() => Text(formatFiat(cryptoAmountToFiat(tokens[_viewModel.observableGasToken.value]!, _viewModel.observableGas.value, _viewModel.observableGasTokenPrice.value), _preference.userCurrencyType.value), style: Theme.of(context).textTheme.bodySmall)),
                                  const SizedBox(height: 2),
                                  Obx(() => Text(formatCrypto(_viewModel.observableGasToken.value,
                                      cryptoAmountToDecimal(tokens[_viewModel.observableGasToken.value]!, _viewModel.observableGas.value)),
                                      style: Theme.of(context).textTheme.labelSmall))
                                ],
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
                              Text('Memo', style: Theme.of(context).textTheme.bodyMedium),
                              Text(widget.memo ?? "", style: Theme.of(context).textTheme.bodySmall)
                            ],
                          )
                      ),
                      Divider(color: Theme.of(context).dividerColor, height: 20),
                    ],
                  ),
                  Obx(() {
                    if (_isSending.isFalse && _isError.isFalse) {
                      return SwipeButton.expand(
                          height: 60,
                          onSwipe: () async {
                            _isSending.value = true;
                            Vibration.vibrate(duration: 100);
                            final now = DateTime.now().millisecondsSinceEpoch;
                            if (now - _viewModel.sessionTime > updateThreshold) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Session Timeout", style: Theme.of(context).textTheme.titleMedium),
                                  backgroundColor: Colors.black,
                                ),
                              );
                              checkAuthAndGo(context, "/wallet");
                              return;
                            }

                            final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
                            final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
                            if (canAuthenticate) {
                              final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
                              if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.face) || availableBiometrics.contains(BiometricType.fingerprint)) {
                                try {
                                  final bool didAuthenticate = await _auth.authenticate(
                                      localizedReason: 'Please authenticate to transfer',
                                      options: const AuthenticationOptions(useErrorDialogs: false));
                                  if (didAuthenticate) {
                                    final sendingJob = _viewModel.generateTransferJob(
                                      widget.token,
                                      widget.blockchain,
                                      _viewModel.observableSenderAddress.value,
                                      widget.receiver,
                                      widget.amount,
                                      fiat: _viewModel.observableFiat.value,
                                      currencyType: _viewModel.observableCurrencyType.value,
                                      memo: widget.memo,
                                    );
                                    Vibration.vibrate(duration: 100);
                                    checkAuthAndGo(
                                        context, '/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send/check', extra: CheckViewProps(
                                      token: widget.token,
                                      blockchain: widget.blockchain,
                                      sender: _viewModel.observableSenderAddress.value,
                                      receiver: widget.receiver,
                                      crypto: widget.amount,
                                      currency: _preference.userCurrencyType.value,
                                      fiat: _viewModel.observableFiat.value,
                                      sendingJob: sendingJob,
                                    ));
                                    _isLoading.value = false;
                                    _isSending.value = false;
                                  } else {
                                    _isLoading.value = false;
                                    _isSending.value = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("You cancelled authorization", style: Theme.of(context).textTheme.titleMedium),
                                        backgroundColor: Colors.black,
                                      ),
                                    );
                                  }
                                } on PlatformException catch (e) {
                                  print("error: $e");
                                  _isLoading.value = false;
                                  _isSending.value = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("$e", style: Theme.of(context).textTheme.titleMedium),
                                      backgroundColor: Colors.black,
                                    ),
                                  );
                                  if (e.code == auth_error.notAvailable) {
                                    // Add handling of no hardware here.
                                  } else if (e.code == auth_error.notEnrolled) {
                                    // ...c
                                  } else {
                                    // ...
                                  }
                                } catch (e) {
                                  _isLoading.value = false;
                                  _isSending.value = false;
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
                          borderRadius: BorderRadius.circular(0),
                          activeTrackColor: SurfyColor.white,
                          activeThumbColor: SurfyColor.blue,
                          child: Text('Swipe to confirm', style: Theme.of(context).textTheme.titleLarge?.apply(color: SurfyColor.blue))
                      );
                    } else if (_isError.isTrue) {
                      return Container(
                          width: double.infinity,
                          height: 60,
                          color: SurfyColor.deepRed,
                          child: Center(
                              child: Text('Error!', style: Theme.of(context).textTheme.titleLarge?.apply(color: Theme.of(context).primaryColorLight))
                          ));
                    } else {
                      return Container(
                          width: double.infinity,
                          height: 60,
                          color: SurfyColor.blue,
                          child: Center(
                              child: Text('Sending...', style: Theme.of(context).textTheme.titleLarge?.apply(color: Theme.of(context).primaryColorLight))
                          ));
                    }
                  })
                ],
              ),
              Obx(() {
                if (_isLoading.isTrue || _isSending.isTrue) {
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

  @override
  Widget build(BuildContext context) {
    _viewModel.init(widget.token,
      widget.blockchain,
      widget.receiver,
      widget.amount,
      // widget.currencyType
    );

    return _buildScaffold();
  }

}