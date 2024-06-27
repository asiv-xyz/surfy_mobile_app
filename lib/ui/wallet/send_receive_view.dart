import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_address.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/balance_view.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/utils/address.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class SendReceivePage extends StatefulWidget {
  const SendReceivePage({super.key, required this.token, required this.blockchain});

  final Token token;
  final Blockchain blockchain;

  @override
  State<StatefulWidget> createState() {
    return _SendReceivePageState();
  }
}

class _SendReceivePageState extends State<SendReceivePage> {
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalances = Get.find();
  final SettingsPreference _preference = Get.find();
  final GetWalletAddress _getWalletAddressUseCase = Get.find();
  final _address = "".obs;

  final Rx<double> _cryptoBalance = Rx(0);
  final Rx<double> _fiatBalance = Rx(0);
  final Rx<double> _tokenPrice = Rx(0);
  final RxBool _isLoading = false.obs;

  Future<void> _getMetadata() async {
    final tokenPrice = await _getTokenPriceUseCase.getSingleTokenPrice(widget.token, _preference.userCurrencyType.value);
    _tokenPrice.value = tokenPrice?.price ?? 0;
    _address.value = await _getWalletAddressUseCase.getAddress(widget.blockchain);
    _cryptoBalance.value = _getWalletBalances.aggregateUserTokenAmount(widget.token, _getWalletBalances.userDataObs.value);
    _fiatBalance.value = _cryptoBalance.value * (tokenPrice?.price ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _isLoading.value = true;
    _getMetadata().then((_) => _isLoading.value = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TokenIconWithNetwork(blockchain: widget.blockchain, token: widget.token, width: 40, height: 40),
            const SizedBox(width: 10,),
            Text(tokens[widget.token]?.name ?? "")
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.isTrue) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: CircularProgressIndicator(color: SurfyColor.blue)
            )
          );
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
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Obx(() => Text(formatFiat(_fiatBalance.value, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.headlineLarge)),
                        //     const SizedBox(height: 5,),
                        //     Obx(() => Text(formatCrypto(widget.token, _cryptoBalance.value), style: Theme.of(context).textTheme.bodyLarge)),
                        //   ],
                        // ),
                        Obx(() => Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: BalanceView(
                              token: widget.token,
                              currencyType: _preference.userCurrencyType.value,
                              fiatBalance: _fiatBalance.value,
                              cryptoBalance: _cryptoBalance.value,
                            )
                        )),
                        SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Obx(() => CurrentPrice(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    tokenName: tokens[widget.token]?.name ?? "",
                                    price: _tokenPrice.value,
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
                            Obx(() => Text(shortAddress(_address.value), style: Theme.of(context).textTheme.labelSmall))
                          ],
                        ),
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(SurfyColor.greyBg),
                                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ))
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _address.value));
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
                    child: const Divider(color: SurfyColor.greyBg, thickness: 6)
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
                                InkWell(
                                  onTap: () {
                                    if (mounted) {
                                      context.push('/send', extra: Pair(widget.token, widget.blockchain));
                                    }
                                  },
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                          color: SurfyColor.blue,
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      child: const Icon(Icons.arrow_upward_outlined, size: 30, color: SurfyColor.black,)
                                  ),
                                ),
                                Text('Send', style: Theme.of(context).textTheme.bodyLarge)
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (mounted) {
                                      context.push('/receive', extra: Pair(widget.token, widget.blockchain));
                                    }
                                  },
                                  child: Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                          color: SurfyColor.blue,
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      child: const Icon(Icons.arrow_downward_outlined, size: 30, color: SurfyColor.black)
                                  ),
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