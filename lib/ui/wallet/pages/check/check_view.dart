import 'dart:async';
import 'package:async/async.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dartx/dartx.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/check/viewmodel/check_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckViewProps {
  CheckViewProps({
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
    required this.sendingJob,
  });

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final BigInt crypto;
  final double fiat;
  final CurrencyType currency;
  final Future<String> sendingJob;

  @override
  String toString() {
    return {
      "token": token.name,
      "blockchain": blockchain.name,
      "sender": sender,
      "receiver": receiver,
      "crypto": crypto,
      "fiat": fiat,
      "currency": currency,
    }.toString();
  }
}

class CheckView extends StatefulWidget {
  const CheckView({super.key,
    required this.token,
    required this.blockchain,
    required this.sender,
    required this.receiver,
    required this.crypto,
    required this.fiat,
    required this.currency,
    required this.sendingJob,
  });

  final Token token;
  final Blockchain blockchain;
  final String sender;
  final String receiver;
  final BigInt crypto;
  final double fiat;
  final CurrencyType currency;
  final Future<String> sendingJob;

  @override
  State<StatefulWidget> createState() {
    return _CheckViewState();
  }
}

abstract class CheckViewInterface {
  void onCreate();
}

class _CheckViewState extends State<CheckView> with SingleTickerProviderStateMixin implements CheckViewInterface {
  final CheckViewModel _viewModel = CheckViewModel();
  final EventBus _bus = Get.find();
  bool _isConfirmed = false;

  @override
  void onCreate() {

  }

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    BackButtonInterceptor.add((bool stopDefaultButtonEvent, RouteInfo info) {
      checkAuthAndGo(context, "/wallet");
      return true;
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeAll();
    super.dispose();
  }

  Widget _buildLoadingWidget() {
    return FutureBuilder<String>(
      future: widget.sendingJob,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.isNotNullOrEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.observableTransactionHash.value = snapshot.data!);
          return StreamBuilder(
            stream: _viewModel.getTransactionSubscription(widget.token, widget.blockchain, snapshot.data!),
            builder: (context, snapshot) {
              if (snapshot.hasData && !_isConfirmed) {
                _isConfirmed = true;
                _bus.emit(ForceUpdateTokenBalanceEvent(
                  token: widget.token,
                  blockchain: widget.blockchain,
                  address: widget.sender,
                ));
                _bus.emit(ReloadHistoryEvent());
                return SizedBox(
                    width: 500,
                    height: 500,
                    child: Column(
                      children: [
                        LottieBuilder.asset("assets/images/animation_complete.json"),
                        Text('Payment Complete!', style: Theme.of(context).textTheme.displaySmall,),
                        const SizedBox(height: 10,),
                        Text('You sent ${formatCrypto(widget.token, cryptoAmountToDecimal(tokens[widget.token]!, widget.crypto))}', style: Theme.of(context).textTheme.labelMedium),
                        Text('To ${shortAddress(widget.receiver)}', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    )
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                    width: 500,
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LottieBuilder.asset(
                          "assets/images/animation_error.json",
                          width: 100,
                        ),
                        Text('Something was wrong!', style: Theme.of(context).textTheme.displaySmall)
                      ],
                    ));
              }

              return SizedBox(
                  width: 500,
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        "assets/images/animation_loading.json",
                        width: 100,
                      ),
                      Text('Waiting confirmation...', style: Theme.of(context).textTheme.displaySmall,)
                    ],
                  ));
            });
        } else if (snapshot.hasError) {
          return Container(
              width: 500,
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    "assets/images/animation_error.json",
                    width: 100,
                  ),
                  Text('Something was wrong!', style: Theme.of(context).textTheme.displaySmall,)
                ],
              ));
        }

        return Container(
            width: 500,
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LottieBuilder.asset(
                  "assets/images/animation_loading.json",
                  width: 100,
                ),
                Text('Broadcasting transaction...', style: Theme.of(context).textTheme.displaySmall,)
              ],
            ));
      }
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text('Check!'),
        ),
        body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _buildLoadingWidget(),
                    Obx(() {
                      if (_viewModel.observableTransactionHash.value.isNullOrEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tx Hash', style: Theme.of(context).textTheme.displaySmall),
                                  Row(
                                    children: [
                                      Text(shortAddress(_viewModel.observableTransactionHash.value), style: Theme.of(context).textTheme.bodyMedium),
                                      IconButton(
                                          onPressed: () {
                                            final scanUrl = blockchains[widget.blockchain]?.getScanUrl(_viewModel.observableTransactionHash.value);
                                            final Uri url = Uri.parse(scanUrl);
                                            launchUrl(url);
                                          },
                                          icon: const Icon(Icons.open_in_browser_outlined)
                                      )
                                    ],
                                  )
                                ],
                              )
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                Container(
                    width: double.infinity,
                    height: 60,
                    child: Material(
                        color: SurfyColor.blue,
                        child: InkWell(
                            onTap: () {
                              if (mounted) {
                                checkAuthAndGo(context, "/wallet");
                              }
                            },
                            child: Center(
                                child: Text('Click to home', style: Theme.of(context).textTheme.headlineLarge?.apply(color: Theme.of(context).primaryColorLight))
                            )
                        )
                    )
                )
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold();
  }

}