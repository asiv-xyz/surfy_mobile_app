import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfy_mobile_app/routing.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/address_badge.dart';
import 'package:surfy_mobile_app/ui/components/balance_view.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/ui/components/loading_widget.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/ui/wallet/pages/detail/viewmodel/wallet_detail_viewmodel.dart';
import 'package:surfy_mobile_app/utils/crypto_and_fiat.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/entity/token/token.dart';

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key, required this.token});

  final Token token;

  @override
  State<StatefulWidget> createState() {
    return _WalletDetailPageState();
  }
}

abstract class WalletDetailPageInterface {
  void onCreate();
  void onLoading();
  void offLoading();
}

class _WalletDetailPageState extends State<WalletDetailPage> implements WalletDetailPageInterface {

  final WalletDetailViewModel _viewModel = WalletDetailViewModel();
  final SettingsPreference _preference = Get.find();

  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<bool> _onlyHeldShow = Rx<bool>(true);

  @override
  void initState() {
    super.initState();
    _viewModel.setView(this);
    _viewModel.init(widget.token, _preference.userCurrencyType.value);
  }

  @override
  Widget build(BuildContext context) {
    final tokenData = tokens[widget.token];
    if (tokenData == null) {
      return Container(
        child: Text('Unknown token: ${widget.token}'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(tokenData.iconAsset, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(tokenData.name)
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return const LoadingWidget(opacity: 0.4);
        }

        return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: BalanceView(
                        token: widget.token,
                        currencyType: _preference.userCurrencyType.value,
                        fiatBalance: cryptoAmountToFiat(tokens[widget.token]!, _viewModel.aggregateBalance(), _viewModel.tokenPrice.value),
                        cryptoBalance: cryptoAmountToDecimal(tokens[widget.token]!, _viewModel.aggregateBalance()),)
                  );
                }),
                Obx(() => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CurrentPrice(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      tokenName: tokens[widget.token]?.name ?? "",
                      price: _viewModel.tokenPrice.value,
                      currency: _preference.userCurrencyType.value,
                    )
                )),
                Divider(color: Theme.of(context).dividerColor),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          activeColor: SurfyColor.blue,
                          shape: const CircleBorder(),
                          value: _onlyHeldShow.value,
                          onChanged: (value) {
                            _onlyHeldShow.value = value ?? false;
                          }
                      ),
                    )),
                    InkWell(
                        onTap: () {
                          _onlyHeldShow.value = !_onlyHeldShow.value;
                        },
                        child: Text('View only the assets I own', style: Theme.of(context).textTheme.labelLarge)
                    )
                  ],
                ),
                Obx(() => Column(
                  children: _viewModel.sortByDesc(_onlyHeldShow.value).map((item) {
                    final address = _viewModel.addresses.value[item.blockchain] ?? "";
                    return InkWell(
                        onTap: () {
                          checkAuthAndPush(context, '/wallet/token/${item.token.name}/blockchain/${item.blockchain.name}');
                        },
                        child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    TokenIconWithNetwork(blockchain: item.blockchain, token: item.token, width: 40, height: 40),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(tokens[item.token]?.name ?? "", style: Theme.of(context).textTheme.displaySmall),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text("${item.blockchain.name}", style: Theme.of(context).textTheme.labelMedium),
                                        const SizedBox(height: 2),
                                        AddressBadge(address: address, mainAxisAlignment: MainAxisAlignment.start,)
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(formatFiat(
                                          cryptoAmountToFiat(tokens[widget.token]!, item.balance, _viewModel.tokenPrice.value),
                                          _preference.userCurrencyType.value), style: Theme.of(context).textTheme.displaySmall),
                                    Text(formatCrypto(widget.token,
                                        cryptoAmountToDecimal(tokens[widget.token]!, item.balance)),
                                        style: Theme.of(context).textTheme.labelMedium)
                                  ],
                                )
                              ],
                            )
                        )
                    );
                  }).toList(),
                )),
              ],
            )
        );
      }),
    );
  }

  @override
  void onCreate() {
  }

  @override
  void offLoading() {
    _isLoading.value = false;
  }

  @override
  void onLoading() {
    _isLoading.value = true;
  }
}