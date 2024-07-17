import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/balance_view.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/single_balance/viewmodel/send_receive_viewmodel.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/entity/blockchain/blockchains.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class SingleBalancePage extends StatefulWidget {
  const SingleBalancePage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _SingleBalancePageState();
  }
}

abstract class SingleBalanceView {
  void startLoading();
  void finishLoading();
}

class _SingleBalancePageState extends State<SingleBalancePage> implements SingleBalanceView {
  final SingleBalanceViewModel _viewModel = SingleBalanceViewModel();
  final SettingsPreference _preference = Get.find();
  final RxBool _isLoading = false.obs;

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
    _viewModel.init(widget.token, widget.blockchain, _preference.userCurrencyType.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TokenIconWithNetwork(
                blockchain: widget.blockchain,
                token: widget.token,
                width: 40,
                height: 40
            ),
            const SizedBox(width: 10,),
            Text(tokens[widget.token]?.name ?? "")
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return const LoadingWidget(opacity: 0.4);
        } else {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: BalanceView(
                              token: widget.token,
                              currencyType: _preference.userCurrencyType.value,
                              cryptoBalance: cryptoAmountToDecimal(tokens[widget.token]!, _viewModel.observableCryptoBalance.value),
                              fiatBalance: cryptoAmountToFiat(tokens[widget.token]!, _viewModel.observableCryptoBalance.value, _viewModel.observableTokenPrice.value),
                            )
                        )),
                        SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Obx(() => CurrentPrice(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    tokenName: tokens[widget.token]?.name ?? "",
                                    price: _viewModel.observableTokenPrice.value,
                                    currency: _preference.userCurrencyType.value)
                                )
                              ],
                            )
                        )
                      ],
                    )
                ),
                Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: SurfyColor.lightGrey),
                        borderRadius: BorderRadius.circular(15)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your ${tokens[widget.token]?.name} address', style: Theme.of(context).textTheme.labelMedium,),
                            Obx(() => Text(shortAddress(_viewModel.observableAddress.value), style: Theme.of(context).textTheme.labelSmall))
                          ],
                        ),
                        OutlinedButton(
                            // style: ButtonStyle(
                            //     // backgroundColor: WidgetStateProperty.all(SurfyColor.greyBg),
                            //     shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(15)
                            //     ))
                            // ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _viewModel.observableAddress.value));
                              Fluttertoast.showToast(msg: 'Copied address!', gravity: ToastGravity.CENTER);
                            },
                            child: Center(
                                child: Text('Copy', style: Theme.of(context).textTheme.labelMedium,)
                            )
                        )
                      ],
                    )
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Divider(thickness: 2)
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (mounted) {
                                      checkAuthAndPush(context, '/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/send');
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: SurfyColor.blue,
                                  ),
                                  icon: Icon(Icons.arrow_upward_outlined, size: 30, color: Theme.of(context).primaryColorLight)
                                ),
                                Text('Send', style: Theme.of(context).textTheme.bodyLarge)
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (mounted) {
                                        checkAuthAndPush(context, '/wallet/token/${widget.token.name}/blockchain/${widget.blockchain.name}/receive');
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: SurfyColor.blue,
                                    ),
                                    icon: Icon(Icons.arrow_downward_outlined, size: 30, color: Theme.of(context).primaryColorLight)
                                ),
                                Text('Receive', style: Theme.of(context).textTheme.bodyLarge)
                              ],
                            )
                          ],
                        )
                      ],
                    )
                ),
              ],
            ),
          );
        }
      }),
    );
  }

}