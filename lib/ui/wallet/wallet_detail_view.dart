import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surfy_mobile_app/domain/token/get_token_price.dart';
import 'package:surfy_mobile_app/domain/token/model/user_token_data.dart';
import 'package:surfy_mobile_app/domain/wallet/get_wallet_balances.dart';
import 'package:surfy_mobile_app/entity/token/token_price.dart';
import 'package:surfy_mobile_app/settings/settings_preference.dart';
import 'package:surfy_mobile_app/ui/components/address_badge.dart';
import 'package:surfy_mobile_app/ui/components/balance_view.dart';
import 'package:surfy_mobile_app/ui/components/current_price.dart';
import 'package:surfy_mobile_app/ui/components/token_icon_with_network.dart';
import 'package:surfy_mobile_app/utils/blockchains.dart';
import 'package:surfy_mobile_app/utils/formatter.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:surfy_mobile_app/utils/tokens.dart';

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({super.key, required this.token});

  final Token token;

  @override
  State<StatefulWidget> createState() {
    return _WalletDetailPageState();
  }
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  final GetTokenPrice _getTokenPriceUseCase = Get.find();
  final GetWalletBalances _getWalletBalancesUseCase = Get.find();
  final SettingsPreference _preference = Get.find();

  final Rx<List<UserTokenData>> _balanceList = Rx<List<UserTokenData>>([]);
  final Rx<TokenPrice?> _tokenPrice = Rx<TokenPrice?>(null);
  final Rx<bool> _isLoading = Rx<bool>(false);
  final Rx<bool> _onlyHeldShow = Rx<bool>(true);
  final Rx<double> _totalCryptoBalance = Rx<double>(0);
  final Rx<double> _totalFiatBalance = Rx<double>(0);

  List<UserTokenData> _getDrawList() {
    if (_onlyHeldShow.isTrue) {
      return _balanceList.value.where((item) => item.amount > BigInt.zero).toList();
    }

    return _balanceList.value;
  }

  Future<void> _loadData() async {
    final loadBalanceAndSortJob = _getWalletBalancesUseCase.getTokenDataList(widget.token).then((result) {
      result.sort((a, b) {
        if (a.amount < b.amount) {
          return 1;
        } else if (a.amount == b.amount) {
          return 0;
        } else {
          return -1;
        }
      });
      _balanceList.value = result;
    });
    final loadTokenPriceData = _getTokenPriceUseCase.getSingleTokenPrice(widget.token, _preference.userCurrencyType.value).then((result) {
      _tokenPrice.value = result;
    });
    final jobList = Future.wait([loadBalanceAndSortJob, loadTokenPriceData]);
    await jobList;

    // final totalBalancePair = _getWalletBalancesUseCase.parseTotalTokenBalanceForUi(widget.token, _balanceList.value, _tokenPrice.value?.price ?? 0.0, _preference.userCurrencyType.value);
    final aggregatedTokenBalance = _getWalletBalancesUseCase.aggregateUserTokenAmount(widget.token, _getWalletBalancesUseCase.userDataObs.value);
    _totalCryptoBalance.value = aggregatedTokenBalance;
    _totalFiatBalance.value = aggregatedTokenBalance * (_tokenPrice.value?.price ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _isLoading.value = true;
    _loadData().then((_) => _isLoading.value = false);
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
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: SurfyColor.blue,),
                const SizedBox(height: 20,),
                Text('Session timeout, reload token data...', style: Theme.of(context).textTheme.titleLarge)
              ],
            )
          );
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
                        fiatBalance: _totalFiatBalance.value,
                        cryptoBalance: _totalCryptoBalance.value,
                      )
                  );
                }),
                Obx(() => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CurrentPrice(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      tokenName: tokens[widget.token]?.name ?? "",
                      price: _tokenPrice.value?.price ?? 0.0,
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
                        child: Text('View only the coins I own', style: Theme.of(context).textTheme.labelLarge)
                    )
                  ],
                ),
                Obx(() => Column(
                  children: _getDrawList().map((item) {
                    final balance = _getWalletBalancesUseCase.aggregateUserTokenAmountByBlockchain(widget.token, item.blockchain, _balanceList.value);
                    final fiat = balance * (_tokenPrice.value?.price ?? 0);
                    return InkWell(
                        onTap: () {
                          context.push('/sendAndReceive', extra: Pair<Token, Blockchain>(item.token, item.blockchain));
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
                                        Text("(${item.blockchain.name})", style: Theme.of(context).textTheme.labelMedium),
                                        const SizedBox(height: 2),
                                        AddressBadge(address: item.address, mainAxisAlignment: MainAxisAlignment.start,)
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(formatFiat(fiat, _preference.userCurrencyType.value), style: Theme.of(context).textTheme.displaySmall),
                                    Text(formatCrypto(widget.token, balance), style: Theme.of(context).textTheme.labelMedium)
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
}