import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';
import 'package:surfy_mobile_app/event_bus/event_bus.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/ui/pos/pages/check/viewmodel/payment_complete_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentCompletePageProps {
  const PaymentCompletePageProps({
    required this.storeName,
    required this.fiatAmount,
    required this.currencyType,
    required this.token,
    required this.blockchain,
    required this.sendingJob,
    required this.senderAddress,
  });

  final String storeName;
  final double fiatAmount;
  final CurrencyType currencyType;
  final Token token;
  final Blockchain blockchain;
  final Future<String> sendingJob;
  final String senderAddress;
}

class PaymentCompletePage extends StatefulWidget {
  const PaymentCompletePage({
    super.key,
    required this.storeName,
    required this.fiatAmount,
    required this.currencyType,
    required this.token,
    required this.blockchain,
    required this.sendingJob,
    required this.senderAddress,
  });

  final String storeName;
  final double fiatAmount;
  final CurrencyType currencyType;
  final Token token;
  final Blockchain blockchain;
  final Future<String> sendingJob;
  final String senderAddress;

  @override
  State<StatefulWidget> createState() {
    return _PaymentCompletePageState();
  }
}

abstract class PaymentCompleteView {}

class _PaymentCompletePageState extends State<PaymentCompletePage>
    implements PaymentCompleteView {
  final PaymentCompleteViewModel _viewModel = PaymentCompleteViewModel();
  final EventBus _bus = Get.find();
  bool _isConfirmed = false;

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
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                _viewModel.observableTransactionHash.value = snapshot.data!);
            return StreamBuilder(
                stream: _viewModel.getTransactionSubscription(
                    widget.token, widget.blockchain, snapshot.data!),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !_isConfirmed) {
                    _isConfirmed = true;
                    _bus.emit(ForceUpdateTokenBalanceEvent(
                      token: widget.token,
                      blockchain: widget.blockchain,
                      address: widget.senderAddress,
                    ));
                    _bus.emit(ReloadHistoryEvent());
                    return Container(
                        width: 500,
                        height: 500,
                        child: Column(
                          children: [
                            LottieBuilder.asset(
                                "assets/images/animation_complete.json"),
                            Text(
                              'Payment Complete!',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 10,),
                            Text('You Paid ${widget.fiatAmount} ${widget.currencyType.name.toUpperCase()} with ${tokens[widget.token]?.name}', style: Theme.of(context).textTheme.labelMedium),
                            Text('to ${widget.storeName}', style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ));
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
                            Text(
                              'Something was wrong!',
                              style: Theme.of(context).textTheme.displaySmall,
                            )
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
                          Text(
                            'Waiting confirmation...',
                            style: Theme.of(context).textTheme.displaySmall,
                          )
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
                    Text(
                      'Something was wrong!',
                      style: Theme.of(context).textTheme.displaySmall,
                    )
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
                  Text(
                    'Broadcasting transaction...',
                    style: Theme.of(context).textTheme.displaySmall,
                  )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0), child: AppBar()),
        body: Container(
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
                      if (_viewModel
                          .observableTransactionHash.value.isNullOrEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tx Hash',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall),
                                  Row(
                                    children: [
                                      Text(
                                          shortAddress(_viewModel
                                              .observableTransactionHash.value),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      IconButton(
                                          onPressed: () {
                                            final scanUrl = blockchains[
                                                    widget.blockchain]
                                                ?.getScanUrl(_viewModel
                                                    .observableTransactionHash
                                                    .value);
                                            final Uri url = Uri.parse(scanUrl);
                                            launchUrl(url);
                                          },
                                          icon: const Icon(
                                              Icons.open_in_browser_outlined))
                                    ],
                                  )
                                ],
                              )),
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
                                child: Text('Click to home',
                                    style: Theme.of(context).textTheme.headlineLarge?.apply(color: Theme.of(context).primaryColorLight))))))
              ],
            )));
  }
}
